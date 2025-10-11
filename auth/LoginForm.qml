import QtQuick 2.15
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

    signal attemptLogin

    ColumnLayout {
        id: contentLayout
        width: parent.width - 20
        anchors.centerIn: parent
        spacing: 10

        Text {
            text: "🔐 ВХОД В СИСТЕМУ"
            font.pixelSize: 16
            font.bold: true
            color: "#2c3e50"
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 4
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3

            Text {
                text: "👤 Логин или E-mail"
                font.pixelSize: 11
                color: "#2c3e50"
            }

            Rectangle {
                Layout.fillWidth: true
                height: 36
                radius: 5
                border.color: loginField.activeFocus ? "#3498db" : "#d0d0d0"
                border.width: loginField.activeFocus ? 1.5 : 1
                color: "#ffffff"

                TextInput {
                    id: loginField
                    anchors.fill: parent
                    anchors.margins: 8
                    verticalAlignment: TextInput.AlignVCenter
                    font.pixelSize: 11
                    color: "#000000"
                    selectByMouse: true
                }

                Text {
                    anchors.fill: parent
                    anchors.margins: 8
                    verticalAlignment: Text.AlignVCenter
                    text: "Введите логин или e-mail"
                    color: "#a0a0a0"
                    visible: !loginField.text && !loginField.activeFocus
                    font.pixelSize: 11
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3

            Text {
                text: "🔒 Пароль"
                font.pixelSize: 11
                color: "#2c3e50"
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Rectangle {
                    Layout.fillWidth: true
                    height: 36
                    radius: 5
                    border.color: passwordField.activeFocus ? "#3498db" : "#d0d0d0"
                    border.width: passwordField.activeFocus ? 1.5 : 1
                    color: "#ffffff"

                    TextInput {
                        id: passwordField
                        anchors.fill: parent
                        anchors.margins: 8
                        verticalAlignment: TextInput.AlignVCenter
                        font.pixelSize: 11
                        echoMode: showPasswordButton.checked ? TextInput.Normal : TextInput.Password
                        color: "#000000"
                        selectByMouse: true
                    }

                    Text {
                        anchors.fill: parent
                        anchors.margins: 8
                        verticalAlignment: Text.AlignVCenter
                        text: "Введите пароль"
                        color: "#a0a0a0"
                        visible: !passwordField.text && !passwordField.activeFocus
                        font.pixelSize: 11
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

                    Text {
                        anchors.centerIn: parent
                        text: "👁"
                        font.pixelSize: 14
                        color: showPasswordButton.checked ? "white" : "#7f8c8d"
                    }

                    Rectangle {
                        visible: !showPasswordButton.checked
                        anchors.centerIn: parent
                        width: 16
                        height: 2
                        rotation: 45
                        color: "#7f8c8d"
                    }

                    MouseArea {
                        id: showPasswordMouseArea
                        anchors.fill: parent
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

            property bool enabled: loginField.text.length > 0 && passwordField.text.length > 0 && !mainWindow._isLoading

            Text {
                anchors.centerIn: parent
                text: mainWindow._isLoading ? "⏳ ЗАГРУЗКА..." : "🚀 ВОЙТИ"
                font.pixelSize: 12
                font.bold: true
                color: "white"
            }

            MouseArea {
                id: loginButtonMouseArea
                anchors.fill: parent
                enabled: loginButton.enabled
                onClicked: attemptLogin()
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 10

            Text {
                text: "Забыли пароль?"
                font.pixelSize: 11
                color: "#3498db"
                opacity: 0.9

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (typeof showError === "function") {
                            showError("Функция восстановления пароля временно недоступна");
                        }
                    }
                }
            }

            Text {
                text: "Регистрация"
                font.pixelSize: 11
                color: "#3498db"
                opacity: 0.9

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (typeof showError === "function") {
                            showError("Регистрация новых пользователей временно отключена");
                        }
                    }
                }
            }
        }
    }

    property alias loginField: loginField
    property alias passwordField: passwordField
    property alias loginButton: loginButton
}
