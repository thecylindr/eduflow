import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../../common" as Common

ApplicationWindow {
    id: portfolioFormWindow
    width: 450
    height: 550
    flags: Qt.Dialog | Qt.FramelessWindowHint
    modality: Qt.ApplicationModal
    color: "transparent"
    visible: false

    property var currentPortfolio: null
    property bool isEditMode: false
    property bool isSaving: false
    property var students: []
    property var events: []

    signal saved(var portfolioData)
    signal cancelled()
    signal saveCompleted(bool success, string message)

    // Обновляем порядок навигации
    property var fieldNavigation: [
        studentComboBox, eventComboBox, dateField, descriptionField
    ]

    function openForAdd() {
        currentPortfolio = null
        isEditMode = false
        isSaving = false
        clearForm()
        portfolioFormWindow.show()
        portfolioFormWindow.requestActivate()
        portfolioFormWindow.x = (Screen.width - portfolioFormWindow.width) / 2
        portfolioFormWindow.y = (Screen.height - portfolioFormWindow.height) / 2
        Qt.callLater(function() { studentComboBox.forceActiveFocus() })
    }

    function openForEdit(portfolioData) {
        currentPortfolio = portfolioData
        isEditMode = true
        isSaving = false
        fillForm(portfolioData)
        portfolioFormWindow.show()
        portfolioFormWindow.requestActivate()
        portfolioFormWindow.x = (Screen.width - portfolioFormWindow.width) / 2
        portfolioFormWindow.y = (Screen.height - portfolioFormWindow.height) / 2
        Qt.callLater(function() { studentComboBox.forceActiveFocus() })
    }

    function closeWindow() {
        portfolioFormWindow.close()
    }

    function clearForm() {
        studentComboBox.currentIndex = -1
        eventComboBox.currentIndex = -1
        dateField.text = ""
        descriptionField.text = ""
    }

    function fillForm(portfolioData) {
        // Заполняем студента
        var studentCode = portfolioData.studentCode || portfolioData.student_code
        if (studentCode) {
            for (var i = 0; i < students.length; i++) {
                var student = students[i]
                var currentStudentCode = student.studentCode || student.student_code
                if (currentStudentCode === studentCode) {
                    studentComboBox.currentIndex = i
                    break
                }
            }
        } else {
            studentComboBox.currentIndex = -1
        }

        // Заполняем событие
        var eventId = portfolioData.eventId || portfolioData.event_id
        if (eventId) {
            for (var j = 0; j < events.length; j++) {
                var eventItem = events[j]
                var currentEventId = eventItem.eventId || eventItem.event_id
                if (currentEventId === eventId) {
                    eventComboBox.currentIndex = j
                    break
                }
            }
        } else {
            eventComboBox.currentIndex = -1
        }

        dateField.text = portfolioData.date || ""
        descriptionField.text = portfolioData.description || ""
    }

    function getPortfolioData() {
        var portfolioId = 0
        if (isEditMode && currentPortfolio) {
            portfolioId = currentPortfolio.portfolioId || currentPortfolio.portfolio_id || 0
        }

        var selectedStudent = studentComboBox.currentIndex >= 0 ?
            students[studentComboBox.currentIndex] : null
        var studentCode = selectedStudent ?
            (selectedStudent.studentCode || selectedStudent.student_code) : ""

        var selectedEvent = eventComboBox.currentIndex >= 0 ?
            events[eventComboBox.currentIndex] : null
        var eventId = selectedEvent ?
            (selectedEvent.eventId || selectedEvent.event_id) : 0

        return {
            portfolio_id: portfolioId,
            student_code: studentCode,
            event_id: eventId,
            date: dateField.text,
            description: descriptionField.text,
            passport_series: "", // Обязательные поля для сервера
            passport_number: "", // Обязательные поля для сервера
            file_path: "" // Обязательные поля для сервера
        }
    }

    function handleSaveResponse(response) {
        isSaving = false
        console.log("🔔 Обработка ответа сохранения портфолио:", JSON.stringify(response, null, 2))

        if (response.success) {
            var message = response.message || (isEditMode ? "✅ Портфолио успешно обновлено!" : "✅ Портфолио успешно добавлено!")
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
            title: isEditMode ? "Редактирование портфолио" : "Добавление портфолио"
            window: portfolioFormWindow
            onClose: {
                cancelled()
                closeWindow()
            }
        }

        // Белая форма
        Rectangle {
            id: whiteForm
            width: 410
            height: 470
            anchors {
                top: titleBar.bottom
                topMargin: 16
                horizontalCenter: parent.horizontalCenter
            }
            color: "#ffffff"
            opacity: 0.925
            radius: 12

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16

                // Контент формы
                Column {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 20

                    // Студент
                    Column {
                        width: parent.width
                        spacing: 8

                        Text {
                            text: "Студент:"
                            color: "#2c3e50"
                            font.bold: true
                            font.pixelSize: 14
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        ComboBox {
                            id: studentComboBox
                            width: parent.width - 40
                            height: 40
                            anchors.horizontalCenter: parent.horizontalCenter
                            enabled: !isSaving
                            font.pixelSize: 14
                            model: portfolioFormWindow.students
                            textRole: "displayName"
                            KeyNavigation.tab: eventComboBox
                            Keys.onReturnPressed: navigateToNextField(studentComboBox)
                            Keys.onEnterPressed: navigateToNextField(studentComboBox)
                            Keys.onUpPressed: navigateToPreviousField(studentComboBox)
                            Keys.onDownPressed: navigateToNextField(studentComboBox)

                            // Функция для отображения ФИО студента
                            property string displayName: {
                                if (model && currentIndex >= 0) {
                                    var student = students[currentIndex]
                                    var lastName = student.lastName || student.last_name || ""
                                    var firstName = student.firstName || student.first_name || ""
                                    var middleName = student.middleName || student.middle_name || ""
                                    return [lastName, firstName, middleName].filter(Boolean).join(" ")
                                }
                                return ""
                            }
                        }
                    }

                    // Событие
                    Column {
                        width: parent.width
                        spacing: 8

                        Text {
                            text: "Событие:"
                            color: "#2c3e50"
                            font.bold: true
                            font.pixelSize: 14
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        ComboBox {
                            id: eventComboBox
                            width: parent.width - 40
                            height: 40
                            anchors.horizontalCenter: parent.horizontalCenter
                            enabled: !isSaving
                            font.pixelSize: 14
                            model: portfolioFormWindow.events
                            textRole: "eventType"
                            KeyNavigation.tab: dateField
                            Keys.onReturnPressed: navigateToNextField(eventComboBox)
                            Keys.onEnterPressed: navigateToNextField(eventComboBox)
                            Keys.onUpPressed: navigateToPreviousField(eventComboBox)
                            Keys.onDownPressed: navigateToNextField(eventComboBox)
                        }
                    }

                    // Дата
                    Column {
                        width: parent.width
                        spacing: 8

                        Text {
                            text: "Дата:"
                            color: "#2c3e50"
                            font.bold: true
                            font.pixelSize: 14
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        TextField {
                            id: dateField
                            width: parent.width - 40
                            height: 40
                            anchors.horizontalCenter: parent.horizontalCenter
                            placeholderText: "ГГГГ-ММ-ДД"
                            horizontalAlignment: Text.AlignHCenter
                            enabled: !isSaving
                            font.pixelSize: 14
                            KeyNavigation.tab: descriptionField
                            Keys.onReturnPressed: navigateToNextField(dateField)
                            Keys.onEnterPressed: navigateToNextField(dateField)
                            Keys.onUpPressed: navigateToPreviousField(dateField)
                            Keys.onDownPressed: navigateToNextField(dateField)
                        }
                    }

                    // Описание
                    Column {
                        width: parent.width
                        spacing: 8

                        Text {
                            text: "Описание:"
                            color: "#2c3e50"
                            font.bold: true
                            font.pixelSize: 14
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        TextArea {
                            id: descriptionField
                            width: parent.width - 40
                            height: 80
                            anchors.horizontalCenter: parent.horizontalCenter
                            placeholderText: "Введите описание портфолио..."
                            wrapMode: Text.WordWrap
                            enabled: !isSaving
                            font.pixelSize: 12
                            KeyNavigation.tab: saveButton
                            Keys.onReturnPressed: navigateToNextField(descriptionField)
                            Keys.onEnterPressed: navigateToNextField(descriptionField)
                            Keys.onUpPressed: navigateToPreviousField(descriptionField)
                            Keys.onDownPressed: saveButton.forceActiveFocus()
                        }
                    }
                }

                // Кнопки действий
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 20

                    Button {
                        id: saveButton
                        text: isSaving ? "⏳ Сохранение..." : "💾 Сохранить"
                        implicitWidth: 140
                        implicitHeight: 40
                        enabled: !isSaving && studentComboBox.currentIndex >= 0
                        font.pixelSize: 14
                        KeyNavigation.tab: cancelButton
                        Keys.onReturnPressed: if (enabled && !isSaving) saveButton.clicked()
                        Keys.onEnterPressed: if (enabled && !isSaving) saveButton.clicked()
                        Keys.onUpPressed: descriptionField.forceActiveFocus()

                        onClicked: {
                            if (studentComboBox.currentIndex < 0) {
                                showMessage("❌ Выберите студента", "error")
                                return
                            }
                            isSaving = true
                            saved(getPortfolioData())
                        }
                    }

                    Button {
                        id: cancelButton
                        text: "❌ Отмена"
                        implicitWidth: 140
                        implicitHeight: 40
                        enabled: !isSaving
                        font.pixelSize: 14
                        KeyNavigation.tab: studentComboBox
                        Keys.onReturnPressed: if (enabled) cancelButton.clicked()
                        Keys.onEnterPressed: if (enabled) cancelButton.clicked()
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
