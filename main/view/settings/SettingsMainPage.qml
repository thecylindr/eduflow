import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: mainPage
    color: "transparent"

    signal settingSelected(string setting)
    signal logoutRequested()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 0

        Text {
            text: "Управление настройками"
            font.pixelSize: 14
            color: "#6c757d"
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 20
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 1

            // Profile setting
            Rectangle {
                Layout.fillWidth: true
                height: 60
                color: profileMouseArea.containsMouse ? "#f0f8ff" : "#ffffff"
                radius: 6
                border.color: profileMouseArea.containsMouse ? "#2196f3" : "transparent"
                border.width: 1

                Row {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    Rectangle {
                        width: 36
                        height: 36
                        radius: 6
                        color: "#e3f2fd"
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            anchors.centerIn: parent
                            text: "👤"
                            font.pixelSize: 14
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        width: parent.width - 100

                        Text {
                            text: "Профиль пользователя"
                            font.pixelSize: 13
                            font.bold: true
                            color: "#2c3e50"
                            elide: Text.ElideRight
                            width: parent.width
                        }

                        Text {
                            text: "Личная информация и контактные данные"
                            font.pixelSize: 11
                            color: "#6c757d"
                            elide: Text.ElideRight
                            width: parent.width
                        }
                    }

                    Text {
                        text: "›"
                        font.pixelSize: 16
                        color: "#6c757d"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: profileMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: settingSelected("profile")
                }
            }

            // Security setting
            Rectangle {
                Layout.fillWidth: true
                height: 60
                color: securityMouseArea.containsMouse ? "#fffbf0" : "#ffffff"
                radius: 6
                border.color: securityMouseArea.containsMouse ? "#ffc107" : "transparent"
                border.width: 1

                Row {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    Rectangle {
                        width: 36
                        height: 36
                        radius: 6
                        color: "#fff3cd"
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            anchors.centerIn: parent
                            text: "🔐"
                            font.pixelSize: 14
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        width: parent.width - 100

                        Text {
                            text: "Безопасность"
                            font.pixelSize: 13
                            font.bold: true
                            color: "#2c3e50"
                            elide: Text.ElideRight
                            width: parent.width
                        }

                        Text {
                            text: "Смена пароля и настройки безопасности"
                            font.pixelSize: 11
                            color: "#6c757d"
                            elide: Text.ElideRight
                            width: parent.width
                        }
                    }

                    Text {
                        text: "›"
                        font.pixelSize: 16
                        color: "#6c757d"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: securityMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: settingSelected("security")
                }
            }

            // Sessions setting
            Rectangle {
                Layout.fillWidth: true
                height: 60
                color: sessionsMouseArea.containsMouse ? "#f0fff0" : "#ffffff"
                radius: 6
                border.color: sessionsMouseArea.containsMouse ? "#4caf50" : "transparent"
                border.width: 1

                Row {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    Rectangle {
                        width: 36
                        height: 36
                        radius: 6
                        color: "#e8f5e8"
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            anchors.centerIn: parent
                            text: "📱"
                            font.pixelSize: 14
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        width: parent.width - 100

                        Text {
                            text: "Активные сессии"
                            font.pixelSize: 13
                            font.bold: true
                            color: "#2c3e50"
                            elide: Text.ElideRight
                            width: parent.width
                        }

                        Text {
                            text: "Управление устройствами и сессиями"
                            font.pixelSize: 11
                            color: "#6c757d"
                            elide: Text.ElideRight
                            width: parent.width
                        }
                    }

                    Text {
                        text: "›"
                        font.pixelSize: 16
                        color: "#6c757d"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: sessionsMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: settingSelected("sessions")
                }
            }

            // Server setting
            Rectangle {
                Layout.fillWidth: true
                height: 60
                color: serverMouseArea.containsMouse ? "#f0f8ff" : "#ffffff"
                radius: 6
                border.color: serverMouseArea.containsMouse ? "#2196f3" : "transparent"
                border.width: 1

                Row {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    Rectangle {
                        width: 36
                        height: 36
                        radius: 6
                        color: "#e3f2fd"
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            anchors.centerIn: parent
                            text: "🌐"
                            font.pixelSize: 14
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        width: parent.width - 100

                        Text {
                            text: "Настройки сервера"
                            font.pixelSize: 13
                            font.bold: true
                            color: "#2c3e50"
                            elide: Text.ElideRight
                            width: parent.width
                        }

                        Text {
                            text: "Информация о подключении и статус сервера"
                            font.pixelSize: 11
                            color: "#6c757d"
                            elide: Text.ElideRight
                            width: parent.width
                        }
                    }

                    Text {
                        text: "›"
                        font.pixelSize: 16
                        color: "#6c757d"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: serverMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: settingSelected("server")
                }
            }

            // About setting
            Rectangle {
                Layout.fillWidth: true
                height: 60
                color: aboutMouseArea.containsMouse ? "#f0f8ff" : "#ffffff"
                radius: 6
                border.color: aboutMouseArea.containsMouse ? "#2196f3" : "transparent"
                border.width: 1

                Row {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    Rectangle {
                        width: 36
                        height: 36
                        radius: 6
                        color: "#e8f5e8"
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            anchors.centerIn: parent
                            text: "ℹ️"
                            font.pixelSize: 14
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        width: parent.width - 100

                        Text {
                            text: "О программе"
                            font.pixelSize: 13
                            font.bold: true
                            color: "#2c3e50"
                            elide: Text.ElideRight
                            width: parent.width
                        }

                        Text {
                            text: "Информация о версии и проекте"
                            font.pixelSize: 11
                            color: "#6c757d"
                            elide: Text.ElideRight
                            width: parent.width
                        }
                    }

                    Text {
                        text: "›"
                        font.pixelSize: 16
                        color: "#6c757d"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: aboutMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: settingSelected("about")
                }
            }
        }

        Item { Layout.fillHeight: true }

        // Logout button
        Rectangle {
            Layout.fillWidth: true
            height: 50
            radius: 6
            color: logoutMouseArea.containsMouse ? "#c0392b" : "#e74c3c"

            Row {
                anchors.centerIn: parent
                spacing: 8

                Text {
                    text: "🚪"
                    font.pixelSize: 14
                    color: "white"
                }

                Text {
                    text: "Выйти из системы"
                    color: "white"
                    font.pixelSize: 13
                    font.bold: true
                }
            }

            MouseArea {
                id: logoutMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: logoutRequested()
            }
        }
    }
}
