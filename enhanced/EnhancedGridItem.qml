// enhanced/EnhancedGridItem.qml
import QtQuick 2.15

Rectangle {
    id: gridItem
    width: 180
    height: 150
    radius: 12
    color: itemMouseArea.containsMouse ? "#f8f9fa" : "#ffffff"
    border.color: itemMouseArea.containsMouse ? "#3498db" : "#e0e0e0"
    border.width: 2

    scale: itemMouseArea.containsMouse ? 1.01 : 1.0

    property var itemData: null
    property string itemType: ""

    signal editRequested(var data)
    signal deleteRequested(var data)

    Behavior on color {
        ColorAnimation { duration: 200 }
    }

    Behavior on border.color {
        ColorAnimation { duration: 200 }
    }

    Column {
        anchors.centerIn: parent
        width: parent.width - 20
        spacing: 8

        // Аватар/иконка
        Rectangle {
            width: 60
            height: 60
            radius: 30
            color: {
                if (itemType === "teacher") return "#3498db";
                if (itemType === "student") return "#2ecc71";
                if (itemType === "group") return "#e74c3c";
                return "#95a5a6";
            }
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                anchors.centerIn: parent
                text: {
                    if (itemType === "teacher") return "👨‍🏫";
                    if (itemType === "student") return "👨‍🎓";
                    if (itemType === "group") return "👥";
                    return "❓";
                }
                font.pixelSize: 20
            }
        }

        // Основная информация
        Column {
            width: parent.width
            spacing: 4

            Text {
                text: {
                    if (itemType === "teacher") {
                        var lastName = itemData.lastName || "";
                        var firstName = itemData.firstName || "";
                        var middleName = itemData.middleName || "";
                        return lastName + "\n" + firstName + " " + middleName;
                    } else if (itemType === "student") {
                        var last_name = itemData.last_name || itemData.lastName || "";
                        var first_name = itemData.first_name || itemData.firstName || "";
                        var middle_name = itemData.middle_name || itemData.middleName || "";
                        return last_name + "\n" + first_name + " " + middle_name;
                    } else if (itemType === "group") {
                        return itemData.name || "Без названия";
                    } else if (itemType === "event") {
                        return itemData.eventType || "Без типа";
                    } else if (itemType === "portfolio") {
                        return itemData.description || "Без описания";
                    }
                    return "Неизвестный тип";
                }
                font.pixelSize: 12
                font.bold: true
                color: "#2c3e50"
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
                maximumLineCount: 2
                elide: Text.ElideRight
            }

            Text {
                text: {
                    if (itemType === "teacher") {
                        return "Опыт: " + (itemData.experience || 0) + " лет";
                    } else if (itemType === "student") {
                        return "Группа: " + (itemData.groupName || itemData.group_name || "Не указана");
                    } else if (itemType === "group") {
                        return "Студентов: " + (itemData.studentCount || 0);
                    } else if (itemType === "event") {
                        return "Категория: " + (itemData.eventCategoryName || "Не указана");
                    } else if (itemType === "portfolio") {
                        return "Студент: " + (itemData.studentName || "Не указан");
                    }
                    return "";
                }
                font.pixelSize: 10
                color: "#7f8c8d"
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
                elide: Text.ElideRight
            }
        }
    }

    // Кнопки действий - ВСЕГДА на переднем плане
    Row {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 6
        spacing: 4
        z: 1000 // Очень высокий z-index

        Rectangle {
            id: editButton
            width: 25
            height: 25
            radius: 5
            color: editMouseArea.containsMouse ? "#3498db" : "transparent"
            border.color: editMouseArea.containsMouse ? "#2980b9" : "#3498db"
            border.width: 1
            z: 1001

            Text {
                anchors.centerIn: parent
                text: "✏️"
                font.pixelSize: 10
                z: 1002
            }

            MouseArea {
                id: editMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                z: 1003
                onClicked: {
                    console.log("✏️ GridItem: редактирование запрошено для", gridItem.itemData);
                    gridItem.editRequested(gridItem.itemData);
                }
            }
        }

        Rectangle {
            id: deleteButton
            width: 25
            height: 25
            radius: 5
            color: deleteMouseArea.containsMouse ? "#e74c3c" : "transparent"
            border.color: deleteMouseArea.containsMouse ? "#c0392b" : "#e74c3c"
            border.width: 1
            z: 1001

            Text {
                anchors.centerIn: parent
                text: "🗑️"
                font.pixelSize: 10
                z: 1002
            }

            MouseArea {
                id: deleteMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                z: 1003
                onClicked: {
                    console.log("🗑️ GridItem: удаление запрошено для", gridItem.itemData);
                    gridItem.deleteRequested(gridItem.itemData);
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
