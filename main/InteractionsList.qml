// main/InteractionsList.qml
import QtQuick 2.15

Item {
    id: interactionsList
    width: parent.width
    height: contentColumn.height

    property var menuItems: [
        { name: "👥 Управление студентами", action: "students" },
        { name: "👨‍🏫 Управление преподавателями", action: "teachers" },
        { name: "👥 Управление группами", action: "groups" },
        { name: "📊 Портфолио студентов", action: "portfolio" },
        { name: "📅 Управление событиями", action: "events" },
        { name: "📈 Статистика и отчеты", action: "statistics" },
        { name: "⚙️ Настройки системы", action: "system_settings" }
    ]

    signal itemClicked(string action, string name)

    Column {
        id: contentColumn
        width: parent.width
        spacing: 8

        Text {
            text: "📋 Меню управления"
            font.pixelSize: 16
            font.bold: true
            color: "#2c3e50"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // Список взаимодействий
        Repeater {
            model: interactionsList.menuItems

            delegate: Rectangle {
                width: contentColumn.width
                height: 45
                radius: 8
                color: mouseArea.containsMouse ? "#e3f2fd" : "transparent"

                Text {
                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                        margins: 10
                    }
                    text: modelData.name
                    font.pixelSize: 12
                    color: "#2c3e50"
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        interactionsList.itemClicked(modelData.action, modelData.name)
                    }
                }
            }
        }

        // Быстрые действия
        Text {
            text: "🚀 Быстрые действия"
            font.pixelSize: 14
            font.bold: true
            color: "#2c3e50"
        }

        // Кнопки быстрых действий
        Grid {
            columns: 2
            spacing: 8
            width: parent.width

            Repeater {
                model: [
                    { text: "Добавить студента", color: "#3498db", action: "add_student" },
                    { text: "Создать событие", color: "#2ecc71", action: "add_event" },
                    { text: "Новая группа", color: "#e74c3c", action: "add_group" }
                ]

                delegate: Rectangle {
                    width: (contentColumn.width - 8) / 2
                    height: 35
                    radius: 6
                    color: quickActionMouseArea.pressed ? Qt.darker(modelData.color, 1.2) : modelData.color

                    Text {
                        anchors.centerIn: parent
                        text: modelData.text
                        font.pixelSize: 10
                        color: "white"
                        font.bold: true
                    }

                    MouseArea {
                        id: quickActionMouseArea
                        anchors.fill: parent
                        onClicked: {
                            interactionsList.itemClicked(modelData.action, modelData.text)
                        }
                    }
                }
            }
        }
    }

    // Функции для работы со списком
    function getMenuItem(action) {
        for (var i = 0; i < menuItems.length; i++) {
            if (menuItems[i].action === action) {
                return menuItems[i]
            }
        }
        return null
    }
}
