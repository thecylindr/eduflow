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
        anchors.margins: 20
        clip: true

        ColumnLayout {
            width: parent.width
            spacing: 20

            Rectangle {
                Layout.fillWidth: true
                height: 450
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

                            TextField {
                                Layout.fillWidth: true
                                height: 44
                                echoMode: TextInput.Password
                                text: securityPage.currentPassword
                                font.pixelSize: 14
                                placeholderText: "Введите текущий пароль"
                                placeholderTextColor: "#95a5a6"

                                background: Rectangle {
                                    radius: 8
                                    border.color: parent.activeFocus ? "#3498db" : "#e0e0e0"
                                    border.width: parent.activeFocus ? 2 : 1
                                    color: "#ffffff"
                                }

                                onTextChanged: securityPage.currentPassword = text
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

                            TextField {
                                Layout.fillWidth: true
                                height: 44
                                echoMode: TextInput.Password
                                text: securityPage.newPassword
                                font.pixelSize: 14
                                placeholderText: "Введите новый пароль"
                                placeholderTextColor: "#95a5a6"

                                background: Rectangle {
                                    radius: 8
                                    border.color: parent.activeFocus ? "#3498db" : "#e0e0e0"
                                    border.width: parent.activeFocus ? 2 : 1
                                    color: "#ffffff"
                                }

                                onTextChanged: securityPage.newPassword = text
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

                            TextField {
                                Layout.fillWidth: true
                                height: 44
                                echoMode: TextInput.Password
                                text: securityPage.confirmPassword
                                font.pixelSize: 14
                                placeholderText: "Повторите новый пароль"
                                placeholderTextColor: "#95a5a6"

                                background: Rectangle {
                                    radius: 8
                                    border.color: parent.activeFocus ? "#3498db" : "#e0e0e0"
                                    border.width: parent.activeFocus ? 2 : 1
                                    color: "#ffffff"
                                }

                                onTextChanged: securityPage.confirmPassword = text
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

                    Rectangle {
                        Layout.preferredWidth: 200
                        Layout.preferredHeight: 48
                        Layout.alignment: Qt.AlignHCenter
                        radius: 10
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
