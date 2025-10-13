// main/AdaptiveSideBar.qml
import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: adaptiveSideBar
    width: currentWidth
    height: parent.height
    color: "#f8f8f8"
    radius: 12
    opacity: 0.95

    property int currentWidth: 280
    property int compactWidth: 80
    property int fullWidth: 280
    property string currentMode: "full"

    signal navigateTo(string view)
    signal logout()

    property var menuItems: [
        {icon: "🏠", name: "Главная панель", view: "dashboard"},
        {icon: "👨‍🏫", name: "Преподаватели", view: "teachers"},
        {icon: "👨‍🎓", name: "Студенты", view: "students"},
        {icon: "👥", name: "Группы", view: "groups"},
        {icon: "📁", name: "Портфолио", view: "portfolio"},
        {icon: "📅", name: "События", view: "events"}
    ]

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        // Панель режимов
        Rectangle {
            Layout.fillWidth: true
            height: 30
            radius: 6
            color: "#e8f4f8"
            border.color: "#bde0fe"
            border.width: 1

            Row {
                anchors.centerIn: parent
                spacing: 8

                Rectangle {
                    width: 20
                    height: 20
                    radius: 4
                    color: adaptiveSideBar.currentMode === "icons" ? "#3498db" : "transparent"
                    border.color: "#3498db"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "◼"
                        font.pixelSize: 8
                        color: adaptiveSideBar.currentMode === "icons" ? "white" : "#3498db"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            adaptiveSideBar.currentMode = "icons"
                            adaptiveSideBar.currentWidth = compactWidth
                        }
                    }
                }

                Rectangle {
                    width: 20
                    height: 20
                    radius: 4
                    color: adaptiveSideBar.currentMode === "compact" ? "#2ecc71" : "transparent"
                    border.color: "#2ecc71"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "▮"
                        font.pixelSize: 8
                        color: adaptiveSideBar.currentMode === "compact" ? "white" : "#2ecc71"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            adaptiveSideBar.currentMode = "compact"
                            adaptiveSideBar.currentWidth = compactWidth + 40
                        }
                    }
                }

                Rectangle {
                    width: 20
                    height: 20
                    radius: 4
                    color: adaptiveSideBar.currentMode === "full" ? "#e74c3c" : "transparent"
                    border.color: "#e74c3c"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "▮▮"
                        font.pixelSize: 8
                        color: adaptiveSideBar.currentMode === "full" ? "white" : "#e74c3c"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            adaptiveSideBar.currentMode = "full"
                            adaptiveSideBar.currentWidth = fullWidth
                        }
                    }
                }
            }
        }

        Text {
            text: {
                if (currentMode === "icons") return "🎯"
                if (currentMode === "compact") return "Панель"
                return "🎯 Панель управления"
            }
            font.pixelSize: currentMode === "icons" ? 24 : 18
            font.bold: true
            color: "#2c3e50"
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 10
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 5

            Text {
                text: currentMode === "full" ? "📊 Основные разделы" : ""
                font.pixelSize: 12
                font.bold: true
                color: "#7f8c8d"
                Layout.bottomMargin: 5
                visible: currentMode !== "icons"
            }

            Repeater {
                model: menuItems

                delegate: Rectangle {
                    Layout.fillWidth: true
                    height: adaptiveSideBar.currentMode === "icons" ? 40 : 50
                    radius: 8
                    color: mainWindow.currentView === modelData.view ? "#3498db" :
                          (navMouseArea.containsMouse ? "#ecf0f1" : "transparent")
                    border.color: mainWindow.currentView === modelData.view ? "#2980b9" : "transparent"
                    border.width: 2

                    Row {
                        anchors.fill: parent
                        anchors.margins: adaptiveSideBar.currentMode === "icons" ? 5 : 10
                        spacing: adaptiveSideBar.currentMode === "icons" ? 0 : 12

                        Text {
                            text: modelData.icon
                            font.pixelSize: adaptiveSideBar.currentMode === "icons" ? 18 : 16
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: {
                                if (adaptiveSideBar.currentMode === "compact")
                                    return modelData.name.split(" ")[0]
                                if (adaptiveSideBar.currentMode === "full")
                                    return modelData.name
                                return ""
                            }
                            color: mainWindow.currentView === modelData.view ? "white" : "#2c3e50"
                            font.pixelSize: adaptiveSideBar.currentMode === "compact" ? 10 : 13
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                            visible: adaptiveSideBar.currentMode !== "icons"
                        }
                    }

                    MouseArea {
                        id: navMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: adaptiveSideBar.navigateTo(modelData.view)
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 10

            Rectangle {
                Layout.fillWidth: true
                height: adaptiveSideBar.currentMode === "icons" ? 60 : 100
                radius: 8
                color: "#e8f4f8"
                border.color: "#bde0fe"
                border.width: 1

                Column {
                    anchors.centerIn: parent
                    spacing: 3

                    Text {
                        text: {
                            if (currentMode === "icons") return "📈"
                            if (currentMode === "compact") return "Статистика"
                            return "📈 Статистика системы"
                        }
                        font.pixelSize: currentMode === "icons" ? 16 : 12
                        font.bold: currentMode !== "icons"
                        color: "#2c3e50"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: currentMode === "icons" ? mainWindow.teachers.length : "👨‍🏫 " + mainWindow.teachers.length
                        font.pixelSize: currentMode === "icons" ? 12 : 10
                        color: "#7f8c8d"
                        visible: currentMode !== "icons"
                    }

                    Text {
                        text: currentMode === "icons" ? mainWindow.students.length : "👨‍🎓 " + mainWindow.students.length
                        font.pixelSize: currentMode === "icons" ? 12 : 10
                        color: "#7f8c8d"
                        visible: currentMode !== "icons"
                    }

                    Text {
                        text: currentMode === "icons" ? mainWindow.groups.length : "👥 " + mainWindow.groups.length
                        font.pixelSize: currentMode === "icons" ? 12 : 10
                        color: "#7f8c8d"
                        visible: currentMode !== "icons"
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: adaptiveSideBar.currentMode === "icons" ? 35 : 40
                radius: 8
                color: logoutMouseArea.pressed ? "#c0392b" : "#e74c3c"

                Row {
                    anchors.centerIn: parent
                    spacing: adaptiveSideBar.currentMode === "icons" ? 0 : 8

                    Text {
                        text: "🚪"
                        font.pixelSize: adaptiveSideBar.currentMode === "icons" ? 16 : 14
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: adaptiveSideBar.currentMode === "icons" ? "" : "Выйти из системы"
                        color: "white"
                        font.pixelSize: adaptiveSideBar.currentMode === "icons" ? 0 : 12
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: logoutMouseArea
                    anchors.fill: parent
                    onClicked: adaptiveSideBar.logout()
                }
            }
        }
    }

    Behavior on currentWidth {
        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
    }
}
