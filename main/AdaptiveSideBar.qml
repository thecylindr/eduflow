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
    property int compactWidth: 70
    property int fullWidth: 280
    property string currentMode: "full"

    // Внутреннее свойство для отслеживания текущего вида
    property string _currentView: "dashboard"

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

    // Функция для обновления текущего вида извне
    function setCurrentView(view) {
        if (_currentView !== view) {
            _currentView = view;
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        // Кнопка переключения режимов
        Rectangle {
            Layout.fillWidth: true
            height: 40
            radius: 8
            color: toggleMouseArea.containsMouse ? "#e3f2fd" : "transparent"
            border.color: "#3498db"
            border.width: 1

            Row {
                anchors.centerIn: parent
                spacing: 8

                Text {
                    text: currentMode === "full" ? "◀" : "▶"
                    font.pixelSize: 16
                    color: "#3498db"
                }

                Text {
                    text: "Свернуть"
                    font.pixelSize: 12
                    color: "#2c3e50"
                    visible: currentMode === "full"
                }
            }

            MouseArea {
                id: toggleMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (currentMode === "full") {
                        currentMode = "compact"
                        currentWidth = compactWidth
                    } else {
                        currentMode = "full"
                        currentWidth = fullWidth
                    }
                }
            }
        }

        // Заголовок
        Text {
            text: currentMode === "full" ? "🎯 Панель управления" : "🎯"
            font.pixelSize: currentMode === "full" ? 18 : 24
            font.bold: true
            color: "#2c3e50"
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 10
        }

        // Основное меню
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 5

            Repeater {
                model: menuItems

                delegate: Rectangle {
                    id: menuItem
                    Layout.fillWidth: true
                    height: 50
                    radius: 8
                    color: adaptiveSideBar._currentView === modelData.view ? "#3498db" :
                          (navMouseArea.containsMouse ? "#ecf0f1" : "transparent")
                    border.color: adaptiveSideBar._currentView === modelData.view ? "#2980b9" : "transparent"
                    border.width: 2

                    Row {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 12

                        Text {
                            text: modelData.icon
                            font.pixelSize: 16
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: modelData.name
                            color: adaptiveSideBar._currentView === modelData.view ? "white" : "#2c3e50"
                            font.pixelSize: 13
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                            visible: currentMode === "full"
                        }
                    }

                    MouseArea {
                        id: navMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            console.log("Navigation requested:", modelData.view);
                            if (adaptiveSideBar._currentView !== modelData.view) {
                                adaptiveSideBar._currentView = modelData.view;
                                adaptiveSideBar.navigateTo(modelData.view);
                            }
                        }
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }

        // Статистика (только в полном режиме)
        Rectangle {
            Layout.fillWidth: true
            height: currentMode === "full" ? 100 : 0
            radius: 8
            color: "#e8f4f8"
            border.color: "#bde0fe"
            border.width: 1
            visible: height > 0

            Column {
                anchors.centerIn: parent
                spacing: 3

                Text {
                    text: "📈 Статистика системы"
                    font.pixelSize: 12
                    font.bold: true
                    color: "#2c3e50"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: "👨‍🏫 " + (mainWindow.teachers ? mainWindow.teachers.length : 0)
                    font.pixelSize: 10
                    color: "#7f8c8d"
                }

                Text {
                    text: "👨‍🎓 " + (mainWindow.students ? mainWindow.students.length : 0)
                    font.pixelSize: 10
                    color: "#7f8c8d"
                }

                Text {
                    text: "👥 " + (mainWindow.groups ? mainWindow.groups.length : 0)
                    font.pixelSize: 10
                    color: "#7f8c8d"
                }
            }
        }

        // Кнопка выхода
        Rectangle {
            Layout.fillWidth: true
            height: 40
            radius: 8
            color: logoutMouseArea.containsMouse ? "#c0392b" : "#e74c3c"

            Row {
                anchors.centerIn: parent
                spacing: 8

                Text {
                    text: "🚪"
                    font.pixelSize: 14
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "Выйти"
                    color: "white"
                    font.pixelSize: 12
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                    visible: currentMode === "full"
                }
            }

            MouseArea {
                id: logoutMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    console.log("Logout requested")
                    adaptiveSideBar.logout()
                }
            }
        }
    }

    Behavior on currentWidth {
        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
    }
}
