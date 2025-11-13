import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: profilePage
    color: "transparent"

    property alias userLogin: profilePage.userLoginInternal
    property alias userFirstName: profilePage.userFirstNameInternal
    property alias userLastName: profilePage.userLastNameInternal
    property alias userMiddleName: profilePage.userMiddleNameInternal
    property alias userEmail: profilePage.userEmailInternal
    property alias userPhoneNumber: profilePage.userPhoneNumberInternal

    property alias editFirstName: profilePage.editFirstNameInternal
    property alias editLastName: profilePage.editLastNameInternal
    property alias editMiddleName: profilePage.editMiddleNameInternal
    property alias editEmail: profilePage.editEmailInternal
    property alias editPhoneNumber: profilePage.editPhoneNumberInternal

    property string userLoginInternal: ""
    property string userFirstNameInternal: ""
    property string userLastNameInternal: ""
    property string userMiddleNameInternal: ""
    property string userEmailInternal: ""
    property string userPhoneNumberInternal: ""

    property string editFirstNameInternal: ""
    property string editLastNameInternal: ""
    property string editMiddleNameInternal: ""
    property string editEmailInternal: ""
    property string editPhoneNumberInternal: ""

    signal fieldChanged(string field, string value)
    signal saveRequested()

    ScrollView {
        anchors.fill: parent
        anchors.margins: 10
        clip: true

        ColumnLayout {
            width: parent.width
            spacing: 10

            Rectangle {
                Layout.fillWidth: true
                height: 220
                radius: 16
                color: "#ffffff"
                border.color: "#e0e0e0"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 16

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16

                        Rectangle {
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 80
                            radius: 40
                            color: "transparent"
                            border.color: "#3498db"
                            border.width: 3

                            Rectangle {
                                width: 70
                                height: 70
                                radius: 35
                                anchors.centerIn: parent
                                color: "#e3f2fd"

                                Image {
                                    anchors.centerIn: parent
                                    source: "qrc:/icons/profile.png"
                                    sourceSize: Qt.size(32, 32)
                                    fillMode: Image.PreserveAspectFit
                                    mipmap: true
                                    antialiasing: true
                                }
                            }
                        }

                        ColumnLayout {
                            spacing: 6

                            Text {
                                text: "@" + userLoginInternal || "???"
                                font.pixelSize: 20
                                font.bold: true
                                color: "#2c3e50"
                            }

                            Text {
                                text: [userLastNameInternal, userFirstNameInternal, userMiddleNameInternal]
                                      .filter(Boolean).join(" ") || "Имя не указано"
                                font.pixelSize: 16
                                color: "#6c757d"
                            }

                            Rectangle {
                                width: 140
                                height: 24
                                radius: 12
                                color: "#e3f2fd"

                                Row {
                                    anchors.centerIn: parent
                                    spacing: 4
                                    Image {
                                        source: "qrc:/icons/user.png"
                                        sourceSize: Qt.size(10, 10)
                                        fillMode: Image.PreserveAspectFit
                                        mipmap: true
                                        antialiasing: true
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: "Аккаунт пользователя"
                                        font.pixelSize: 10
                                        color: "#3498db"
                                        font.bold: true
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        columnSpacing: 20
                        rowSpacing: 12

                        RowLayout {
                            spacing: 8
                            Layout.fillWidth: true

                            Rectangle {
                                width: 30
                                height: 30
                                radius: 15
                                color: "#e3f2fd"

                                Image {
                                    anchors.centerIn: parent
                                    source: "qrc:/icons/email.png"
                                    sourceSize: Qt.size(14, 14)
                                    fillMode: Image.PreserveAspectFit
                                    mipmap: true
                                    antialiasing: true
                                }
                            }

                            ColumnLayout {
                                spacing: 2
                                Layout.fillWidth: true

                                Text {
                                    text: "Email"
                                    font.pixelSize: 12
                                    color: "#6c757d"
                                }

                                Text {
                                    text: userEmailInternal || "Не указан"
                                    font.pixelSize: 14
                                    color: userEmailInternal ? "#2c3e50" : "#95a5a6"
                                    font.bold: !!userEmailInternal
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                            }
                        }

                        RowLayout {
                            spacing: 8
                            Layout.fillWidth: true

                            Rectangle {
                                width: 30
                                height: 30
                                radius: 15
                                color: "#e8f5e8"

                                Image {
                                    anchors.centerIn: parent
                                    source: "qrc:/icons/phone.png"
                                    sourceSize: Qt.size(14, 14)
                                    fillMode: Image.PreserveAspectFit
                                    mipmap: true
                                    antialiasing: true
                                }
                            }

                            ColumnLayout {
                                spacing: 2
                                Layout.fillWidth: true

                                Text {
                                    text: "Телефон"
                                    font.pixelSize: 12
                                    color: "#6c757d"
                                }

                                Text {
                                    text: userPhoneNumberInternal || "Не указан"
                                    font.pixelSize: 14
                                    color: userPhoneNumberInternal ? "#2c3e50" : "#95a5a6"
                                    font.bold: !!userPhoneNumberInternal
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 600
                radius: 16
                color: "#ffffff"
                border.color: "#e0e0e0"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 20

                    Row {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 8

                        Image {
                            source: "qrc:/icons/edit.png"
                            sourceSize: Qt.size(18, 18)
                            fillMode: Image.PreserveAspectFit
                            mipmap: true
                            antialiasing: true
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "Редактирование профиля"
                            font.pixelSize: 18
                            font.bold: true
                            color: "#2c3e50"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 16

                        ColumnLayout {
                            spacing: 6
                            Layout.fillWidth: true

                            Text {
                                text: "Фамилия"
                                font.pixelSize: 14
                                color: "#2c3e50"
                                font.bold: true
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 44
                                radius: 8
                                border.color: lastNameField.activeFocus ? "#3498db" : "#e0e0e0"
                                border.width: lastNameField.activeFocus ? 2 : 1
                                color: "#ffffff"

                                TextInput {
                                    id: lastNameField
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    verticalAlignment: TextInput.AlignVCenter
                                    text: profilePage.editLastNameInternal
                                    font.pixelSize: 14
                                    selectByMouse: true

                                    onTextChanged: {
                                        profilePage.editLastNameInternal = text
                                        fieldChanged("lastName", text)
                                    }
                                }

                                Text {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    verticalAlignment: Text.AlignVCenter
                                    text: "Введите фамилию"
                                    color: "#a0a0a0"
                                    visible: !lastNameField.text && !lastNameField.activeFocus
                                    font.pixelSize: 14
                                }
                            }
                        }

                        ColumnLayout {
                            spacing: 6
                            Layout.fillWidth: true

                            Text {
                                text: "Имя"
                                font.pixelSize: 14
                                color: "#2c3e50"
                                font.bold: true
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 44
                                radius: 8
                                border.color: firstNameField.activeFocus ? "#3498db" : "#e0e0e0"
                                border.width: firstNameField.activeFocus ? 2 : 1
                                color: "#ffffff"

                                TextInput {
                                    id: firstNameField
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    verticalAlignment: TextInput.AlignVCenter
                                    text: profilePage.editFirstNameInternal
                                    font.pixelSize: 14
                                    selectByMouse: true

                                    onTextChanged: {
                                        profilePage.editFirstNameInternal = text
                                        fieldChanged("firstName", text)
                                    }
                                }

                                Text {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    verticalAlignment: Text.AlignVCenter
                                    text: "Введите имя"
                                    color: "#a0a0a0"
                                    visible: !firstNameField.text && !firstNameField.activeFocus
                                    font.pixelSize: 14
                                }
                            }
                        }

                        ColumnLayout {
                            spacing: 6
                            Layout.fillWidth: true

                            Text {
                                text: "Отчество"
                                font.pixelSize: 14
                                color: "#2c3e50"
                                font.bold: true
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 44
                                radius: 8
                                border.color: middleNameField.activeFocus ? "#3498db" : "#e0e0e0"
                                border.width: middleNameField.activeFocus ? 2 : 1
                                color: "#ffffff"

                                TextInput {
                                    id: middleNameField
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    verticalAlignment: TextInput.AlignVCenter
                                    text: profilePage.editMiddleNameInternal
                                    font.pixelSize: 14
                                    selectByMouse: true

                                    onTextChanged: {
                                        profilePage.editMiddleNameInternal = text
                                        fieldChanged("middleName", text)
                                    }
                                }

                                Text {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    verticalAlignment: Text.AlignVCenter
                                    text: "Введите отчество"
                                    color: "#a0a0a0"
                                    visible: !middleNameField.text && !middleNameField.activeFocus
                                    font.pixelSize: 14
                                }
                            }
                        }

                        ColumnLayout {
                            spacing: 6
                            Layout.fillWidth: true

                            Text {
                                text: "Email"
                                font.pixelSize: 14
                                color: "#2c3e50"
                                font.bold: true
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 44
                                radius: 8
                                border.color: emailField.activeFocus ? "#3498db" : "#e0e0e0"
                                border.width: emailField.activeFocus ? 2 : 1
                                color: "#ffffff"

                                TextInput {
                                    id: emailField
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    verticalAlignment: TextInput.AlignVCenter
                                    text: profilePage.editEmailInternal
                                    font.pixelSize: 14
                                    selectByMouse: true

                                    onTextChanged: {
                                        profilePage.editEmailInternal = text
                                        fieldChanged("email", text)
                                    }
                                }

                                Text {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    verticalAlignment: Text.AlignVCenter
                                    text: "Введите email"
                                    color: "#a0a0a0"
                                    visible: !emailField.text && !emailField.activeFocus
                                    font.pixelSize: 14
                                }
                            }
                        }

                        ColumnLayout {
                            spacing: 6
                            Layout.fillWidth: true

                            Text {
                                text: "Телефон"
                                font.pixelSize: 14
                                color: "#2c3e50"
                                font.bold: true
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 44
                                radius: 8
                                border.color: phoneField.activeFocus ? "#3498db" : "#e0e0e0"
                                border.width: phoneField.activeFocus ? 2 : 1
                                color: "#ffffff"

                                TextInput {
                                    id: phoneField
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    verticalAlignment: TextInput.AlignVCenter
                                    text: profilePage.editPhoneNumberInternal
                                    font.pixelSize: 14
                                    selectByMouse: true

                                    onTextChanged: {
                                        profilePage.editPhoneNumberInternal = text
                                        fieldChanged("phoneNumber", text)
                                    }
                                }

                                Text {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    verticalAlignment: Text.AlignVCenter
                                    text: "Введите телефон"
                                    color: "#a0a0a0"
                                    visible: !phoneField.text && !phoneField.activeFocus
                                    font.pixelSize: 14
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
                            color: saveMouseArea.containsMouse ? "#2980b9" : "#3498db"

                            Row {
                                anchors.centerIn: parent
                                spacing: 8

                                Image {
                                    source: "qrc:/icons/save.png"
                                    sourceSize: Qt.size(16, 16)
                                    fillMode: Image.PreserveAspectFit
                                    mipmap: true
                                    antialiasing: true
                                }

                                Text {
                                    text: "Сохранить изменения"
                                    color: "white"
                                    font.pixelSize: 14
                                    font.bold: true
                                }
                            }

                            MouseArea {
                                id: saveMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: saveRequested()
                            }
                        }
                    }
                }
            }
        }
    }
}
