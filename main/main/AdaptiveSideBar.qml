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
                    rotation: textVisible ? 0 : -90
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

        // Заголовок окон
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

                    // Градиент для активного элемента
                    gradient: adaptiveSideBar.currentView === modelData.view ? activeGradient : null
                    color: adaptiveSideBar.currentView === modelData.view ? "transparent" :
                          (navMouseArea.containsMouse ? "transparent" : "transparent")

                    // Градиентная обводка при наведении
                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius
                        color: "transparent"
                        border.color: "transparent"
                        border.width: 0

                        gradient: navMouseArea.containsMouse && adaptiveSideBar.currentView !== modelData.view ? hoverGradient : null

                        // Внутренняя заливка для непрозрачности
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 2
                            radius: parent.radius - 1
                            color: adaptiveSideBar.currentView === modelData.view ? "transparent" :
                                  (navMouseArea.containsMouse ? "#f8f8f8" : "transparent")
                        }
                    }

                    Row {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 12

                        Text {
                            text: modelData.icon
                            font.pixelSize: 16
                            anchors.verticalCenter: parent.verticalCenter
                            color: adaptiveSideBar.currentView === modelData.view ? "white" :
                                  (navMouseArea.containsMouse ? "#2575fc" : "#2c3e50")
                        }

                        Text {
                            text: modelData.name
                            color: adaptiveSideBar.currentView === modelData.view ? "#808080" : "#2c3e50"
                            font.pixelSize: 13
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                            visible: textVisible
                        }
                    }

                    // Дополнительный индикатор активного элемента (полоска слева)
                    Rectangle {
                        anchors {
                            left: parent.left
                            verticalCenter: parent.verticalCenter
                        }
                        width: 4
                        height: parent.height - 16
                        radius: 2
                        color: adaptiveSideBar.currentView === modelData.view ? "#808080" : "#2575fc"
                        visible: adaptiveSideBar.currentView === modelData.view || navMouseArea.containsMouse
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

        // Кнопка настроек учетной записи (ОДНА внизу)
        Rectangle {
            Layout.fillWidth: true
            height: 40
            radius: 8
            color: adaptiveSideBar.currentView === "settings" ? "#2575fc" :
                  (settingsMouseArea.containsMouse ? "#34495e" : "#2c3e50")

            Row {
                anchors.centerIn: parent
                spacing: 8

                Text {
                    text: "⚙️"
                    font.pixelSize: 14
                    anchors.verticalCenter: parent.verticalCenter
                    color: "white"
                }

                Text {
                    text: "Настройки"
                    color: "white"
                    font.pixelSize: 12
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                    visible: textVisible
                }
            }

            // Подсказка для кнопки настроек в компактном режиме
            Rectangle {
                id: settingsTooltip
                visible: !textVisible && settingsMouseArea.containsMouse
                x: parent.width + 5
                y: (parent.height - height) / 2
                width: settingsTooltipText.contentWidth + 20
                height: 30
                color: "#2c3e50"
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
                    id: settingsTooltipText
                    anchors.centerIn: parent
                    text: "Настройки"
                    color: "white"
                    font.pixelSize: 12
                    font.bold: true
                }

                Behavior on opacity {
                    NumberAnimation { duration: 150 }
                }
            }

            MouseArea {
                id: settingsMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (mainWindow) {
                        mainWindow.navigateTo("settings");
                    }
                }
            }
        }
    }

    // Градиенты для разных состояний
    Gradient {
        id: activeGradient
        GradientStop { position: 0.0; color: "#6a11cb" }
        GradientStop { position: 1.0; color: "#2575fc" }
    }

    Gradient {
        id: hoverGradient
        GradientStop { position: 0.0; color: "#6a11cb" }
        GradientStop { position: 1.0; color: "#2575fc" }
    }

    Behavior on currentWidth {
        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
    }
}
