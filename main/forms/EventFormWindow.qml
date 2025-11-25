import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts 1.15
import "../../common" as Common

Window {
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
    property string portfolioStatus: "Загрузка портфолио..."

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
        portfolioStatus = "Загрузка портфолио..."
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
        console.log("Открытие формы для редактирования:", JSON.stringify(eventData))
        currentEvent = eventData
        isEditMode = true
        isSaving = false
        portfoliosLoaded = false
        portfoliosLoading = false
        portfolioStatus = "Загрузка портфолио..."
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
        categoryField.text = ""
        startDateField.text = ""
        endDateField.text = ""
        locationField.text = ""
        loreField.text = ""
    }

    function fillForm(eventData) {
        console.log("Заполнение формы события:", JSON.stringify(eventData))

        if (!portfoliosLoaded) {
            console.log("Портфолио еще не загружены, отложим заполнение формы")
            return
        }

        var measureCode = eventData.measureCode || eventData.portfolio_id || eventData.event_id || 0
        console.log("Ищем портфолио с measure_code:", measureCode)

        if (measureCode > 0) {
            var foundIndex = -1
            for (var i = 0; i < portfolioList.length; i++) {
                if (portfolioList[i].measure_code === measureCode) {
                    foundIndex = i
                    console.log("Найдено портфолио, индекс:", i)
                    break
                }
            }

            if (foundIndex >= 0) {
                portfolioComboBox.currentIndex = foundIndex
            } else {
                console.log("Портфолио с measure_code", measureCode, "не найдено")
            }
        }

        eventTypeField.text = eventData.eventType || eventData.event_type || ""

        var categoryValue = eventData.category || ""
        categoryField.text = categoryValue
        console.log("Заполнено поле категории:", categoryValue)

        // Преобразуем даты из ГГГГ-ММ-ДД в ДД.ММ.ГГГГ
        var serverStartDate = eventData.startDate || eventData.start_date || ""
        if (serverStartDate) {
            var startParts = serverStartDate.split('-')
            if (startParts.length === 3) {
                startDateField.text = startParts[2] + "." + startParts[1] + "." + startParts[0]
            } else {
                startDateField.text = serverStartDate
            }
        } else {
            startDateField.text = ""
        }

        var serverEndDate = eventData.endDate || eventData.end_date || ""
        if (serverEndDate) {
            var endParts = serverEndDate.split('-')
            if (endParts.length === 3) {
                endDateField.text = endParts[2] + "." + endParts[1] + "." + endParts[0]
            } else {
                endDateField.text = serverEndDate
            }
        } else {
            endDateField.text = ""
        }

        locationField.text = eventData.location || ""
        loreField.text = eventData.lore || ""

        console.log("Форма заполнена. Категория:", categoryField.text)
    }

    function getEventData() {
        if (portfolioComboBox.currentIndex < 0) {
            console.log("Портфолио не выбрано")
            return null
        }

        var selectedPortfolio = portfolioList[portfolioComboBox.currentIndex]

        if (!selectedPortfolio || !selectedPortfolio.measure_code) {
            console.log("Выбранное портфолио невалидно")
            return null
        }

        // Преобразуем даты из ДД.ММ.ГГГГ в ГГГГ-ММ-ДД для сервера
        var startDateText = startDateField.text.trim()
        var formattedStartDate = startDateText
        if (startDateText) {
            var startParts = startDateText.split('.')
            if (startParts.length === 3) {
                formattedStartDate = startParts[2] + "-" + startParts[1] + "-" + startParts[0]
            }
        }

        var endDateText = endDateField.text.trim()
        var formattedEndDate = endDateText
        if (endDateText) {
            var endParts = endDateText.split('.')
            if (endParts.length === 3) {
                formattedEndDate = endParts[2] + "-" + endParts[1] + "-" + endParts[0]
            }
        }

        var eventData = {
            eventType: eventTypeField.text.trim(),
            category: categoryField.text.trim(),
            measureCode: selectedPortfolio.measure_code,
            startDate: formattedStartDate,
            endDate: formattedEndDate,
            location: locationField.text.trim(),
            lore: loreField.text.trim()
        }

        if (isEditMode && currentEvent) {
            eventData.id = currentEvent.id;
            console.log("Добавлен уникальный ID события для редактирования:", eventData.id)
        }

        console.log("Сформированные данные события:", JSON.stringify(eventData))
        console.log("measureCode:", eventData.measureCode)
        console.log("Категория для сохранения:", eventData.category)
        console.log("Режим редактирования:", isEditMode)
        return eventData
    }

    function validateDate(text) {
        if (!text) return true

        var parts = text.split('.')
        if (parts.length !== 3) return false

        var day = parseInt(parts[0])
        var month = parseInt(parts[1])
        var year = parseInt(parts[2])

        if (day < 1 || day > 31) return false
        if (month < 1 || month > 12) return false
        if (year < 1900 || year > 2100) return false

        return true
    }

    function handleSaveResponse(response) {
        isSaving = false
        console.log("Обработка ответа сохранения события:", JSON.stringify(response, null, 2))

        if (response.success) {
            var message = response.message || (isEditMode ? "Событие успешно обновлено!" : "Событие успешно добавлено!")
            showMessage(message, "success")
            saveCompleted(true, message)
            closeWindow()
        } else {
            var errorMsg = (response.error || "Неизвестная ошибка")
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
            return
        }

        portfoliosLoading = true
        portfolioStatus = "Загрузка портфолио..."
        mainApi.getPortfolioForEvents(function(response) {
            portfoliosLoading = false

            if (response.success) {
                eventFormWindow.portfolioList = response.data
                eventFormWindow.portfoliosLoaded = true
                portfolioStatus = "Загружено: " + response.data.length + " портфолио"

                if (response.data.length > 0) {
                    for (var i = 0; i < Math.min(3, response.data.length); i++) {
                        var p = response.data[i]
                    }

                    if (isEditMode && currentEvent) {
                        fillForm(currentEvent)
                    }
                } else {
                    portfolioStatus = "Нет доступных портфолио"
                    showMessage("Нет доступных портфолио для привязки событий", "error")
                }
            } else {
                portfolioStatus = "Ошибка загрузки"
                showMessage("Ошибка загрузки портфолио: " + response.error, "error")
            }
        })
    }

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
            height: 560
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

                    ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                    Column {
                        width: parent.width
                        spacing: 12

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

                                contentItem: Text {
                                    text: portfolioComboBox.displayText
                                    color: "#000000"
                                    horizontalAlignment: Text.AlignLeft
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                    rightPadding: portfolioComboBox.indicator.width + 10
                                    font: portfolioComboBox.font
                                }

                                indicator: Rectangle {
                                    x: portfolioComboBox.width - width - 5
                                    y: portfolioComboBox.topPadding + (portfolioComboBox.height - height) / 2
                                    width: 12
                                    height: 8
                                    color: "transparent"
                                    Rectangle {
                                        width: 8
                                        height: 8
                                        color: "#666666"
                                        rotation: 45
                                        anchors.centerIn: parent
                                    }
                                }

                                popup: Popup {
                                    y: portfolioComboBox.height - 1
                                    width: portfolioComboBox.width
                                    implicitHeight: contentItem.implicitHeight
                                    padding: 1

                                    contentItem: ListView {
                                        clip: true
                                        implicitHeight: contentHeight
                                        model: portfolioComboBox.popup.visible ? portfolioComboBox.delegateModel : null
                                        currentIndex: portfolioComboBox.highlightedIndex

                                        ScrollIndicator.vertical: ScrollIndicator { }
                                    }

                                    background: Rectangle {
                                        color: "#ffffff"
                                        border.color: "#e0e0e0"
                                        radius: 8
                                    }
                                }

                                delegate: ItemDelegate {
                                    width: portfolioComboBox.width
                                    contentItem: Text {
                                        text: modelData.displayText
                                        color: "#000000"
                                        font: portfolioComboBox.font
                                        elide: Text.ElideRight
                                        verticalAlignment: Text.AlignVCenter
                                        leftPadding: 10
                                    }
                                    background: Rectangle {
                                        color: highlighted ? "#e0e0e0" : "#ffffff"
                                    }
                                    highlighted: portfolioComboBox.highlightedIndex === index
                                }

                                textRole: "displayText"

                                model: portfolioList.map(function(portfolio) {
                                    return {
                                        measure_code: portfolio.measure_code,
                                        displayText: "Приказ №" + portfolio.decree + " - " + portfolio.student_name
                                    }
                                })

                                displayText: {
                                    if (portfoliosLoading) return "Загрузка..."
                                    if (portfolioList.length === 0) return "Нет портфолио"
                                    return currentIndex >= 0 ? currentText : "Выберите портфолио..."
                                }

                                KeyNavigation.tab: eventTypeField
                                Keys.onReturnPressed: navigateToNextField(portfolioComboBox)
                                Keys.onUpPressed: navigateToPreviousField(portfolioComboBox)
                                Keys.onDownPressed: navigateToNextField(portfolioComboBox)

                                ToolTip.text: "Выберите портфолио студента для привязки события"
                                ToolTip.visible: hovered
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
                                KeyNavigation.tab: categoryField
                                Keys.onReturnPressed: navigateToNextField(eventTypeField)
                                Keys.onUpPressed: navigateToPreviousField(eventTypeField)
                                Keys.onDownPressed: navigateToNextField(eventTypeField)
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: 6

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
                                Keys.onUpPressed: navigateToPreviousField(categoryField)
                                Keys.onDownPressed: navigateToNextField(categoryField)
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
                                        placeholderText: "ДД.ММ.ГГГГ"
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
                                        validator: RegularExpressionValidator {
                                            regularExpression: /^[\d\.]*$/
                                        }
                                        KeyNavigation.tab: endDateField
                                        Keys.onReturnPressed: navigateToNextField(startDateField)
                                        Keys.onUpPressed: navigateToPreviousField(startDateField)
                                        Keys.onDownPressed: navigateToNextField(startDateField)
                                    }

                                    Text {
                                        text: !validateDate(startDateField.text) && startDateField.text !== "" ? "Неверный формат даты" : ""
                                        color: !validateDate(startDateField.text) && startDateField.text !== "" ? "#e74c3c" : "#7f8c8d"
                                        font.pixelSize: 10
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
                                        placeholderText: "ДД.ММ.ГГГГ"
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
                                        validator: RegularExpressionValidator {
                                            regularExpression: /^[\d\.]*$/
                                        }
                                        KeyNavigation.tab: locationField
                                        Keys.onReturnPressed: navigateToNextField(endDateField)
                                        Keys.onUpPressed: navigateToPreviousField(endDateField)
                                        Keys.onDownPressed: navigateToNextField(endDateField)
                                    }

                                    Text {
                                        text: !validateDate(endDateField.text) && endDateField.text !== "" ? "Неверный формат даты" : ""
                                        color: !validateDate(endDateField.text) && endDateField.text !== "" ? "#e74c3c" : "#7f8c8d"
                                        font.pixelSize: 10
                                    }
                                }
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: 6

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
                                Keys.onUpPressed: navigateToPreviousField(locationField)
                                Keys.onDownPressed: navigateToNextField(locationField)
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

                            Rectangle {
                                id: loreFieldContainer
                                width: parent.width
                                height: 100
                                radius: 8
                                border.color: "#e0e0e0"
                                border.width: 1
                                color: "#ffffff"

                                ScrollView {
                                    id: scrollView
                                    anchors.fill: parent
                                    anchors.margins: 4
                                    clip: true

                                    TextArea {
                                        id: loreField
                                        width: parent.width
                                        placeholderText: "Введите описание события..."
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                        enabled: !isSaving
                                        font.pixelSize: 12
                                        color: "#000000"
                                        selectByMouse: true
                                        background: null

                                        KeyNavigation.tab: saveButton
                                        Keys.onReturnPressed: navigateToNextField(loreField)
                                        Keys.onUpPressed: navigateToPreviousField(loreField)
                                        Keys.onDownPressed: saveButton.forceActiveFocus()
                                    }
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 20

                    Button {
                        id: saveButton
                        text: isSaving ? "Сохранение..." : "Сохранить"
                        implicitWidth: 140
                        implicitHeight: 40
                        enabled: !isSaving &&
                                portfolioComboBox.currentIndex >= 0 &&
                                portfolioList.length > 0 &&
                                eventTypeField.text.trim() !== "" &&
                                categoryField.text.trim() !== "" &&
                                startDateField.text.trim() !== "" && validateDate(startDateField.text) &&
                                endDateField.text.trim() !== "" && validateDate(endDateField.text)
                        font.pixelSize: 14
                        font.bold: true

                        background: Rectangle {
                            radius: 20
                            color: saveButton.enabled ? "#27ae60" : "#95a5a6"
                            border.color: saveButton.enabled ? "#219a52" : "transparent"
                            border.width: 2
                        }

                        contentItem: Row {
                            spacing: 8
                            anchors.centerIn: parent

                            Image {
                                source: isSaving ? "qrc:/icons/loading.png" : "qrc:/icons/save.png"
                                width: 16
                                height: 16
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: saveButton.text
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font: saveButton.font
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        KeyNavigation.tab: cancelButton
                        Keys.onReturnPressed: if (enabled && !isSaving) saveButton.clicked()
                        Keys.onUpPressed: loreField.forceActiveFocus()

                        onClicked: {
                            if (portfolioComboBox.currentIndex < 0) {
                                showMessage("Выберите портфолио студента", "error")
                                return
                            }

                            var selectedPortfolio = portfolioList[portfolioComboBox.currentIndex]
                            if (!selectedPortfolio || !selectedPortfolio.measure_code) {
                                showMessage("Выберите валидное портфолио", "error")
                                return
                            }

                            if (eventTypeField.text.trim() === "") {
                                showMessage("Введите тип мероприятия", "error")
                                return
                            }

                            if (categoryField.text.trim() === "") {
                                showMessage("Введите полное название категории", "error")
                                return
                            }

                            if (startDateField.text.trim() === "" || endDateField.text.trim() === "") {
                                showMessage("Заполните даты проведения", "error")
                                return
                            }

                            if (!validateDate(startDateField.text) || !validateDate(endDateField.text)) {
                                showMessage("Неверный формат дат", "error")
                                return
                            }

                            isSaving = true
                            console.log("Сохранение события...")
                            var eventData = getEventData()
                            if (eventData) {
                                saved(eventData)
                            } else {
                                isSaving = false
                                showMessage("Ошибка формирования данных события", "error")
                            }
                        }
                    }

                    Button {
                        id: cancelButton
                        text: "Отмена"
                        implicitWidth: 140
                        implicitHeight: 40
                        enabled: !isSaving
                        font.pixelSize: 14
                        font.bold: true

                        background: Rectangle {
                            radius: 20
                            color: "#e74c3c"
                            border.color: "#c0392b"
                            border.width: 2
                        }

                        contentItem: Row {
                            spacing: 8
                            anchors.centerIn: parent

                            Image {
                                source: "qrc:/icons/cross.png"
                                width: 16
                                height: 16
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: cancelButton.text
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font: cancelButton.font
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        KeyNavigation.tab: portfolioComboBox
                        Keys.onReturnPressed: if (enabled) cancelButton.clicked()
                        Keys.onUpPressed: saveButton.forceActiveFocus()

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
