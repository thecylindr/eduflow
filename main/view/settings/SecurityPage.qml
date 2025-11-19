import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15

Rectangle {
    id: securityPage
    color: "transparent"
    property bool isMobile: false

    property string currentPassword: ""
    property string newPassword: ""
    property string confirmPassword: ""

    signal changePasswordRequested()

    ScrollView {
        anchors.fill: parent
        anchors.margins: isMobile ? 5 : 10
        clip: true

        ColumnLayout {
            width: parent.width
            spacing: isMobile ? 8 : 10

            Rectangle {
                Layout.fillWidth: true
                height: isMobile ? 480 : 550
                radius: isMobile ? 12 : 16
                color: "#ffffff"
                border.color: "#e0e0e0"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: isMobile ? 16 : 24
                    spacing: isMobile ? 16 : 20

                    Row {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: isMobile ? 6 : 8

                        Image {
                            source: "qrc:/icons/security.png"
                            sourceSize: Qt.size(isMobile ? 24 : 32, isMobile ? 24 : 32)
                            fillMode: Image.PreserveAspectFit
                            mipmap: true
                            antialiasing: true
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "Безопасность"
                            font.pixelSize: isMobile ? 16 : 18
                            font.bold: true
                            color: "#2c3e50"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: isMobile ? 12 : 16

                        ColumnLayout {
                            spacing: isMobile ? 4 : 6
                            Layout.fillWidth: true

                            Text {
                                text: "Текущий пароль:"
                                font.pixelSize: isMobile ? 13 : 14
                                color: "#2c3e50"
                                font.bold: true
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: isMobile ? 4 : 6

                                Rectangle {
                                    Layout.fillWidth: true
                                    height: isMobile ? 40 : 44
                                    radius: isMobile ? 6 : 8
                                    border.color: currentPasswordField.activeFocus ? "#3498db" : "#e0e0e0"
                                    border.width: currentPasswordField.activeFocus ? 2 : 1
                                    color: "#ffffff"

                                    TextInput {
                                        id: currentPasswordField
                                        anchors.fill: parent
                                        anchors.margins: isMobile ? 6 : 8
                                        verticalAlignment: TextInput.AlignVCenter
                                        echoMode: showCurrentPasswordButton.checked ? TextInput.Normal : TextInput.Password
                                        text: securityPage.currentPassword
                                        font.pixelSize: isMobile ? 13 : 14
                                        selectByMouse: true

                                        onTextChanged: securityPage.currentPassword = text
                                    }

                                    Text {
                                        anchors.fill: parent
                                        anchors.margins: isMobile ? 6 : 8
                                        verticalAlignment: Text.AlignVCenter
                                        text: "Введите текущий пароль"
                                        color: "#a0a0a0"
                                        visible: !currentPasswordField.text && !currentPasswordField.activeFocus
                                        font.pixelSize: isMobile ? 13 : 14
                                    }
                                }

                                Rectangle {
                                    id: showCurrentPasswordButton
                                    width: isMobile ? 32 : 36
                                    height: isMobile ? 32 : 36
                                    radius: isMobile ? 6 : 8
                                    border.color: showCurrentPasswordMouseArea.containsPress ? "#3498db" : "#d0d0d0"
                                    border.width: 1
                                    color: showCurrentPasswordButton.checked ? "#3498db" : "transparent"

                                    property bool checked: false

                                    Image {
                                        anchors.centerIn: parent
                                        source: showCurrentPasswordButton.checked ? "qrc:/icons/eye.png" : "qrc:/icons/eye-off.png"
                                        sourceSize: Qt.size(isMobile ? 14 : 16, isMobile ? 14 : 16)
                                        fillMode: Image.PreserveAspectFit
                                        mipmap: true
                                        antialiasing: true
                                    }

                                    MouseArea {
                                        id: showCurrentPasswordMouseArea
                                        anchors.fill: parent
                                        onClicked: showCurrentPasswordButton.checked = !showCurrentPasswordButton.checked
                                    }
                                }
                            }
                        }

                        // Общий переключатель видимости для нового пароля и подтверждения
                        ColumnLayout {
                            spacing: isMobile ? 4 : 6
                            Layout.fillWidth: true

                            Text {
                                text: "Новый пароль:"
                                font.pixelSize: isMobile ? 13 : 14
                                color: "#2c3e50"
                                font.bold: true
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: isMobile ? 4 : 6

                                Rectangle {
                                    Layout.fillWidth: true
                                    height: isMobile ? 40 : 44
                                    radius: isMobile ? 6 : 8
                                    border.color: newPasswordField.activeFocus ? "#3498db" : "#e0e0e0"
                                    border.width: newPasswordField.activeFocus ? 2 : 1
                                    color: "#ffffff"

                                    TextInput {
                                        id: newPasswordField
                                        anchors.fill: parent
                                        anchors.margins: isMobile ? 6 : 8
                                        verticalAlignment: TextInput.AlignVCenter
                                        echoMode: showNewAndConfirmPasswordButton.checked ? TextInput.Normal : TextInput.Password
                                        text: securityPage.newPassword
                                        font.pixelSize: isMobile ? 13 : 14
                                        selectByMouse: true

                                        onTextChanged: securityPage.newPassword = text
                                    }

                                    Text {
                                        anchors.fill: parent
                                        anchors.margins: isMobile ? 6 : 8
                                        verticalAlignment: Text.AlignVCenter
                                        text: "Введите новый пароль"
                                        color: "#a0a0a0"
                                        visible: !newPasswordField.text && !newPasswordField.activeFocus
                                        font.pixelSize: isMobile ? 13 : 14
                                    }
                                }

                                // Общий переключатель для двух полей
                                Rectangle {
                                    id: showNewAndConfirmPasswordButton
                                    width: isMobile ? 32 : 36
                                    height: isMobile ? 32 : 36
                                    radius: isMobile ? 6 : 8
                                    border.color: showNewAndConfirmPasswordMouseArea.containsPress ? "#3498db" : "#d0d0d0"
                                    border.width: 1
                                    color: showNewAndConfirmPasswordButton.checked ? "#3498db" : "transparent"

                                    property bool checked: false

                                    Image {
                                        anchors.centerIn: parent
                                        source: showNewAndConfirmPasswordButton.checked ? "qrc:/icons/eye.png" : "qrc:/icons/eye-off.png"
                                        sourceSize: Qt.size(isMobile ? 14 : 16, isMobile ? 14 : 16)
                                        fillMode: Image.PreserveAspectFit
                                        mipmap: true
                                        antialiasing: true
                                    }

                                    MouseArea {
                                        id: showNewAndConfirmPasswordMouseArea
                                        anchors.fill: parent
                                        onClicked: showNewAndConfirmPasswordButton.checked = !showNewAndConfirmPasswordButton.checked
                                    }
                                }
                            }
                        }

                        ColumnLayout {
                            spacing: isMobile ? 4 : 6
                            Layout.fillWidth: true

                            Text {
                                text: "Подтверждение пароля:"
                                font.pixelSize: isMobile ? 13 : 14
                                color: "#2c3e50"
                                font.bold: true
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: isMobile ? 40 : 44
                                radius: isMobile ? 6 : 8
                                border.color: confirmPasswordField.activeFocus ? "#3498db" : "#e0e0e0"
                                border.width: confirmPasswordField.activeFocus ? 2 : 1
                                color: "#ffffff"

                                TextInput {
                                    id: confirmPasswordField
                                    anchors.fill: parent
                                    anchors.margins: isMobile ? 6 : 8
                                    verticalAlignment: TextInput.AlignVCenter
                                    echoMode: showNewAndConfirmPasswordButton.checked ? TextInput.Normal : TextInput.Password
                                    text: securityPage.confirmPassword
                                    font.pixelSize: isMobile ? 13 : 14
                                    selectByMouse: true

                                    onTextChanged: securityPage.confirmPassword = text
                                }

                                Text {
                                    anchors.fill: parent
                                    anchors.margins: isMobile ? 6 : 8
                                    verticalAlignment: Text.AlignVCenter
                                    text: "Повторите новый пароль"
                                    color: "#a0a0a0"
                                    visible: !confirmPasswordField.text && !confirmPasswordField.activeFocus
                                    font.pixelSize: isMobile ? 13 : 14
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: isMobile ? 80 : 100
                        radius: isMobile ? 6 : 8
                        color: "#f8f9fa"
                        border.color: "#e9ecef"
                        border.width: 1

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: isMobile ? 8 : 12
                            spacing: isMobile ? 6 : 8

                            Text {
                                text: "Требования к паролю:"
                                font.pixelSize: isMobile ? 11 : 12
                                font.bold: true
                                color: "#6c757d"
                            }

                            Row {
                                spacing: isMobile ? 6 : 8

                                Image {
                                    source: securityPage.newPassword.length >= 6 ? "qrc:/icons/check.png" : "qrc:/icons/cross.png"
                                    sourceSize: Qt.size(isMobile ? 8 : 10, isMobile ? 8 : 10)
                                    fillMode: Image.PreserveAspectFit
                                    mipmap: true
                                    antialiasing: true
                                }

                                Text {
                                    text: "Не менее 6 символов"
                                    font.pixelSize: isMobile ? 10 : 11
                                    color: securityPage.newPassword.length >= 6 ? "#27ae60" : "#e74c3c"
                                }
                            }

                            Row {
                                spacing: isMobile ? 6 : 8

                                Image {
                                    source: (securityPage.newPassword === securityPage.confirmPassword && securityPage.newPassword.length > 0) ? "qrc:/icons/check.png" : "qrc:/icons/cross.png"
                                    sourceSize: Qt.size(isMobile ? 8 : 10, isMobile ? 8 : 10)
                                    fillMode: Image.PreserveAspectFit
                                    mipmap: true
                                    antialiasing: true
                                }

                                Text {
                                    text: "Пароли совпадают"
                                    font.pixelSize: isMobile ? 10 : 11
                                    color: (securityPage.newPassword === securityPage.confirmPassword && securityPage.newPassword.length > 0) ? "#27ae60" : "#e74c3c"
                                }
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: isMobile ? 40 : 48

                        Rectangle {
                            width: isMobile ? 180 : 200
                            height: isMobile ? 40 : 48
                            radius: isMobile ? 8 : 10
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: changeMouseArea.containsMouse ? "#c0392b" : "#e74c3c"
                            opacity: (securityPage.newPassword.length >= 6 && securityPage.newPassword === securityPage.confirmPassword && securityPage.currentPassword.length > 0) ? 1 : 0.6

                            Row {
                                anchors.centerIn: parent
                                spacing: isMobile ? 6 : 8

                                Image {
                                    source: "qrc:/icons/refresh.png"
                                    sourceSize: Qt.size(isMobile ? 16 : 20, isMobile ? 16 : 20)
                                    fillMode: Image.PreserveAspectFit
                                    mipmap: true
                                    antialiasing: true
                                }

                                Text {
                                    text: "Сменить пароль"
                                    color: "white"
                                    font.pixelSize: isMobile ? 12 : 14
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
