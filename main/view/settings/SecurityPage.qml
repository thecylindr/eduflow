import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: securityPage
    color: "transparent"

    property string currentPassword: ""
    property string newPassword: ""
    property string confirmPassword: ""

    signal changePasswordRequested()

    ScrollView {
        anchors.fill: parent
        anchors.margins: 10
        clip: true

        ColumnLayout {
            width: parent.width
            spacing: 10

            Rectangle {
                Layout.fillWidth: true
                height: 550
                radius: 16
                color: "#ffffff"
                border.color: "#e0e0e0"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 20

                    Text {
                        text: "🔐 Безопасность"
                        font.pixelSize: 18
                        font.bold: true
                        color: "#2c3e50"
                        Layout.alignment: Qt.AlignHCenter
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 16

                        ColumnLayout {
                            spacing: 6
                            Layout.fillWidth: true

                            Text {
                                text: "Текущий пароль:"
                                font.pixelSize: 14
                                color: "#2c3e50"
                                font.bold: true
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 44
                                    radius: 8
                                    border.color: currentPasswordField.activeFocus ? "#3498db" : "#e0e0e0"
                                    border.width: currentPasswordField.activeFocus ? 2 : 1
                                    color: "#ffffff"

                                    TextInput {
                                        id: currentPasswordField
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        verticalAlignment: TextInput.AlignVCenter
                                        echoMode: showCurrentPasswordButton.checked ? TextInput.Normal : TextInput.Password
                                        text: securityPage.currentPassword
                                        font.pixelSize: 14
                                        selectByMouse: true

                                        onTextChanged: securityPage.currentPassword = text
                                    }

                                    Text {
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        verticalAlignment: Text.AlignVCenter
                                        text: "Введите текущий пароль"
                                        color: "#a0a0a0"
                                        visible: !currentPasswordField.text && !currentPasswordField.activeFocus
                                        font.pixelSize: 14
                                    }
                                }

                                Rectangle {
                                    id: showCurrentPasswordButton
                                    width: 36
                                    height: 36
                                    radius: 8
                                    border.color: showCurrentPasswordMouseArea.containsPress ? "#3498db" : "#d0d0d0"
                                    border.width: 1
                                    color: showCurrentPasswordButton.checked ? "#3498db" : "transparent"

                                    property bool checked: false

                                    Text {
                                        anchors.centerIn: parent
                                        text: "👁"
                                        font.pixelSize: 16
                                        color: showCurrentPasswordButton.checked ? "white" : "#7f8c8d"
                                    }

                                    Rectangle {
                                        visible: !showCurrentPasswordButton.checked
                                        anchors.centerIn: parent
                                        width: 20
                                        height: 2
                                        rotation: 45
                                        color: "#7f8c8d"
                                    }

                                    MouseArea {
                                        id: showCurrentPasswordMouseArea
                                        anchors.fill: parent
                                        onClicked: showCurrentPasswordButton.checked = !showCurrentPasswordButton.checked
                                    }
                                }
                            }
                        }

                        ColumnLayout {
                            spacing: 6
                            Layout.fillWidth: true

                            Text {
                                text: "Новый пароль:"
                                font.pixelSize: 14
                                color: "#2c3e50"
                                font.bold: true
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 44
                                    radius: 8
                                    border.color: newPasswordField.activeFocus ? "#3498db" : "#e0e0e0"
                                    border.width: newPasswordField.activeFocus ? 2 : 1
                                    color: "#ffffff"

                                    TextInput {
                                        id: newPasswordField
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        verticalAlignment: TextInput.AlignVCenter
                                        echoMode: showNewPasswordButton.checked ? TextInput.Normal : TextInput.Password
                                        text: securityPage.newPassword
                                        font.pixelSize: 14
                                        selectByMouse: true

                                        onTextChanged: securityPage.newPassword = text
                                    }

                                    Text {
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        verticalAlignment: Text.AlignVCenter
                                        text: "Введите новый пароль"
                                        color: "#a0a0a0"
                                        visible: !newPasswordField.text && !newPasswordField.activeFocus
                                        font.pixelSize: 14
                                    }
                                }

                                Rectangle {
                                    id: showNewPasswordButton
                                    width: 36
                                    height: 36
                                    radius: 8
                                    border.color: showNewPasswordMouseArea.containsPress ? "#3498db" : "#d0d0d0"
                                    border.width: 1
                                    color: showNewPasswordButton.checked ? "#3498db" : "transparent"

                                    property bool checked: false

                                    Text {
                                        anchors.centerIn: parent
                                        text: "👁"
                                        font.pixelSize: 16
                                        color: showNewPasswordButton.checked ? "white" : "#7f8c8d"
                                    }

                                    Rectangle {
                                        visible: !showNewPasswordButton.checked
                                        anchors.centerIn: parent
                                        width: 20
                                        height: 2
                                        rotation: 45
                                        color: "#7f8c8d"
                                    }

                                    MouseArea {
                                        id: showNewPasswordMouseArea
                                        anchors.fill: parent
                                        onClicked: showNewPasswordButton.checked = !showNewPasswordButton.checked
                                    }
                                }
                            }
                        }

                        ColumnLayout {
                            spacing: 6
                            Layout.fillWidth: true

                            Text {
                                text: "Подтверждение пароля:"
                                font.pixelSize: 14
                                color: "#2c3e50"
                                font.bold: true
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 44
                                    radius: 8
                                    border.color: confirmPasswordField.activeFocus ? "#3498db" : "#e0e0e0"
                                    border.width: confirmPasswordField.activeFocus ? 2 : 1
                                    color: "#ffffff"

                                    TextInput {
                                        id: confirmPasswordField
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        verticalAlignment: TextInput.AlignVCenter
                                        echoMode: showConfirmPasswordButton.checked ? TextInput.Normal : TextInput.Password
                                        text: securityPage.confirmPassword
                                        font.pixelSize: 14
                                        selectByMouse: true

                                        onTextChanged: securityPage.confirmPassword = text
                                    }

                                    Text {
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        verticalAlignment: Text.AlignVCenter
                                        text: "Повторите новый пароль"
                                        color: "#a0a0a0"
                                        visible: !confirmPasswordField.text && !confirmPasswordField.activeFocus
                                        font.pixelSize: 14
                                    }
                                }

                                Rectangle {
                                    id: showConfirmPasswordButton
                                    width: 36
                                    height: 36
                                    radius: 8
                                    border.color: showConfirmPasswordMouseArea.containsPress ? "#3498db" : "#d0d0d0"
                                    border.width: 1
                                    color: showConfirmPasswordButton.checked ? "#3498db" : "transparent"

                                    property bool checked: false

                                    Text {
                                        anchors.centerIn: parent
                                        text: "👁"
                                        font.pixelSize: 16
                                        color: showConfirmPasswordButton.checked ? "white" : "#7f8c8d"
                                    }

                                    Rectangle {
                                        visible: !showConfirmPasswordButton.checked
                                        anchors.centerIn: parent
                                        width: 20
                                        height: 2
                                        rotation: 45
                                        color: "#7f8c8d"
                                    }

                                    MouseArea {
                                        id: showConfirmPasswordMouseArea
                                        anchors.fill: parent
                                        onClicked: showConfirmPasswordButton.checked = !showConfirmPasswordButton.checked
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 100
                        radius: 8
                        color: "#f8f9fa"
                        border.color: "#e9ecef"
                        border.width: 1

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8

                            Text {
                                text: "Требования к паролю:"
                                font.pixelSize: 12
                                font.bold: true
                                color: "#6c757d"
                            }

                            Row {
                                spacing: 8

                                Text {
                                    text: securityPage.newPassword.length >= 6 ? "✅" : "❌"
                                    font.pixelSize: 10
                                }

                                Text {
                                    text: "Не менее 6 символов"
                                    font.pixelSize: 11
                                    color: securityPage.newPassword.length >= 6 ? "#27ae60" : "#e74c3c"
                                }
                            }

                            Row {
                                spacing: 8

                                Text {
                                    text: (securityPage.newPassword === securityPage.confirmPassword && securityPage.newPassword.length > 0) ? "✅" : "❌"
                                    font.pixelSize: 10
                                }

                                Text {
                                    text: "Пароли совпадают"
                                    font.pixelSize: 11
                                    color: (securityPage.newPassword === securityPage.confirmPassword && securityPage.newPassword.length > 0) ? "#27ae60" : "#e74c3c"
                                }
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 48

                        Rectangle {
                            width: 200
                            height: 48
                            radius: 10
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: changeMouseArea.containsMouse ? "#c0392b" : "#e74c3c"
                            opacity: (securityPage.newPassword.length >= 6 && securityPage.newPassword === securityPage.confirmPassword && securityPage.currentPassword.length > 0) ? 1 : 0.6

                            Row {
                                anchors.centerIn: parent
                                spacing: 8

                                Text {
                                    text: "🔄"
                                    font.pixelSize: 16
                                    color: "white"
                                }

                                Text {
                                    text: "Сменить пароль"
                                    color: "white"
                                    font.pixelSize: 14
                                    font.bold: true
                                }
                            }

                            MouseArea {
                                id: changeMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                enabled: securityPage.newPassword.length >= 6 && securityPage.newPassword === securityPage.confirmPassword && securityPage.currentPassword.length > 0
                                onClicked: changePasswordRequested()
                            }
                        }
                    }
                }
            }
        }
    }
}
