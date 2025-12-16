import QtQuick
import QtQuick.Layouts 1.15

Rectangle {
    id: loginForm
    width: parent.width * 0.85
    height: contentLayout.height + 25
    radius: 8
    color: "#f8f8f8"
    opacity: 0.95
    border.color: "#e0e0e0"
    border.width: 1

    property bool isMobile: Qt.platform.os === "android" || Qt.platform.os === "ios" ||
                           Qt.platform.os === "tvos" || Qt.platform.os === "wasm"

    signal attemptLogin

    function focusLogin() {
        loginField.focus = true
        loginField.cursorPosition = loginField.text.length
    }

    function focusPassword() {
        passwordField.focus = true
        passwordField.cursorPosition = passwordField.text.length
    }

    function submitForm() {
        if (loginButton.enabled) {
            attemptLogin()
        }
    }

    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            submitForm()
            event.accepted = true
        } else if (event.key === Qt.Key_Down) {
            focusPassword()
            event.accepted = true
        } else if (event.key === Qt.Key_Up) {
            focusLogin()
            event.accepted = true
        }
    }

    ColumnLayout {
        id: contentLayout
        width: parent.width - 20
        anchors.centerIn: parent
        spacing: 10

        Row {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 4
            spacing: 8

            AnimatedImage {
                source: "qrc:/icons/security.gif"
                sourceSize: Qt.size(20, 20)
                anchors.verticalCenter: parent.verticalCenter
                playing: true
                speed: 0.8
            }

            Text {
                text: "ВХОД В СИСТЕМУ"
                font.pixelSize: isMobile ? 18 : 16
                font.bold: true
                color: "#2c3e50"
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3

            Row {
                spacing: 4
                AnimatedImage {
                    source: loginField.activeFocus ? "qrc:/icons/profile.gif" : "qrc:/icons/user.png"
                    sourceSize: Qt.size(16, 16)
                    anchors.verticalCenter: parent.verticalCenter
                    playing: loginField.activeFocus
                    speed: 0.7
                }
                Text {
                    text: "Логин или E-mail"
                    font.pixelSize: isMobile ? 13 : 11
                    color: "#2c3e50"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 32
                radius: 5
                border.color: loginField.activeFocus ? "#3498db" : "#d0d0d0"
                border.width: loginField.activeFocus ? 1.5 : 1
                color: "#ffffff"

                TextInput {
                    id: loginField
                    anchors.fill: parent
                    anchors.margins: 8
                    verticalAlignment: TextInput.AlignVCenter
                    font.pixelSize: isMobile ? 14 : 12
                    color: "#000000"
                    selectByMouse: true
                    focus: true

                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            loginForm.submitForm()
                            event.accepted = true
                        } else if (event.key === Qt.Key_Down) {
                            loginForm.focusPassword()
                            event.accepted = true
                        } else if (event.key === Qt.Key_Up) {
                            loginForm.focusLogin()
                            event.accepted = true
                        }
                    }
                }

                Text {
                    anchors.fill: parent
                    anchors.margins: 8
                    verticalAlignment: Text.AlignVCenter
                    text: "Введите логин или e-mail"
                    color: "#a0a0a0"
                    visible: !loginField.text && !loginField.activeFocus
                    font.pixelSize: isMobile ? 14 : 12
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3

            Row {
                spacing: 4
                AnimatedImage {
                    source: passwordField.activeFocus ? "qrc:/icons/security.gif" : "qrc:/icons/security.png"
                    sourceSize: Qt.size(16, 16)
                    anchors.verticalCenter: parent.verticalCenter
                    playing: passwordField.activeFocus
                    speed: 0.7
                }
                Text {
                    text: "Пароль"
                    font.pixelSize: isMobile ? 13 : 11
                    color: "#2c3e50"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Rectangle {
                    Layout.fillWidth: true
                    height: 32
                    radius: 5
                    border.color: passwordField.activeFocus ? "#3498db" : "#d0d0d0"
                    border.width: passwordField.activeFocus ? 1.5 : 1
                    color: "#ffffff"

                    TextInput {
                        id: passwordField
                        anchors.fill: parent
                        anchors.margins: 8
                        verticalAlignment: TextInput.AlignVCenter
                        font.pixelSize: isMobile ? 14 : 12
                        echoMode: showPasswordButton.checked ? TextInput.Normal : TextInput.Password
                        color: "#000000"
                        selectByMouse: true

                        Keys.onPressed: (event) => {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                loginForm.submitForm()
                                event.accepted = true
                            } else if (event.key === Qt.Key_Down) {
                                loginForm.focusPassword()
                                event.accepted = true
                            } else if (event.key === Qt.Key_Up) {
                                loginForm.focusLogin()
                                event.accepted = true
                            }
                        }
                    }

                    Text {
                        anchors.fill: parent
                        anchors.margins: 8
                        verticalAlignment: Text.AlignVCenter
                        text: "Введите пароль"
                        color: "#a0a0a0"
                        visible: !passwordField.text && !passwordField.activeFocus
                        font.pixelSize: isMobile ? 14 : 12
                    }
                }

                Rectangle {
                    id: showPasswordButton
                    width: 26
                    height: 26
                    radius: 5
                    border.color: showPasswordMouseArea.containsPress ? "#3498db" : "#d0d0d0"
                    border.width: 1
                    color: showPasswordButton.checked ? "#3498db" : "transparent"

                    property bool checked: false

                    Image {
                        anchors.centerIn: parent
                        source: showPasswordButton.checked ? "qrc:/icons/eye.png" : "qrc:/icons/eye-off.png"
                        sourceSize: Qt.size(16, 16)
                    }

                    MouseArea {
                        id: showPasswordMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: showPasswordButton.checked = !showPasswordButton.checked
                    }
                }
            }
        }

        Rectangle {
            id: loginButton
            Layout.fillWidth: true
            height: 40
            radius: 5
            color: loginButtonMouseArea.pressed ? "#2980b9" : (loginButton.enabled ? "#3498db" : "#d0d0d0")

            property bool enabled: loginField.text.length > 0 && passwordField.text.length > 0 && !authWindow._isLoading

            Row {
                anchors.centerIn: parent
                spacing: 6
                AnimatedImage {
                    source: authWindow._isLoading ? "qrc:/icons/loading.png" : "qrc:/icons/check.png"
                    sourceSize: Qt.size(16, 16)
                    anchors.verticalCenter: parent.verticalCenter
                    playing: authWindow._isLoading
                }
                Text {
                    text: authWindow._isLoading ? "ЗАГРУЗКА..." : "ВОЙТИ"
                    font.pixelSize: isMobile ? 14 : 12
                    font.bold: true
                    color: "white"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                id: loginButtonMouseArea
                anchors.fill: parent
                hoverEnabled: true
                enabled: loginButton.enabled
                onClicked: attemptLogin()
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 10

            Text {
                text: "Забыли пароль?"
                font.pixelSize: isMobile ? 14 : 12
                color: "#3498db"
                opacity: 0.9

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (typeof showError === "function") {
                            showError("Данный функционал пока не реализован.");
                        }
                    }
                }
            }

            Text {
                text: "Регистрация"
                font.pixelSize: isMobile ? 14 : 12
                color: "#3498db"
                opacity: 0.9

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (typeof authWindow !== "undefined" && authWindow.showRegistrationForm) {
                            authWindow.showRegistrationForm();
                        }
                    }
                }
            }
        }
    }

    property alias loginField: loginField
    property alias passwordField: passwordField
    property alias loginButton: loginButton

    Component.onCompleted: {
        focusLogin()
    }
}
