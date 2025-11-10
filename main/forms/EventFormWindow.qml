import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../../common" as Common

ApplicationWindow {
    id: eventFormWindow
    width: 450
    height: 600
    flags: Qt.Dialog | Qt.FramelessWindowHint
    modality: Qt.ApplicationModal
    color: "transparent"
    visible: false

    property var currentEvent: null
    property bool isEditMode: false
    property bool isSaving: false
    property bool manualEntryMode: false
    property var eventCategories: [] // Сохраняем свойство для обратной совместимости

    signal saved(var eventData)
    signal cancelled()
    signal saveCompleted(bool success, string message)

    // Порядок навигации между полями
    property var fieldNavigation: [
        categoryModeSwitch, eventCategoryField, eventTypeField,
        startDateField, endDateField, locationField, loreField
    ]

    function openForAdd() {
        currentEvent = null
        isEditMode = false
        isSaving = false
        manualEntryMode = false
        clearForm()
        eventFormWindow.show()
        eventFormWindow.requestActivate()
        eventFormWindow.x = (Screen.width - eventFormWindow.width) / 2
        eventFormWindow.y = (Screen.height - eventFormWindow.height) / 2
        Qt.callLater(function() { categoryModeSwitch.forceActiveFocus() })
    }

    function openForEdit(eventData) {
        currentEvent = eventData
        isEditMode = true
        isSaving = false
        manualEntryMode = true // В режиме редактирования всегда ручной ввод
        fillForm(eventData)
        eventFormWindow.show()
        eventFormWindow.requestActivate()
        eventFormWindow.x = (Screen.width - eventFormWindow.width) / 2
        eventFormWindow.y = (Screen.height - eventFormWindow.height) / 2
        Qt.callLater(function() { categoryModeSwitch.forceActiveFocus() })
    }

    function closeWindow() {
        eventFormWindow.close()
    }

    function clearForm() {
        manualEntryMode = false
        eventCategoryField.text = ""
        eventTypeField.text = ""
        startDateField.text = ""
        endDateField.text = ""
        locationField.text = ""
        loreField.text = ""
    }

    function fillForm(eventData) {
        console.log("📝 Заполнение формы события:", JSON.stringify(eventData))

        // Заполняем поля вручную
        eventCategoryField.text = eventData.eventCategory || eventData.event_category || ""
        eventTypeField.text = eventData.eventType || eventData.event_type || ""
        startDateField.text = eventData.startDate || eventData.start_date || ""
        endDateField.text = eventData.endDate || eventData.end_date || ""
        locationField.text = eventData.location || ""
        loreField.text = eventData.lore || ""
    }

    function getEventData() {
        var eventId = 0
        if (isEditMode && currentEvent) {
            eventId = currentEvent.eventId || currentEvent.event_id || 0
        }

        var eventData = {
            event_id: eventId,
            event_type: eventTypeField.text.trim(),  // сокращенное наименование
            event_category: eventCategoryField.text.trim(),  // полное наименование
            start_date: startDateField.text.trim(),
            end_date: endDateField.text.trim(),
            location: locationField.text.trim(),
            lore: loreField.text.trim()
        }

        console.log("📦 Сформированные данные события:", JSON.stringify(eventData))
        return eventData
    }

    function handleSaveResponse(response) {
        isSaving = false
        console.log("🔔 Обработка ответа сохранения события:", JSON.stringify(response, null, 2))

        if (response.success) {
            var message = response.message || (isEditMode ? "✅ Событие успешно обновлено!" : "✅ Событие успешно добавлено!")
            showMessage(message, "success")
            saveCompleted(true, message)
            closeWindow()
        } else {
            var errorMsg = "❌ " + (response.error || "Неизвестная ошибка")
            showMessage(errorMsg, "error")
            saveCompleted(false, errorMsg)
        }
    }

    function showMessage(text, type) {
        console.log(type.toUpperCase() + ":", text)
        if (mainWindow && mainWindow.showMessage) {
            mainWindow.showMessage(text, type)
        }
    }

    function navigateToNextField(currentField) {
        var currentIndex = -1
        for (var i = 0; i < fieldNavigation.length; i++) {
            if (fieldNavigation[i] === currentField) {
                currentIndex = i
                break
            }
        }

        if (currentIndex !== -1 && currentIndex < fieldNavigation.length - 1) {
            fieldNavigation[currentIndex + 1].forceActiveFocus()
        } else if (currentIndex === fieldNavigation.length - 1) {
            saveButton.forceActiveFocus()
        }
    }

    function navigateToPreviousField(currentField) {
        var currentIndex = -1
        for (var i = 0; i < fieldNavigation.length; i++) {
            if (fieldNavigation[i] === currentField) {
                currentIndex = i
                break
            }
        }

        if (currentIndex > 0) {
            fieldNavigation[currentIndex - 1].forceActiveFocus()
        }
    }

    // Основной контейнер с градиентом
    Rectangle {
        id: windowContainer
        anchors.fill: parent
        radius: 16
        color: "transparent"
        clip: true

        // Градиентный фон
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#6a11cb" }
                GradientStop { position: 1.0; color: "#2575fc" }
            }
            radius: 15
        }

        // Полигоны
        Common.PolygonBackground {
            anchors.fill: parent
        }

        // TitleBar за белой формой
        Common.DialogTitleBar {
            id: titleBar
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 8
            }
            height: 28
            title: isEditMode ? "Редактирование события" : "Добавление события"
            window: eventFormWindow
            onClose: {
                cancelled()
                closeWindow()
            }
        }

        // Белая форма
        Rectangle {
            id: whiteForm
            width: 430
            height: 470
            anchors {
                top: titleBar.bottom
                topMargin: 20
                horizontalCenter: parent.horizontalCenter
            }
            color: "#ffffff"
            opacity: 0.925
            radius: 12

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 12

                // Контент без прокрутки
                Column {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 12

                    // Переключатель режима ввода
                    Column {
                        width: parent.width
                        spacing: 6

                        Text {
                            text: "Режим ввода категории:"
                            color: "#2c3e50"
                            font.bold: true
                            font.pixelSize: 13
                        }

                        Row {
                            width: parent.width
                            spacing: 10

                            Button {
                                id: categoryModeSwitch
                                text: manualEntryMode ? "📝 Ручной ввод" : "📝 Перейти в ручной ввод"
                                implicitHeight: 30
                                font.pixelSize: 12
                                background: Rectangle {
                                    radius: 6
                                    color: manualEntryMode ? "#4CAF50" : "#FF9800"
                                }
                                contentItem: Text {
                                    text: categoryModeSwitch.text
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font: categoryModeSwitch.font
                                }
                                KeyNavigation.tab: eventCategoryField

                                onClicked: {
                                    manualEntryMode = true
                                    showMessage("✅ Включен режим ручного ввода. Теперь можно вводить полное и сокращенное наименование вручную.", "success")
                                }
                            }

                            Text {
                                text: manualEntryMode ? "✓ Режим ручного ввода" : "Выберите режим"
                                color: manualEntryMode ? "#4CAF50" : "#666666"
                                font.pixelSize: 11
                                verticalAlignment: Text.AlignVCenter
                                height: 30
                            }
                        }
                    }

                    // Полное наименование мероприятия (ручной ввод)
                    Column {
                        width: parent.width
                        spacing: 6

                        Text {
                            text: "Полное наименование мероприятия:"
                            color: "#2c3e50"
                            font.bold: true
                            font.pixelSize: 13
                        }

                        TextField {
                            id: eventCategoryField
                            width: parent.width
                            height: 32
                            placeholderText: "Введите полное наименование мероприятия"
                            horizontalAlignment: Text.AlignLeft
                            enabled: !isSaving
                            font.pixelSize: 13
                            background: Rectangle {
                                radius: 8
                                color: "#ffffff"
                                border.color: "#e0e0e0"
                                border.width: 1
                            }
                            color: "#000000"
                            KeyNavigation.tab: eventTypeField
                            Keys.onReturnPressed: navigateToNextField(eventCategoryField)

                            ToolTip.text: "Введите полное наименование мероприятия (например: 'Всероссийская олимпиада по программированию')"
                            ToolTip.visible: hovered
                        }
                    }

                    // Сокращенное наименование мероприятия (ручной ввод)
                    Column {
                        width: parent.width
                        spacing: 6

                        Text {
                            text: "Сокращенное наименование:"
                            color: "#2c3e50"
                            font.bold: true
                            font.pixelSize: 13
                        }

                        TextField {
                            id: eventTypeField
                            width: parent.width
                            height: 32
                            placeholderText: "Введите сокращенное наименование"
                            horizontalAlignment: Text.AlignLeft
                            enabled: !isSaving
                            font.pixelSize: 13
                            background: Rectangle {
                                radius: 8
                                color: "#ffffff"
                                border.color: "#e0e0e0"
                                border.width: 1
                            }
                            color: "#000000"
                            KeyNavigation.tab: startDateField
                            Keys.onReturnPressed: navigateToNextField(eventTypeField)

                            ToolTip.text: "Введите сокращенное наименование (например: 'ВОП')"
                            ToolTip.visible: hovered
                        }
                    }

                    // Даты начала и окончания
                    Column {
                        width: parent.width
                        spacing: 6

                        Text {
                            text: "Даты проведения:"
                            color: "#2c3e50"
                            font.bold: true
                            font.pixelSize: 13
                        }

                        Row {
                            width: parent.width
                            spacing: 8

                            Column {
                                width: (parent.width - 8) / 2
                                spacing: 4

                                Text {
                                    text: "Начало:"
                                    color: "#2c3e50"
                                    font.pixelSize: 11
                                }

                                TextField {
                                    id: startDateField
                                    width: parent.width
                                    height: 30
                                    placeholderText: "ГГГГ-ММ-ДД"
                                    horizontalAlignment: Text.AlignLeft
                                    enabled: !isSaving
                                    font.pixelSize: 12
                                    background: Rectangle {
                                        radius: 6
                                        color: "#ffffff"
                                        border.color: "#e0e0e0"
                                        border.width: 1
                                    }
                                    color: "#000000"
                                    KeyNavigation.tab: endDateField
                                    Keys.onReturnPressed: navigateToNextField(startDateField)
                                }
                            }

                            Column {
                                width: (parent.width - 8) / 2
                                spacing: 4

                                Text {
                                    text: "Окончание:"
                                    color: "#2c3e50"
                                    font.pixelSize: 11
                                }

                                TextField {
                                    id: endDateField
                                    width: parent.width
                                    height: 30
                                    placeholderText: "ГГГГ-ММ-ДД"
                                    horizontalAlignment: Text.AlignLeft
                                    enabled: !isSaving
                                    font.pixelSize: 12
                                    background: Rectangle {
                                        radius: 6
                                        color: "#ffffff"
                                        border.color: "#e0e0e0"
                                        border.width: 1
                                    }
                                    color: "#000000"
                                    KeyNavigation.tab: locationField
                                    Keys.onReturnPressed: navigateToNextField(endDateField)
                                }
                            }
                        }
                    }

                    // Местоположение
                    Column {
                        width: parent.width
                        spacing: 6

                        Text {
                            text: "Местоположение:"
                            color: "#2c3e50"
                            font.bold: true
                            font.pixelSize: 13
                        }

                        TextField {
                            id: locationField
                            width: parent.width
                            height: 32
                            placeholderText: "Введите местоположение"
                            horizontalAlignment: Text.AlignLeft
                            enabled: !isSaving
                            font.pixelSize: 13
                            background: Rectangle {
                                radius: 8
                                color: "#ffffff"
                                border.color: "#e0e0e0"
                                border.width: 1
                            }
                            color: "#000000"
                            KeyNavigation.tab: loreField
                            Keys.onReturnPressed: navigateToNextField(locationField)
                        }
                    }

                    // Описание (лора)
                    Column {
                        width: parent.width
                        spacing: 6

                        Text {
                            text: "Описание события:"
                            color: "#2c3e50"
                            font.bold: true
                            font.pixelSize: 13
                        }

                        TextArea {
                            id: loreField
                            width: parent.width
                            height: 60
                            placeholderText: "Введите описание события..."
                            wrapMode: Text.WordWrap
                            enabled: !isSaving
                            font.pixelSize: 12
                            background: Rectangle {
                                radius: 8
                                color: "#ffffff"
                                border.color: "#e0e0e0"
                                border.width: 1
                            }
                            color: "#000000"
                            KeyNavigation.tab: saveButton
                            Keys.onReturnPressed: navigateToNextField(loreField)
                        }
                    }
                }

                // Кнопки действий
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 15

                    Button {
                        id: saveButton
                        text: isSaving ? "⏳ Сохранение..." : "💾 Сохранить"
                        implicitWidth: 130
                        implicitHeight: 36
                        enabled: !isSaving &&
                                eventCategoryField.text.trim() !== "" &&
                                eventTypeField.text.trim() !== "" &&
                                startDateField.text.trim() !== "" &&
                                endDateField.text.trim() !== ""
                        font.pixelSize: 13
                        background: Rectangle {
                            radius: 8
                            color: saveButton.enabled ? "#4CAF50" : "#cccccc"
                        }
                        contentItem: Text {
                            text: saveButton.text
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font: saveButton.font
                        }
                        KeyNavigation.tab: cancelButton
                        Keys.onReturnPressed: if (enabled && !isSaving) saveButton.clicked()

                        onClicked: {
                            if (eventCategoryField.text.trim() === "" || eventTypeField.text.trim() === "") {
                                showMessage("❌ Заполните полное и сокращенное наименование", "error")
                                return
                            }
                            if (startDateField.text.trim() === "" || endDateField.text.trim() === "") {
                                showMessage("❌ Заполните даты проведения", "error")
                                return
                            }

                            isSaving = true
                            console.log("💾 Сохранение события...")
                            var eventData = getEventData()
                            saved(eventData)
                        }
                    }

                    Button {
                        id: cancelButton
                        text: "❌ Отмена"
                        implicitWidth: 130
                        implicitHeight: 36
                        enabled: !isSaving
                        font.pixelSize: 13
                        background: Rectangle {
                            radius: 8
                            color: "#f44336"
                        }
                        contentItem: Text {
                            text: cancelButton.text
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font: cancelButton.font
                        }
                        KeyNavigation.tab: categoryModeSwitch
                        Keys.onReturnPressed: if (enabled) cancelButton.clicked()

                        onClicked: {
                            cancelled()
                            closeWindow()
                        }
                    }
                }
            }
        }
    }
}
