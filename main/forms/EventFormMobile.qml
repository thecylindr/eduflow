import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15
import QtQuick.Controls.Universal
import "../../common" as Common

Window {
    id: eventFormWindow
    width: Math.min(Screen.width * 0.95, 400)
    height: Math.min(Screen.height * 0.9, 700)
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
        Qt.callLater(function() {
            if (portfolioList.length > 0) {
                portfolioComboBox.forceActiveFocus()
            } else {
                eventTypeField.forceActiveFocus()
            }
        })
    }

    function openForEdit(eventData) {
        currentEvent = eventData
        isEditMode = true
        isSaving = false
        portfoliosLoaded = false
        portfoliosLoading = false
        portfolioStatus = "Загрузка портфолио..."
        loadPortfolios()
        eventFormWindow.show()
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
        if (!portfoliosLoaded) return

        var measureCode = eventData.measureCode || eventData.portfolio_id || eventData.event_id || 0
        if (measureCode > 0) {
            var foundIndex = -1
            for (var i = 0; i < portfolioList.length; i++) {
                if (portfolioList[i].measure_code === measureCode) {
                    foundIndex = i
                    break
                }
            }
            if (foundIndex >= 0) {
                portfolioComboBox.currentIndex = foundIndex
            }
        }

        eventTypeField.text = eventData.eventType || eventData.event_type || ""
        categoryField.text = eventData.category || ""

        var serverStartDate = eventData.startDate || eventData.start_date || ""
        if (serverStartDate) {
            var startParts = serverStartDate.split('-')
            if (startParts.length === 3) {
                startDateField.text = startParts[2] + "." + startParts[1] + "." + startParts[0]
            } else {
                startDateField.text = serverStartDate
            }
        }

        var serverEndDate = eventData.endDate || eventData.end_date || ""
        if (serverEndDate) {
            var endParts = serverEndDate.split('-')
            if (endParts.length === 3) {
                endDateField.text = endParts[2] + "." + endParts[1] + "." + endParts[0]
            } else {
                endDateField.text = serverEndDate
            }
        }

        locationField.text = eventData.location || ""
        loreField.text = eventData.lore || ""
    }

    function getEventData() {
        if (portfolioComboBox.currentIndex < 0) return null

        var selectedPortfolio = portfolioList[portfolioComboBox.currentIndex]
        if (!selectedPortfolio || !selectedPortfolio.measure_code) return null

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
            eventData.id = currentEvent.id
        }

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

    function loadPortfolios() {
        if (portfoliosLoading) return
        portfoliosLoading = true
        portfolioStatus = "Загрузка портфолио..."
        mainApi.getPortfolioForEvents(function(response) {
            portfoliosLoading = false
            if (response.success) {
                eventFormWindow.portfolioList = response.data
                eventFormWindow.portfoliosLoaded = true
                portfolioStatus = "Загружено: " + response.data.length + " портфолио"
                if (response.data.length > 0) {
                    if (isEditMode && currentEvent) {
                        fillForm(currentEvent)
                    }
                } else {
                    portfolioStatus = "Нет доступных портфолио"
                }
            } else {
                portfolioStatus = "Ошибка загрузки"
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
            width: parent.width - 20
            height: parent.height - titleBar.height - 40
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
                        spacing: 15

                        Column {
                            width: parent.width
                            spacing: 8

                            Label {
                                text: "Портфолио студента:"
                                font.bold: true
                                font.pixelSize: 14
                                color: "#2c3e50"
                            }

                            ComboBox {
                                id: portfolioComboBox
                                width: parent.width
                                height: 45
                                enabled: !isSaving && portfolioList.length > 0
                                font.pixelSize: 14

                                background: Rectangle {
                                    radius: 8
                                    color: "#ffffff"
                                    border.color: portfolioComboBox.enabled ? "#e0e0e0" : "#f0f0f0"
                                    border.width: 1
                                }

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
                            }

                            Label {
                                text: portfolioStatus
                                color: {
                                    if (portfoliosLoading) return "#ff9800"
                                    if (portfolioList.length === 0) return "#f44336"
                                    if (portfolioComboBox.currentIndex < 0) return "#ff9800"
                                    return "#4CAF50"
                                }
                                font.pixelSize: 12
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: 8

                            Label {
                                text: "Тип мероприятия:"
                                font.bold: true
                                font.pixelSize: 14
                                color: "#2c3e50"
                            }

                            TextField {
                                id: eventTypeField
                                width: parent.width
                                height: 45
                                placeholderText: "Введите тип мероприятия"
                                font.pixelSize: 14
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: 8

                            Label {
                                text: "Название мероприятия:"
                                font.bold: true
                                font.pixelSize: 14
                                color: "#2c3e50"
                            }

                            TextField {
                                id: categoryField
                                width: parent.width
                                height: 45
                                placeholderText: "Введите полное название мероприятия"
                                font.pixelSize: 14
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: 8

                            Label {
                                text: "Даты проведения:"
                                font.bold: true
                                font.pixelSize: 14
                                color: "#2c3e50"
                            }

                            Grid {
                                width: parent.width
                                columns: 2
                                spacing: 10

                                Column {
                                    width: parent.width / 2 - 5
                                    spacing: 4

                                    Label {
                                        text: "Начало:"
                                        font.pixelSize: 12
                                        color: "#2c3e50"
                                    }

                                    TextField {
                                        id: startDateField
                                        width: parent.width
                                        height: 40
                                        placeholderText: "ДД.ММ.ГГГГ"
                                        font.pixelSize: 14
                                        validator: RegularExpressionValidator {
                                            regularExpression: /^[\d\.]*$/
                                        }
                                    }
                                }

                                Column {
                                    width: parent.width / 2 - 5
                                    spacing: 4

                                    Label {
                                        text: "Окончание:"
                                        font.pixelSize: 12
                                        color: "#2c3e50"
                                    }

                                    TextField {
                                        id: endDateField
                                        width: parent.width
                                        height: 40
                                        placeholderText: "ДД.ММ.ГГГГ"
                                        font.pixelSize: 14
                                        validator: RegularExpressionValidator {
                                            regularExpression: /^[\d\.]*$/
                                        }
                                    }
                                }
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: 8

                            Label {
                                text: "Местоположение:"
                                font.bold: true
                                font.pixelSize: 14
                                color: "#2c3e50"
                            }

                            TextField {
                                id: locationField
                                width: parent.width
                                height: 45
                                placeholderText: "Введите местоположение"
                                font.pixelSize: 14
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: 8

                            Label {
                                text: "Описание события:"
                                font.bold: true
                                font.pixelSize: 14
                                color: "#2c3e50"
                            }

                            TextArea {
                                id: loreField
                                width: parent.width
                                height: 100
                                placeholderText: "Введите описание события..."
                                wrapMode: TextArea.Wrap
                                font.pixelSize: 14
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
                        implicitHeight: 45
                        enabled: !isSaving && portfolioComboBox.currentIndex >= 0 && portfolioList.length > 0 &&
                                eventTypeField.text.trim() !== "" && categoryField.text.trim() !== "" &&
                                startDateField.text.trim() !== "" && validateDate(startDateField.text) &&
                                endDateField.text.trim() !== "" && validateDate(endDateField.text)
                        font.pixelSize: 14
                        font.bold: true

                        background: Rectangle {
                            radius: 22
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

                        onClicked: {
                            if (portfolioComboBox.currentIndex < 0) return
                            var selectedPortfolio = portfolioList[portfolioComboBox.currentIndex]
                            if (!selectedPortfolio || !selectedPortfolio.measure_code) return
                            if (eventTypeField.text.trim() === "") return
                            if (categoryField.text.trim() === "") return
                            if (startDateField.text.trim() === "" || endDateField.text.trim() === "") return
                            if (!validateDate(startDateField.text) || !validateDate(endDateField.text)) return

                            isSaving = true
                            var eventData = getEventData()
                            if (eventData) {
                                saved(eventData)
                            } else {
                                isSaving = false
                            }
                        }
                    }

                    Button {
                        id: cancelButton
                        text: "Отмена"
                        implicitWidth: 140
                        implicitHeight: 45
                        enabled: !isSaving
                        font.pixelSize: 14
                        font.bold: true

                        background: Rectangle {
                            radius: 22
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
