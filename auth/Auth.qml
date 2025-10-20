import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects
import QtQml 2.15
import "../common" as Common

ApplicationWindow {
    id: authWindow
    width: 420
    height: 500
    visible: true
    title: "Вход в систему | " + appName
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint
    minimumHeight: 500
    minimumWidth: 420
    //maximumHeight: 900
    //maximumWidth: 800

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

    signal loginSuccessful(string token, var userData)

    // Добавляем AuthAPI
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
        source: "../main/Main.qml"

        onLoaded: if (item) item.show()
    }

    Behavior on width {
        NumberAnimation {
            duration: 300;
            easing.type: Easing.InOutQuad
        }
    }

    Behavior on height {
        NumberAnimation {
            duration: 300;
            easing.type: Easing.InOutQuad
        }
    }

    Component.onCompleted: {
        serverConfig.updateFromSettings();
        updateWindowHeight();
        windowContainer.forceActiveFocus(); // Фокус на корневой элемент для обработки клавиш
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
        if (!isWindowMaximized) {
            authWindow.height = calculateBaseHeight();
        } else {
            // В масштабированном режиме учитываем базовую высоту + приращение
            var baseHeightValue = calculateBaseHeight();
            authWindow.height = Math.min(maximumHeight, baseHeightValue + heightIncrement);
        }
    }

    function toggleMaximize() {
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
        if (!isWindowMaximized) return;

        var expectedWidth = baseNormalWidth + widthIncrement;
        if (Math.abs(width - expectedWidth) > 5) {
            isWindowMaximized = false;
        }
    }

    onHeightChanged: {
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
                    showSuccess(_loginResult.message);

                    if (_loginResult.token) {
                        authToken = _loginResult.token;
                        settingsManager.authToken = _loginResult.token;
                    }

                    mainWindowLoader.active = true;
                    authWindow.close();
                } else {
                    showError(_loginResult.message);
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
                showSuccess(result.message);

                // Сохраняем email перед очисткой формы
                var registeredEmail = registrationForm.emailField.text;

                // Переключаемся на форму входа
                showLoginForm();

                // Заполняем поле логина в форме авторизации
                setLoginEmail(registeredEmail);

                // Очищаем все поля формы регистрации
                registrationForm.clearAllFields();
            } else {
                showError(result.message);
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

        var startTime = Date.now();
        showLoading();

        var login = loginForm.loginField.text;
        var password = loginForm.passwordField.text;

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
        anchors.fill: parent
        radius: 24
        color: "#f0f0f0"
        clip: true
        z: -3
        focus: true // Важно: даем фокус для обработки клавиш

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
            visible: parent !== null
        }

        Common.TitleBar {
            id: titleBar
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 10
            }
            isWindowMaximized: authWindow.isWindowMaximized
            currentView: "Вход в систему"
            window: authWindow

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
