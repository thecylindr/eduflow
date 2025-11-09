import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../../common" as Common

ApplicationWindow {
    id: eventFormWindow
    width: 450
    height: 550 // Уменьшена высота
    flags: Qt.Dialog | Qt.FramelessWindowHint
    modality: Qt.ApplicationModal
    color: "transparent"
    visible: false

    property var currentEvent: null
    property bool isEditMode: false
    property bool isSaving: false
    property var eventCategories: []

    signal saved(var eventData)
    signal cancelled()
    signal saveCompleted(bool success, string message)

    // Порядок навигации между полями
    property var fieldNavigation: [
        eventTypeField, eventCategoryComboBox, startDateField,
        endDateField, locationField, maxParticipantsField, loreField
    ]

    function openForAdd() {
        currentEvent = null
        isEditMode = false
        isSaving = false
        clearForm()
        eventFormWindow.show()
        eventFormWindow.requestActivate()
        eventFormWindow.x = (Screen.width - eventFormWindow.width) / 2
        eventFormWindow.y = (Screen.height - eventFormWindow.height) / 2
        Qt.callLater(function() { eventTypeField.forceActiveFocus() })
    }

    function openForEdit(eventData) {
        currentEvent = eventData
        isEditMode = true
        isSaving = false
        fillForm(eventData)
        eventFormWindow.show()
        eventFormWindow.requestActivate()
        eventFormWindow.x = (Screen.width - eventFormWindow.width) / 2
        eventFormWindow.y = (Screen.height - eventFormWindow.height) / 2
        Qt.callLater(function() { eventTypeField.forceActiveFocus() })
    }

    function closeWindow() {
        eventFormWindow.close()
    }

    function clearForm() {
        eventTypeField.text = ""
        eventCategoryComboBox.currentIndex = -1
        startDateField.text = ""
        endDateField.text = ""
        locationField.text = ""
        loreField.text = ""
        maxParticipantsField.text = ""
    }

    function fillForm(eventData) {
        eventTypeField.text = eventData.eventType || eventData.event_type || ""

        // Находим индекс категории в комбобоксе
        var categoryId = eventData.eventCategory || eventData.event_category
        if (categoryId) {
            for (var i = 0; i < eventCategories.length; i++) {
                var category = eventCategories[i]
                var currentCategoryId = category.eventCategoryId || category.event_category_id
                if (currentCategoryId === categoryId) {
                    eventCategoryComboBox.currentIndex = i
                    break
                }
            }
        } else {
            eventCategoryComboBox.currentIndex = -1
        }

        startDateField.text = eventData.startDate || eventData.start_date || ""
        endDateField.text = eventData.endDate || eventData.end_date || ""
        locationField.text = eventData.location || ""
        loreField.text = eventData.lore || ""
        maxParticipantsField.text = eventData.maxParticipants || eventData.max_participants || ""
    }

    function getEventData() {
        var eventId = 0
        if (isEditMode && currentEvent) {
            eventId = currentEvent.eventId || currentEvent.event_id || 0
        }

        var selectedCategory = eventCategoryComboBox.currentIndex >= 0 ?
            eventCategories[eventCategoryComboBox.currentIndex] : null
        var categoryId = selectedCategory ?
            (selectedCategory.eventCategoryId || selectedCategory.event_category_id) : 0

        return {
            event_id: eventId,
            event_type: eventTypeField.text,
            event_category: categoryId,
            start_date: startDateField.text,
            end_date: endDateField.text,
            location: locationField.text,
            lore: loreField.text,
            max_participants: parseInt(maxParticipantsField.text) || 0
        }
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
            height: 500 // Уменьшена высота
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

                    // Тип события
                    Column {
                        width: parent.width
                        spacing: 6

                        Text {
                            text: "Тип события:"
                            color: "#2c3e50"
                            font.bold: true
                            font.pixelSize: 13
                        }

                        TextField {
                            id: eventTypeField
                            width: parent.width
                            height: 32
                            placeholderText: "Введите тип события*"
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
                            KeyNavigation.tab: eventCategoryComboBox
                            Keys.onReturnPressed: navigateToNextField(eventTypeField)
                            Keys.onEnterPressed: navigateToNextField(eventTypeField)
                        }
                    }

                    // Категория события
                    Column {
                        width: parent.width
                        spacing: 6

                        Text {
                            text: "Категория события:"
                            color: "#2c3e50"
                            font.bold: true
                            font.pixelSize: 13
                        }

                        ComboBox {
                            id: eventCategoryComboBox
                            width: parent.width
                            height: 32
                            enabled: !isSaving
                            font.pixelSize: 13
                            model: eventFormWindow.eventCategories
                            textRole: "name"
                            background: Rectangle {
                                radius: 8
                                color: "#ffffff"
                                border.color: "#e0e0e0"
                                border.width: 1
                            }
                            contentItem: Text {
                                text: eventCategoryComboBox.displayText
                                color: "#000000"
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 10
                                font: eventCategoryComboBox.font
                            }
                            KeyNavigation.tab: startDateField
                            Keys.onReturnPressed: navigateToNextField(eventCategoryComboBox)
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
                            KeyNavigation.tab: maxParticipantsField
                            Keys.onReturnPressed: navigateToNextField(locationField)
                        }
                    }

                    // Максимальное количество участников
                    Column {
                        width: parent.width
                        spacing: 6

                        Text {
                            text: "Макс. участников:"
                            color: "#2c3e50"
                            font.bold: true
                            font.pixelSize: 13
                        }

                        TextField {
                            id: maxParticipantsField
                            width: parent.width
                            height: 32
                            placeholderText: "Введите количество"
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
                            validator: IntValidator { bottom: 1; top: 9999 }
                            KeyNavigation.tab: loreField
                            Keys.onReturnPressed: navigateToNextField(maxParticipantsField)
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
                        enabled: !isSaving && eventTypeField.text.trim() !== "" &&
                                eventCategoryComboBox.currentIndex >= 0 &&
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
                            if (eventTypeField.text.trim() === "") {
                                showMessage("❌ Введите тип события", "error")
                                return
                            }
                            if (eventCategoryComboBox.currentIndex < 0) {
                                showMessage("❌ Выберите категорию события", "error")
                                return
                            }
                            if (startDateField.text.trim() === "" || endDateField.text.trim() === "") {
                                showMessage("❌ Заполните даты проведения", "error")
                                return
                            }
                            isSaving = true
                            saved(getEventData())
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
                        KeyNavigation.tab: eventTypeField
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
