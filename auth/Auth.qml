import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects
import QtQml 2.15
import "../common" as Common

Window {
    id: authWindow
    width: 420
    height: 500
    visible: true
    title: "Вход в систему | " + appName
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint
    minimumHeight: 500
    minimumWidth: 420

    property bool isWindowMaximized: false
    property int baseHeight: 500
    property int localServerExtraHeight: 100
    property int errorExtraHeight: 0

    property string _errorMessage: ""
    property bool _showingError: false
    property string _successMessage: ""
    property bool _showingSuccess: false
    property bool _isLoading: false

    property string remoteApiBaseUrl: "http://deltablast.fun"
    property int remotePort: 5000

    property int _minLoadingTime: 500
    property var _loginResult: null

    property bool _showingRegistration: false
    property int registrationExtraHeight: 150

    property string authToken: ""

    // Фиксированные приращения для масштабирования
    property int widthIncrement: 90
    property int heightIncrement: 120

    // Базовые размеры для разных состояний
    property int baseNormalWidth: 420
    property int baseNormalHeight: 500
    property int baseScaledWidth: baseNormalWidth + widthIncrement
    property int baseScaledHeight: baseNormalHeight + heightIncrement

    // Определение мобильного устройства по ОС
    property bool isMobile: Qt.platform.os === "android" || Qt.platform.os === "ios" ||
                           Qt.platform.os === "tvos" || Qt.platform.os === "wasm" ||
                           Screen.width < 768 || Screen.height < 768

    // Дополнительная переменная для полного отключения изменения размеров
    property bool disableResize: isMobile

    // Отступы для Android системных кнопок
    property int androidTopMargin: (Qt.platform.os === "android") ? 24 : 0
    property int androidBottomMargin: (Qt.platform.os === "android") ? 48 : 0

    signal loginSuccessful(string token, var userData)

    // Обновленный AuthAPI
    AuthAPI {
        id: authAPI
        remoteApiBaseUrl: authWindow.remoteApiBaseUrl
        remotePort: authWindow.remotePort
    }

    // Загрузчик главной формы
    Loader {
        id: mainWindowLoader
        active: false
        asynchronous: true
        source: "../main/main/Main.qml"

        onLoaded: if (item) item.show()
    }

    Behavior on width {
        enabled: !disableResize // Отключаем анимацию на мобильных
        NumberAnimation {
            duration: 300;
            easing.type: Easing.InOutQuad
        }
    }

    Behavior on height {
        enabled: !disableResize // Отключаем анимацию на мобильных
        NumberAnimation {
            duration: 300;
            easing.type: Easing.InOutQuad
        }
    }

    Component.onCompleted: {
        // На мобильных устройствах устанавливаем фиксированный размер
        if (disableResize) {
            authWindow.width = Math.min(Screen.width, baseNormalWidth);
            authWindow.height = Math.min(Screen.height, baseNormalHeight);
            authWindow.minimumWidth = authWindow.width;
            authWindow.maximumWidth = authWindow.width;
            authWindow.minimumHeight = authWindow.height;
            authWindow.maximumHeight = authWindow.height;
        }

        serverConfig.updateFromSettings();
        updateWindowHeight();
        windowContainer.forceActiveFocus();

        // Сначала проверяем доступность сервера
        console.log("🧪 Проверка доступности сервера...");
        var testXhr = new XMLHttpRequest();
        testXhr.open("GET", settingsManager.serverAddress + "/api/status", true);
        testXhr.onreadystatechange = function() {
            if (testXhr.readyState === XMLHttpRequest.DONE) {
                console.log("🧪 Статус сервера:", testXhr.status, testXhr.responseText);

                // После проверки сервера инициализируем AuthAPI
                var baseUrl = settingsManager.useLocalServer ?
                    settingsManager.serverAddress :
                    (remoteApiBaseUrl + ":" + remotePort);

                authAPI.initialize("", baseUrl);

                // Затем проверяем токен
                var savedToken = settingsManager.authToken || "";
                if (savedToken && savedToken.length > 0) {
                    console.log("🔐 Найден сохраненный токен, проверяем...");
                    console.log("   Токен (первые 10):", savedToken.substring(0, 10) + "...");
                    // Задержка для гарантии инициализации
                    tokenCheckTimer.start();
                } else {
                    console.log("🔐 Сохраненный токен не найден, показываем форму входа");
                }
            }
        };
        testXhr.send();
    }

    // Таймер для отложенной проверки токена
    Timer {
        id: tokenCheckTimer
        interval: 100
        onTriggered: {
            var savedToken = settingsManager.authToken || "";
            checkSavedToken(savedToken);
        }
    }

    function saveServerConfig(serverAddress) {
        try {
            settingsManager.serverAddress = serverAddress;
            serverConfig.updateFromSettings();
            showSuccess("Настройки сервера успешно сохранены.");
        } catch (error) {
            showError("Ошибка сохранения настроек");
        }
    }

    function resetSettings() {
        try {
            settingsManager.serverAddress = "http://localhost:5000";
            serverConfig.updateFromSettings();
            showSuccess("Настройки сброшены к значениям по умолчанию.");
        } catch (error) {
            showError("Ошибка сброса настроек");
        }
    }

    function checkSavedToken(token) {
        console.log("🔐 Проверка сохраненного токена...");
        console.log("   Длина токена:", token.length);
        console.log("   Токен (первые 20):", token.substring(0, 20) + "...");

        // Защита от множественных вызовов
        if (_isLoading) {
            console.log("⚠️ Проверка токена уже выполняется, пропускаем...");
            return;
        }

        _isLoading = true;
        showLoading();

        // ОБНОВЛЯЕМ ТОКЕН В AuthAPI ПЕРЕД ПРОВЕРКОЙ
        authAPI.authToken = token;

        authAPI.validateToken(function(result) {
            _isLoading = false;
            hideLoading();

            console.log("🔐 Результат проверки токена:", JSON.stringify(result, null, 2));

            if (result.success && result.valid) {
                console.log("✅ Токен валиден, автоматический вход");
                authToken = token;
                settingsManager.authToken = token;

                // ЗАПУСКАЕМ ГЛАВНОЕ ОКНО И СРАЗУ ЗАКРЫВАЕМ АВТОРИЗАЦИЮ
                mainWindowLoader.active = true;
                authWindow.close();
            } else {
                console.log("⚠️ Токен невалиден, показываем форму авторизации");
                console.log("   Причина:", result.message || result.error);

                // ОЧИЩАЕМ НЕВАЛИДНЫЙ ТОКЕН
                settingsManager.authToken = "";
                authToken = "";

                if (result.success === false || result.valid === false) {
                    showError("Ваша сессия истекла. Пожалуйста, войдите снова.");
                } else {
                    showError("Проблема с подключением: " + (result.message || result.error));
                }

                // Показываем форму входа
                showLoginForm();
            }
        });
    }

    function showRegistrationForm() {
        _showingRegistration = true;
        updateWindowHeight();
        // Даем фокус форме регистрации
        if (registrationForm) {
            registrationForm.focusUsername();
        }
        windowContainer.forceActiveFocus(); // Возвращаем фокус окну
    }

    function showLoginForm() {
        _showingRegistration = false;
        updateWindowHeight();
        // Даем фокус форме входа
        if (loginForm) {
            loginForm.focusLogin();
        }
        windowContainer.forceActiveFocus(); // Возвращаем фокус окну
    }

    function calculateBaseHeight() {
        var targetHeight = baseNormalHeight;

        if (settingsManager.useLocalServer && !_showingRegistration) {
            targetHeight += localServerExtraHeight;
        }

        if (_showingError) {
            targetHeight += 60;
        }

        if (_showingRegistration) {
            targetHeight += registrationExtraHeight;
        }

        return Math.max(minimumHeight, Math.min(maximumHeight, targetHeight));
    }

    function updateWindowHeight() {
        // На мобильных устройствах игнорируем изменение высоты
        if (disableResize) return;

        if (!isWindowMaximized) {
            authWindow.height = calculateBaseHeight();
        } else {
            // В масштабированном режиме учитываем базовую высоту + приращение
            var baseHeightValue = calculateBaseHeight();
            authWindow.height = Math.min(maximumHeight, baseHeightValue + heightIncrement);
        }
    }

    function toggleMaximize() {
        // На мобильных устройствах полностью отключаем масштабирование
        if (disableResize) {
            return;
        }

        if (isWindowMaximized) {
            // Возвращаем к исходному размеру с учетом текущего состояния
            authWindow.width = baseNormalWidth;
            authWindow.height = calculateBaseHeight();
            isWindowMaximized = false;
        } else {
            // Увеличиваем на фиксированные значения с учетом текущего состояния
            var targetWidth = Math.min(baseNormalWidth + widthIncrement, maximumWidth);
            var baseHeightValue = calculateBaseHeight();
            var targetHeight = Math.min(baseHeightValue + heightIncrement, maximumHeight);

            authWindow.width = targetWidth;
            authWindow.height = targetHeight;
            isWindowMaximized = true;
        }
    }

    // Сбрасываем флаг масштабирования при ручном изменении размера
    onWidthChanged: {
        // На мобильных устройствах игнорируем изменение размера
        if (disableResize) return;

        if (!isWindowMaximized) return;

        var expectedWidth = baseNormalWidth + widthIncrement;
        if (Math.abs(width - expectedWidth) > 5) {
            isWindowMaximized = false;
        }
    }

    onHeightChanged: {
        // На мобильных устройствах игнорируем изменение размера
        if (disableResize) return;

        if (!isWindowMaximized) return;

        var expectedHeight = calculateBaseHeight() + heightIncrement;
        if (Math.abs(height - expectedHeight) > 5) {
            isWindowMaximized = false;
        }
    }

    Timer {
        id: loadingTimer
        interval: 1
        running: false
        repeat: false
        onTriggered: {
            hideLoading();
            _isLoading = false;
            if (_loginResult) {
                if (_loginResult.success) {
                    showSuccess(_loginResult.message || "Вход выполнен успешно");

                    if (_loginResult.token) {
                        authToken = _loginResult.token;
                        settingsManager.authToken = _loginResult.token;
                        // ОБНОВЛЯЕМ ТОКЕН В API
                        authAPI.authToken = _loginResult.token;
                    }

                    mainWindowLoader.active = true;
                    authWindow.close();
                } else {
                    // ИСПОЛЬЗУЕМ error ЕСЛИ message ОТСУТСТВУЕТ
                    var errorMessage = _loginResult.error || _loginResult.message || "Ошибка входа";
                    showError(errorMessage);
                    console.log("❌ Показана ошибка входа:", errorMessage);
                }
                _loginResult = null;
            }
        }
    }

    function attemptRegistration() {
        if (!isRegistrationFormValid() || _isLoading) return;

        _isLoading = true;
        var startTime = Date.now();
        showLoading();

        try {
            var nameData = registrationForm.parseFullName();
            var userData = {
                username: registrationForm.usernameField.text,
                email: registrationForm.emailField.text,
                password: registrationForm.passwordField.text,
                firstName: nameData.firstName,
                lastName: nameData.lastName,
                middleName: nameData.middleName,
                phoneNumber: registrationForm.phoneField.text
            };

            authAPI.sendRegistrationRequest(userData, function(result) {
                var elapsed = Date.now() - startTime;
                var remaining = Math.max(_minLoadingTime - elapsed, 0);
                registrationResultTimer.interval = remaining;
                registrationResultTimer.result = result;
                registrationResultTimer.start();
            });
        } catch (error) {
            hideLoading();
            _isLoading = false;
            showError("Ошибка при регистрации: " + error);
        }
    }

    Timer {
        id: registrationResultTimer
        property var result
        onTriggered: {
            hideLoading();
            _isLoading = false;
            if (result.success) {
                // УБРАНО: showSuccess(result.message);

                // Сохраняем email перед очисткой формы
                var registeredEmail = registrationForm.emailField.text;

                // Переключаемся на форму входа
                showLoginForm();

                // Заполняем поле логина в форме авторизации
                setLoginEmail(registeredEmail);

                // Очищаем все поля формы регистрации
                registrationForm.clearAllFields();
            } else {
                showError(result.message || result.error);
            }
        }
    }

    function setLoginEmail(email) {
        if (loginForm && loginForm.loginField && email) {
            loginForm.loginField.text = email;
            loginForm.loginField.cursorPosition = email.length;
        }
    }

    function isRegistrationFormValid() {
        return registrationForm.usernameField.text.length > 0 &&
               registrationForm.hasValidFullName &&
               registrationForm.emailField.text.length > 0 &&
               registrationForm.passwordField.text.length > 0 &&
               registrationForm.confirmPasswordField.text.length > 0 &&
               registrationForm.passwordField.text === registrationForm.confirmPasswordField.text;
    }

    function attemptLogin() {
        if (!isFormValid() || _isLoading) return;

        // Валидация полей
        var login = loginForm.loginField.text.trim();
        var password = loginForm.passwordField.text;

        if (login === "" || password === "") {
            showError("Логин и пароль не могут быть пустыми");
            return;
        }

        var startTime = Date.now();
        showLoading();

        try {
            authAPI.sendLoginRequest(login, password, function(result) {
                var elapsed = Date.now() - startTime;
                var remaining = Math.max(_minLoadingTime - elapsed, 0);

                _isLoading = true;
                _loginResult = result;
                loadingTimer.interval = remaining;
                loadingTimer.start();

                if (result.success && result.token) {
                    authToken = result.token;
                    settingsManager.authToken = result.token;
                    console.log("🔐 Токен сохранен:", result.token.substring(0, 20) + "...");

                    if (mainWindowLoader.item) {
                        mainWindowLoader.item.initializeProfile(result.token, authAPI.baseUrl);
                    }
                }
            });
        } catch (error) {
            hideLoading();
            _isLoading = false;
            showError("Ошибка при входе: " + error);
        }
    }

    function showError(message) {
        try {
            _successMessage = "";
            _showingSuccess = false;
            _errorMessage = message;
            _showingError = message !== "";

            if (_showingError) {
                errorExtraHeight = 60;
                errorAutoHideTimer.restart();
            } else {
                errorExtraHeight = 0;
            }

            updateWindowHeight();
        } catch (error) {}
    }

    function showSuccess(message) {
        try {
            _errorMessage = "";
            _showingError = false;
            _successMessage = message;
            _showingSuccess = message !== "";

            if (_showingSuccess) {
                successAutoHideTimer.restart();
            }

            updateWindowHeight();
        } catch (error) {}
    }

    function showLoading() {
        try {
            loadingAnimation.visible = true;
            loadingAnimation.opacity = 1;

            if (_showingRegistration) {
                registrationForm.opacity = 0.6;
                registrationForm.registerButton.enabled = false;
            } else {
                loginForm.opacity = 0.6;
                loginForm.loginButton.enabled = false;
            }
        } catch (error) {}
    }

    function hideLoading() {
        try {
            loadingAnimation.opacity = 0;
            loadingAnimation.visible = false;

            if (_showingRegistration) {
                registrationForm.opacity = 1.0;
                registrationForm.registerButton.enabled = true;
            } else {
                loginForm.opacity = 1.0;
                loginForm.loginButton.enabled = true;
            }
        } catch (error) {}
    }

    function isFormValid() {
        return loginForm.loginField.text.length > 0 && loginForm.passwordField.text.length > 0;
    }

    Rectangle {
        id: windowContainer
        anchors {
            fill: parent
            topMargin: authWindow.androidTopMargin
            bottomMargin: authWindow.androidBottomMargin
        }
        radius: 24
        color: "#f0f0f0"
        clip: true
        z: -3
        focus: true

        // Обработка глобальных горячих клавиш
        Keys.onPressed: (event) => {
            if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter) && (event.modifiers & Qt.ControlModifier)) {
                // Ctrl+Enter для принудительной отправки формы
                if (_showingRegistration) {
                    attemptRegistration();
                } else {
                    attemptLogin();
                }
                event.accepted = true;
            }
        }

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

        Common.PolygonBackground {
            id: polygonRepeater
            anchors.fill: parent
            polygonCount: 4
            visible: parent !== null
            isMobile: authWindow.isMobile
        }

        Common.TitleBar {
            id: titleBar
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                topMargin: 10 + authWindow.androidTopMargin
                leftMargin: 10
                rightMargin: 10
            }
            isWindowMaximized: authWindow.isWindowMaximized
            currentView: "Вход в систему"
            window: authWindow
            isMobile: authWindow.disableResize

            onToggleMaximize: authWindow.toggleMaximize()
            onShowMinimized: authWindow.showMinimized()
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
            visible: !_showingRegistration

            onServerTypeToggled: function(useLocal) {
                settingsManager.useLocalServer = useLocal;
                updateWindowHeight();
            }

            onSaveServerConfig: function(serverAddress) {
                authWindow.saveServerConfig(serverAddress);
            }

            onResetSettings: {
                authWindow.resetSettings();
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

            onAttemptRegistration: authWindow.attemptRegistration()
            onShowLoginForm: authWindow.showLoginForm()
        }

        LoginForm {
            id: loginForm
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: serverConfig.visible ? serverConfig.bottom : successMessage.bottom
                topMargin: 32
            }
            width: parent.width * 0.78
            visible: !_showingRegistration

            onAttemptLogin: authWindow.attemptLogin()
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
            interval: 7500
            onTriggered: showError("")
        }

        Timer {
            id: successAutoHideTimer
            interval: 5000
            onTriggered: showSuccess("")
        }
    }

    Connections {
        target: settingsManager
        function onUseLocalServerChanged() {
            updateWindowHeight();
        }
    }
}
