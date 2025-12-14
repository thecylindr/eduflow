import QtQuick

Rectangle {
    id: gridItem
    width: {
        if (isMobile) {
            // В мобильной версии ширина рассчитывается для 2 элементов в ряд
            var availableWidth = parent ? parent.width : 160;
            var spacing = 10; // Отступ между элементами
            return (availableWidth - spacing) / 2;
        } else {
            return 180; // Фиксированная ширина для десктопа
        }
    }
    height: isMobile ? 140 : 160
    radius: isMobile ? 10 : 12
    color: itemMouseArea.containsMouse ? "#f8f9fa" : "#ffffff"
    border.color: itemMouseArea.containsMouse ? "#3498db" : "#e0e0e0"
    border.width: 1

    scale: itemMouseArea.containsMouse ? 1.02 : 1.0

    property var itemData: null
    property string itemType: ""
    property bool isMobile: false

    signal editRequested(var data)
    signal doubleClicked(var data)
    signal deleteRequested(var data)

    // Функция для форматирования даты в дд.мм.гггг
    function formatDate(dateString) {
        if (!dateString) return "";

        try {
            var date = new Date(dateString);
            if (isNaN(date.getTime())) return dateString;

            var day = date.getDate().toString().padStart(2, '0');
            var month = (date.getMonth() + 1).toString().padStart(2, '0');
            var year = date.getFullYear();

            return day + "." + month + "." + year;
        } catch(e) {
            return dateString;
        }
    }

    // Функция для проверки активности события
    function isEventActive(eventData) {
        var status = eventData.status || "active";

        // Если статус не "active", возвращаем false
        if (status !== "active") return false;

        var startDate = eventData.startDate;
        if (!startDate) return true; // Если даты нет, считаем активным

        try {
            var eventDate = new Date(startDate);
            var today = new Date();

            // Сбрасываем время для сравнения только дат
            eventDate.setHours(0, 0, 0, 0);
            today.setHours(0, 0, 0, 0);

            // Событие активно, если его дата сегодня или в будущем
            return eventDate >= today;
        } catch(e) {
            return true;
        }
    }

    Behavior on color {
        ColorAnimation { duration: 200 }
    }

    Behavior on border.color {
        ColorAnimation { duration: 200 }
    }

    Behavior on scale {
        NumberAnimation { duration: 150 }
    }

    Column {
        anchors.centerIn: parent
        width: parent.width - (isMobile ? 16 : 20)
        spacing: isMobile ? 6 : 8

        Rectangle {
            width: isMobile ? 48 : 60
            height: isMobile ? 48 : 60
            radius: isMobile ? 24 : 30
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
                width: isMobile ? 24 : 30
                height: isMobile ? 24 : 30
                fillMode: Image.PreserveAspectFit
            }
        }

        Column {
            width: parent.width
            spacing: isMobile ? 3 : 4

            Text {
                text: {
                    if (itemType === "teacher") {
                        var lastName = itemData.lastName || "";
                        var firstName = itemData.firstName || "";
                        return isMobile ? lastName : (lastName + "\n" + firstName);
                    } else if (itemType === "student") {
                        var last_name = itemData.last_name || itemData.lastName || "";
                        var first_name = itemData.first_name || itemData.firstName || "";
                        return isMobile ? last_name : (last_name + "\n" + first_name);
                    } else if (itemType === "group") {
                        return itemData.name || "Без названия";
                    } else if (itemType === "event") {
                        var eventType = itemData.eventType || "Без типа";
                        var category = itemData.category || itemData.eventCategory || "Без наименования";
                        return isMobile ? eventType : (eventType + " • " + category);
                    } else if (itemType === "portfolio") {
                        var studentName = itemData.studentName || "Неизвестный студент";
                        var decree = itemData.decree || "";
                        if (decree) {
                            return isMobile ? "Портфолио #" + decree : "Портфолио студента\n#" + decree;
                        } else {
                            return isMobile ? "Портфолио" : "Портфолио студента\n" + studentName;
                        }
                    }
                    return "Неизвестный тип";
                }
                font.pixelSize: isMobile ? 12 : 13
                font.bold: true
                color: "#2c3e50"
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
                maximumLineCount: isMobile ? 2 : 3
                elide: Text.ElideRight
            }

            Text {
                text: {
                    if (itemType === "teacher") {
                        return "Опыт: " + (itemData.experience || 0) + " лет";
                    } else if (itemType === "student") {
                        var group = itemData.groupName || itemData.group_name || "Не указана";
                        return isMobile ? group : ("Группа: " + group);
                    } else if (itemType === "group") {
                        return "Студентов: " + (itemData.studentCount || 0);
                    } else if (itemType === "event") {
                        var location = itemData.location || "Место не указано";
                        var date = itemData.startDate || "";
                        var status = itemData.status || "active";

                        // Форматируем дату
                        var formattedDate = date ? formatDate(date) : "";

                        // Проверяем активность события
                        var statusText = "";
                        if (status === "active") {
                            statusText = isEventActive(itemData) ? "Активно" : "Неактивно";
                        } else if (status === "completed") {
                            statusText = "Завершено";
                        } else if (status === "cancelled") {
                            statusText = "Отменено";
                        } else {
                            statusText = status;
                        }

                        if (isMobile) {
                            return formattedDate || location;
                        } else {
                            if (formattedDate) {
                                return location + "\n" + formattedDate + " • " + statusText;
                            } else {
                                return location + "\n" + statusText;
                            }
                        }
                    } else if (itemType === "portfolio") {
                        var studentName = itemData.studentName || "Неизвестный студент";
                        var date = itemData.date || "";
                        var formattedDate = date ? formatDate(date) : "";

                        if (isMobile) {
                            return formattedDate || studentName;
                        } else {
                            if (formattedDate) {
                                return studentName + "\n" + formattedDate;
                            } else {
                                return studentName;
                            }
                        }
                    }
                    return "";
                }
                font.pixelSize: isMobile ? 10 : 11
                color: "#7f8c8d"
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
                wrapMode: Text.WordWrap
                maximumLineCount: isMobile ? 2 : 2
                elide: Text.ElideRight
            }
        }
    }

    Column {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: isMobile ? 6 : 8
        spacing: isMobile ? 4 : 6
        z: 1000

        Rectangle {
            id: editButton
            width: isMobile ? 26 : 28
            height: isMobile ? 26 : 28
            radius: isMobile ? 6 : 7
            color: editMouseArea.containsMouse ? "#3498db" : "transparent"
            border.color: editMouseArea.containsMouse ? "#2980b9" : "#3498db"
            border.width: 1
            z: 1001

            AnimatedImage {
                id: editIcon
                anchors.centerIn: parent
                source: editMouseArea.containsMouse ? "qrc:icons/pencil.gif" : "qrc:icons/pencil.png"
                width: isMobile ? 14 : 16
                height: isMobile ? 14 : 16
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
            width: isMobile ? 26 : 28
            height: isMobile ? 26 : 28
            radius: isMobile ? 6 : 7
            color: deleteMouseArea.containsMouse ? "#e74c3c" : "transparent"
            border.color: deleteMouseArea.containsMouse ? "#c0392b" : "#e74c3c"
            border.width: 1
            z: 1001

            Image {
                anchors.centerIn: parent
                source: "qrc:icons/cross.png"
                width: isMobile ? 14 : 16
                height: isMobile ? 14 : 16
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
