import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../../common" as Common

ApplicationWindow {
    id: eventFormWindow
    width: 540
    height: 640
    flags: Qt.Dialog | Qt.FramelessWindowHint
    modality: Qt.ApplicationModal
    color: "transparent"
    visible: false

    property var currentEvent: null
    property bool isEditMode: false
    property bool isSaving: false
    property var eventCategories: []
    property var portfolioList: []
    property bool portfoliosLoaded: false
    property bool portfoliosLoading: false
    property string portfolioStatus: "⏳ Загрузка портфолио..."

    signal saved(var eventData)
    signal cancelled()
    signal saveCompleted(bool success, string message)

    property var fieldNavigation: [
        portfolioComboBox, eventTypeField, categoryField, startDateField, endDateField, locationField, loreField
    ]

    function openForAdd() {
        currentEvent = null
        isEditMode = false
        isSaving = false
        portfoliosLoaded = false
        portfoliosLoading = false
        portfolioStatus = "⏳ Загрузка портфолио..."
        clearForm()
        loadPortfolios()
        eventFormWindow.show()
        eventFormWindow.requestActivate()
        eventFormWindow.x = (Screen.width - eventFormWindow.width) / 2
        eventFormWindow.y = (Screen.height - eventFormWindow.height) / 2
        Qt.callLater(function() {
            if (portfolioList.length > 0) {
                portfolioComboBox.forceActiveFocus()
            } else {
                eventTypeField.forceActiveFocus()
            }
        })
    }

    function openForEdit(eventData) {
        console.log("✏️ Открытие формы для редактирования:", JSON.stringify(eventData))
        currentEvent = eventData
        isEditMode = true
        isSaving = false
        portfoliosLoaded = false
        portfoliosLoading = false
        portfolioStatus = "⏳ Загрузка портфолио..."
        loadPortfolios()
        eventFormWindow.show()
        eventFormWindow.requestActivate()
        eventFormWindow.x = (Screen.width - eventFormWindow.width) / 2
        eventFormWindow.y = (Screen.height - eventFormWindow.height) / 2
        Qt.callLater(function() {
            if (portfolioList.length > 0) {
                portfolioComboBox.forceActiveFocus()
            } else {
                eventTypeField.forceActiveFocus()
            }
        })
    }

    function closeWindow() {
        eventFormWindow.close()
    }

    function clearForm() {
        portfolioComboBox.currentIndex = -1
        eventTypeField.text = ""
        startDateField.text = ""
        endDateField.text = ""
        locationField.text = ""
        loreField.text = ""
    }

    function fillForm(eventData) {
        console.log("📝 Заполнение формы события:", JSON.stringify(eventData))

        if (!portfoliosLoaded) {
            console.log("⏳ Портфолио еще не загружены, отложим заполнение формы")
            return
        }

        // 🔥 УЛУЧШЕННАЯ ЛОГИКА: пробуем разные возможные поля для measure_code
        var measureCode = eventData.measureCode || eventData.portfolio_id || eventData.event_id || 0
        console.log("🔍 Ищем портфолио с measure_code:", measureCode, "в списке из", portfolioList.length, "элементов")

        if (measureCode > 0) {
            var foundIndex = -1
            for (var i = 0; i < portfolioList.length; i++) {
                console.log("   Сравниваем с portfolioList[", i, "]:", portfolioList[i].measure_code)
                if (portfolioList[i].measure_code === measureCode) {
                    foundIndex = i
                    console.log("✅ Найдено портфолио, индекс:", i)
                    break
                }
            }

            if (foundIndex >= 0) {
                portfolioComboBox.currentIndex = foundIndex
                console.log("✅ Портфолио выбрано в комбобоксе")
            } else {
                console.log("⚠️ Портфолио с measure_code", measureCode, "не найдено в списке")
                console.log("📋 Доступные measure_codes:", portfolioList.map(function(p) { return p.measure_code; }))
            }
        } else {
            console.log("⚠️ measure_code не указан или равен 0")
        }

        eventTypeField.text = eventData.eventType || eventData.event_type || ""
        categoryField.text = eventData.category || ""
        startDateField.text = eventData.startDate || eventData.start_date || ""
        endDateField.text = eventData.endDate || eventData.end_date || ""
        locationField.text = eventData.location || ""
        loreField.text = eventData.lore || ""
    }

    function getEventData() {
        if (portfolioComboBox.currentIndex < 0) {
            console.log("❌ Портфолио не выбрано")
            return null
        }

        var selectedPortfolio = portfolioList[portfolioComboBox.currentIndex]

        if (!selectedPortfolio || !selectedPortfolio.measure_code) {
            console.log("❌ Выбранное портфолио невалидно")
            return null
        }

        var eventData = {
            eventType: eventTypeField.text.trim(),
            category: categoryField.text.trim(), // 🔥 ДОБАВЛЕНО: полное название
            measureCode: selectedPortfolio.measure_code,
            startDate: startDateField.text.trim(),
            endDate: endDateField.text.trim(),
            location: locationField.text.trim(),
            lore: loreField.text.trim()
        }

        if (isEditMode && currentEvent) {
            eventData.id = currentEvent.id;
            console.log("🔧 Добавлен уникальный ID события для редактирования:", eventData.id)
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

    function loadPortfolios() {
        if (portfoliosLoading) {
            console.log("⚠️ Загрузка портфолио уже выполняется")
            return
        }

        console.log("📚 Начинаем загрузку списка портфолио...")
        portfoliosLoading = true
        portfolioStatus = "⏳ Загрузка портфолио..."

        // Сначала используем отладочную функцию для понимания структуры данных
        mainApi.debugGetPortfolio(function(debugResponse) {
            console.log("🔍 Отладочная информация получена")

            // Затем загружаем данные для формы
            mainApi.getPortfolioForEvents(function(response) {
                portfoliosLoading = false

                if (response.success) {
                    eventFormWindow.portfolioList = response.data
                    eventFormWindow.portfoliosLoaded = true
                    portfolioStatus = "✅ Загружено: " + response.data.length + " портфолио"

                    console.log("✅ Портфолио загружены:", response.data.length)

                    if (response.data.length > 0) {
                        console.log("📋 Примеры портфолио:")
                        for (var i = 0; i < Math.min(3, response.data.length); i++) {
                            var p = response.data[i]
                            console.log("   " + p.measure_code + " - Приказ №" + p.decree + " - " + p.student_name)
                        }

                        // Если это режим редактирования, заполняем форму
                        if (isEditMode && currentEvent) {
                            console.log("🔄 Заполняем форму после загрузки портфолио")
                            fillForm(currentEvent)
                        }
                    } else {
                        console.log("⚠️ Список портфолио пуст")
                        portfolioStatus = "⚠️ Нет доступных портфолио"
                        showMessage("❌ Нет доступных портфолио для привязки событий", "error")
                    }
                } else {
                    console.log("❌ Ошибка загрузки портфолио:", response.error)
                    portfolioStatus = "❌ Ошибка загрузки"
                    showMessage("❌ Ошибка загрузки портфолио: " + response.error, "error")
                }
            })
        })
    }


    // Основной контейнер
    Rectangle {
        id: windowContainer
        anchors.fill: parent
        radius: 16
        color: "transparent"
        clip: true

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#6a11cb" }
                GradientStop { position: 1.0; color: "#2575fc" }
            }
            radius: 15
        }

        Common.PolygonBackground {
            anchors.fill: parent
        }

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

        Rectangle {
            id: whiteForm
            width: 480
            height: 500
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

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    Column {
                        width: parent.width
                        spacing: 12

                        // Выбор портфолио
                        Column {
                            width: parent.width
                            spacing: 6

                            Text {
                                text: "Портфолио студента:"
                                color: "#2c3e50"
                                font.bold: true
                                font.pixelSize: 13
                            }

                            ComboBox {
                                id: portfolioComboBox
                                width: parent.width
                                height: 36
                                enabled: !isSaving && portfolioList.length > 0
                                font.pixelSize: 13

                                background: Rectangle {
                                    radius: 8
                                    color: "#ffffff"
                                    border.color: portfolioComboBox.enabled ? "#e0e0e0" : "#f0f0f0"
                                    border.width: 1
                                }

                                textRole: "displayText"

                                model: portfolioList.map(function(portfolio) {
                                    return {
                                        measure_code: portfolio.measure_code,
                                        displayText: "Приказ №" + portfolio.decree + " - " + portfolio.student_name
                                    }
                                })

                                displayText: {
                                    if (portfoliosLoading) return "⏳ Загрузка..."
                                    if (portfolioList.length === 0) return "❌ Нет портфолио"
                                    return currentIndex >= 0 ? currentText : "Выберите портфолио..."
                                }

                                KeyNavigation.tab: eventTypeField
                                Keys.onReturnPressed: navigateToNextField(portfolioComboBox)

                                ToolTip.text: "Выберите портфолио студента для привязки события"
                                ToolTip.visible: hovered

                                onActivated: {
                                    console.log("📚 Выбрано портфолио:", currentIndex,
                                                "measure_code:", portfolioList[currentIndex].measure_code)
                                }
                            }

                            Text {
                                text: portfolioStatus
                                color: {
                                    if (portfoliosLoading) return "#ff9800"
                                    if (portfolioList.length === 0) return "#f44336"
                                    if (portfolioComboBox.currentIndex < 0) return "#ff9800"
                                    return "#4CAF50"
                                }
                                font.pixelSize: 11
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: 6

                            Text {
                                text: "Тип мероприятия:"
                                color: "#2c3e50"
                                font.bold: true
                                font.pixelSize: 13
                            }

                            TextField {
                                id: eventTypeField
                                width: parent.width
                                height: 32
                                placeholderText: "Введите тип мероприятия"
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
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: 6

                            Text {
                                text: "Полное название события:"
                                color: "#2c3e50"
                                font.bold: true
                                font.pixelSize: 13
                            }

                            TextField {
                                id: categoryField
                                width: parent.width
                                height: 32
                                placeholderText: "Введите полное название мероприятия"
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
                                Keys.onReturnPressed: navigateToNextField(categoryField)
                            }
                        }

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
                                height: 80
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
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 15

                    Button {
                        id: saveButton
                        text: isSaving ? "⏳ Сохранение..." : "💾 Сохранить"
                        implicitWidth: 130
                        implicitHeight: 36
                        enabled: !isSaving &&
                                portfolioComboBox.currentIndex >= 0 &&
                                portfolioList.length > 0 &&
                                eventTypeField.text.trim() !== "" &&
                                categoryField.text.trim() !== "" &&
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
                            if (portfolioComboBox.currentIndex < 0) {
                                showMessage("❌ Выберите портфолио студента", "error")
                                return
                            }

                            var selectedPortfolio = portfolioList[portfolioComboBox.currentIndex]
                            if (!selectedPortfolio || !selectedPortfolio.measure_code) {
                                showMessage("❌ Выберите валидное портфолио", "error")
                                return
                            }

                            if (eventTypeField.text.trim() === "") {
                                showMessage("❌ Введите тип мероприятия", "error")
                                return
                            }

                            if (categoryField.text.trim() === "") {
                                showMessage("❌ Введите полное название категории", "error") // 🔥 НОВАЯ ПРОВЕРКА
                                return
                            }

                            if (startDateField.text.trim() === "" || endDateField.text.trim() === "") {
                                showMessage("❌ Заполните даты проведения", "error")
                                return
                            }

                            isSaving = true
                            console.log("💾 Сохранение события...")
                            var eventData = getEventData()
                            if (eventData) {
                                saved(eventData)
                            } else {
                                isSaving = false
                                showMessage("❌ Ошибка формирования данных события", "error")
                            }
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
                        KeyNavigation.tab: portfolioComboBox
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
