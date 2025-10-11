import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects
import QtQml 2.15
import QtCore

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
    maximumHeight: 660

    property bool isWindowMaximized: false
    property int normalHeight: 540 // Сохраняем нормальную высоту для восстановления

    // Используем settingsManager вместо appSettings
    property bool useLocalServer: settingsManager.useLocalServer
    property string serverAddress: settingsManager.serverAddress
    property string apiPath: settingsManager.apiPath

    property string remoteApiBaseUrl: "https://deltablast.fun"
    property int remotePort: 5000

    // Плавная анимация изменения высоты окна
    Behavior on height {
        NumberAnimation {
            duration: 300;
            easing.type: Easing.InOutQuad
        }
    }

    // Обработчик изменения типа сервера
    onUseLocalServerChanged: {
        if (!isWindowMaximized) {
            if (useLocalServer) {
                // Увеличиваем только высоту для локального сервера
                normalHeight = 620;
                mainWindow.height = 660;
            } else {
                // Уменьшаем высоту для официального сервера
                normalHeight = 540;
                mainWindow.height = 560;
            }
        }
    }

    // Объявления всех функций как свойств компонента
    property var attemptLogin: function() {
        if (!isFormValid()) return;

        showLoading();

        checkInternetConnection(function(hasConnection) {
            if (!hasConnection) {
                hideLoading();
                var serverType = useLocalServer ? "локальному " : "";
                showError("Не удалось подключиться к " + serverType + "серверу.");
                return;
            }

            sendLoginData(loginField.text, passwordField.text, function(result) {
                hideLoading();
                if (result.success) {
                    showError("");
                    console.log("Успешный вход! Токен:", result.token);
                    // Успешный вход - можно добавить переход
                } else {
                    showError(result.message);
                }
            });
        });
    }

    property var resetSettings: function() {
        settingsManager.serverAddress = "http://localhost:5000";
        settingsManager.apiPath = "/api";

        serverAddressField.text = settingsManager.serverAddress;
        apiPathField.text = settingsManager.apiPath;

        showError("Настройки сброшены к значениям по умолчанию.");
    }

    property var saveServerConfig: function() {
        settingsManager.serverAddress = serverAddressField.text;
        settingsManager.apiPath = apiPathField.text;
        showError("Настройки сервера сохранены");
    }

    property var toggleMaximize: function() {
        if (isWindowMaximized) {
            // Восстанавливаем предыдущий размер с сохранением высоты
            mainWindow.width = 420;
            mainWindow.height = normalHeight;
            isWindowMaximized = false;
        } else {
            // Запоминаем текущую высоту перед максимизацией
            normalHeight = mainWindow.height;
            // Устанавливаем максимальный размер
            mainWindow.width = mainWindow.maximumWidth;
            mainWindow.height = mainWindow.maximumHeight;
            isWindowMaximized = true;
        }
    }

    property var checkInternetConnection: function(callback) {
        var xhr = new XMLHttpRequest();
        xhr.timeout = 5000;

        var url = useLocalServer ?
            (serverAddress + apiPath + "/check-connection") :
            (remoteApiBaseUrl + ":" + remotePort + "/api/check-connection");

        console.log("Checking connection to:", url);

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    console.log("Connection successful");
                    callback(true);
                } else {
                    console.log("Connection failed, status:", xhr.status);
                    callback(false);
                }
            }
        };

        xhr.ontimeout = function() {
            console.log("Connection timeout");
            callback(false);
        };
        xhr.onerror = function() {
            console.log("Connection error");
            callback(false);
        };

        try {
            xhr.open("GET", url, true);
            xhr.send();
        } catch (error) {
            console.log("Connection exception:", error);
            callback(false);
        }
    }

    property var sendLoginData: function(login, password, callback) {
        var xhr = new XMLHttpRequest();
        xhr.timeout = 5000;

        var baseUrl = useLocalServer ? serverAddress : (remoteApiBaseUrl + ":" + remotePort);
        var currentApiPath = useLocalServer ? apiPath : "/api";
        var url = baseUrl + currentApiPath + "/login";

        console.log("Sending login request to:", url);

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                try {
                    var response = JSON.parse(xhr.responseText);
                    console.log("Login response:", response);
                    if (xhr.status === 200) {
                        callback({ success: true, message: "Успешный вход!", token: response.token });
                    } else {
                        callback({ success: false, message: response.error || "Ошибка авторизации" });
                    }
                } catch (e) {
                    console.log("Response parsing error:", e);
                    callback({ success: false, message: "Ошибка обработки ответа сервера" });
                }
            }
        };

        xhr.ontimeout = function() {
            callback({ success: false, message: "Таймаут соединения с сервером." });
        };
        xhr.onerror = function() {
            callback({ success: false, message: "Ошибка соединения с сервером." });
        };

        try {
            xhr.open("POST", url, true);
            xhr.setRequestHeader("Content-Type", "application/json");
            xhr.send(JSON.stringify({
                email: login,
                password: password
            }));
        } catch (error) {
            console.log("Request sending error:", error);
            callback({ success: false, message: "Ошибка отправки данных." });
        }
    }

    property var showError: function(message) {
        errorMessageText.text = message;
        errorAutoHideTimer.restart();
    }

    property var showLoading: function() {
        loadingAnimation.visible = true;
        loadingAnimation.opacity = 1;
        loginForm.opacity = 0.85;
        loginButton.enabled = false;
    }

    property var hideLoading: function() {
        loadingAnimation.opacity = 0;
        loadingAnimation.visible = false;
        loginForm.opacity = 0.95;
        loginButton.enabled = true;
    }

    property var isFormValid: function() {
        return loginField.text.length > 0 && passwordField.text.length > 0;
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
        Repeater {
            id: polygonRepeater
            model: 10
            z: 1

            Item {
                id: polygonContainer
                property real startX: Math.random() * (windowContainer.width + 120) - 60
                property real startY: Math.random() * (windowContainer.height + 120) - 60
                property real targetX: Math.random() * (windowContainer.width + 120) - 60
                property real targetY: Math.random() * (windowContainer.height + 120) - 60
                property real polygonSize: 30 + Math.random() * 45
                property color polygonColor: [
                    "#FF5252", "#FF4081", "#E040FB", "#7C4DFF", "#536DFE",
                    "#448AFF", "#40C4FF", "#18FFFF", "#64FFDA", "#69F0AE",
                    "#FFA500", "#AFEEEE", "#4169E1", "#FFFFF0", "#696969",
                    "#CD853F", "#483D8B", "#FF8C00", "#006400", "#2E8B57"
                ][Math.floor(Math.random() * 20)]

                x: startX
                y: startY
                opacity: 0
                width: polygonSize * 2
                height: polygonSize * 2
                z: 0

                Canvas {
                    id: polygonCanvas
                    anchors.fill: parent
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.clearRect(0, 0, width, height);
                        drawPolygon(ctx);
                    }

                    function drawPolygon(ctx) {
                        var sides = 6 + Math.floor(Math.random() * 3);
                        var radius = polygonSize;
                        var centerX = width / 2;
                        var centerY = height / 2;

                        ctx.shadowColor = polygonColor;
                        ctx.shadowBlur = 12;

                        ctx.beginPath();
                        ctx.moveTo(centerX + radius * Math.cos(0), centerY + radius * Math.sin(0));

                        for (var i = 1; i <= sides; i++) {
                            ctx.lineTo(centerX + radius * Math.cos(i * 2 * Math.PI / sides),
                                      centerY + radius * Math.sin(i * 2 * Math.PI / sides));
                        }

                        ctx.closePath();
                        ctx.fillStyle = polygonColor;
                        ctx.fill();
                    }
                }

                Glow {
                    anchors.fill: polygonCanvas
                    radius: 10
                    samples: 12
                    color: polygonContainer.polygonColor
                    source: polygonCanvas
                    opacity: polygonContainer.opacity * 0.6
                }

                SequentialAnimation {
                    id: appearAnimation
                    running: true
                    loops: Animation.Infinite
                    PauseAnimation { duration: index * 1200 }
                    ParallelAnimation {
                        NumberAnimation {
                            target: polygonContainer; property: "opacity"; from: 0; to: 0.6; duration: 3000; easing.type: Easing.InOutQuad }
                        NumberAnimation {
                            target: polygonContainer; property: "x"; from: startX; to: targetX; duration: 12000; easing.type: Easing.InOutQuad }
                        NumberAnimation {
                            target: polygonContainer; property: "y"; from: startY; to: targetY; duration: 12000; easing.type: Easing.InOutQuad }
                        RotationAnimation {
                            target: polygonContainer; from: 0; to: 90 + Math.random() * 90; duration: 10000; easing.type: Easing.InOutQuad }
                    }
                    PauseAnimation { duration: 3000 }
                    ParallelAnimation {
                        NumberAnimation {
                            target: polygonContainer; property: "opacity"; from: 0.6; to: 0; duration: 4000; easing.type: Easing.InOutQuad }
                        NumberAnimation {
                            target: polygonContainer; property: "x"; from: targetX; to: targetX + (Math.random() - 0.5) * 150; duration: 4000; easing.type: Easing.InOutQuad }
                        NumberAnimation {
                            target: polygonContainer; property: "y"; from: targetY; to: targetY + (Math.random() - 0.5) * 150; duration: 4000; easing.type: Easing.InOutQuad }
                    }
                    PauseAnimation { duration: 2000 + Math.random() * 3000 }
                    ScriptAction {
                        script: {
                            polygonContainer.startX = polygonContainer.x;
                            polygonContainer.startY = polygonContainer.y;
                            polygonContainer.targetX = Math.random() * (windowContainer.width + 150) - 75;
                            polygonContainer.targetY = Math.random() * (windowContainer.height + 150) - 75;
                            polygonContainer.polygonColor = [
                                    "#FF5252", "#FF4081", "#E040FB", "#7C4DFF", "#536DFE",
                                    "#448AFF", "#40C4FF", "#18FFFF", "#64FFDA", "#69F0AE",
                                    "#FFA500", "#AFEEEE", "#4169E1", "#FFFFF0", "#696969",
                                    "#CD853F", "#483D8B", "#FF8C00", "#006400", "#2E8B57"
                            ][Math.floor(Math.random() * 20)];
                            polygonCanvas.requestPaint();
                        }
                    }
                }
                Component.onCompleted: polygonCanvas.requestPaint()
            }
        }

        // Полупрозрачная верхняя панель
        Rectangle {
            id: titleBar
            height: 25
            color: "#ffffff"
            opacity: 1
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            radius: 12
            z: 10

            Text {
                anchors.centerIn: parent
                text: "Вход в систему | " + appName
                color: "#2c3e50"
                font.pixelSize: 12
                font.bold: true
            }

            // Иконка на git
            Rectangle {
                id: gitflicButton
                width: 16
                height: 16
                radius: 8
                color: gitflicMouseArea.containsMouse ? "#4CAF50" : "transparent"
                anchors {
                    left: parent.left
                    leftMargin: 10
                    verticalCenter: parent.verticalCenter
                }

                Text {
                    anchors.centerIn: parent
                    text: "🌐"
                    font.pixelSize: 10
                    color: gitflicMouseArea.containsMouse ? "white" : "#2c3e50"
                }

                MouseArea {
                    id: gitflicMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        Qt.openUrlExternally("https://gitflic.ru/project/cylindr/eduflow");
                    }
                }
            }

            Row {
                id: buttonRowsPanel
                z: 11
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    rightMargin: 8
                }
                spacing: 6

                // Кнопка свернуть
                Rectangle {
                    id: minimizeButton
                    width: 16
                    height: 16
                    radius: 8
                    color: minimizeMouseArea.containsMouse ? "#FFD960" : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "-"
                        color: minimizeMouseArea.containsMouse ? "white" : "#2c3e50"
                        font.pixelSize: 12
                        font.bold: true
                    }

                    MouseArea {
                        id: minimizeMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: mainWindow.showMinimized()
                    }
                }

                // Кнопка развернуть/восстановить
                Rectangle {
                    id: maximizeButton
                    width: 16
                    height: 16
                    radius: 8
                    color: maximizeMouseArea.containsMouse ? "#3498db" : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: isWindowMaximized ? "❐" : "⛶"
                        color: maximizeMouseArea.containsMouse ? "white" : "#2c3e50"
                        font.pixelSize: 10
                        font.bold: true
                    }

                    MouseArea {
                        id: maximizeMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: toggleMaximize()
                    }
                }

                // Кнопка закрыть
                Rectangle {
                    id: closeButton
                    width: 16
                    height: 16
                    radius: 8
                    color: closeMouseArea.containsMouse ? "#ff5c5c" : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "×"
                        color: closeMouseArea.containsMouse ? "white" : "#2c3e50"
                        font.pixelSize: 12
                        font.bold: true
                    }

                    MouseArea {
                        id: closeMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: Qt.quit()
                    }
                }
            }

            // Универсальная область для перетаскивания окна
            MouseArea {
                id: dragArea
                anchors {
                    left: gitflicButton.right
                    right: buttonRowsPanel.left
                    top: parent.top
                    bottom: parent.bottom
                    leftMargin: 5
                }
                drag.target: null
                property point clickPos: Qt.point(0, 0)

                onPressed: function(mouse) {
                    if (mouse.button === Qt.LeftButton) {
                        clickPos = Qt.point(mouse.x, mouse.y)
                        mainWindow.startSystemMove()
                    }
                }

                onPositionChanged: function(mouse) {
                    if (mouse.buttons === Qt.LeftButton && !mainWindow.startSystemMove) {
                        var delta = Qt.point(mouse.x - clickPos.x, mouse.y - clickPos.y)
                        mainWindow.x += delta.x
                        mainWindow.y += delta.y
                    }
                }
            }
        }

        Rectangle {
            id: errorMessageContainer
            width: parent.width * 0.78
            height: errorMessageText.visible ? Math.min(errorMessageText.contentHeight + 16, 100) : 0
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
                topMargin: 32
            }
            radius: 8
            color: "#ffebee"
            border.color: "#f44336"
            border.width: 2
            visible: errorMessageText.text !== ""
            opacity: visible ? 1 : 0
            clip: true
            z: 10

            Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
            Behavior on opacity { NumberAnimation { duration: 250 } }

            Text {
                id: errorMessageText
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    right: parent.right
                    margins: 16
                }
                text: ""
                font.pixelSize: 12
                color: "#d32f2f"
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
        }

        // Блок выбора сервера
        Rectangle {
            id: serverConfigBox
            width: parent.width * 0.78
            height: useLocalServer ? 210 : 60
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: errorMessageContainer.bottom
                topMargin: 24
            }
            radius: 8
            color: "#f8f8f8"
            opacity: 0.95
            border.color: "#e0e0e0"
            border.width: 1
            clip: true

            // Плавная анимация изменения высоты блока настроек
            Behavior on height {
                NumberAnimation {
                    duration: 300;
                    easing.type: Easing.OutCubic
                }
            }

            ColumnLayout {
                id: serverConfigColumn
                width: parent.width - 16
                anchors.centerIn: parent
                spacing: 8

                // Выбор типа сервера
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15

                    // Официальный сервер
                    Rectangle {
                        Layout.fillWidth: true
                        height: 40
                        radius: 8
                        color: !useLocalServer ? "#e3f2fd" : "#f5f5f5"
                        border.color: !useLocalServer ? "#2196f3" : "#e0e0e0"
                        border.width: 2

                        Text {
                            anchors.centerIn: parent
                            text: "🌐 Официальный\nEduFlow"
                            font.pixelSize: 11
                            color: !useLocalServer ? "#1976d2" : "#9e9e9e"
                            horizontalAlignment: Text.AlignHCenter
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                settingsManager.useLocalServer = false;
                            }
                        }
                    }

                    // Локальный сервер
                    Rectangle {
                        Layout.fillWidth: true
                        height: 40
                        radius: 8
                        color: useLocalServer ? "#e8f5e8" : "#f5f5f5"
                        border.color: useLocalServer ? "#4caf50" : "#e0e0e0"
                        border.width: 2

                        Text {
                            anchors.centerIn: parent
                            text: "💻 Локальный\nНастраиваемый"
                            font.pixelSize: 11
                            color: useLocalServer ? "#2e7d32" : "#9e9e9e"
                            horizontalAlignment: Text.AlignHCenter
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                settingsManager.useLocalServer = true;
                            }
                        }
                    }
                }

                // Настройки для локального сервера
                ColumnLayout {
                    id: localServerSettings
                    Layout.fillWidth: true
                    spacing: 8
                    visible: useLocalServer
                    opacity: visible ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 200
                        }
                    }

                    // Адрес сервера
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: "📡 Адрес сервера:"
                            font.pixelSize: 11
                            color: "#2c3e50"
                            font.bold: true
                        }

                        TextField {
                            id: serverAddressField
                            Layout.fillWidth: true
                            placeholderText: "http://localhost:5000"
                            font.pixelSize: 11
                            text: serverAddress
                            padding: 8

                            background: Rectangle {
                                radius: 4
                                border.color: parent.activeFocus ? "#3498db" : "#d0d0d0"
                                border.width: parent.activeFocus ? 1.5 : 1
                                color: "#ffffff"
                            }
                        }
                    }

                    // API путь
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: "📁 API путь:"
                            font.pixelSize: 11
                            color: "#2c3e50"
                            font.bold: true
                        }

                        TextField {
                            id: apiPathField
                            Layout.fillWidth: true
                            placeholderText: "/api"
                            text: apiPath
                            font.pixelSize: 11
                            padding: 8

                            background: Rectangle {
                                radius: 4
                                border.color: parent.activeFocus ? "#3498db" : "#d0d0d0"
                                border.width: parent.activeFocus ? 1.5 : 1
                                color: "#ffffff"
                            }
                        }
                    }

                    // Кнопки управления
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Button {
                            text: "Сохранить"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 32
                            onClicked: saveServerConfig()

                            background: Rectangle {
                                radius: 8
                                color: parent.down ? "#27ae60" : "#2ecc71"
                            }

                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font.pixelSize: 11
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Button {
                            text: "Сбросить"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 32
                            onClicked: resetSettings()

                            background: Rectangle {
                                radius: 8
                                color: parent.down ? "#c0392b" : "#e74c3c"
                            }

                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font.pixelSize: 11
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: loginForm
            width: parent.width * 0.78
            height: contentLayout.height + 35
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: serverConfigBox.bottom
                topMargin: 32
            }
            radius: 8
            color: "#f8f8f8"
            opacity: 0.95
            border.color: "#e0e0e0"
            border.width: 1

            ColumnLayout {
                id: contentLayout
                width: parent.width - 25
                anchors.centerIn: parent
                spacing: 12

                Text {
                    text: "🔐 ВХОД В СИСТЕМУ"
                    font.pixelSize: 18
                    font.bold: true
                    color: "#2c3e50"
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 6
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        text: "👤 Логин или E-mail"
                        font.pixelSize: 12
                        color: "#2c3e50"
                    }

                    TextField {
                        id: loginField
                        Layout.fillWidth: true
                        placeholderText: "Введите логин или e-mail"
                        font.pixelSize: 12
                        padding: 10
                        color: "#000000"

                        background: Rectangle {
                            radius: 5
                            border.color: loginField.activeFocus ? "#3498db" : "#d0d0d0"
                            border.width: loginField.activeFocus ? 1.5 : 1
                            color: "#ffffff"
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        text: "🔒 Пароль"
                        font.pixelSize: 12
                        color: "#2c3e50"
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        TextField {
                            id: passwordField
                            Layout.fillWidth: true
                            placeholderText: "Введите пароль"
                            font.pixelSize: 12
                            padding: 10
                            echoMode: showPasswordButton.checked ? TextField.Normal : TextField.Password
                            color: "#000000"

                            background: Rectangle {
                                radius: 5
                                border.color: passwordField.activeFocus ? "#3498db" : "#d0d0d0"
                                border.width: passwordField.activeFocus ? 1.5 : 1
                                color: "#ffffff"
                            }
                        }

                        Button {
                            id: showPasswordButton
                            implicitWidth: 28
                            implicitHeight: 28
                            checkable: true
                            checked: false

                            background: Rectangle {
                                radius: 5
                                border.color: showPasswordButton.down ? "#3498db" : "#d0d0d0"
                                border.width: 1
                                color: showPasswordButton.checked ? "#3498db" : "transparent"
                            }

                            contentItem: Item {
                                Text {
                                    anchors.centerIn: parent
                                    text: showPasswordButton.checked ? "👁" : "👁"
                                    font.pixelSize: 16
                                    color: showPasswordButton.checked ? "white" : "#7f8c8d"
                                }

                                Rectangle {
                                    visible: !showPasswordButton.checked
                                    anchors.centerIn: parent
                                    width: 18
                                    height: 2
                                    rotation: 45
                                    color: "#7f8c8d"
                                }
                            }

                            onCheckedChanged: {
                                passwordField.echoMode = checked ? TextField.Normal : TextField.Password;
                            }
                        }
                    }
                }

                Button {
                    id: loginButton
                    text: "🚀 ВОЙТИ"
                    Layout.fillWidth: true
                    font.pixelSize: 13
                    font.bold: true
                    padding: 12
                    enabled: loginField.text.length > 0 && passwordField.text.length > 0

                    background: Rectangle {
                        radius: 5
                        color: loginButton.down ? "#2980b9" : (loginButton.enabled ? "#3498db" : "#d0d0d0")
                    }

                    contentItem: Text {
                        text: loginButton.text
                        font: loginButton.font
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: attemptLogin()
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 12

                    Text {
                        text: "Забыли пароль?"
                        font.pixelSize: 13
                        color: "#3498db"
                        opacity: 0.9

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: showError("Функция восстановления пароля временно недоступна")
                        }
                    }

                    Text {
                        text: "Регистрация"
                        font.pixelSize: 13
                        color: "#3498db"
                        opacity: 0.9

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: showError("Регистрация новых пользователей временно отключена")
                        }
                    }
                }
            }
        }

        // Анимация загрузки
        Rectangle {
            id: loadingAnimation
            anchors.centerIn: parent
            width: 50
            height: 50
            radius: 25
            color: "transparent"
            visible: false
            opacity: 0
            z: 20

            Behavior on opacity { NumberAnimation { duration: 300 } }

            RotationAnimation {
                target: loadingAnimation
                running: loadingAnimation.visible
                from: 0
                to: 360
                duration: 1000
                loops: Animation.Infinite
            }

            Canvas {
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    ctx.strokeStyle = "#3498db";
                    ctx.lineWidth = 3;
                    ctx.beginPath();
                    ctx.arc(width/2, height/2, width/2 - 2, 0, Math.PI * 1.5);
                    ctx.stroke();
                }
            }
        }

        Rectangle {
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: 10
            }
            width: copyrightText.width + 16
            height: copyrightText.height + 8
            color: "#40000000"
            radius: 5
            opacity: 0.9
        }

        Text {
            id: copyrightText
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: 14
            }
            text: "© 2025 Система безопасности"
            font.pixelSize: 10
            color: "white"
            opacity: 0.95
        }

        Timer {
            id: errorAutoHideTimer
            interval: 5000
            onTriggered: errorMessageText.text = "";
        }

        function isFormValid() {
            return loginField.text.length > 0 && passwordField.text.length > 0;
        }
    }
}
