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
        isLoading = true;
        mainWindow.mainApi.getEvents(function(response) {
            isLoading = false;
            if (response && response.success) {
                console.log("✅ Данные событий получены:", JSON.stringify(response.data));

                // 🔥 ИСПРАВЛЕНИЕ: response.data уже содержит массив событий
                var eventsData = response.data || [];
                var processedEvents = [];

                console.log("📊 Количество событий от сервера:", eventsData.length);

                for (var i = 0; i < eventsData.length; i++) {
                    var event = eventsData[i];
                    console.log("📋 Обработка события " + i + ":", JSON.stringify(event));

                    // 🔥 УЛУЧШЕННОЕ ПРЕОБРАЗОВАНИЕ: используем все возможные варианты полей
                    var processedEvent = {
                        // Основные идентификаторы
                        id: event.id || event.eventId || 0,
                        eventId: event.eventId || event.event_id || 0,

                        // 🔥 ВАЖНОЕ ИСПРАВЛЕНИЕ: правильное получение категории
                        category: event.category || "",
                        eventCategory: event.category || "", // Дублируем для таблицы

                        // Основные поля события
                        eventType: event.eventType || event.event_type || "",
                        startDate: event.startDate || event.start_date || "",
                        endDate: event.endDate || event.end_date || "",
                        location: event.location || "",
                        lore: event.lore || "",

                        // Дополнительные поля
                        maxParticipants: event.maxParticipants || event.max_participants || 0,
                        currentParticipants: event.currentParticipants || event.current_participants || 0,
                        status: event.status || "active"
                    };

                    // 🔥 ДЕБАГ: логируем категорию
                    console.log("   🏷️ Категория события " + i + ":", processedEvent.category);
                    console.log("   🏷️ eventCategory события " + i + ":", processedEvent.eventCategory);

                    processedEvents.push(processedEvent);
                }

                eventsView.events = processedEvents;
                console.log("✅ События обработаны:", eventsView.events.length);

                if (eventsView.events.length > 0) {
                    console.log("📊 Первое событие:", JSON.stringify(eventsView.events[0]));
                    console.log("🏷️ Категория первого события:", eventsView.events[0].category);
                    console.log("🏷️ eventCategory первого события:", eventsView.events[0].eventCategory);
                } else {
                    console.log("⚠️ Нет событий для отображения");
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

                if (eventsView.eventCategories.length > 0) {
                    console.log("📊 Первая категория:", JSON.stringify(eventsView.eventCategories[0]));
                }

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
            console.log("📨 Ответ добавления события:", response);

            if (response && response.success) {
                showMessage("✅ " + ((response.message || response.data?.message) || "Событие успешно добавлено"), "success");
                if (eventFormWindow.item) {
                    eventFormWindow.close();
                }
                refreshEvents();
            } else {
                var errorMsg = response?.error || "Неизвестная ошибка";
                showMessage("❌ Ошибка добавления события: " + errorMsg, "error");
                if (eventFormWindow.item) {
                    eventFormWindow.item.isSaving = false;
                }
            }
        });
    }

    function updateEvent(eventData) {
        if (!eventData) {
            showMessage("❌ Данные события не указаны", "error")
            return
        }

        var uniqueEventId = eventData.id
        if (!uniqueEventId) {
            showMessage("❌ ID события не указан", "error")
            return
        }

        isLoading = true
        console.log("🔄 ОБНОВЛЕНИЕ События - ДЕТАЛИ:")
        console.log("   Уникальный ID события:", uniqueEventId)
        console.log("   Данные для обновления:", JSON.stringify(eventData))

        var updateData = {
            eventType: eventData.eventType,
            measureCode: eventData.measureCode,
            startDate: eventData.startDate,
            endDate: eventData.endDate,
            location: eventData.location,
            lore: eventData.lore,
            category: eventData.eventCategory // НАИМЕНОВАНИЕ категории
        }

        console.log("   Данные для отправки:", JSON.stringify(updateData))

        mainWindow.mainApi.updateEvent(uniqueEventId, updateData, function(response) {
            isLoading = false
            console.log("📨 ОТВЕТ ОБНОВЛЕНИЯ:", JSON.stringify(response))

            if (response && response.success) {
                showMessage("✅ " + ((response.message || response.data && response.data.message) || "Событие успешно обновлено"), "success")
                if (eventFormWindow.item) {
                    eventFormWindow.close()
                }
                refreshEvents()
            } else {
                var errorMsg = response && response.error ? response.error : "Неизвестная ошибка"
                console.log("❌ ОШИБКА ОБНОВЛЕНИЯ:", errorMsg)
                showMessage("❌ Ошибка обновления события: " + errorMsg, "error")
                if (eventFormWindow.item) {
                    eventFormWindow.item.isSaving = false
                }
            }
        })
    }

    function deleteEvent(eventId, eventName) {
        if (!eventId) {
            showMessage("❌ ID события не указан", "error");
            return;
        }

        var uniqueEventId = eventId;

        console.log("🗑️ Удаление события:", "Уникальный ID:", uniqueEventId, "Название:", eventName);

        if (confirm("Вы уверены, что хотите удалить событие:\n" + (eventName || "Без названия") + "?")) {
            isLoading = true;

            mainWindow.mainApi.deleteEvent(uniqueEventId, function(response) {
                isLoading = false;
                if (response && response.success) {
                    showMessage("✅ " + ((response.message || response.data && response.data.message) || "Событие успешно удалено"), "success");
                    refreshEvents();
                } else {
                    var errorMsg = response && response.error ? response.error : "Неизвестная ошибка";
                    console.log("❌ Ошибка удаления события:", errorMsg);
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

            // 🔥 ОБНОВЛЕННЫЕ ЗАГОЛОВКИ СТОЛБЦОВ
            property var customHeaders: ({
                "eventCategory": "Наименование категории",
                "eventType": "Тип события",
                "startDate": "Дата начала",
                "endDate": "Дата окончания",
                "location": "Место проведения",
                "lore": "Описание",
                "status": "Статус"
            })

            // 🔥 ДОБАВЛЕНО: кастомное отображение для категории
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
                console.log("📅 Двойной клик по событию:", itemData);
                if (eventFormWindow.item) {
                    eventFormWindow.openForEdit(itemData);
                } else {
                    eventFormWindow.active = true;
                }
            }

            onItemEditRequested: function(itemData) {
                if (!itemData) return;
                console.log("✏️ EventsView: редактирование запрошено для", itemData);
                console.log("🏷️ Категория события:", itemData.category);
                console.log("🏷️ eventCategory события:", itemData.eventCategory);

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
                console.log("🗑️ EventsView: удаление запрошено для", eventName, "Уникальный ID:", uniqueEventId);
                deleteEvent(uniqueEventId, eventName);
            }
        }
    }

    // Загрузчик формы события
    Loader {
        id: eventFormWindow
        source: "../forms/EventFormWindow.qml"
        active: true

        onLoaded: {
            console.log("✅ EventFormWindow загружен")

            if (item) {
                item.saved.connect(function(eventData) {
                    console.log("💾 Сохранение события:", JSON.stringify(eventData));
                    if (!eventData) return;

                    // Определяем режим по наличию ID
                    if (eventData.id && eventData.id !== 0) {
                        console.log("🔧 Режим редактирования, ID:", eventData.id);
                        updateEvent(eventData);
                    } else {
                        console.log("➕ Режим добавления нового события");
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
