// AdaptiveSideBar.qml
import QtQuick
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
        {icon: "qrc:/icons/home.png", name: "Главная панель", view: "dashboard"},
        {icon: "qrc:/icons/teachers.png", name: "Преподаватели", view: "teachers"},
        {icon: "qrc:/icons/students.png", name: "Студенты", view: "students"},
        {icon: "qrc:/icons/groups.png", name: "Группы", view: "groups"},
        {icon: "qrc:/icons/portfolio.png", name: "Портфолио", view: "portfolio"},
        {icon: "qrc:/icons/events.png", name: "События", view: "events"}
    ]

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            spacing: 8


            Row {
                Layout.fillWidth: true
                spacing: 8
                visible: textVisible

                Rectangle {
                    width: 32
                    height: 32
                    radius: 8
                    color: "#3498db"
                    anchors.verticalCenter: parent.verticalCenter

                    Image {
                        anchors.centerIn: parent
                        source: "qrc:/icons/earth.png"
                        sourceSize: Qt.size(24, 24)
                        fillMode: Image.PreserveAspectFit
                        mipmap: true
                        antialiasing: true
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 0

                    Text {
                        text: appName
                        font.pixelSize: 16
                        font.bold: true
                        color: "#2c3e50"
                    }

                    Text {
                        text: "Панель управления"
                        font.pixelSize: 14
                        color: "#7f8c8d"
                    }
                }
            }

            // Кнопка переключения режимов - всегда видна
            Item {
                Layout.fillWidth: !textVisible
                Layout.preferredWidth: textVisible ? 28 : parent.width
                Layout.preferredHeight: 28
                Layout.alignment: textVisible ? Qt.AlignRight : Qt.AlignHCenter

                Rectangle {
                    width: 28
                    height: 28
                    radius: 6
                    color: toggleMouseArea.containsMouse ? "#f1f3f4" : "transparent"
                    border.color: toggleMouseArea.containsMouse ? "#3498db" : "transparent"
                    border.width: 1
                    anchors.centerIn: parent

                    Image {
                        id: sidebarIcon
                        anchors.centerIn: parent
                        source: "qrc:/icons/sidebar.png"
                        sourceSize: Qt.size(16, 16)
                        fillMode: Image.PreserveAspectFit
                        mipmap: true
                        antialiasing: true

                        // Начальное состояние - 0 градусов (горизонтальное положение)
                        rotation: 0

                        // Поворачиваем на -90 градусов против часовой стрелки в компактном режиме
                        Behavior on rotation {
                            NumberAnimation {
                                duration: 300
                                easing.type: Easing.InOutQuad
                            }
                        }
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

                                // Анимируем поворот иконки
                                if (currentMode === "full") {
                                    sidebarIcon.rotation = -90 // Поворачиваем против часовой стрелки
                                } else {
                                    sidebarIcon.rotation = 0   // Возвращаем в горизонтальное положение
                                }

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
            height: 1
            color: "#3498db"
            opacity: 0.3
            Layout.topMargin: 3
            Layout.bottomMargin: 3
        }

        // Основное меню
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 2

            Repeater {
                model: menuItems

                delegate: Rectangle {
                    id: menuItem
                    Layout.fillWidth: true
                    height: 36
                    radius: 6
                    color: adaptiveSideBar.currentView === modelData.view ? "#e3f2fd" :
                          (navMouseArea.containsMouse ? "#f8f9fa" : "transparent")
                    border.color: adaptiveSideBar.currentView === modelData.view ? "#3498db" : "transparent"
                    border.width: 1

                    Row {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8

                        Image {
                            source: modelData.icon
                            sourceSize: Qt.size(20, 20)
                            anchors.verticalCenter: parent.verticalCenter
                            fillMode: Image.PreserveAspectFit
                            mipmap: true
                            antialiasing: true
                        }

                        Text {
                            text: modelData.name
                            color: adaptiveSideBar.currentView === modelData.view ? "#1976d2" : "#5f6368"
                            font.pixelSize: 14
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
                            rightMargin: 6
                        }
                        width: 3
                        height: 16
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
                        width: compactTooltipText.contentWidth + 12
                        height: 26
                        color: "#34495e"
                        radius: 4
                        z: 1000

                        Text {
                            id: compactTooltipText
                            anchors.centerIn: parent
                            text: modelData.name
                            color: "white"
                            font.pixelSize: 10
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
            height: textVisible ? 60 : 0
            radius: 8
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
                spacing: 3

                Row {
                    spacing: 5

                    Image {
                        source: "qrc:/icons/statistics.png"
                        sourceSize: Qt.size(20, 20)
                        fillMode: Image.PreserveAspectFit
                        mipmap: true
                        antialiasing: true
                    }

                    Text {
                        text: "Статистика"
                        font.pixelSize: 12
                        font.bold: true
                        color: "#2c3e50"
                    }
                }

                Row {
                    spacing: 8

                    Row {
                        spacing: 3
                        Image {
                            source: "qrc:/icons/teachers.png"
                            sourceSize: Qt.size(20, 20)
                            fillMode: Image.PreserveAspectFit
                            mipmap: true
                            antialiasing: true
                        }
                        Text {
                            text: mainWindow.teachers ? mainWindow.teachers.length : 0
                            font.pixelSize: 14
                            color: "#6c757d"
                        }
                    }

                    Row {
                        spacing: 3
                        Image {
                            source: "qrc:/icons/students.png"
                            sourceSize: Qt.size(20, 20)
                            fillMode: Image.PreserveAspectFit
                            mipmap: true
                            antialiasing: true
                        }
                        Text {
                            text: mainWindow.students ? mainWindow.students.length : 0
                            font.pixelSize: 14
                            color: "#6c757d"
                        }
                    }

                    Row {
                        spacing: 3
                        Image {
                            source: "qrc:/icons/groups.png"
                            sourceSize: Qt.size(20, 20)
                            fillMode: Image.PreserveAspectFit
                            mipmap: true
                            antialiasing: true
                        }
                        Text {
                            text: mainWindow.groups ? mainWindow.groups.length : 0
                            font.pixelSize: 14
                            color: "#6c757d"
                        }
                    }
                }
            }
        }

        // Кнопка настроек
        Rectangle {
            Layout.fillWidth: true
            height: 36
            radius: 6
            color: adaptiveSideBar.currentView === "settings" ? "#e3f2fd" :
                  (settingsMouseArea.containsMouse ? "#f8f9fa" : "transparent")
            border.color: adaptiveSideBar.currentView === "settings" ? "#3498db" : "transparent"
            border.width: 1

            Row {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8

                AnimatedImage {
                    sourceSize: Qt.size(18,18)
                    source: settingsMouseArea.containsMouse ? "qrc:/icons/settings.gif" : "qrc:/icons/settings.png"
                    fillMode: Image.PreserveAspectFit
                    speed: 0.7
                    mipmap: true
                    antialiasing: true
                    playing: settingsMouseArea.containsMouse
                }

                Text {
                    text: "Настройки"
                    color: adaptiveSideBar.currentView === "settings" ? "#1976d2" : "#5f6368"
                    font.pixelSize: 14
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
                width: settingsTooltipText.contentWidth + 12
                height: 26
                color: "#34495e"
                radius: 4
                z: 1000

                Text {
                    id: settingsTooltipText
                    anchors.centerIn: parent
                    text: "Настройки"
                    color: "white"
                    font.pixelSize: 10
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

    Timer {
        id: toggleCooldown
        interval: 1000
        onTriggered: canToggle = true
    }

    Behavior on currentWidth {
        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
    }
}
