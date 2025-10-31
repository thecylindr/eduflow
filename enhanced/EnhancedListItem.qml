// enhanced/EnhancedListItem.qml
import QtQuick 2.15

Rectangle {
    id: listItem
    height: 60
    radius: 8
    color: itemMouseArea.containsMouse ? "#f8f9fa" : "#ffffff"
    border.color: itemMouseArea.containsMouse ? "#3498db" : "#e0e0e0"
    border.width: 1

    scale: itemMouseArea.containsMouse ? 1.01 : 1.0

    // Упрощенная установка ширины - без конфликтующих якорей
    width: parent ? parent.width - 20 : 100
    anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined

    property var itemData: null
    property string itemType: ""

    signal editRequested(var data)
    signal deleteRequested(var data)

    Behavior on color {
        ColorAnimation { duration: 150 }
    }

    Behavior on border.color {
        ColorAnimation { duration: 150 }
    }

    // Основной контент
    Row {
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 12

        // Аватар/иконка
        Rectangle {
            width: 40
            height: 40
            radius: 20
            color: {
                if (itemType === "teacher") return "#3498db";
                if (itemType === "student") return "#2ecc71";
                if (itemType === "group") return "#e74c3c";
                return "#95a5a6";
            }

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
            width: listItem.width - 120
            spacing: 2

            Text {
                text: {
                    if (itemType === "teacher") {
                        return (itemData.lastName || "") + " " + (itemData.firstName || "") + " " + (itemData.middleName || "");
                    } else if (itemType === "student") {
                        var last_name = itemData.last_name || itemData.lastName || "";
                        var first_name = itemData.first_name || itemData.firstName || "";
                        var middle_name = itemData.middle_name || itemData.middleName || "";
                        return last_name + " " + first_name + " " + middle_name;
                    } else if (itemType === "group") {
                        return itemData.name || "Без названия";
                    }
                    return "Неизвестный тип";
                }
                font.pixelSize: 13
                font.bold: true
                color: "#2c3e50"
                elide: Text.ElideRight
                width: parent.width
            }

            Text {
                text: {
                    if (itemType === "teacher") {
                        return (itemData.specialization || "Не указана") + " · " + (itemData.experience || 0) + " лет";
                    } else if (itemType === "student") {
                        return "Группа: " + (itemData.groupName || itemData.group_name || "Не указана");
                    } else if (itemType === "group") {
                        return "Студентов: " + (itemData.studentCount || 0) + " · " + (itemData.teacherName || "Без куратора");
                    }
                    return "";
                }
                font.pixelSize: 11
                color: "#7f8c8d"
                elide: Text.ElideRight
                width: parent.width
            }
        }
    }

    // Кнопки действий - ВСЕГДА на переднем плане
    Row {
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8
        z: 1000 // Очень высокий z-index чтобы быть поверх всего

        Rectangle {
            id: editButton
            width: 28
            height: 28
            radius: 6
            color: editMouseArea.containsMouse ? "#3498db" : "transparent"
            border.color: editMouseArea.containsMouse ? "#2980b9" : "#3498db"
            border.width: 1
            z: 1001

            Text {
                anchors.centerIn: parent
                text: "✏️"
                font.pixelSize: 11
                z: 1002
            }

            MouseArea {
                id: editMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                z: 1003
                onClicked: {
                    console.log("✏️ ListItem: редактирование запрошено для", listItem.itemData);
                    listItem.editRequested(listItem.itemData);
                }
            }
        }

        Rectangle {
            id: deleteButton
            width: 28
            height: 28
            radius: 6
            color: deleteMouseArea.containsMouse ? "#e74c3c" : "transparent"
            border.color: deleteMouseArea.containsMouse ? "#c0392b" : "#e74c3c"
            border.width: 1
            z: 1001

            Text {
                anchors.centerIn: parent
                text: "🗑️"
                font.pixelSize: 11
                z: 1002
            }

            MouseArea {
                id: deleteMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                z: 1003
                onClicked: {
                    console.log("🗑️ ListItem: удаление запрошено для", listItem.itemData);
                    listItem.deleteRequested(listItem.itemData);
                }
            }
        }
    }

    MouseArea {
        id: itemMouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        propagateComposedEvents: true

        onClicked: {
            // Пропускаем клик только если не нажата кнопка
            if (!editMouseArea.containsMouse && !deleteMouseArea.containsMouse) {
                mouse.accepted = false;
            }
        }
    }
}
