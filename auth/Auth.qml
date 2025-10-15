import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects
import QtQml 2.15

ApplicationWindow {
    id: authWindow
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
    property bool _isLoading: false

    property string remoteApiBaseUrl: "https://deltablast.fun"
    property int remotePort: 5000

    property int _minLoadingTime: 500
    property var _loginResult: null

    property bool _showingRegistration: false
    property int registrationExtraHeight: 150

    property string authToken: ""

    signal loginSuccessful(string token, var userData)

    // Добавляем AuthAPI
    AuthAPI {
        id: authAPI
        remoteApiBaseUrl: authWindow.remoteApiBaseUrl
        remotePort: authWindow.remotePort
    }

    Loader {
        id: mainWindowLoader
        active: false
        asynchronous: true
        source: "../main/Main.qml"

        onLoaded: {
            if (item) {
                if (authToken) {
                    item.authToken = authToken;
                }
                item.show();
                closeTimer.start();
            }
        }

        onStatusChanged: {
            _isLoading = false;
            if (status === Loader.Error) {
                showError("Ошибка загрузки интерфейса: " + sourceComponent.errorString());
                hideLoading();
            }
        }
    }

    Timer {
        id: closeTimer
        interval: 100
        onTriggered: authWindow.hide()
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
    }

    function showAuthWindow() {
        authWindow.show();
        authWindow.raise();
        authWindow.requestActivate();
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
    }

    function showLoginForm() {
        _showingRegistration = false;
        updateWindowHeight();
    }

    function updateWindowHeight() {
        if (!isWindowMaximized) {
            var targetHeight = baseHeight;

            if (settingsManager.useLocalServer && !_showingRegistration) {
                targetHeight += localServerExtraHeight;
            }

            if (_showingError) {
                targetHeight += 60;
            }

            if (_showingRegistration) {
                targetHeight += registrationExtraHeight;
            }

            targetHeight = Math.max(minimumHeight, Math.min(maximumHeight, targetHeight));
            authWindow.height = targetHeight;
        }
    }

    function toggleMaximize() {
        if (isWindowMaximized) {
            authWindow.showNormal();
            isWindowMaximized = false;
            updateWindowHeight();
        } else {
            authWindow.showMaximized();
            isWindowMaximized = true;
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
        if (loginForm && loginForm.setLogin && email) {
            loginForm.setLogin(email);
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
                margins: 10
            }
            isWindowMaximized: authWindow.isWindowMaximized

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
            interval: 5000
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
