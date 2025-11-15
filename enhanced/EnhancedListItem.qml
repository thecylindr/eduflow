import QtQuick 2.15

Rectangle {
    id: listItem
    height: 60
    radius: 8
    color: itemMouseArea.containsMouse ? "#f8f9fa" : "#ffffff"
    border.color: itemMouseArea.containsMouse ? "#3498db" : "#e0e0e0"
    border.width: 1

    scale: itemMouseArea.containsMouse ? 1.01 : 1.0

    width: parent ? parent.width - 30 : 90
    anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined

    property var itemData: null
    property string itemType: ""

    signal editRequested(var data)
    signal doubleClicked(var data)
    signal deleteRequested(var data)

    Behavior on color {
        ColorAnimation { duration: 150 }
    }

    Behavior on border.color {
        ColorAnimation { duration: 150 }
    }

    Row {
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 12

        Rectangle {
            width: 40
            height: 40
            radius: 20
            color: {
                if (itemType === "teacher") return "#3498db";
                if (itemType === "student") return "#2ecc71";
                if (itemType === "group") return "#e74c3c";
                if (itemType === "event") return "#f39c12";
                if (itemType === "portfolio") return "#9b59b6";
                return "#95a5a6";
            }

            Image {
                anchors.centerIn: parent
                source: {
                    if (itemType === "teacher") return "qrc:icons/teachers.png";
                    if (itemType === "student") return "qrc:icons/students.png";
                    if (itemType === "group") return "qrc:icons/groups.png";
                    if (itemType === "event") return "qrc:icons/events.png";
                    if (itemType === "portfolio") return "qrc:icons/portfolio.png";
                    return "qrc:icons/info.png";
                }
                width: 20
                height: 20
                fillMode: Image.PreserveAspectFit
            }
        }

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
                    } else if (itemType === "event") {
                        var eventType = itemData.eventType || "Без типа";
                        var category = itemData.category || itemData.eventCategory || "Без наименования";
                        return eventType + "\n" + category;
                    } else if (itemType === "portfolio") {
                        var studentName = itemData.studentName || "Неизвестный студент";
                        var decree = itemData.decree || "";
                        if (decree) {
                            return "Портфолио студента #" + decree;
                        } else {
                            return "Портфолио студента " + studentName;
                        }
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
                    } else if (itemType === "event") {
                        var location = itemData.location || "Место не указано";
                        var date = itemData.startDate || "";
                        var status = itemData.status || "active";

                        var statusText = "";
                        if (status === "active") statusText = "Активно";
                        else if (status === "completed") statusText = "Завершено";
                        else if (status === "cancelled") statusText = "Отменено";
                        else statusText = status;

                        if (date) {
                            return location + " · " + date + " · " + statusText;
                        } else {
                            return location + " · " + statusText;
                        }
                    } else if (itemType === "portfolio") {
                        var studentName = itemData.studentName || "Неизвестный студент";
                        var date = itemData.date || "";
                        if (date) {
                            return studentName + " · " + date;
                        } else {
                            return studentName;
                        }
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

    Row {
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8
        z: 1000

        Rectangle {
            id: editButton
            width: 28
            height: 28
            radius: 6
            color: editMouseArea.containsMouse ? "#3498db" : "transparent"
            border.color: editMouseArea.containsMouse ? "#2980b9" : "#3498db"
            border.width: 1
            z: 1001

            AnimatedImage {
                id: editIcon
                anchors.centerIn: parent
                source: editMouseArea.containsMouse ? "qrc:icons/pencil.gif" : "qrc:icons/pencil.png"
                width: 14
                height: 14
                fillMode: Image.PreserveAspectFit
                playing: editMouseArea.containsMouse
            }

            MouseArea {
                id: editMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                z: 1003
                onClicked: {
                    console.log("ListItem: редактирование запрошено для", listItem.itemData);
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

            Image {
                anchors.centerIn: parent
                source: "qrc:icons/cross.png"
                width: 14
                height: 14
                fillMode: Image.PreserveAspectFit
            }

            MouseArea {
                id: deleteMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                z: 1003
                onClicked: {
                    console.log("ListItem: удаление запрошено для", listItem.itemData);
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

        onDoubleClicked: {
            console.log("ListItem: двойной клик по", listItem.itemData);
            listItem.doubleClicked(listItem.itemData);
        }

        onClicked: function(mouse) {
            if (!editMouseArea.containsMouse && !deleteMouseArea.containsMouse) {
                mouse.accepted = false;
            }
        }
    }
}
