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

    Column {
        anchors.fill: parent
        anchors.margins: 12
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
                        var last_name = itemData.last_name || "";
                        var first_name = itemData.first_name || "";
                        var middle_name = itemData.middle_name || "";
                        return last_name + "\n" + first_name + " " + middle_name;
                    } else if (itemType === "group") {
                        return itemData.name || "Без названия";
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
                        return "Группа: " + (itemData.group_id || "Не указана");
                    } else if (itemType === "group") {
                        return "Студентов: " + (itemData.studentCount || 0);
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

        // Кнопки действий
        Row {
            spacing: 8
            anchors.horizontalCenter: parent.horizontalCenter

            Rectangle {
                id: editButton
                width: 25
                height: 25
                radius: 5
                color: editMouseArea.containsMouse ? "#3498db" : "transparent"
                border.color: editMouseArea.containsMouse ? "#2980b9" : "#3498db"
                border.width: 2

                Text {
                    anchors.centerIn: parent
                    text: "✏️"
                    font.pixelSize: 10
                }

                MouseArea {
                    id: editMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: gridItem.editRequested(gridItem.itemData)
                }
            }

            Rectangle {
                id: deleteButton
                width: 25
                height: 25
                radius: 5
                color: deleteMouseArea.containsMouse ? "#e74c3c" : "transparent"
                border.color: deleteMouseArea.containsMouse ? "#c0392b" : "#e74c3c"
                border.width: 2

                Text {
                    anchors.centerIn: parent
                    text: "🗑️"
                    font.pixelSize: 10
                }

                MouseArea {
                    id: deleteMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: gridItem.deleteRequested(gridItem.itemData)
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
