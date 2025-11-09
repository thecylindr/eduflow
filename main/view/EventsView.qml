import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "../../enhanced" as Enhanced

Item {
    id: eventsView

    property var events: []
    property var eventCategories: []
    property bool isLoading: false

    function refreshEvents() {
        console.log("🔄 Загрузка событий...");
        isLoading = true;
        mainWindow.mainApi.getEvents(function(response) {
            isLoading = false;
            if (response && response.success) {
                console.log("✅ Данные событий получены:", JSON.stringify(response.data));
                var eventsData = response.data || [];
                var processedEvents = [];

                for (var i = 0; i < eventsData.length; i++) {
                    var event = eventsData[i];
                    console.log("📋 Обработка события:", JSON.stringify(event));

                    var processedEvent = {
                        eventId: event.eventId || event.event_id || 0,
                        eventCategory: event.eventCategory || event.event_category || 0,
                        eventCategoryName: getCategoryName(event.eventCategory || event.event_category),
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
                console.log("✅ События обработаны:", eventsView.events.length);

                // Проверяем, что данные правильно установлены
                if (eventsView.events.length > 0) {
                    console.log("📊 Первое событие:", JSON.stringify(eventsView.events[0]));
                }
            } else {
                var errorMsg = response && response.error ? response.error : "Неизвестная ошибка";
                console.log("❌ Ошибка загрузки событий:", errorMsg);
                showMessage("❌ Ошибка загрузки событий: " + errorMsg, "error");
            }
        });
    }

    function refreshEventCategories() {
        console.log("📂 Загрузка категорий событий...");
        mainWindow.mainApi.getEventCategories(function(response) {
            if (response && response.success) {
                eventsView.eventCategories = response.data || [];
                console.log("✅ Категории событий загружены:", eventsView.eventCategories.length);

                // Загружаем события после загрузки категорий
                refreshEvents();
            } else {
                var errorMsg = response && response.error ? response.error : "Неизвестная ошибка";
                console.log("❌ Ошибка загрузки категорий событий:", errorMsg);
                showMessage("❌ Ошибка загрузки категорий событий: " + errorMsg, "error");
            }
        });
    }

    function showMessage(text, type) {
        if (mainWindow && mainWindow.showMessage) {
            mainWindow.showMessage(text, type);
        }
    }

    function getCategoryName(categoryId) {
        if (!categoryId || !eventCategories || !Array.isArray(eventCategories)) {
            return "Без категории";
        }

        for (var i = 0; i < eventCategories.length; i++) {
            var category = eventCategories[i];
            if (category && category.event_category_id === categoryId) {
                return category.name || "Без названия";
            }
        }
        return "Неизвестная категория";
    }

    // CRUD функции для событий
    function addEvent(eventData) {
        if (!eventData) {
            showMessage("❌ Данные события не указаны", "error");
            return;
        }

        isLoading = true;
        console.log("➕ Добавление события:", JSON.stringify(eventData));

        mainWindow.mainApi.addEvent(eventData, function(response) {
            isLoading = false;
            if (response && response.success) {
                showMessage("✅ " + ((response.message || response.data && response.data.message) || "Событие успешно добавлено"), "success");
                if (eventFormWindow.item) {
                    eventFormWindow.close();
                }
                refreshEvents();
            } else {
                var errorMsg = response && response.error ? response.error : "Неизвестная ошибка";
                showMessage("❌ Ошибка добавления события: " + errorMsg, "error");
                if (eventFormWindow.item) {
                    eventFormWindow.item.isSaving = false;
                }
            }
        });
    }

    function updateEvent(eventData) {
        if (!eventData) {
            showMessage("❌ Данные события не указаны", "error");
            return;
        }

        var eventId = eventData.event_id || eventData.eventId;
        if (!eventId) {
            showMessage("❌ ID события не указан", "error");
            return;
        }

        isLoading = true;
        console.log("🔄 Обновление события ID:", eventId, "Данные:", JSON.stringify(eventData));

        mainWindow.mainApi.updateEvent(eventId, eventData, function(response) {
            isLoading = false;
            if (response && response.success) {
                showMessage("✅ " + ((response.message || response.data && response.data.message) || "Событие успешно обновлено"), "success");
                if (eventFormWindow.item) {
                    eventFormWindow.close();
                }
                refreshEvents();
            } else {
                var errorMsg = response && response.error ? response.error : "Неизвестная ошибка";
                showMessage("❌ Ошибка обновления события: " + errorMsg, "error");
                if (eventFormWindow.item) {
                    eventFormWindow.item.isSaving = false;
                }
            }
        });
    }

    function deleteEvent(eventId, eventName) {
        if (!eventId) {
            showMessage("❌ ID события не указан", "error");
            return;
        }

        if (confirm("Вы уверены, что хотите удалить событие:\n" + (eventName || "Без названия") + "?")) {
            isLoading = true;
            mainWindow.mainApi.deleteEvent(eventId, function(response) {
                isLoading = false;
                if (response && response.success) {
                    showMessage("✅ " + ((response.message || response.data && response.data.message) || "Событие успешно удалено"), "success");
                    refreshEvents();
                } else {
                    var errorMsg = response && response.error ? response.error : "Неизвестная ошибка";
                    showMessage("❌ Ошибка удаления события: " + errorMsg, "error");
                }
            });
        }
    }

    function confirm(message) {
        console.log("Подтверждение:", message);
        return true;
    }

    Component.onCompleted: {
        console.log("EventsView: Component.onCompleted");
        refreshEventCategories();
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 15

        Column {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: "📅 Управление событиями"
                font.pixelSize: 20
                font.bold: true
                color: "#2c3e50"
                anchors.horizontalCenter: parent.horizontalCenter
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

            Row {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 15

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
                    color: refreshMouseArea.containsMouse ? "#d35400" : "#e67e22"
                    border.color: refreshMouseArea.containsMouse ? "#a04000" : "white"
                    border.width: 2

                    Row {
                        anchors.centerIn: parent
                        spacing: 5

                        Text {
                            text: "🔄"
                            font.pixelSize: 12
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
                        id: refreshMouseArea
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
                    color: addMouseArea.containsMouse ? "#d35400" : "#e67e22"
                    border.color: addMouseArea.containsMouse ? "#a04000" : "white"
                    border.width: 2

                    Row {
                        anchors.centerIn: parent
                        spacing: 5

                        Text {
                            text: "➕"
                            font.pixelSize: 12
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
                        id: addMouseArea
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

                Text {
                    text: "⏳"
                    font.pixelSize: 14
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
            searchPlaceholder: "Поиск событий..."
            sortOptions: ["По категории", "По типу", "По дате начала", "По статусу"]
            sortRoles: ["eventCategoryName", "eventType", "startDate", "status"]

            onItemEditRequested: function(itemData) {
                if (!itemData) return;
                console.log("✏️ EventsView: редактирование запрошено для", itemData);
                if (eventFormWindow.item) {
                    eventFormWindow.openForEdit(itemData);
                } else {
                    eventFormWindow.active = true;
                }
            }

            onItemDeleteRequested: function(itemData) {
                if (!itemData) return;
                var eventId = itemData.eventId;
                var eventName = itemData.eventType || "Без названия";
                console.log("🗑️ EventsView: удаление запрошено для", eventName, "ID:", eventId);
                deleteEvent(eventId, eventName);
            }
        }
    }

    // Загрузчик формы события
    Loader {
        id: eventFormWindow
        source: "../forms/EventFormWindow.qml"
        active: true

        onLoaded: {
            console.log("✅ EventFormWindow загружен");

            if (item) {
                item.saved.connect(function(eventData) {
                    console.log("💾 Сохранение события:", JSON.stringify(eventData));
                    if (!eventData) return;

                    if (eventData.event_id && eventData.event_id !== 0) {
                        updateEvent(eventData);
                    } else {
                        addEvent(eventData);
                    }
                });

                item.cancelled.connect(function() {
                    console.log("❌ Отмена редактирования события");
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
