import QtQuick

Rectangle {
    id: gridItem
    width: 180
    height: 150
    radius: 12
    color: itemMouseArea.containsMouse ? "#f8f9fa" : "#ffffff"
    border.color: itemMouseArea.containsMouse ? "#3498db" : "#e0e0e0"
    border.width: 1

    scale: itemMouseArea.containsMouse ? 1.01 : 1.0

    property var itemData: null
    property string itemType: ""

    signal editRequested(var data)
    signal doubleClicked(var data)
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

        Rectangle {
            width: 60
            height: 60
            radius: 30
            color: {
                if (itemType === "teacher") return "#3498db";
                if (itemType === "student") return "#2ecc71";
                if (itemType === "group") return "#e74c3c";
                if (itemType === "event") return "#f39c12";
                if (itemType === "portfolio") return "#9b59b6";
                return "#95a5a6";
            }
            anchors.horizontalCenter: parent.horizontalCenter

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
                width: 30
                height: 30
                fillMode: Image.PreserveAspectFit
            }
        }

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
                        var eventType = itemData.eventType || "Без типа";
                        var category = itemData.category || itemData.eventCategory || "Без наименования";
                        return eventType + " • " + category;
                    } else if (itemType === "portfolio") {
                        var studentName = itemData.studentName || "Неизвестный студент";
                        var decree = itemData.decree || "";
                        if (decree) {
                            return "Портфолио студента\n#" + decree;
                        } else {
                            return "Портфолио студента\n" + studentName;
                        }
                    }
                    return "Неизвестный тип";
                }
                font.pixelSize: 12
                font.bold: true
                color: "#2c3e50"
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
                maximumLineCount: 3
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
                        var location = itemData.location || "Место не указано";
                        var date = itemData.startDate || "";
                        var status = itemData.status || "active";

                        var statusText = "";
                        if (status === "active") statusText = "Активно";
                        else if (status === "completed") statusText = "Завершено";
                        else if (status === "cancelled") statusText = "Отменено";
                        else statusText = status;

                        if (date) {
                            return location + "\n" + date + " • " + statusText;
                        } else {
                            return location + "\n" + statusText;
                        }
                    } else if (itemType === "portfolio") {
                        var studentName = itemData.studentName || "Неизвестный студент";
                        var date = itemData.date || "";
                        if (date) {
                            return studentName + "\n" + date;
                        } else {
                            return studentName;
                        }
                    }
                    return "";
                }
                font.pixelSize: 10
                color: "#7f8c8d"
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }
        }
    }

    Row {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 6
        spacing: 4
        z: 1000

        Rectangle {
            id: editButton
            width: 25
            height: 25
            radius: 5
            color: editMouseArea.containsMouse ? "#3498db" : "transparent"
            border.color: editMouseArea.containsMouse ? "#2980b9" : "#3498db"
            border.width: 1
            z: 1001

            AnimatedImage {
                id: editIcon
                anchors.centerIn: parent
                source: editMouseArea.containsMouse ? "qrc:icons/pencil.gif" : "qrc:icons/pencil.png"
                width: 12
                height: 12
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
                    console.log("GridItem: редактирование запрошено для", gridItem.itemData);
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

            Image {
                anchors.centerIn: parent
                source: "qrc:icons/cross.png"
                width: 12
                height: 12
                fillMode: Image.PreserveAspectFit
            }

            MouseArea {
                id: deleteMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                z: 1003
                onClicked: {
                    console.log("GridItem: удаление запрошено для", gridItem.itemData);
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

        onDoubleClicked: {
            console.log("GridItem: двойной клик по", gridItem.itemData);
            gridItem.doubleClicked(gridItem.itemData);
        }

        onClicked: function(mouse) {
            if (!editMouseArea.containsMouse && !deleteMouseArea.containsMouse) {
                mouse.accepted = false;
            }
        }
    }
}
