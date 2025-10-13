import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects
import QtQml 2.15

ApplicationWindow {
    id: mainWindow
    width: 420
    height: 500
    visible: true
    title: "Вход в систему | " + appName
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint
    minimumWidth: 420
    maximumWidth: 580
    minimumHeight: 500
    maximumHeight: 700

    property bool isWindowMaximized: false
    property int baseHeight: 500
    property int localServerExtraHeight: 100
    property int errorExtraHeight: 0

    property string _errorMessage: ""
    property bool _showingError: false
    property string _successMessage: ""
    property bool _showingSuccess: false

    property string remoteApiBaseUrl: "https://deltablast.fun"
    property int remotePort: 5000

    property bool _isLoading: false
    property int _minLoadingTime: 500
    property var _loginResult: null

    property bool _showingRegistration: false
    property int registrationExtraHeight: 110

    property string authToken: ""
    property bool _mainWindowLoaded: false

    // Loader для главного окна
    Loader {
        id: mainWindowLoader
        active: false
        asynchronous: true

        onLoaded: {
            console.log("✅ Главное окно загружено через Loader");
            _mainWindowLoaded = true;

            // Передаем параметры в загруженный компонент
            if (item) {
                item.authToken = authToken;
                item.serverAddress = settingsManager.useLocalServer ?
                    settingsManager.serverAddress :
                    (remoteApiBaseUrl + ":" + remotePort);
                item.useLocalServer = settingsManager.useLocalServer;

                // Показываем главное окно и скрываем окно авторизации
                item.visible = true;
                mainWindow.visible = false;
            }
        }

        onStatusChanged: {
            if (status === Loader.Error) {
                console.error("❌ Ошибка загрузки главного окна:", sourceComponent.errorString());
                showError("Ошибка загрузки интерфейса: " + sourceComponent.errorString());
                hideLoading();
                _isLoading = false;
            }
        }
    }

    // Плавная анимация изменения высоты окна
    Behavior on height {
        NumberAnimation {
            duration: 300;
            easing.type: Easing.InOutQuad
        }
    }

    // Инициализация при загрузке
    Component.onCompleted: {
        serverConfig.updateFromSettings();
        updateWindowHeight();
    }

    // Функции для работы с настройками сервера
    function saveServerConfig(serverAddress) {
        settingsManager.serverAddress = serverAddress;
        serverConfig.updateFromSettings();
        showSuccess("Настройки сервера сохранены");
    }

    function resetSettings() {
        settingsManager.serverAddress = "http://localhost:5000";
        serverConfig.updateFromSettings();
        showSuccess("Настройки сброшены к значениям по умолчанию.");
    }

    // Переключение между формами
    function showRegistrationForm() {
        _showingRegistration = true;
        updateWindowHeight();
    }

    function showLoginForm() {
        _showingRegistration = false;
        updateWindowHeight();
    }

    // Обновление высоты окна (исправленная версия)
    function updateWindowHeight() {
        if (!isWindowMaximized) {
            var targetHeight = baseHeight;

            if (settingsManager.useLocalServer && !_showingRegistration) {
                targetHeight += localServerExtraHeight;
            }

            if (_showingError) {
                targetHeight += errorExtraHeight;
            }

            if (_showingRegistration) {
                targetHeight += registrationExtraHeight;
            }

            mainWindow.height = targetHeight;
        }
    }

    function toggleMaximize() {
        if (isWindowMaximized) {
            mainWindow.showNormal();
            isWindowMaximized = false;
            updateWindowHeight();
        } else {
            mainWindow.showMaximized();
            isWindowMaximized = true;
        }
    }

    Timer {
        id: loadingTimer
        interval: 1
        onTriggered: {
            hideLoading();
            _isLoading = false;
            if (_loginResult) {
                if (_loginResult.success) {
                    showSuccess(_loginResult.message);

                    // Сохраняем токен перед переходом
                    if (_loginResult.token) {
                        authToken = _loginResult.token;
                        settingsManager.authToken = _loginResult.token;
                        console.log("🔑 Токен сохранен, длина:", _loginResult.token.length);
                    }

                    // Загружаем главное окно через Loader
                    loadMainWindow();
                } else {
                    showError(_loginResult.message);
                }
                _loginResult = null;
            }
        }
    }

    // Функция загрузки главного окна через Loader
    function loadMainWindow() {
        console.log("🔄 Загрузка главного окна через Loader...");

        // Устанавливаем источник для Loader'а
        mainWindowLoader.source = "../main/Main.qml";

        // Активируем Loader
        mainWindowLoader.active = true;
    }

    // Функция регистрации
    function attemptRegistration() {
        if (!isRegistrationFormValid() || _isLoading) return;

        _isLoading = true;
        var startTime = Date.now();
        showLoading();

        // Используем parseFullName для получения отдельных компонентов
        var nameData = registrationForm.parseFullName();

        var userData = {
            email: registrationForm.emailField.text,
            password: registrationForm.passwordField.text,
            firstName: nameData.firstName,
            lastName: nameData.lastName,
            middleName: nameData.middleName,
            phoneNumber: registrationForm.phoneField.text
        };

        sendRegistrationRequest(userData, function(result) {
            var elapsed = Date.now() - startTime;
            var remaining = Math.max(_minLoadingTime - elapsed, 0);

            registrationResultTimer.interval = remaining;
            registrationResultTimer.result = result;
            registrationResultTimer.start();
        });
    }

    // Таймер для обработки результата регистрации
    Timer {
        id: registrationResultTimer
        property var result
        onTriggered: {
            hideLoading();
            _isLoading = false;
            if (result.success) {
                showSuccess(result.message);
                showLoginForm();
                registrationForm.clearForm();
            } else {
                showError(result.message);
            }
        }
    }

    function sendRegistrationRequest(userData, callback) {
        var xhr = new XMLHttpRequest();
        xhr.timeout = 10000;

        var baseUrl = settingsManager.useLocalServer ?
            settingsManager.serverAddress :
            (remoteApiBaseUrl + ":" + remotePort);
        var url = baseUrl + "/register";

        console.log("Отправка запроса регистрации на:", url);
        console.log("Данные:", {
            email: userData.email,
            password: "***",
            firstName: userData.firstName,
            lastName: userData.lastName
        });

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                console.log("Статус ответа:", xhr.status);
                console.log("Текст ответа:", xhr.responseText);

                try {
                    var response = JSON.parse(xhr.responseText);

                    if (xhr.status === 201) {
                        callback({
                            success: true,
                            message: response.message || "Регистрация успешна! Теперь вы можете войти в систему."
                        });
                    } else {
                        callback({
                            success: false,
                            message: response.error || "Ошибка регистрации: " + xhr.status
                        });
                    }
                } catch (e) {
                    console.log("Ошибка парсинга JSON:", e);
                    callback({
                        success: false,
                        message: "Неверный формат ответа сервера."
                    });
                }
            }
        };

        xhr.ontimeout = function() {
            callback({ success: false, message: "Таймаут соединения." });
        };

        xhr.onerror = function() {
            callback({ success: false, message: "Ошибка сети или неверные параметры." });
        };

        try {
            xhr.open("POST", url, true);
            xhr.setRequestHeader("Content-Type", "application/json");
            xhr.send(JSON.stringify(userData));
        } catch (error) {
            callback({ success: false, message: "Ошибка отправки: " + error });
        }
    }

    // Обновленная функция проверки валидности формы регистрации
    function isRegistrationFormValid() {
        return registrationForm.hasValidFullName &&
               registrationForm.emailField.text.length > 0 &&
               registrationForm.passwordField.text.length > 0 &&
               registrationForm.confirmPasswordField.text.length > 0 &&
               registrationForm.passwordField.text === registrationForm.confirmPasswordField.text;
    }

    function attemptLogin() {
        if (!isFormValid() || _isLoading) return;

        _isLoading = true;
        var startTime = Date.now();
        showLoading();

        var login = loginForm.loginField.text;
        var password = loginForm.passwordField.text;

        sendLoginRequest(login, password, function(result) {
            var elapsed = Date.now() - startTime;
            var remaining = Math.max(_minLoadingTime - elapsed, 0);

            _loginResult = result;
            loadingTimer.interval = remaining;
            loadingTimer.start();

            // Сохраняем токен в свойстве окна
            if (result.success && result.token) {
                authToken = result.token;
                settingsManager.authToken = result.token;
                console.log("Токен сохранен локально и в настройках, длина:", result.token.length);
            }
        });
    }

    function sendLoginRequest(login, password, callback) {
        var xhr = new XMLHttpRequest();
        xhr.timeout = 10000;

        var baseUrl = settingsManager.useLocalServer ?
            settingsManager.serverAddress :
            (remoteApiBaseUrl + ":" + remotePort);
        var url = baseUrl + "/login";

        console.log("Отправка запроса на:", url);
        console.log("Данные:", { email: login, password: "***" });

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                console.log("Статус ответа:", xhr.status);
                console.log("Текст ответа:", xhr.responseText);

                try {
                    var response = JSON.parse(xhr.responseText);

                    if (xhr.status === 200) {
                        callback({
                            success: true,
                            message: response.message || "Успешный вход!",
                            token: response.token
                        });
                    } else {
                        callback({
                            success: false,
                            message: response.error || "Ошибка: " + xhr.status
                        });
                    }
                } catch (e) {
                    console.log("Ошибка парсинга JSON:", e);
                    callback({
                        success: false,
                        message: "Неверный формат ответа сервера"
                    });
                }
            }
        };

        xhr.ontimeout = function() {
            callback({ success: false, message: "Таймаут соединения" });
        };

        xhr.onerror = function() {
            callback({ success: false, message: "Ошибка сети" });
        };

        try {
            xhr.open("POST", url, true);
            xhr.setRequestHeader("Content-Type", "application/json");
            xhr.send(JSON.stringify({
                email: login,
                password: password
            }));
        } catch (error) {
            callback({ success: false, message: "Ошибка отправки: " + error });
        }
    }

    function showError(message) {
        _successMessage = "";
        _showingSuccess = false;
        _errorMessage = message;
        _showingError = message !== "";

        if (_showingError) {
            errorExtraHeight = 10;
            errorAutoHideTimer.restart();
        } else {
            errorExtraHeight = 0;
        }

        updateWindowHeight();
    }

    function showSuccess(message) {
        _errorMessage = "";
        _showingError = false;
        _successMessage = message;
        _showingSuccess = message !== "";

        if (_showingSuccess) {
            errorExtraHeight = 0;
            successAutoHideTimer.restart();
        }

        updateWindowHeight();
    }

    function showLoading() {
        loadingAnimation.visible = true;
        loadingAnimation.opacity = 1;
        // Исправлено: устанавливаем прозрачность для активной формы
        if (_showingRegistration) {
            registrationForm.opacity = 0.6;
            registrationForm.registerButton.enabled = false;
        } else {
            loginForm.opacity = 0.6;
            loginForm.loginButton.enabled = false;
        }
    }

    function hideLoading() {
        loadingAnimation.opacity = 0;
        loadingAnimation.visible = false;
        // Исправлено: восстанавливаем прозрачность для активной формы
        if (_showingRegistration) {
            registrationForm.opacity = 0.95;
            registrationForm.registerButton.enabled = true;
        } else {
            loginForm.opacity = 0.95;
            loginForm.loginButton.enabled = true;
        }
    }

    function isFormValid() {
        return loginForm.loginField.text.length > 0 && loginForm.passwordField.text.length > 0;
    }

    // Основной контейнер
    Rectangle {
        id: windowContainer
        anchors.fill: parent
        radius: 24
        color: "#f0f0f0"
        clip: true
        z: -3

        Rectangle {
            id: background
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#6a11cb" }
                GradientStop { position: 1.0; color: "#2575fc" }
            }
            z: 0
            radius: 20
        }

        BackgroundPolygons {
            id: backgroundPolygons
            anchors.fill: parent
            visible: parent !== null
        }

        AuthTitleBar {
            id: titleBar
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            isWindowMaximized: mainWindow.isWindowMaximized

            onToggleMaximize: mainWindow.toggleMaximize()
            onShowMinimized: mainWindow.showMinimized()
            onClose: Qt.quit()
        }

        Message {
            id: errorMessage
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: titleBar.bottom
                topMargin: 8
            }
            width: parent.width * 0.78
            messageText: _errorMessage
            showingMessage: _showingError
            messageType: "error"

            onCloseMessage: showError("")
        }

        Message {
            id: successMessage
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: errorMessage.bottom
                topMargin: 8
            }
            width: parent.width * 0.78
            messageText: _successMessage
            showingMessage: _showingSuccess
            messageType: "success"

            onCloseMessage: showSuccess("")
        }

        ServerConfig {
            id: serverConfig
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: successMessage.bottom
                topMargin: 24
            }
            width: parent.width * 0.78
            visible: !_showingRegistration // Скрываем настройки сервера при регистрации

            onServerTypeToggled: function(useLocal) {
                settingsManager.useLocalServer = useLocal;
                updateWindowHeight();
            }

            onSaveServerConfig: function(serverAddress) {
                mainWindow.saveServerConfig(serverAddress);
            }

            onResetSettings: {
                mainWindow.resetSettings();
            }
        }

        RegistrationForm {
            id: registrationForm
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: successMessage.bottom
                topMargin: _showingRegistration ? 24 : 32
            }
            width: parent.width * 0.78
            visible: _showingRegistration

            onAttemptRegistration: mainWindow.attemptRegistration()
            onShowLoginForm: mainWindow.showLoginForm()
        }

        LoginForm {
            id: loginForm
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: serverConfig.visible ? serverConfig.bottom : successMessage.bottom // Динамическая привязка
                topMargin: 32
            }
            width: parent.width * 0.78
            visible: !_showingRegistration

            onAttemptLogin: mainWindow.attemptLogin()
        }

        LoadingAnimation {
            id: loadingAnimation
            anchors.centerIn: parent
        }

        CopyrightFooter {
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: 10
            }
        }

        Timer {
            id: errorAutoHideTimer
            interval: 5000
            onTriggered: showError("");
        }

        Timer {
            id: successAutoHideTimer
            interval: 5000
            onTriggered: showSuccess("");
        }
    }

    Connections {
        target: settingsManager

        function onUseLocalServerChanged() {
            updateWindowHeight();
        }
    }
}
