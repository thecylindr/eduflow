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
                color: profileMouseArea.containsMouse ? "#e3f2fd" : "#ffffff"
                radius: 6
                border.color: profileMouseArea.containsMouse ? "#2196f3" : "#e0e0e0"
                border.width: 1

                Row {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    Rectangle {
                        width: 36
                        height: 36
                        radius: 6
                        color: profileMouseArea.containsMouse ? "#2196f3" : "#f8f9fa"
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            anchors.centerIn: parent
                            text: "👤"
                            font.pixelSize: 14
                            color: profileMouseArea.containsMouse ? "white" : "#2196f3"
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
                            color: profileMouseArea.containsMouse ? "#2196f3" : "#2c3e50"
                            elide: Text.ElideRight
                            width: parent.width
                        }

                        Text {
                            text: "Личная информация и контактные данные"
                            font.pixelSize: 11
                            color: profileMouseArea.containsMouse ? "#2196f3" : "#6c757d"
                            elide: Text.ElideRight
                            width: parent.width
                        }
                    }

                    Text {
                        text: "›"
                        font.pixelSize: 16
                        color: profileMouseArea.containsMouse ? "#2196f3" : "#6c757d"
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
                color: securityMouseArea.containsMouse ? "#fff3e0" : "#ffffff"
                radius: 6
                border.color: securityMouseArea.containsMouse ? "#ff9800" : "#e0e0e0"
                border.width: 1

                Row {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    Rectangle {
                        width: 36
                        height: 36
                        radius: 6
                        color: securityMouseArea.containsMouse ? "#ff9800" : "#f8f9fa"
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            anchors.centerIn: parent
                            text: "🔐"
                            font.pixelSize: 14
                            color: securityMouseArea.containsMouse ? "white" : "#ff9800"
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
                            color: securityMouseArea.containsMouse ? "#ff9800" : "#2c3e50"
                            elide: Text.ElideRight
                            width: parent.width
                        }

                        Text {
                            text: "Смена пароля и настройки безопасности"
                            font.pixelSize: 11
                            color: securityMouseArea.containsMouse ? "#ff9800" : "#6c757d"
                            elide: Text.ElideRight
                            width: parent.width
                        }
                    }

                    Text {
                        text: "›"
                        font.pixelSize: 16
                        color: securityMouseArea.containsMouse ? "#ff9800" : "#6c757d"
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
                color: sessionsMouseArea.containsMouse ? "#e8f5e8" : "#ffffff"
                radius: 6
                border.color: sessionsMouseArea.containsMouse ? "#4caf50" : "#e0e0e0"
                border.width: 1

                Row {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    Rectangle {
                        width: 36
                        height: 36
                        radius: 6
                        color: sessionsMouseArea.containsMouse ? "#4caf50" : "#f8f9fa"
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            anchors.centerIn: parent
                            text: "📱"
                            font.pixelSize: 14
                            color: sessionsMouseArea.containsMouse ? "white" : "#4caf50"
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
                            color: sessionsMouseArea.containsMouse ? "#4caf50" : "#2c3e50"
                            elide: Text.ElideRight
                            width: parent.width
                        }

                        Text {
                            text: "Управление устройствами и сессиями"
                            font.pixelSize: 11
                            color: sessionsMouseArea.containsMouse ? "#4caf50" : "#6c757d"
                            elide: Text.ElideRight
                            width: parent.width
                        }
                    }

                    Text {
                        text: "›"
                        font.pixelSize: 16
                        color: sessionsMouseArea.containsMouse ? "#4caf50" : "#6c757d"
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
                color: serverMouseArea.containsMouse ? "#f3e5f5" : "#ffffff"
                radius: 6
                border.color: serverMouseArea.containsMouse ? "#9c27b0" : "#e0e0e0"
                border.width: 1

                Row {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    Rectangle {
                        width: 36
                        height: 36
                        radius: 6
                        color: serverMouseArea.containsMouse ? "#9c27b0" : "#f8f9fa"
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            anchors.centerIn: parent
                            text: "🌐"
                            font.pixelSize: 14
                            color: serverMouseArea.containsMouse ? "white" : "#9c27b0"
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
                            color: serverMouseArea.containsMouse ? "#9c27b0" : "#2c3e50"
                            elide: Text.ElideRight
                            width: parent.width
                        }

                        Text {
                            text: "Информация о подключении и статус сервера"
                            font.pixelSize: 11
                            color: serverMouseArea.containsMouse ? "#9c27b0" : "#6c757d"
                            elide: Text.ElideRight
                            width: parent.width
                        }
                    }

                    Text {
                        text: "›"
                        font.pixelSize: 16
                        color: serverMouseArea.containsMouse ? "#9c27b0" : "#6c757d"
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
                color: aboutMouseArea.containsMouse ? "#e1f5fe" : "#ffffff"
                radius: 6
                border.color: aboutMouseArea.containsMouse ? "#03a9f4" : "#e0e0e0"
                border.width: 1

                Row {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    Rectangle {
                        width: 36
                        height: 36
                        radius: 6
                        color: aboutMouseArea.containsMouse ? "#03a9f4" : "#f8f9fa"
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            anchors.centerIn: parent
                            text: "ℹ️"
                            font.pixelSize: 14
                            color: aboutMouseArea.containsMouse ? "white" : "#03a9f4"
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
                            color: aboutMouseArea.containsMouse ? "#03a9f4" : "#2c3e50"
                            elide: Text.ElideRight
                            width: parent.width
                        }

                        Text {
                            text: "Информация о версии и проекте"
                            font.pixelSize: 11
                            color: aboutMouseArea.containsMouse ? "#03a9f4" : "#6c757d"
                            elide: Text.ElideRight
                            width: parent.width
                        }
                    }

                    Text {
                        text: "›"
                        font.pixelSize: 16
                        color: aboutMouseArea.containsMouse ? "#03a9f4" : "#6c757d"
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
