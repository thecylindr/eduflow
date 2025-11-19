import QtQuick
import QtQuick.Layouts 1.15

Rectangle {
    id: mainPage
    color: "transparent"
    property bool isMobile: false

    signal settingSelected(string setting)
    signal logoutRequested()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: isMobile ? 8 : 15
        spacing: 0

        Text {
            text: "Управление настройками"
            font.pixelSize: isMobile ? 12 : 14
            color: "#6c757d"
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: isMobile ? 15 : 20
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 1

            // Profile setting
            Rectangle {
                Layout.fillWidth: true
                height: isMobile ? 50 : 60
                color: profileMouseArea.containsMouse ? "#e3f2fd" : "#ffffff"
                radius: isMobile ? 4 : 6
                border.color: profileMouseArea.containsMouse ? "#2196f3" : "#e0e0e0"
                border.width: 1

                Row {
                    anchors.fill: parent
                    anchors.margins: isMobile ? 8 : 12
                    spacing: isMobile ? 8 : 12

                    Rectangle {
                        width: isMobile ? 30 : 36
                        height: isMobile ? 30 : 36
                        radius: isMobile ? 4 : 6
                        color: profileMouseArea.containsMouse ? "#2196f3" : "#f8f9fa"
                        anchors.verticalCenter: parent.verticalCenter

                        AnimatedImage {
                            anchors.centerIn: parent
                            width: isMobile ? 20 : 24
                            height: isMobile ? 20 : 24
                            source: profileMouseArea.containsMouse ? "qrc:/icons/profile.gif" : "qrc:/icons/profile.png"
                            fillMode: Image.PreserveAspectFit
                            speed: 0.7
                            mipmap: true
                            antialiasing: true
                            playing: profileMouseArea.containsMouse
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: isMobile ? 1 : 2
                        width: parent.width - (isMobile ? 60 : 100)

                        Text {
                            text: "Профиль пользователя"
                            font.pixelSize: isMobile ? 12 : 13
                            font.bold: true
                            color: profileMouseArea.containsMouse ? "#2196f3" : "#2c3e50"
                            elide: Text.ElideRight
                            width: parent.width
                        }

                        Text {
                            text: "Личная информация и контактные данные"
                            font.pixelSize: isMobile ? 10 : 11
                            color: profileMouseArea.containsMouse ? "#2196f3" : "#6c757d"
                            elide: Text.ElideRight
                            width: parent.width
                        }
                    }

                    Text {
                        text: "›"
                        font.pixelSize: isMobile ? 14 : 16
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
                height: isMobile ? 50 : 60
                color: securityMouseArea.containsMouse ? "#e8f5e8" : "#ffffff"
                radius: isMobile ? 4 : 6
                border.color: securityMouseArea.containsMouse ? "#4caf50" : "#e0e0e0"
                border.width: 1

                Row {
                    anchors.fill: parent
                    anchors.margins: isMobile ? 8 : 12
                    spacing: isMobile ? 8 : 12

                    Rectangle {
                        width: isMobile ? 30 : 36
                        height: isMobile ? 30 : 36
                        radius: isMobile ? 4 : 6
                        color: securityMouseArea.containsMouse ? "#4caf50" : "#f8f9fa"
                        anchors.verticalCenter: parent.verticalCenter

                        AnimatedImage {
                            anchors.centerIn: parent
                            width: isMobile ? 20 : 24
                            height: isMobile ? 20 : 24
                            source: securityMouseArea.containsMouse ? "qrc:/icons/security.gif" : "qrc:/icons/security.png"
                            fillMode: Image.PreserveAspectFit
                            speed: 0.7
                            mipmap: true
                            antialiasing: true
                            playing: securityMouseArea.containsMouse
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: isMobile ? 1 : 2
                        width: parent.width - (isMobile ? 60 : 100)

                        Text {
                            text: "Безопасность"
                            font.pixelSize: isMobile ? 12 : 13
                            font.bold: true
                            color: securityMouseArea.containsMouse ? "#4caf50" : "#2c3e50"
                            elide: Text.ElideRight
                            width: parent.width
                        }

                        Text {
                            text: "Смена пароля и настройки безопасности"
                            font.pixelSize: isMobile ? 10 : 11
                            color: securityMouseArea.containsMouse ? "#4caf50" : "#6c757d"
                            elide: Text.ElideRight
                            width: parent.width
                        }
                    }

                    Text {
                        text: "›"
                        font.pixelSize: isMobile ? 14 : 16
                        color: securityMouseArea.containsMouse ? "#4caf50" : "#6c757d"
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
                height: isMobile ? 50 : 60
                color: sessionsMouseArea.containsMouse ? "#fff3e0" : "#ffffff"
                radius: isMobile ? 4 : 6
                border.color: sessionsMouseArea.containsMouse ? "#ff9800" : "#e0e0e0"
                border.width: 1

                Row {
                    anchors.fill: parent
                    anchors.margins: isMobile ? 8 : 12
                    spacing: isMobile ? 8 : 12

                    Rectangle {
                        width: isMobile ? 30 : 36
                        height: isMobile ? 30 : 36
                        radius: isMobile ? 4 : 6
                        color: sessionsMouseArea.containsMouse ? "#ff9800" : "#f8f9fa"
                        anchors.verticalCenter: parent.verticalCenter

                        AnimatedImage {
                            anchors.centerIn: parent
                            width: isMobile ? 20 : 24
                            height: isMobile ? 20 : 24
                            source: sessionsMouseArea.containsMouse ? "qrc:/icons/sessions.gif" : "qrc:/icons/sessions.png"
                            fillMode: Image.PreserveAspectFit
                            speed: 0.7
                            mipmap: true
                            antialiasing: true
                            playing: sessionsMouseArea.containsMouse
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: isMobile ? 1 : 2
                        width: parent.width - (isMobile ? 60 : 100)

                        Text {
                            text: "Активные сессии"
                            font.pixelSize: isMobile ? 12 : 13
                            font.bold: true
                            color: sessionsMouseArea.containsMouse ? "#ff9800" : "#2c3e50"
                            elide: Text.ElideRight
                            width: parent.width
                        }

                        Text {
                            text: "Управление устройствами и сессиями"
                            font.pixelSize: isMobile ? 10 : 11
                            color: sessionsMouseArea.containsMouse ? "#ff9800" : "#6c757d"
                            elide: Text.ElideRight
                            width: parent.width
                        }
                    }

                    Text {
                        text: "›"
                        font.pixelSize: isMobile ? 14 : 16
                        color: sessionsMouseArea.containsMouse ? "#ff9800" : "#6c757d"
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
                height: isMobile ? 50 : 60
                color: serverMouseArea.containsMouse ? "#f3e5f5" : "#ffffff"
                radius: isMobile ? 4 : 6
                border.color: serverMouseArea.containsMouse ? "#9c27b0" : "#e0e0e0"
                border.width: 1

                Row {
                    anchors.fill: parent
                    anchors.margins: isMobile ? 8 : 12
                    spacing: isMobile ? 8 : 12

                    Rectangle {
                        width: isMobile ? 30 : 36
                        height: isMobile ? 30 : 36
                        radius: isMobile ? 4 : 6
                        color: serverMouseArea.containsMouse ? "#9c27b0" : "#f8f9fa"
                        anchors.verticalCenter: parent.verticalCenter

                        AnimatedImage {
                            anchors.centerIn: parent
                            width: isMobile ? 20 : 24
                            height: isMobile ? 20 : 24
                            source: serverMouseArea.containsMouse ? "qrc:/icons/server.gif" : "qrc:/icons/server.png"
                            fillMode: Image.PreserveAspectFit
                            speed: 0.7
                            mipmap: true
                            antialiasing: true
                            playing: serverMouseArea.containsMouse
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: isMobile ? 1 : 2
                        width: parent.width - (isMobile ? 60 : 100)

                        Text {
                            text: "Настройки сервера"
                            font.pixelSize: isMobile ? 12 : 13
                            font.bold: true
                            color: serverMouseArea.containsMouse ? "#9c27b0" : "#2c3e50"
                            elide: Text.ElideRight
                            width: parent.width
                        }

                        Text {
                            text: "Информация о подключении и статус сервера"
                            font.pixelSize: isMobile ? 10 : 11
                            color: serverMouseArea.containsMouse ? "#9c27b0" : "#6c757d"
                            elide: Text.ElideRight
                            width: parent.width
                        }
                    }

                    Text {
                        text: "›"
                        font.pixelSize: isMobile ? 14 : 16
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
                height: isMobile ? 50 : 60
                color: aboutMouseArea.containsMouse ? "#e1f5fe" : "#ffffff"
                radius: isMobile ? 4 : 6
                border.color: aboutMouseArea.containsMouse ? "#03a9f4" : "#e0e0e0"
                border.width: 1

                Row {
                    anchors.fill: parent
                    anchors.margins: isMobile ? 8 : 12
                    spacing: isMobile ? 8 : 12

                    Rectangle {
                        width: isMobile ? 30 : 36
                        height: isMobile ? 30 : 36
                        radius: isMobile ? 4 : 6
                        color: aboutMouseArea.containsMouse ? "#03a9f4" : "#f8f9fa"
                        anchors.verticalCenter: parent.verticalCenter

                        Image {
                            anchors.centerIn: parent
                            source: "qrc:/icons/about.png"
                            sourceSize: Qt.size(isMobile ? 24 : 36, isMobile ? 24 : 36)
                            fillMode: Image.PreserveAspectFit
                            mipmap: true
                            antialiasing: true
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: isMobile ? 1 : 2
                        width: parent.width - (isMobile ? 60 : 100)

                        Text {
                            text: "О программе"
                            font.pixelSize: isMobile ? 12 : 13
                            font.bold: true
                            color: aboutMouseArea.containsMouse ? "#03a9f4" : "#2c3e50"
                            elide: Text.ElideRight
                            width: parent.width
                        }

                        Text {
                            text: "Информация о версии и проекте"
                            font.pixelSize: isMobile ? 10 : 11
                            color: aboutMouseArea.containsMouse ? "#03a9f4" : "#6c757d"
                            elide: Text.ElideRight
                            width: parent.width
                        }
                    }

                    Text {
                        text: "›"
                        font.pixelSize: isMobile ? 14 : 16
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
            height: isMobile ? 44 : 50
            radius: isMobile ? 4 : 6
            color: logoutMouseArea.containsMouse ? "#c0392b" : "#e74c3c"

            Row {
                anchors.centerIn: parent
                spacing: isMobile ? 6 : 8

                Image {
                    source: "qrc:/icons/logout.png"
                    sourceSize: Qt.size(isMobile ? 24 : 48, isMobile ? 24 : 48)
                    fillMode: Image.PreserveAspectFit
                    mipmap: true
                    antialiasing: true
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "Выйти из системы"
                    color: "white"
                    font.pixelSize: isMobile ? 12 : 13
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
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
