import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects
import QtQml 2.15
import QtCore

ApplicationWindow {
id: registerWindow
width: 450
height: 650
visible: true
title: "Регистрация | " + appName
color: "transparent"
flags: Qt.Window | Qt.FramelessWindowHint
minimumWidth: 450
maximumWidth: 600
minimumHeight: 650
maximumHeight: 800


property bool isWindowMaximized: false

// Используем settingsManager
property bool useLocalServer: settingsManager.useLocalServer
property string serverAddress: settingsManager.serverAddress
property string remoteApiBaseUrl: "https://deltablast.fun"
property int remotePort: 5000

// Функции для работы с API
property var attemptRegister: function() {
    if (!isFormValid()) return;

    // Проверка совпадения паролей
    if (passwordField.text !== confirmPasswordField.text) {
        showError("Пароли не совпадают!");
        return;
    }

    showLoading();

    checkInternetConnection(function(hasConnection) {
        if (!hasConnection) {
            hideLoading();
            var serverType = useLocalServer ? "локальному " : "";
            showError("Не удалось подключиться к " + serverType + "серверу.");
            return;
        }

        sendRegisterData(
            firstNameField.text,
            lastNameField.text,
            middleNameField.text,
            phoneField.text,
            emailField.text,
            passwordField.text,
            function(result) {
                hideLoading();
                if (result.success) {
                    showError("");
                    console.log("Успешная регистрация!");
                    showSuccessMessage("Регистрация завершена успешно!");
                    // Закрываем окно через 2 секунды и открываем окно авторизации
                    successTimer.start();
                } else {
                    showError(result.message);
                }
            }
        );
    });
}

property var checkInternetConnection: function(callback) {
    var xhr = new XMLHttpRequest();
    xhr.timeout = 5000;

    var baseUrl = useLocalServer ? serverAddress : (remoteApiBaseUrl + ":" + remotePort);
    var url = baseUrl + "/check-connection";

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

property var sendRegisterData: function(firstName, lastName, middleName, phone, email, password, callback) {
    var xhr = new XMLHttpRequest();
    xhr.timeout = 10000;

    var baseUrl = useLocalServer ? serverAddress : (remoteApiBaseUrl + ":" + remotePort);
    var url = baseUrl + "/register";

    console.log("Sending register request to:", url);

    var requestData = {
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password
    };

    // Добавляем опциональные поля, если они заполнены
    if (middleName !== "") requestData.middleName = middleName;
    if (phone !== "") requestData.phoneNumber = phone;

    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            try {
                var response = JSON.parse(xhr.responseText);
                console.log("Register response:", response);
                if (xhr.status === 201) {
                    callback({ success: true, message: "Регистрация успешна!" });
                } else {
                    callback({ success: false, message: response.error || "Ошибка регистрации" });
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
        xhr.send(JSON.stringify(requestData));
    } catch (error) {
        console.log("Request sending error:", error);
        callback({ success: false, message: "Ошибка отправки данных." });
    }
}

property var showError: function(message) {
    errorMessageText.text = message;
    errorAutoHideTimer.restart();
}

property var showSuccessMessage: function(message) {
    successMessageText.text = message;
    successMessageContainer.visible = true;
    successAutoHideTimer.restart();
}

property var showLoading: function() {
    loadingAnimation.visible = true;
    loadingAnimation.opacity = 1;
    registerForm.opacity = 0.85;
    registerButton.enabled = false;
}

property var hideLoading: function() {
    loadingAnimation.opacity = 0;
    loadingAnimation.visible = false;
    registerForm.opacity = 0.95;
    registerButton.enabled = true;
}

property var isFormValid: function() {
    return firstNameField.text.length > 0 &&
           lastNameField.text.length > 0 &&
           emailField.text.length > 0 &&
           passwordField.text.length > 0 &&
           confirmPasswordField.text.length > 0;
}

property var toggleMaximize: function() {
    if (isWindowMaximized) {
        registerWindow.width = 450;
        registerWindow.height = 650;
        isWindowMaximized = false;
    } else {
        registerWindow.width = registerWindow.maximumWidth;
        registerWindow.height = registerWindow.maximumHeight;
        isWindowMaximized = true;
    }
}

property var openAuthWindow: function() {
    var component = Qt.createComponent("Auth.qml");
    if (component.status === Component.Ready) {
        var authWindow = component.createObject(registerWindow, {
            "x": registerWindow.x,
            "y": registerWindow.y,
            "width": registerWindow.width,
            "height": registerWindow.height
        });
        authWindow.show();
        registerWindow.close();
    } else {
        console.log("Error loading Auth.qml:", component.errorString());
    }
}

// Основной контейнер
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

    // Многоугольники на фоне (как в Auth.qml)
    Repeater {
        id: polygonRepeater
        model: 8
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
                "#448AFF", "#40C4FF", "#18FFFF", "#64FFDA", "#69F0AE"
            ][Math.floor(Math.random() * 10)]

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
                            "#448AFF", "#40C4FF", "#18FFFF", "#64FFDA", "#69F0AE"
                        ][Math.floor(Math.random() * 10)];
                        polygonCanvas.requestPaint();
                    }
                }
            }
            Component.onCompleted: polygonCanvas.requestPaint()
        }
    }

    // Верхняя панель
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
            text: "Регистрация | " + appName
            color: "#2c3e50"
            font.pixelSize: 12
            font.bold: true
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
                    onClicked: registerWindow.showMinimized()
                }
            }

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

        MouseArea {
            id: dragArea
            anchors {
                left: parent.left
                right: buttonRowsPanel.left
                top: parent.top
                bottom: parent.bottom
            }
            drag.target: null
            property point clickPos: Qt.point(0, 0)

            onPressed: function(mouse) {
                if (mouse.button === Qt.LeftButton) {
                    clickPos = Qt.point(mouse.x, mouse.y)
                    registerWindow.startSystemMove()
                }
            }

            onPositionChanged: function(mouse) {
                if (mouse.buttons === Qt.LeftButton && !registerWindow.startSystemMove) {
                    var delta = Qt.point(mouse.x - clickPos.x, mouse.y - clickPos.y)
                    registerWindow.x += delta.x
                    registerWindow.y += delta.y
                }
            }
        }
    }

    // Сообщение об ошибке
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

    // Сообщение об успехе
    Rectangle {
        id: successMessageContainer
        width: parent.width * 0.78
        height: successMessageText.visible ? Math.min(successMessageText.contentHeight + 16, 100) : 0
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: 32
        }
        radius: 8
        color: "#e8f5e8"
        border.color: "#4caf50"
        border.width: 2
        visible: false
        opacity: visible ? 1 : 0
        clip: true
        z: 10

        Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: 250 } }

        Text {
            id: successMessageText
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                right: parent.right
                margins: 16
            }
            text: ""
            font.pixelSize: 12
            color: "#2e7d32"
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }
    }

    // Форма регистрации
    Rectangle {
        id: registerForm
        width: parent.width * 0.78
        height: contentLayout.height + 35
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: errorMessageContainer.bottom
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
                text: "📝 РЕГИСТРАЦИЯ"
                font.pixelSize: 18
                font.bold: true
                color: "#2c3e50"
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: 6
            }

            // Имя
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: "👤 Имя *"
                    font.pixelSize: 12
                    color: "#2c3e50"
                }

                TextField {
                    id: firstNameField
                    Layout.fillWidth: true
                    placeholderText: "Введите ваше имя"
                    font.pixelSize: 12
                    padding: 10
                    color: "#000000"

                    background: Rectangle {
                        radius: 5
                        border.color: firstNameField.activeFocus ? "#3498db" : "#d0d0d0"
                        border.width: firstNameField.activeFocus ? 1.5 : 1
                        color: "#ffffff"
                    }
                }
            }

            // Фамилия
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: "👤 Фамилия *"
                    font.pixelSize: 12
                    color: "#2c3e50"
                }

                TextField {
                    id: lastNameField
                    Layout.fillWidth: true
                    placeholderText: "Введите вашу фамилию"
                    font.pixelSize: 12
                    padding: 10
                    color: "#000000"

                    background: Rectangle {
                        radius: 5
                        border.color: lastNameField.activeFocus ? "#3498db" : "#d0d0d0"
                        border.width: lastNameField.activeFocus ? 1.5 : 1
                        color: "#ffffff"
                    }
                }
            }

            // Отчество
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: "👤 Отчество"
                    font.pixelSize: 12
                    color: "#2c3e50"
                }

                TextField {
                    id: middleNameField
                    Layout.fillWidth: true
                    placeholderText: "Введите ваше отчество (необязательно)"
                    font.pixelSize: 12
                    padding: 10
                    color: "#000000"

                    background: Rectangle {
                        radius: 5
                        border.color: middleNameField.activeFocus ? "#3498db" : "#d0d0d0"
                        border.width: middleNameField.activeFocus ? 1.5 : 1
                        color: "#ffffff"
                    }
                }
            }

            // Телефон
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: "📞 Телефон"
                    font.pixelSize: 12
                    color: "#2c3e50"
                }

                TextField {
                    id: phoneField
                    Layout.fillWidth: true
                    placeholderText: "Введите ваш телефон (необязательно)"
                    font.pixelSize: 12
                    padding: 10
                    color: "#000000"

                    background: Rectangle {
                        radius: 5
                        border.color: phoneField.activeFocus ? "#3498db" : "#d0d0d0"
                        border.width: phoneField.activeFocus ? 1.5 : 1
                        color: "#ffffff"
                    }
                }
            }

            // Email
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: "📧 E-mail *"
                    font.pixelSize: 12
                    color: "#2c3e50"
                }

                TextField {
                    id: emailField
                    Layout.fillWidth: true
                    placeholderText: "Введите ваш e-mail"
                    font.pixelSize: 12
                    padding: 10
                    color: "#000000"

                    background: Rectangle {
                        radius: 5
                        border.color: emailField.activeFocus ? "#3498db" : "#d0d0d0"
                        border.width: emailField.activeFocus ? 1.5 : 1
                        color: "#ffffff"
                    }
                }
            }

            // Пароль
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: "🔒 Пароль *"
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
                    }
                }
            }

            // Подтверждение пароля
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: "🔒 Подтверждение пароля *"
                    font.pixelSize: 12
                    color: "#2c3e50"
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    TextField {
                        id: confirmPasswordField
                        Layout.fillWidth: true
                        placeholderText: "Повторите пароль"
                        font.pixelSize: 12
                        padding: 10
                        echoMode: showConfirmPasswordButton.checked ? TextField.Normal : TextField.Password
                        color: "#000000"

                        background: Rectangle {
                            radius: 5
                            border.color: confirmPasswordField.activeFocus ? "#3498db" : "#d0d0d0"
                            border.width: confirmPasswordField.activeFocus ? 1.5 : 1
                            color: "#ffffff"
                        }
                    }

                    Button {
                        id: showConfirmPasswordButton
                        implicitWidth: 28
                        implicitHeight: 28
                        checkable: true
                        checked: false

                        background: Rectangle {
                            radius: 5
                            border.color: showConfirmPasswordButton.down ? "#3498db" : "#d0d0d0"
                            border.width: 1
                            color: showConfirmPasswordButton.checked ? "#3498db" : "transparent"
                        }

                        contentItem: Item {
                            Text {
                                anchors.centerIn: parent
                                text: showConfirmPasswordButton.checked ? "👁" : "👁"
                                font.pixelSize: 16
                                color: showConfirmPasswordButton.checked ? "white" : "#7f8c8d"
                            }

                            Rectangle {
                                visible: !showConfirmPasswordButton.checked
                                anchors.centerIn: parent
                                width: 18
                                height: 2
                                rotation: 45
                                color: "#7f8c8d"
                            }
                        }
                    }
                }
            }

            Button {
                id: registerButton
                text: "🚀 ЗАРЕГИСТРИРОВАТЬСЯ"
                Layout.fillWidth: true
                font.pixelSize: 13
                font.bold: true
                padding: 12
                enabled: firstNameField.text.length > 0 &&
                         lastNameField.text.length > 0 &&
                         emailField.text.length > 0 &&
                         passwordField.text.length > 0 &&
                         confirmPasswordField.text.length > 0

                background: Rectangle {
                    radius: 5
                    color: registerButton.down ? "#2980b9" : (registerButton.enabled ? "#3498db" : "#d0d0d0")
                }

                contentItem: Text {
                    text: registerButton.text
                    font: registerButton.font
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: attemptRegister()
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "← Назад к авторизации"
                font.pixelSize: 13
                color: "#3498db"
                opacity: 0.9

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: openAuthWindow()
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

    // Копирайт
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

    Timer {
        id: successAutoHideTimer
        interval: 5000
        onTriggered: successMessageContainer.visible = false;
    }

    Timer {
        id: successTimer
        interval: 2000
        onTriggered: {
            openAuthWindow();
        }
    }
}
}
