import QtQuick
import QtQuick.Layouts 1.15
import QtQuick.Controls
import "../../enhanced" as Enhanced

Item {
    id: eventsView

    property var events: []
    property var eventCategories: []
    property bool isLoading: false
    property bool isMobile: Qt.platform.os === "android" || Qt.platform.os === "ios" ||
                           Qt.platform.os === "tvos" || Qt.platform.os === "wasm"

    function refreshEvents() {
        isLoading = true;
        mainWindow.mainApi.getEvents(function(response) {
            isLoading = false;
            if (response && response.success) {
                var eventsData = response.data || [];
                var processedEvents = [];

                for (var i = 0; i < eventsData.length; i++) {
                    var event = eventsData[i];

                    var processedEvent = {
                        id: event.id || event.eventId || 0,
                        eventId: event.eventId || event.event_id || 0,
                        category: event.category || "",
                        eventCategory: event.category || "",
                        eventType: event.eventType || event.event_type || "",
                        startDate: event.startDate || event.start_date || "",
                        endDate: event.endDate || event.end_date || "",
                        location: event.location || "",
                        lore: event.lore || "",
                        maxParticipants: event.maxParticipants || event.max_participants || 0,
                        currentParticipants: event.currentParticipants || event.current_participants || 0,
                        status: event.status || "active"
                    };

                    processedEvents.push(processedEvent);
                }

                eventsView.events = processedEvents;
            } else {
                var errorMsg = response && response.error ? response.error : "Неизвестная ошибка";
                showMessage("Ошибка загрузки событий: " + errorMsg, "error");
            }
        });
    }

    function refreshEventCategories() {
        mainWindow.mainApi.getEventCategories(function(response) {
            if (response && response.success) {
                eventsView.eventCategories = response.data || [];

                refreshEvents();
            } else {
                var errorMsg = response && response.error ? response.error : "Неизвестная ошибка";
                showMessage("Ошибка загрузки категорий событий: " + errorMsg, "error");
            }
        });
    }

    function showMessage(text, type) {
        if (mainWindow && mainWindow.showMessage) {
            mainWindow.showMessage(text, type);
        }
    }

    function addEvent(eventData) {
        if (!eventData) {
            showMessage("Данные события не указаны", "error");
            return;
        }

        isLoading = true;

        mainWindow.mainApi.addEvent(eventData, function(response) {
            isLoading = false;

            if (response && response.success) {
                showMessage("" + ((response.message || response.data?.message) || "Событие успешно добавлено"), "success");
                if (eventFormWindow.item) {
                    eventFormWindow.close();
                }
                refreshEvents();
            } else {
                var errorMsg = response?.error || "Неизвестная ошибка";
                showMessage("Ошибка добавления события: " + errorMsg, "error");
                if (eventFormWindow.item) {
                    eventFormWindow.item.isSaving = false;
                }
            }
        });
    }

    function updateEvent(eventData) {
        if (!eventData) {
            showMessage("Данные события не указаны", "error")
            return
        }

        var uniqueEventId = eventData.id
        if (!uniqueEventId) {
            showMessage("ID события не указан", "error")
            return
        }

        isLoading = true

        var updateData = {
            eventType: eventData.eventType,
            measureCode: eventData.measureCode,
            startDate: eventData.startDate,
            endDate: eventData.endDate,
            location: eventData.location,
            lore: eventData.lore,
            category: eventData.category
        }

        mainWindow.mainApi.updateEvent(uniqueEventId, updateData, function(response) {
            isLoading = false

            if (response && response.success) {
                showMessage("" + ((response.message || response.data && response.data.message) || "Событие успешно обновлено"), "success")
                if (eventFormWindow.item) {
                    eventFormWindow.close()
                }
                refreshEvents()
            } else {
                var errorMsg = response && response.error ? response.error : "Неизвестная ошибка"
                showMessage("Ошибка обновления события: " + errorMsg, "error")
                if (eventFormWindow.item) {
                    eventFormWindow.item.isSaving = false
                }
            }
        })
    }

    function deleteEvent(eventId, eventName) {
        if (!eventId) {
            showMessage("ID события не указан", "error");
            return;
        }

        var uniqueEventId = eventId;

        if (confirm("Вы уверены, что хотите удалить событие:\n" + (eventName || "Без названия") + "?")) {
            isLoading = true;

            mainWindow.mainApi.deleteEvent(uniqueEventId, function(response) {
                isLoading = false;
                if (response && response.success) {
                    showMessage("" + ((response.message || response.data && response.data.message) || "Событие успешно удалено"), "success");
                    refreshEvents();
                } else {
                    var errorMsg = response && response.error ? response.error : "Неизвестная ошибка";
                    showMessage("Ошибка удаления события: " + errorMsg, "error");
                }
            });
        }
    }

    function confirm(message) {
        return true;
    }

    Component.onCompleted: {
        refreshEventCategories();
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 15

        Column {
            Layout.fillWidth: true
            spacing: 8

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10

                Image {
                    source: "qrc:/icons/events.png"
                    sourceSize: Qt.size(24, 24)
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "Управление событиями"
                    font.pixelSize: 20
                    font.bold: true
                    color: "#2c3e50"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: "#e0e0e0"
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 50
            radius: 8
            color: "#e67e22"
            border.color: "#d35400"
            border.width: 1

            // Мобильная версия - центрированные большие кнопки
            Row {
                anchors.centerIn: parent
                spacing: isMobile ? 30 : 15
                visible: isMobile

                // Кнопка обновления для мобильных
                Rectangle {
                    width: 50
                    height: 50
                    radius: 25
                    color: refreshMouseAreaMobile.containsPress ? "#d35400" : "transparent"

                    Image {
                        source: "qrc:/icons/refresh.png"
                        sourceSize: Qt.size(28, 28)
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        id: refreshMouseAreaMobile
                        anchors.fill: parent
                        onClicked: refreshEvents()
                    }
                }

                // Текст счетчика для мобильных
                Text {
                    text: "Всего: " + (events ? events.length : 0)
                    color: "white"
                    font.pixelSize: 16
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Кнопка добавления для мобильных
                Rectangle {
                    width: 50
                    height: 50
                    radius: 25
                    color: addMouseAreaMobile.containsPress ? "#d35400" : "transparent"

                    Text {
                        text: "+"
                        color: "white"
                        font.pixelSize: 32
                        font.bold: true
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        id: addMouseAreaMobile
                        anchors.fill: parent
                        onClicked: {
                            if (eventFormWindow.item) {
                                eventFormWindow.openForAdd();
                            } else {
                                eventFormWindow.active = true;
                            }
                        }
                    }
                }
            }

            // Десктопная версия - без изменений
            Row {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 15
                visible: !isMobile

                Text {
                    text: "Всего событий: " + (events ? events.length : 0)
                    color: "white"
                    font.pixelSize: 14
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }

                Item { width: 20 }

                Rectangle {
                    width: 100
                    height: 30
                    radius: 6
                    color: refreshMouseAreaDesktop.containsMouse ? "#d35400" : "#e67e22"
                    border.color: refreshMouseAreaDesktop.containsMouse ? "#a04000" : "white"
                    border.width: 2

                    Row {
                        anchors.centerIn: parent
                        spacing: 5

                        Image {
                            source: "qrc:/icons/refresh.png"
                            sourceSize: Qt.size(20, 20)
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "Обновить"
                            color: "white"
                            font.pixelSize: 12
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: refreshMouseAreaDesktop
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: refreshEvents()
                    }
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    width: 150
                    height: 30
                    radius: 6
                    color: addMouseAreaDesktop.containsMouse ? "#d35400" : "#e67e22"
                    border.color: addMouseAreaDesktop.containsMouse ? "#a04000" : "white"
                    border.width: 2

                    Row {
                        anchors.centerIn: parent
                        spacing: 5

                        Image {
                            source: "qrc:/icons/events.png"
                            sourceSize: Qt.size(12, 12)
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "Добавить событие"
                            color: "white"
                            font.pixelSize: 12
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: addMouseAreaDesktop
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (eventFormWindow.item) {
                                eventFormWindow.openForAdd();
                            } else {
                                eventFormWindow.active = true;
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 30
            radius: 6
            color: "#fff3cd"
            border.color: "#ffeaa7"
            border.width: 1
            visible: isLoading

            Row {
                anchors.centerIn: parent
                spacing: 10

                Image {
                    source: "qrc:/icons/loading.png"
                    sourceSize: Qt.size(14, 14)
                }

                Text {
                    text: "Загрузка данных..."
                    color: "#856404"
                    font.pixelSize: 12
                    font.bold: true
                }
            }
        }

        Enhanced.EnhancedTableView {
            id: eventsTable
            Layout.fillWidth: true
            Layout.fillHeight: true
            sourceModel: eventsView.events || []
            itemType: "event"
            searchPlaceholder: "Поиск события..."
            sortOptions: ["По наименованию", "По типу", "По дате начала", "По статусу", "По месту проведения"]
            sortRoles: ["eventCategory", "eventType", "startDate", "status", "location"]

            property var customHeaders: ({
                "eventCategory": "Наименование категории",
                "eventType": "Тип события",
                "startDate": "Дата начала",
                "endDate": "Дата окончания",
                "location": "Место проведения",
                "lore": "Описание",
                "status": "Статус"
            })

            property var customDisplay: ({
                "category": function(value, item) {
                    return value || "Без категории";
                },
                "startDate": function(value, item) {
                    return value || "Не указана";
                },
                "endDate": function(value, item) {
                    return value || "Не указана";
                }
            })

            onItemDoubleClicked: function(itemData) {
                if (eventFormWindow.item) {
                    eventFormWindow.openForEdit(itemData);
                } else {
                    eventFormWindow.active = true;
                }
            }

            onItemEditRequested: function(itemData) {
                if (!itemData) return;

                if (eventFormWindow.item) {
                    eventFormWindow.openForEdit(itemData);
                } else {
                    eventFormWindow.active = true;
                }
            }

            onItemDeleteRequested: function(itemData) {
                if (!itemData) return;
                var uniqueEventId = itemData.id;
                var eventName = itemData.eventType || itemData.category || "Без названия";
                deleteEvent(uniqueEventId, eventName);
            }
        }
    }

    // Загрузчик формы события
    Loader {
        id: eventFormWindow
        source: isMobile ? "../forms/EventFormMobile.qml" : "../forms/EventFormWindow.qml"
        active: true

        onLoaded: {
            if (item) {
                item.saved.connect(function(eventData) {
                    if (!eventData) return;

                    if (eventData.id && eventData.id !== 0) {
                        updateEvent(eventData);
                    } else {
                        addEvent(eventData);
                    }
                });

                item.cancelled.connect(function() {
                    if (item) {
                        item.closeWindow();
                    }
                });
            }
        }

        function openForAdd() {
                if (eventFormWindow.item) {
                    eventFormWindow.item.eventCategories = eventsView.eventCategories || [];
                    eventFormWindow.item.openForAdd();
                } else {
                    eventFormWindow.active = true;
                }
            }

            function openForEdit(eventData) {
                if (eventFormWindow.item) {
                    eventFormWindow.item.eventCategories = eventsView.eventCategories || [];
                    eventFormWindow.item.openForEdit(eventData);
                } else {
                    eventFormWindow.active = true;
                }
            }

            function close() {
                if (eventFormWindow.item) {
                    eventFormWindow.item.closeWindow();
                }
            }
    }
}
