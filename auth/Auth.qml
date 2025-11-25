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
    property int baseNormalWidth: 420
    property int baseNormalHeight: 500
    property int localServerExtraHeight: 100
    property int registrationExtraHeight: 150

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
    property bool _isGoodClosing: false
    property string authToken: ""

    // Фиксированные приращения для масштабирования
    property int widthIncrement: 90
    property int heightIncrement: 120

    // Защита от рекурсии
    property bool _updatingWindowHeight: false

    // Определение мобильного устройства по ОС
    property bool isMobile: Qt.platform.os === "android" || Qt.platform.os === "ios" ||
                           Qt.platform.os === "tvos" || Qt.platform.os === "wasm"
    property bool disableResize: isMobile

    // Отступы для Android системных кнопок
    property int androidTopMargin: (Qt.platform.os === "android") ? 16 : 0
    property int androidBottomMargin: (Qt.platform.os === "android" &&  parent.width < parent.height) ? 28 : 0

    signal loginSuccessful(string token, var userData)

    // Behavior анимации для android & linux & ios
    Behavior on height {
        enabled: Qt.platform.os !== "windows"
        NumberAnimation {
            duration: 250
            easing.type: Easing.Linear
        }
    }

    AuthAPI {
        id: authAPI
        remoteApiBaseUrl: authWindow.remoteApiBaseUrl
        remotePort: authWindow.remotePort
    }

    Loader {
        id: mainWindowLoader
        active: false
        asynchronous: true
        source: "../main/main/Main.qml"
        onLoaded: if (item) item.show()
    }

    Timer {
        id: tokenCheckTimer
        interval: 100
        onTriggered: {
            var savedToken = settingsManager.authToken || "";
            checkSavedToken(savedToken);
        }
    }

    Timer {
        id: safeUpdateHeightTimer
        interval: 16
        onTriggered: updateWindowHeight()
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

        // Инициализируем AuthAPI с текущими настройками
        updateAuthAPI();

        // Проверка сервера через AuthAPI
        authAPI.testConnection(function(success) {
            console.log("🧪 Статус сервера:", success ? "доступен" : "недоступен");

            var savedToken = settingsManager.authToken || "";
            if (savedToken && savedToken.length > 0) {
                console.log("🔐 Найден сохраненный токен, проверяем...");
                tokenCheckTimer.start();
            }
        });
    }

    // Обработчик кнопки "Назад" для Android и Десктопа
    onClosing: (close) => {
        if (isMobile) {
            close.accepted = false
            handleBackButton()
        } else if (!_isGoodClosing) {
            Qt.quit()
        }
    }


    // Компонент для диалога выхода
    Component {
        id: exitDialogComponent
        Common.MobileCloseApp {
            onConfirmed: Qt.exit(0)
            onCancelled: close()
            Component.onCompleted: openDialog()
        }
    }

    function toggleMaximize() {
        // На мобильных устройствах полностью отключаем масштабирование
        if (disableResize) {
            return;
        }

        if (isWindowMaximized) {
            // Возвращаем к исходному размеру с анимацией
            authWindow.width = baseNormalWidth;
            authWindow.height = calculateBaseHeight();
            isWindowMaximized = false;
        } else {
            // Увеличиваем на фиксированные значения с анимацией
            var targetWidth = Math.min(baseNormalWidth + widthIncrement, maximumWidth);
            var baseHeightValue = calculateBaseHeight();
            var targetHeight = Math.min(baseHeightValue + heightIncrement, maximumHeight);

            authWindow.width = targetWidth;
            authWindow.height = targetHeight;
            isWindowMaximized = true;
        }
    }

    // Функция для обновления высоты окна с анимацией
    function updateWindowHeight() {
        // На мобильных устройствах игнорируем изменение высоты
        if (disableResize) return;
        if (_updatingWindowHeight) return;

        _updatingWindowHeight = true;

        var targetHeight = calculateBaseHeight();

        if (!isWindowMaximized) {
            if (Math.abs(authWindow.height - targetHeight) > 1) {
                authWindow.height = targetHeight;
            }
        } else {
            var baseHeightValue = calculateBaseHeight();
            var maximizedHeight = Math.min(maximumHeight, baseHeightValue + heightIncrement);
            if (Math.abs(authWindow.height - maximizedHeight) > 1) {
                authWindow.height = maximizedHeight;
            }
        }

        _updatingWindowHeight = false;
    }

    // Расчет базовой высоты
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

    function saveServerConfig(serverAddress) {
        try {
            settingsManager.serverAddress = serverAddress;
            serverConfig.updateFromSettings();
            updateAuthAPI(); // Добавляем обновление API
            showSuccess("Настройки сервера успешно сохранены.");
        } catch (error) {
            showError("Ошибка сохранения настроек");
        }
    }

    function resetSettings() {
        try {
            settingsManager.serverAddress = "http://localhost:5000";
            settingsManager.useLocalServer = true; // Сбрасываем тип сервера
            serverConfig.updateFromSettings();
            updateAuthAPI(); // Добавляем обновление API
            showSuccess("Настройки сброшены к значениям по умолчанию.");
        } catch (error) {
            showError("Ошибка сброса настроек: " + error);
        }
    }

    function checkSavedToken(token) {
        if (_isLoading) return;

        _isLoading = true;
        showLoading();

        authAPI.authToken = token;

        authAPI.validateToken(function(result) {
            _isLoading = false;
            hideLoading();

            if (result.success && result.valid) {
                _isGoodClosing = true;
                authToken = token;
                settingsManager.authToken = token;
                mainWindowLoader.active = true;
                authWindow.close();
            } else {
                settingsManager.authToken = "";
                authToken = "";
                showError("Ваша сессия истекла. Пожалуйста, войдите снова.");
                showLoginForm();
            }
        });
    }

    function showRegistrationForm() {
        _showingRegistration = true;
        safeUpdateHeightTimer.start();
        windowContainer.forceActiveFocus();
    }

    function showLoginForm() {
        _showingRegistration = false;
        safeUpdateHeightTimer.start();
        windowContainer.forceActiveFocus();
    }

    function normalizePhoneNumber(phone) {
        // Проверяем, что phone не undefined или null
        if (!phone) {
            return ""
        }

        // Преобразуем в строку на случай, если передано число
        var phoneString = String(phone);

        // Удаляем все нецифровые символы
        var digits = phoneString.replace(/\D/g, '')

        // Если номер пустой, возвращаем пустую строку
        if (digits.length === 0) {
            return ""
        }

        // Если номер начинается с 8, заменяем на 7
        if (digits.startsWith('8')) {
            digits = '7' + digits.substring(1)
        }
        // Если номер начинается не с 7 и не с 8, добавляем 7 в начало
        else if (!digits.startsWith('7')) {
            digits = '7' + digits
        }

        // Ограничиваем длину до 11 цифр
        digits = digits.substring(0, 11)

        // Если осталась только одна цифра 7, возвращаем пустую строку
        if (digits === '7') {
            return ""
        }

        return digits
    }

    function attemptRegistration() {
        if (!isRegistrationFormValid() || _isLoading) return;

        _isLoading = true;
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
                phoneNumber: normalizePhoneNumber(registrationForm.phoneField.text)
            };

            authAPI.sendRegistrationRequest(userData, function(result) {
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
                var registeredEmail = registrationForm.emailField.text;
                showLoginForm();
                setLoginEmail(registeredEmail);
                registrationForm.clearAllFields();
                showSuccess("Регистрация прошла успешно! Теперь вы можете войти в систему.")
            } else {
                showError(result.message || result.error);
            }
        }
    }

    function setLoginEmail(email) {
        if (loginForm && loginForm.loginField && email) {
            loginForm.loginField.text = email;
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

        var login = loginForm.loginField.text.trim();
        var password = loginForm.passwordField.text;

        if (login === "" || password === "") {
            showError("Логин и пароль не могут быть пустыми");
            return;
        }

        showLoading();

        try {
            authAPI.sendLoginRequest(login, password, function(result) {
                _isLoading = true;
                _loginResult = result;
                loadingTimer.start();

                if (result.success && result.token) {
                    authToken = result.token;
                    settingsManager.authToken = result.token;
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

    function updateAuthAPI() {
        var baseUrl = settingsManager.useLocalServer ?
            settingsManager.serverAddress :
            (remoteApiBaseUrl + ":" + remotePort);

        authAPI.initialize(authAPI.authToken, baseUrl);
    }

    function showError(message) {
        _successMessage = "";
        _showingSuccess = false;
        _errorMessage = message;
        _showingError = message !== "";

        if (_showingError) {
            errorAutoHideTimer.restart();
            safeUpdateHeightTimer.start();
        } else {
            safeUpdateHeightTimer.start();
        }
    }

    function showSuccess(message) {
        _errorMessage = "";
        _showingError = false;
        _successMessage = message;
        _showingSuccess = message !== "";

        if (_showingSuccess) {
            successAutoHideTimer.restart();
        }
    }

    function showLoading() {
        loadingAnimation.visible = true;
        loadingAnimation.opacity = 1;

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

        if (_showingRegistration) {
            registrationForm.opacity = 1.0;
            registrationForm.registerButton.enabled = true;
        } else {
            loginForm.opacity = 1.0;
            loginForm.loginButton.enabled = true;
        }
    }

    function isFormValid() {
        return loginForm.loginField.text.length > 0 && loginForm.passwordField.text.length > 0;
    }

    Rectangle {
        id: windowContainer
        anchors.fill: parent
        radius: 24
        color: "#f0f0f0"
        clip: true
        focus: true

        Keys.onPressed: (event) => {
            if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter) && (event.modifiers & Qt.ControlModifier)) {
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
            anchors.fill: parent
            polygonCount: 4
            isMobile: authWindow.isMobile
        }

        // Искры на фоне
        Common.SparksBackground {
            anchors.fill: parent
            isMobile: authWindow.isMobile
            z: 1
            enabled: !authWindow._isLoading
        }

        Common.BottomBlur {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            blurHeight: androidBottomMargin
            blurOpacity: 0.8
            z: 2
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
            currentView: _showingRegistration ? "Регистрация" : "Вход в систему"
            window: authWindow
            isMobile: authWindow.isMobile
            authmenu: true

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
            scale: isMobile ? 1.12 : 1
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
            scale: isMobile ? 1.12 : 1
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
            scale: isMobile ? 1.12 : 1
            visible: !_showingRegistration
            isMobile: authWindow.isMobile

            onServerTypeToggled: function(useLocal) {
                settingsManager.useLocalServer = useLocal;
                safeUpdateHeightTimer.start();
                updateAuthAPI();
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
                topMargin: 24
            }
            width: parent.width * 0.78
            scale: isMobile ? 1.12 : 1
            visible: _showingRegistration
            isMobile: authWindow.isMobile

            onAttemptRegistration: authWindow.attemptRegistration()
            onShowLoginForm: authWindow.showLoginForm()
        }

        LoginForm {
            id: loginForm
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: serverConfig.visible ? serverConfig.bottom : successMessage.bottom
                topMargin: isMobile ? 40 : 32
            }
            width: parent.width * 0.78
            scale: isMobile ? 1.12 : 1
            visible: !_showingRegistration
            isMobile: authWindow.isMobile

            onAttemptLogin: authWindow.attemptLogin()
        }

        LoadingAnimation {
            id: loadingAnimation
            scale: isMobile ? 1.12 : 1
            anchors.centerIn: parent
        }

        CopyrightFooter {
            scale: isMobile ? 1.12 : 1
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: 20 + androidBottomMargin
            }
            isMobile: authWindow.isMobile
        }

        Timer {
            id: loadingTimer
            interval: 1
            onTriggered: {
                hideLoading();
                _isLoading = false;
                if (_loginResult) {
                    if (_loginResult.success) {
                        _isGoodClosing = true;
                        showSuccess(_loginResult.message || "Вход выполнен успешно");
                        mainWindowLoader.active = true;
                        authWindow.close();
                    } else {
                        var errorMessage = _loginResult.error || _loginResult.message || "Ошибка входа";
                        showError(errorMessage);
                    }
                    _loginResult = null;
                }
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
            safeUpdateHeightTimer.start();
            updateAuthAPI();
        }
    }

    // Вспомогательные функции
    function handleBackButton() {
        if (_showingRegistration) {
            showLoginForm();
        } else {
            showExitDialog();
        }
    }

    function showExitDialog() {
        // Снимаем фокус с любых активных элементов
        windowContainer.forceActiveFocus()
        var dialog = exitDialogComponent.createObject(authWindow);
        dialog.open();
    }
}
