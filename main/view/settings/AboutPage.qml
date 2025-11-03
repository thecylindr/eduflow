import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: aboutPage
    color: "transparent"

    // Свойства получаются из SettingsView, который получает их из main.cpp
    property string appVersion
    property string appName
    property string organizationName
    property string gitflicUrl
    property string serverGitflicUrl

    ScrollView {
        anchors.fill: parent
        anchors.margins: 20
        clip: true

        ColumnLayout {
            width: parent.width
            spacing: 20

            Rectangle {
                Layout.fillWidth: true
                height: 440
                radius: 16
                color: "#ffffff"
                border.color: "#e0e0e0"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 20

                    Text {
                        text: "ℹ️ О программе"
                        font.pixelSize: 18
                        font.bold: true
                        color: "#2c3e50"
                        Layout.alignment: Qt.AlignHCenter
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 16

                        // App info section
                        Rectangle {
                            Layout.fillWidth: true
                            height: 80
                            radius: 8
                            color: "#e3f2fd"
                            border.color: "#bbdefb"
                            border.width: 1

                            Row {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 15

                                Rectangle {
                                    width: 50
                                    height: 50
                                    radius: 10
                                    color: "#3498db"
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        anchors.centerIn: parent
                                        text: "🎓"
                                        font.pixelSize: 20
                                    }
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 4

                                    Text {
                                        text: aboutPage.appName
                                        font.pixelSize: 16
                                        font.bold: true
                                        color: "#2c3e50"
                                    }

                                    Text {
                                        text: "Версия " + aboutPage.appVersion
                                        font.pixelSize: 12
                                        color: "#6c757d"
                                    }
                                }
                            }
                        }

                        // Details section
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                Text {
                                    text: "📱"
                                    font.pixelSize: 14
                                    color: "#6c757d"
                                    Layout.preferredWidth: 20
                                }

                                Text {
                                    text: "Версия приложения:"
                                    font.pixelSize: 14
                                    color: "#6c757d"
                                    Layout.preferredWidth: 140
                                }

                                Text {
                                    text: aboutPage.appVersion
                                    font.pixelSize: 14
                                    color: "#2c3e50"
                                    font.bold: true
                                    Layout.fillWidth: true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                Text {
                                    text: "🏢"
                                    font.pixelSize: 14
                                    color: "#6c757d"
                                    Layout.preferredWidth: 20
                                }

                                Text {
                                    text: "Организация:"
                                    font.pixelSize: 14
                                    color: "#6c757d"
                                    Layout.preferredWidth: 140
                                }

                                Text {
                                    text: aboutPage.organizationName
                                    font.pixelSize: 14
                                    color: "#2c3e50"
                                    font.bold: true
                                    Layout.fillWidth: true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                Text {
                                    text: "📅"
                                    font.pixelSize: 14
                                    color: "#6c757d"
                                    Layout.preferredWidth: 20
                                }

                                Text {
                                    text: "Год выпуска:"
                                    font.pixelSize: 14
                                    color: "#6c757d"
                                    Layout.preferredWidth: 140
                                }

                                Text {
                                    text: "2025"
                                    font.pixelSize: 14
                                    color: "#2c3e50"
                                    font.bold: true
                                    Layout.fillWidth: true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                Text {
                                    text: "⚙️"
                                    font.pixelSize: 14
                                    color: "#6c757d"
                                    Layout.preferredWidth: 20
                                }

                                Text {
                                    text: "Платформа:"
                                    font.pixelSize: 14
                                    color: "#6c757d"
                                    Layout.preferredWidth: 140
                                }

                                Text {
                                    text: "Qt"
                                    font.pixelSize: 14
                                    color: "#2c3e50"
                                    font.bold: true
                                    Layout.fillWidth: true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                Text {
                                    text: "🀄"
                                    font.pixelSize: 14
                                    color: "#6c757d"
                                    Layout.preferredWidth: 20
                                }

                                Text {
                                    text: "ЯП:"
                                    font.pixelSize: 14
                                    color: "#6c757d"
                                    Layout.preferredWidth: 140
                                }

                                Text {
                                    text: "C++17"
                                    font.pixelSize: 14
                                    color: "#2c3e50"
                                    font.bold: true
                                    Layout.fillWidth: true
                                }
                            }
                        }

                        // Links section
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
                                    text: "🔗 Ссылки на проект:"
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: "#6c757d"
                                }

                                Row {
                                    spacing: 10

                                    Rectangle {
                                        width: 150
                                        height: 36
                                        radius: 6
                                        color: clientMouseArea.containsMouse ? "#3498db" : "#e3f2fd"
                                        border.color: clientMouseArea.containsMouse ? "#2980b9" : "#b3e5fc"
                                        border.width: 1

                                        Row {
                                            anchors.centerIn: parent
                                            spacing: 6

                                            Text {
                                                text: "🌐"
                                                font.pixelSize: 12
                                                anchors.verticalCenter: parent.verticalCenter
                                            }

                                            Text {
                                                text: "Клиентская часть"
                                                color: clientMouseArea.containsMouse ? "white" : "#3498db"
                                                font.pixelSize: 11
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
                                        width: 150
                                        height: 36
                                        radius: 6
                                        color: serverMouseArea.containsMouse ? "#27ae60" : "#e8f5e8"
                                        border.color: serverMouseArea.containsMouse ? "#219653" : "#c8e6c9"
                                        border.width: 1

                                        Row {
                                            anchors.centerIn: parent
                                            spacing: 6

                                            Text {
                                                text: "🔧"
                                                font.pixelSize: 12
                                                anchors.verticalCenter: parent.verticalCenter
                                            }

                                            Text {
                                                text: "Серверная часть"
                                                color: serverMouseArea.containsMouse ? "white" : "#27ae60"
                                                font.pixelSize: 11
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

                                Text {
                                    text: "💡 Исходный код доступен на Gitflic"
                                    font.pixelSize: 10
                                    color: "#6c757d"
                                    font.italic: true
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 120
                radius: 16
                color: "#e8f4f8"
                border.color: "#b3e5fc"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 8

                    Text {
                        text: "💡 О проекте EduFlow"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#0277bd"
                    }

                    Text {
                        text: "Система управления образовательным процессом для учебных заведений. " +
                              "Предоставляет инструменты для управления студентами, преподавателями, " +
                              "группами и учебными материалами."
                        font.pixelSize: 12
                        color: "#0288d1"
                        lineHeight: 1.4
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }
    }
}
