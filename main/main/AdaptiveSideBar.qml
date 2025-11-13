// AdaptiveSideBar.qml
import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: adaptiveSideBar
    width: currentWidth
    height: parent.height
    color: "#ffffff"
    radius: 16
    opacity: 0.925
    border.color: "#e0e0e0"
    border.width: 1
    z: 1

    property int currentWidth: 280
    property int compactWidth: 70
    property int fullWidth: 280
    property bool canToggle: true

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
        anchors.margins: 12
        spacing: 8

        // Заголовок и кнопка переключения
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            // Логотип и название - скрываются в компактном режиме
            Row {
                Layout.fillWidth: true
                spacing: 10
                visible: textVisible

                Rectangle {
                    width: 36
                    height: 36
                    radius: 10
                    color: "#3498db"
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: "🎯"
                        font.pixelSize: 18
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 0

                    Text {
                        text: "EduFlow"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#2c3e50"
                    }

                    Text {
                        text: "Панель управления"
                        font.pixelSize: 10
                        color: "#7f8c8d"
                    }
                }
            }

            // Кнопка переключения режимов - всегда видна
            Item {
                    Layout.fillWidth: !textVisible // В компактном режиме занимает всю ширину для центрирования
                    Layout.preferredWidth: textVisible ? 32 : parent.width // В полном режиме - фиксированная ширина
                    Layout.preferredHeight: 32
                    Layout.alignment: textVisible ? Qt.AlignRight : Qt.AlignHCenter // Центрируем в компактном режиме

                    Rectangle {
                        width: 32
                        height: 32
                        radius: 8
                        color: toggleMouseArea.containsMouse ? "#f1f3f4" : "transparent"
                        border.color: toggleMouseArea.containsMouse ? "#3498db" : "transparent"
                        border.width: 1
                        anchors.centerIn: parent // Центрируем внутри Item

                        Text {
                            anchors.centerIn: parent
                            text: textVisible ? "◀" : "▶"
                            font.pixelSize: 12
                            color: "#5f6368"
                            font.bold: true
                        }

                        MouseArea {
                            id: toggleMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (canToggle) {
                                    canToggle = false
                                    toggleCooldown.start()

                                    textVisible = !textVisible
                                    if (currentMode === "full") {
                                        currentWidth = compactWidth
                                    } else {
                                        currentWidth = fullWidth
                                    }
                                }
                            }
                        }
                    }
                }
        }

        // Разделитель
        Rectangle {
            Layout.fillWidth: true
            height: 2
            color: "#3498db"
            opacity: 0.3
            Layout.topMargin: 5
            Layout.bottomMargin: 5
        }

        // Основное меню
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 4

            Repeater {
                model: menuItems

                delegate: Rectangle {
                    id: menuItem
                    Layout.fillWidth: true
                    height: 44
                    radius: 8
                    color: adaptiveSideBar.currentView === modelData.view ? "#e3f2fd" :
                          (navMouseArea.containsMouse ? "#f8f9fa" : "transparent")
                    border.color: adaptiveSideBar.currentView === modelData.view ? "#3498db" : "transparent"
                    border.width: 1

                    Row {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        Text {
                            text: modelData.icon
                            font.pixelSize: 16
                            anchors.verticalCenter: parent.verticalCenter
                            color: adaptiveSideBar.currentView === modelData.view ? "#1976d2" : "#5f6368"
                        }

                        Text {
                            text: modelData.name
                            color: adaptiveSideBar.currentView === modelData.view ? "#1976d2" : "#5f6368"
                            font.pixelSize: 13
                            font.bold: adaptiveSideBar.currentView === modelData.view
                            anchors.verticalCenter: parent.verticalCenter
                            visible: textVisible
                        }
                    }

                    // Индикатор активного элемента
                    Rectangle {
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            rightMargin: 8
                        }
                        width: 3
                        height: 20
                        radius: 2
                        color: "#1976d2"
                        visible: adaptiveSideBar.currentView === modelData.view
                    }

                    // Упрощенная подсказка в компактном режиме
                    Rectangle {
                        id: compactTooltip
                        visible: !textVisible && navMouseArea.containsMouse
                        x: menuItem.width + 5
                        y: (menuItem.height - height) / 2
                        width: compactTooltipText.contentWidth + 16
                        height: 30
                        color: "#34495e"
                        radius: 6
                        z: 1000

                        Text {
                            id: compactTooltipText
                            anchors.centerIn: parent
                            text: modelData.name
                            color: "white"
                            font.pixelSize: 11
                            font.bold: true
                        }
                    }

                    MouseArea {
                        id: navMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (mainWindow) {
                                mainWindow.navigateTo(modelData.view)
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
            height: textVisible ? 70 : 0
            radius: 10
            color: "#f8f9fa"
            border.color: "#e9ecef"
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
                spacing: 4

                Text {
                    text: "📊 Статистика"
                    font.pixelSize: 11
                    font.bold: true
                    color: "#2c3e50"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Row {
                    spacing: 12
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        text: "👨‍🏫" + (mainWindow.teachers ? mainWindow.teachers.length : 0)
                        font.pixelSize: 10
                        color: "#6c757d"
                    }

                    Text {
                        text: "👨‍🎓" + (mainWindow.students ? mainWindow.students.length : 0)
                        font.pixelSize: 10
                        color: "#6c757d"
                    }

                    Text {
                        text: "👥" + (mainWindow.groups ? mainWindow.groups.length : 0)
                        font.pixelSize: 10
                        color: "#6c757d"
                    }
                }
            }
        }

        // Кнопка настроек
        Rectangle {
            Layout.fillWidth: true
            height: 44
            radius: 8
            color: adaptiveSideBar.currentView === "settings" ? "#e3f2fd" :
                  (settingsMouseArea.containsMouse ? "#f8f9fa" : "transparent")
            border.color: adaptiveSideBar.currentView === "settings" ? "#3498db" : "transparent"
            border.width: 1

            Row {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 12

                Text {
                    text: "⚙️"
                    font.pixelSize: 16
                    anchors.verticalCenter: parent.verticalCenter
                    color: adaptiveSideBar.currentView === "settings" ? "#1976d2" : "#5f6368"
                }

                Text {
                    text: "Настройки"
                    color: adaptiveSideBar.currentView === "settings" ? "#1976d2" : "#5f6368"
                    font.pixelSize: 13
                    font.bold: adaptiveSideBar.currentView === "settings"
                    anchors.verticalCenter: parent.verticalCenter
                    visible: textVisible
                }
            }

            // Упрощенная подсказка для настроек в компактном режиме
            Rectangle {
                id: settingsTooltip
                visible: !textVisible && settingsMouseArea.containsMouse
                x: parent.width + 5
                y: (parent.height - height) / 2
                width: settingsTooltipText.contentWidth + 16
                height: 30
                color: "#34495e"
                radius: 6
                z: 1000

                Text {
                    id: settingsTooltipText
                    anchors.centerIn: parent
                    text: "Настройки"
                    color: "white"
                    font.pixelSize: 11
                    font.bold: true
                }
            }

            MouseArea {
                id: settingsMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (mainWindow) {
                        mainWindow.navigateTo("settings")
                    }
                }
            }
        }
    }

    // Таймер для ограничения частоты переключения
    Timer {
        id: toggleCooldown
        interval: 1000
        onTriggered: canToggle = true
    }

    Behavior on currentWidth {
        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
    }
}
