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
    z: 1

    property int currentWidth: 280
    property int compactWidth: 70
    property int fullWidth: 280

    // Автоматическое определение режима по ширине
    readonly property string currentMode: currentWidth === compactWidth ? "compact" : "full"
    // Отдельное свойство для немедленного скрытия текста
    property bool textVisible: currentMode === "full"

    // Текущий вид управляется Main
    property string currentView: "dashboard"

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

        // Кнопка переключения режимов с тремя полосками
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

                // Иконка из трех полосок
                Item {
                    width: 20
                    height: 14

                    // Три горизонтальные полоски
                    Column {
                        anchors.centerIn: parent
                        spacing: 2

                        Rectangle {
                            width: 16
                            height: 2
                            radius: 1
                            color: toggleMouseArea.containsMouse ? "#2980b9" : "#3498db"
                        }
                        Rectangle {
                            width: 16
                            height: 2
                            radius: 1
                            color: toggleMouseArea.containsMouse ? "#2980b9" : "#3498db"
                        }
                        Rectangle {
                            width: 16
                            height: 2
                            radius: 1
                            color: toggleMouseArea.containsMouse ? "#2980b9" : "#3498db"
                        }
                    }

                    // Вращение иконки в зависимости от режима
                    rotation: textVisible ? 0 : 90
                    Behavior on rotation {
                        NumberAnimation { duration: 200 }
                    }
                }

                Text {
                    text: textVisible ? "Свернуть" : "Развернуть"
                    font.pixelSize: 12
                    color: "#2c3e50"
                    visible: textVisible
                }
            }

            MouseArea {
                id: toggleMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    textVisible = !textVisible;

                    if (currentMode === "full") {
                        currentWidth = compactWidth;
                    } else {
                        currentWidth = fullWidth;
                    }
                }
            }
        }

        // Заголовок
        Text {
            text: textVisible ? "🎯 Панель управления" : "🎯"
            font.pixelSize: textVisible ? 18 : 20
            font.bold: true
            color: "#2c3e50"
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 10
            visible: true
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
                    color: adaptiveSideBar.currentView === modelData.view ? "#3498db" :
                          (navMouseArea.containsMouse ? "#ecf0f1" : "transparent")
                    border.color: adaptiveSideBar.currentView === modelData.view ? "#2980b9" : "transparent"
                    border.width: 2

                    Row {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 12

                        Text {
                            text: modelData.icon
                            font.pixelSize: 16
                            anchors.verticalCenter: parent.verticalCenter
                            color: adaptiveSideBar.currentView === modelData.view ? "white" :
                                  (navMouseArea.containsMouse ? "#2980b9" : "#2c3e50")
                        }

                        Text {
                            text: modelData.name
                            color: adaptiveSideBar.currentView === modelData.view ? "white" : "#2c3e50"
                            font.pixelSize: 13
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                            visible: textVisible
                        }
                    }

                    // Подсказка в компактном режиме при наведении
                    Rectangle {
                        id: compactTooltip
                        visible: !textVisible && navMouseArea.containsMouse
                        x: menuItem.width + 5
                        y: (menuItem.height - height) / 2
                        width: compactTooltipText.contentWidth + 20
                        height: 30
                        color: "#3498db"
                        radius: 6
                        z: 1000

                        // Альтернатива тени - светлая обводка
                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            border.color: "#ffffff"
                            border.width: 2
                            radius: 6
                        }

                        Text {
                            id: compactTooltipText
                            anchors.centerIn: parent
                            text: modelData.name
                            color: "white"
                            font.pixelSize: 12
                            font.bold: true
                        }

                        Behavior on opacity {
                            NumberAnimation { duration: 150 }
                        }
                    }

                    MouseArea {
                        id: navMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            console.log("🖱️ Нажата кнопка:", modelData.view);
                            if (mainWindow) {
                                mainWindow.navigateTo(modelData.view);
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
            height: textVisible ? 100 : 0
            radius: 8
            color: "#e8f4f8"
            border.color: "#bde0fe"
            border.width: 1
            visible: height > 0
            opacity: textVisible ? 1 : 0

            Behavior on height {
                NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
            }
            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }

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
                    color: "white"
                }

                Text {
                    text: "Выйти"
                    color: "white"
                    font.pixelSize: 12
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                    visible: textVisible
                }
            }

            // Подсказка для кнопки выхода в компактном режиме
            Rectangle {
                id: logoutTooltip
                visible: !textVisible && logoutMouseArea.containsMouse
                x: parent.width + 5
                y: (parent.height - height) / 2
                width: logoutTooltipText.contentWidth + 20
                height: 30
                color: "#e74c3c"
                radius: 6
                z: 1000

                // Альтернатива тени - светлая обводка
                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    border.color: "#ffffff"
                    border.width: 2
                    radius: 6
                }

                Text {
                    id: logoutTooltipText
                    anchors.centerIn: parent
                    text: "Выйти"
                    color: "white"
                    font.pixelSize: 12
                    font.bold: true
                }

                Behavior on opacity {
                    NumberAnimation { duration: 150 }
                }
            }

            MouseArea {
                id: logoutMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    console.log("🔒 Запрос выхода");
                    if (mainWindow) {
                        mainWindow.logout();
                    }
                }
            }
        }
    }

    Behavior on currentWidth {
        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
    }
}
