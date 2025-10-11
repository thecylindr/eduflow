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
    property int _minLoadingTime: 500 // время ожидания (в миллисекундах)
    property var _loginResult: null

    // Плавная анимация изменения высоты окна
    Behavior on height {
        NumberAnimation {
            duration: 300;
            easing.type: Easing.InOutQuad
        }
    }

    // Инициализация при загрузке
    Component.onCompleted: {
        console.log("Загружены настройки:",
            "useLocalServer:", settingsManager.useLocalServer,
            "serverAddress:", settingsManager.serverAddress);

        serverConfig.updateFromSettings();
        updateWindowHeight();
    }

    // Обнови функцию saveServerConfig:
    function saveServerConfig(serverAddress) {
        settingsManager.serverAddress = serverAddress;
        // Принудительно обновляем UI после сохранения
        serverConfig.updateFromSettings();
        showSuccess("Настройки сервера сохранены");
    }

    // Обнови функцию resetSettings:
    function resetSettings() {
        settingsManager.serverAddress = "http://localhost:5000";
        serverConfig.updateFromSettings();
        showSuccess("Настройки сброшены к значениям по умолчанию.");
    }

    // Обновление высоты окна
    function updateWindowHeight() {
        if (!isWindowMaximized) {
            var targetHeight = baseHeight;

            if (settingsManager.useLocalServer) {
                targetHeight += localServerExtraHeight;
            }

            if (_showingError) {
                targetHeight += errorExtraHeight;
            }

            mainWindow.height = targetHeight;
        }
    }

    // Функции
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

    // Таймер для минимального времени загрузки
    Timer {
        id: loadingTimer
        interval: 1
        onTriggered: {
            hideLoading();
            _isLoading = false;
            if (_loginResult) {
                if (_loginResult.success) {
                    showSuccess(_loginResult.message);
                    console.log("Успешный вход! Токен:", _loginResult.token);
                } else {
                    showError(_loginResult.message);
                }
                _loginResult = null;
            }
        }
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
        });
    }

    function sendLoginRequest(login, password, callback) {
        var xhr = new XMLHttpRequest();
        xhr.timeout = 10000;

        // Используем настройки напрямую из SettingsManager
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
        loginForm.opacity = 0.6;
        loginForm.loginButton.enabled = false;
    }

    function hideLoading() {
        loadingAnimation.opacity = 0;
        loadingAnimation.visible = false;
        loginForm.opacity = 0.95;
        loginForm.loginButton.enabled = true;
    }

    function isFormValid() {
        return loginForm.loginField.text.length > 0 && loginForm.passwordField.text.length > 0;
    }

    // Основной контейнер с скругленными углами
    Rectangle {
        id: windowContainer
        anchors.fill: parent
        radius: 24
        color: "#f0f0f0"
        clip: true
        z: -3

        // Градиентный фон
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

        // Многоугольники на фоне
        BackgroundPolygons {
            id: backgroundPolygons
            anchors.fill: parent
        }

        // Полупрозрачная верхняя панель
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

        // Сообщение об ошибке (располагается ПОД заголовком)
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

        // Сообщение об успехе (располагается ПОД сообщением об ошибке)
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

        // Блок выбора сервера (располагается ПОД сообщениями)
        ServerConfig {
            id: serverConfig
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: successMessage.bottom
                topMargin: 24
            }
            width: parent.width * 0.78

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

        // Форма входа
        LoginForm {
            id: loginForm
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: serverConfig.bottom
                topMargin: 32
            }
            width: parent.width * 0.78

            onAttemptLogin: mainWindow.attemptLogin()
        }

        // Анимация загрузки
        LoadingAnimation {
            id: loadingAnimation
            anchors.centerIn: parent
        }

        // Нижняя информация
        CopyrightFooter {
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: 15
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

    // Обработчики изменений настроек
    Connections {
        target: settingsManager

        function onUseLocalServerChanged() {
            console.log("Настройки изменились: useLocalServer =", settingsManager.useLocalServer);
            updateWindowHeight();
        }

        function onServerAddressChanged() {
            console.log("Настройки изменились: serverAddress =", settingsManager.serverAddress);
        }
    }
}
