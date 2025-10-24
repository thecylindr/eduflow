// enhanced/EnhancedListItem.qml
import QtQuick 2.15

Rectangle {
    id: listItem
    width: parent ? parent.width - 20 : 200
    height: 80
    radius: 12
    color: itemMouseArea.containsMouse ? "#f8f9fa" : "#ffffff"
    border.color: itemMouseArea.containsMouse ? "#3498db" : "#e0e0e0"
    border.width: 2

    property var itemData: null
    property string itemType: ""

    signal editRequested(var data)
    signal deleteRequested(var data)

    scale: itemMouseArea.containsMouse ? 1.02 : 1.0

    Behavior on scale {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }

    Behavior on color {
        ColorAnimation { duration: 200 }
    }

    Behavior on border.color {
        ColorAnimation { duration: 200 }
    }

    Row {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 15

        // Аватар/иконка
        Rectangle {
            width: 50
            height: 50
            radius: 25
            color: {
                if (itemType === "teacher") return "#3498db";
                if (itemType === "student") return "#2ecc71";
                if (itemType === "group") return "#e74c3c";
                return "#95a5a6";
            }
            anchors.verticalCenter: parent.verticalCenter

            Text {
                anchors.centerIn: parent
                text: {
                    if (itemType === "teacher") return "👨‍🏫";
                    if (itemType === "student") return "👨‍🎓";
                    if (itemType === "group") return "👥";
                    return "❓";
                }
                font.pixelSize: 16
            }
        }

        // Основная информация
        Column {
            width: parent.width - 180
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            Text {
                text: {
                    if (itemType === "teacher") {
                        return (itemData.lastName || "") + " " + (itemData.firstName || "") + " " + (itemData.middleName || "");
                    } else if (itemType === "student") {
                        return (itemData.last_name || "") + " " + (itemData.first_name || "") + " " + (itemData.middle_name || "");
                    } else if (itemType === "group") {
                        return itemData.name || "Без названия";
                    }
                    return "Неизвестный тип";
                }
                font.pixelSize: 14
                font.bold: true
                color: "#2c3e50"
                elide: Text.ElideRight
                width: parent.width
            }

            Text {
                text: {
                    if (itemType === "teacher") {
                        return "Специализация: " + (itemData.specialization || "Не указана") + " · Опыт: " + (itemData.experience || 0) + " лет";
                    } else if (itemType === "student") {
                        return "Группа: " + (itemData.group_id || "Не указана") + " · " + (itemData.email || "Нет контактов");
                    } else if (itemType === "group") {
                        return "Студентов: " + (itemData.studentCount || 0) + " · Куратор: " + (itemData.teacherName || "Не назначен");
                    }
                    return "";
                }
                font.pixelSize: 11
                color: "#7f8c8d"
                elide: Text.ElideRight
                width: parent.width
            }
        }

        // Кнопки действий
        Row {
            spacing: 8
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                id: editButton
                width: 30
                height: 30
                radius: 6
                color: editMouseArea.containsMouse ? "#3498db" : "transparent"
                border.color: editMouseArea.containsMouse ? "#2980b9" : "#3498db"
                border.width: 2

                Text {
                    anchors.centerIn: parent
                    text: "✏️"
                    font.pixelSize: 12
                }

                MouseArea {
                    id: editMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: listItem.editRequested(listItem.itemData)
                }
            }

            Rectangle {
                id: deleteButton
                width: 30
                height: 30
                radius: 6
                color: deleteMouseArea.containsMouse ? "#e74c3c" : "transparent"
                border.color: deleteMouseArea.containsMouse ? "#c0392b" : "#e74c3c"
                border.width: 2

                Text {
                    anchors.centerIn: parent
                    text: "🗑️"
                    font.pixelSize: 12
                }

                MouseArea {
                    id: deleteMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: listItem.deleteRequested(listItem.itemData)
                }
            }
        }
    }

    MouseArea {
        id: itemMouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }
}
