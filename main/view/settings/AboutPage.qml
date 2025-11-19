import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15

Rectangle {
    id: aboutPage
    color: "transparent"
    property bool isMobile: false

    property string appVersion
    property string appName
    property string organizationName
    property string gitflicUrl
    property string serverGitflicUrl

    ScrollView {
        anchors.fill: parent
        anchors.margins: isMobile ? 5 : 10
        clip: true

        ColumnLayout {
            width: parent.width
            spacing: isMobile ? 1 : 2

            Rectangle {
                Layout.fillWidth: true
                height: isMobile ? 360 : 440
                radius: isMobile ? 12 : 16
                color: "#ffffff"
                border.color: "#e0e0e0"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: isMobile ? 16 : 24
                    spacing: isMobile ? 8 : 10

                    Row {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: isMobile ? 6 : 8

                        Image {
                            source: "qrc:/icons/about.png"
                            sourceSize: Qt.size(isMobile ? 36 : 48, isMobile ? 36 : 48)
                            fillMode: Image.PreserveAspectFit
                            mipmap: true
                            antialiasing: true
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "О программе"
                            font.pixelSize: isMobile ? 16 : 18
                            font.bold: true
                            color: "#2c3e50"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: isMobile ? 12 : 16

                        Rectangle {
                            Layout.fillWidth: true
                            height: isMobile ? 70 : 80
                            radius: isMobile ? 6 : 8
                            color: "#e3f2fd"
                            border.color: "#bbdefb"
                            border.width: 1

                            Row {
                                anchors.fill: parent
                                anchors.margins: isMobile ? 10 : 15
                                spacing: isMobile ? 10 : 15

                                Rectangle {
                                    width: isMobile ? 40 : 50
                                    height: isMobile ? 40 : 50
                                    radius: isMobile ? 8 : 10
                                    color: "#3498db"
                                    anchors.verticalCenter: parent.verticalCenter

                                    Image {
                                        anchors.centerIn: parent
                                        source: "qrc:/icons/app_icon.png"
                                        sourceSize: Qt.size(isMobile ? 28 : 36, isMobile ? 28 : 36)
                                        fillMode: Image.PreserveAspectFit
                                        mipmap: true
                                        antialiasing: true
                                    }
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: isMobile ? 2 : 4

                                    Text {
                                        text: aboutPage.appName
                                        font.pixelSize: isMobile ? 14 : 16
                                        font.bold: true
                                        color: "#2c3e50"
                                    }

                                    Text {
                                        text: "Версия " + aboutPage.appVersion
                                        font.pixelSize: isMobile ? 10 : 12
                                        color: "#6c757d"
                                    }
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: isMobile ? 8 : 12

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: isMobile ? 8 : 10

                                Image {
                                    source: "qrc:/icons/version.png"
                                    sourceSize: Qt.size(isMobile ? 16 : 18, isMobile ? 16 : 18)
                                    fillMode: Image.PreserveAspectFit
                                    mipmap: true
                                    antialiasing: true
                                    Layout.preferredWidth: isMobile ? 18 : 20
                                }

                                Text {
                                    text: "Версия:"
                                    font.pixelSize: isMobile ? 12 : 14
                                    color: "#6c757d"
                                    Layout.preferredWidth: isMobile ? 80 : 140
                                }

                                Text {
                                    text: aboutPage.appVersion
                                    font.pixelSize: isMobile ? 12 : 14
                                    color: "#2c3e50"
                                    font.bold: true
                                    Layout.fillWidth: true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: isMobile ? 8 : 10

                                Image {
                                    source: "qrc:/icons/organization.png"
                                    sourceSize: Qt.size(isMobile ? 16 : 18, isMobile ? 16 : 18)
                                    fillMode: Image.PreserveAspectFit
                                    mipmap: true
                                    antialiasing: true
                                    Layout.preferredWidth: isMobile ? 18 : 20
                                }

                                Text {
                                    text: "Организация:"
                                    font.pixelSize: isMobile ? 12 : 14
                                    color: "#6c757d"
                                    Layout.preferredWidth: isMobile ? 80 : 140
                                }

                                Text {
                                    text: aboutPage.organizationName
                                    font.pixelSize: isMobile ? 12 : 14
                                    color: "#2c3e50"
                                    font.bold: true
                                    Layout.fillWidth: true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: isMobile ? 8 : 10

                                Image {
                                    source: "qrc:/icons/calendar.png"
                                    sourceSize: Qt.size(isMobile ? 16 : 18, isMobile ? 16 : 18)
                                    fillMode: Image.PreserveAspectFit
                                    mipmap: true
                                    antialiasing: true
                                    Layout.preferredWidth: isMobile ? 18 : 20
                                }

                                Text {
                                    text: "Год выпуска:"
                                    font.pixelSize: isMobile ? 12 : 14
                                    color: "#6c757d"
                                    Layout.preferredWidth: isMobile ? 80 : 140
                                }

                                Text {
                                    text: "2025"
                                    font.pixelSize: isMobile ? 12 : 14
                                    color: "#2c3e50"
                                    font.bold: true
                                    Layout.fillWidth: true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: isMobile ? 8 : 10

                                Image {
                                    source: "qrc:/icons/platform.png"
                                    sourceSize: Qt.size(isMobile ? 16 : 18, isMobile ? 16 : 18)
                                    fillMode: Image.PreserveAspectFit
                                    mipmap: true
                                    antialiasing: true
                                    Layout.preferredWidth: isMobile ? 18 : 20
                                }

                                Text {
                                    text: "Платформа:"
                                    font.pixelSize: isMobile ? 12 : 14
                                    color: "#6c757d"
                                    Layout.preferredWidth: isMobile ? 80 : 140
                                }

                                Text {
                                    text: "Qt"
                                    font.pixelSize: isMobile ? 12 : 14
                                    color: "#2c3e50"
                                    font.bold: true
                                    Layout.fillWidth: true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: isMobile ? 8 : 10

                                Image {
                                    source: "qrc:/icons/language.png"
                                    sourceSize: Qt.size(isMobile ? 16 : 18, isMobile ? 16 : 18)
                                    fillMode: Image.PreserveAspectFit
                                    mipmap: true
                                    antialiasing: true
                                    Layout.preferredWidth: isMobile ? 18 : 20
                                }

                                Text {
                                    text: "ЯП:"
                                    font.pixelSize: isMobile ? 12 : 14
                                    color: "#6c757d"
                                    Layout.preferredWidth: isMobile ? 80 : 140
                                }

                                Text {
                                    text: "C++17"
                                    font.pixelSize: isMobile ? 12 : 14
                                    color: "#2c3e50"
                                    font.bold: true
                                    Layout.fillWidth: true
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: isMobile ? 90 : 100
                            radius: isMobile ? 6 : 8
                            color: "#f8f9fa"
                            border.color: "#e9ecef"
                            border.width: 1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: isMobile ? 8 : 12
                                spacing: isMobile ? 6 : 8

                                Text {
                                    text: "Ссылки на проект:"
                                    font.pixelSize: isMobile ? 11 : 12
                                    font.bold: true
                                    color: "#6c757d"
                                }

                                Column {
                                    spacing: isMobile ? 6 : 8

                                    Rectangle {
                                        width: isMobile ? parent.width : 150
                                        height: isMobile ? 32 : 36
                                        radius: isMobile ? 5 : 6
                                        color: clientMouseArea.containsMouse ? "#3498db" : "#e3f2fd"
                                        border.color: clientMouseArea.containsMouse ? "#2980b9" : "#b3e5fc"
                                        border.width: 1

                                        Row {
                                            anchors.centerIn: parent
                                            spacing: isMobile ? 4 : 6

                                            Image {
                                                source: "qrc:/icons/link.png"
                                                sourceSize: Qt.size(isMobile ? 16 : 18, isMobile ? 16 : 18)
                                                fillMode: Image.PreserveAspectFit
                                                mipmap: true
                                                antialiasing: true
                                                anchors.verticalCenter: parent.verticalCenter
                                            }

                                            Text {
                                                text: "Клиентская часть"
                                                color: clientMouseArea.containsMouse ? "white" : "#3498db"
                                                font.pixelSize: isMobile ? 10 : 11
                                                font.bold: true
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }

                                        MouseArea {
                                            id: clientMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: Qt.openUrlExternally(aboutPage.gitflicUrl)
                                        }
                                    }

                                    Rectangle {
                                        width: isMobile ? parent.width : 150
                                        height: isMobile ? 32 : 36
                                        radius: isMobile ? 5 : 6
                                        color: serverMouseArea.containsMouse ? "#27ae60" : "#e8f5e8"
                                        border.color: serverMouseArea.containsMouse ? "#219653" : "#c8e6c9"
                                        border.width: 1

                                        Row {
                                            anchors.centerIn: parent
                                            spacing: isMobile ? 4 : 6

                                            Image {
                                                source: "qrc:/icons/server.png"
                                                sourceSize: Qt.size(isMobile ? 16 : 18, isMobile ? 16 : 18)
                                                fillMode: Image.PreserveAspectFit
                                                mipmap: true
                                                antialiasing: true
                                                anchors.verticalCenter: parent.verticalCenter
                                            }

                                            Text {
                                                text: "Серверная часть"
                                                color: serverMouseArea.containsMouse ? "white" : "#27ae60"
                                                font.pixelSize: isMobile ? 10 : 11
                                                font.bold: true
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }

                                        MouseArea {
                                            id: serverMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: Qt.openUrlExternally(aboutPage.serverGitflicUrl)
                                        }
                                    }
                                }

                                Row {
                                    spacing: 4
                                    Image {
                                        source: "qrc:/icons/info.png"
                                        sourceSize: Qt.size(isMobile ? 14 : 18, isMobile ? 14 : 18)
                                        fillMode: Image.PreserveAspectFit
                                        mipmap: true
                                        antialiasing: true
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: "Исходный код доступен на Gitflic"
                                        font.pixelSize: isMobile ? 9 : 10
                                        color: "#6c757d"
                                        font.italic: true
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: descriptionText.height + (isMobile ? 40 : 60)
                radius: isMobile ? 12 : 16
                color: "#e8f4f8"
                border.color: "#b3e5fc"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: isMobile ? 12 : 20
                    spacing: isMobile ? 6 : 8

                    Row {
                        spacing: isMobile ? 4 : 6
                        Image {
                            source: "qrc:/icons/info.png"
                            sourceSize: Qt.size(isMobile ? 12 : 14, isMobile ? 12 : 14)
                            fillMode: Image.PreserveAspectFit
                            mipmap: true
                            antialiasing: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "О проекте EduFlow"
                            font.pixelSize: isMobile ? 12 : 14
                            font.bold: true
                            color: "#0277bd"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Text {
                        id: descriptionText
                        text: "Система управления образовательным процессом для учебных заведений. " +
                              "Предоставляет инструменты для управления студентами, преподавателями, " +
                              "группами и учебными материалами."
                        font.pixelSize: isMobile ? 11 : 12
                        color: "#0288d1"
                        lineHeight: 1.4
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }
}
