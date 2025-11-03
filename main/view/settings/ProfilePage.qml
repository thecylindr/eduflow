import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: profilePage
    color: "transparent"

    // Делаем свойства публичными для внешнего доступа
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

    // Внутренние свойства
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
        anchors.margins: 20
        clip: true

        ColumnLayout {
            width: parent.width
            spacing: 20

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
                            color: "#e3f2fd"

                            Text {
                                anchors.centerIn: parent
                                text: "👤"
                                font.pixelSize: 32
                            }
                        }

                        ColumnLayout {
                            spacing: 4

                            Text {
                                text: userLoginInternal || "Гость"
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

                            Text {
                                text: "👤 Аккаунт пользователя"
                                font.pixelSize: 12
                                color: "#3498db"
                                font.bold: true
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

                            Text {
                                text: "📧"
                                font.pixelSize: 14
                                color: "#6c757d"
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

                            Text {
                                text: "📱"
                                font.pixelSize: 14
                                color: "#6c757d"
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
                Layout.minimumHeight: 500
                radius: 16
                color: "#ffffff"
                border.color: "#e0e0e0"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 20

                    Text {
                        text: "✏️ Редактирование профиля"
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
                                text: "Фамилия"
                                font.pixelSize: 14
                                color: "#2c3e50"
                                font.bold: true
                            }

                            TextField {
                                Layout.fillWidth: true
                                height: 44
                                text: profilePage.editLastNameInternal
                                font.pixelSize: 14
                                placeholderText: "Введите фамилию"
                                placeholderTextColor: "#95a5a6"

                                background: Rectangle {
                                    radius: 8
                                    border.color: parent.activeFocus ? "#3498db" : "#e0e0e0"
                                    border.width: parent.activeFocus ? 2 : 1
                                    color: "#ffffff"
                                }

                                onTextChanged: {
                                    profilePage.editLastNameInternal = text
                                    fieldChanged("lastName", text)
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

                            TextField {
                                Layout.fillWidth: true
                                height: 44
                                text: profilePage.editFirstNameInternal
                                font.pixelSize: 14
                                placeholderText: "Введите имя"
                                placeholderTextColor: "#95a5a6"

                                background: Rectangle {
                                    radius: 8
                                    border.color: parent.activeFocus ? "#3498db" : "#e0e0e0"
                                    border.width: parent.activeFocus ? 2 : 1
                                    color: "#ffffff"
                                }

                                onTextChanged: {
                                    profilePage.editFirstNameInternal = text
                                    fieldChanged("firstName", text)
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

                            TextField {
                                Layout.fillWidth: true
                                height: 44
                                text: profilePage.editMiddleNameInternal
                                font.pixelSize: 14
                                placeholderText: "Введите отчество"
                                placeholderTextColor: "#95a5a6"

                                background: Rectangle {
                                    radius: 8
                                    border.color: parent.activeFocus ? "#3498db" : "#e0e0e0"
                                    border.width: parent.activeFocus ? 2 : 1
                                    color: "#ffffff"
                                }

                                onTextChanged: {
                                    profilePage.editMiddleNameInternal = text
                                    fieldChanged("middleName", text)
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

                            TextField {
                                Layout.fillWidth: true
                                height: 44
                                text: profilePage.editEmailInternal
                                font.pixelSize: 14
                                placeholderText: "Введите email"
                                placeholderTextColor: "#95a5a6"

                                background: Rectangle {
                                    radius: 8
                                    border.color: parent.activeFocus ? "#3498db" : "#e0e0e0"
                                    border.width: parent.activeFocus ? 2 : 1
                                    color: "#ffffff"
                                }

                                onTextChanged: {
                                    profilePage.editEmailInternal = text
                                    fieldChanged("email", text)
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

                            TextField {
                                Layout.fillWidth: true
                                height: 44
                                text: profilePage.editPhoneNumberInternal
                                font.pixelSize: 14
                                placeholderText: "Введите телефон"
                                placeholderTextColor: "#95a5a6"

                                background: Rectangle {
                                    radius: 8
                                    border.color: parent.activeFocus ? "#3498db" : "#e0e0e0"
                                    border.width: parent.activeFocus ? 2 : 1
                                    color: "#ffffff"
                                }

                                onTextChanged: {
                                    profilePage.editPhoneNumberInternal = text
                                    fieldChanged("phoneNumber", text)
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 200
                        Layout.preferredHeight: 48
                        Layout.alignment: Qt.AlignHCenter
                        radius: 10
                        color: saveMouseArea.containsMouse ? "#2980b9" : "#3498db"

                        Row {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                text: "💾"
                                font.pixelSize: 16
                                color: "white"
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
