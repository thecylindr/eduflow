import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../../common" as Common

ApplicationWindow {
    id: portfolioFormWindow
    width: 450
    height: 450
    flags: Qt.Dialog | Qt.FramelessWindowHint
    modality: Qt.ApplicationModal
    color: "transparent"
    visible: false

    property var currentPortfolio: null
    property bool isEditMode: false
    property bool isSaving: false
    property var students: []

    signal saved(var portfolioData)
    signal cancelled()
    signal saveCompleted(bool success, string message)

    property var fieldNavigation: [
        studentComboBox, dateField, decreeField
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
        dateField.text = ""
        decreeField.text = ""
    }

    function fillForm(portfolioData) {
        // Заполняем студента - ПРЕОБРАЗУЕМ В ЧИСЛО
        var studentCode = portfolioData.studentCode || portfolioData.student_code
        if (studentCode) {
            var numericStudentCode = parseInt(studentCode)
            for (var i = 0; i < students.length; i++) {
                var student = students[i]
                var currentStudentCode = parseInt(student.studentCode || student.student_code || 0)
                if (currentStudentCode === numericStudentCode) {
                    studentComboBox.currentIndex = i
                    break
                }
            }
        } else {
            studentComboBox.currentIndex = -1
        }

        // Преобразуем дату из ГГГГ-ММ-ДД в ДД.ММ.ГГГГ
        var serverDate = portfolioData.date || ""
        if (serverDate) {
            var parts = serverDate.split('-')
            if (parts.length === 3) {
                dateField.text = parts[2] + "." + parts[1] + "." + parts[0]
            } else {
                dateField.text = serverDate
            }
        } else {
            dateField.text = ""
        }

        decreeField.text = portfolioData.decree || ""
    }

    function getPortfolioData() {
        var portfolioId = 0;
        if (isEditMode && currentPortfolio) {
            portfolioId = currentPortfolio.portfolioId || currentPortfolio.portfolio_id || 0;
        }

        var selectedStudent = studentComboBox.currentIndex >= 0 ?
            students[studentComboBox.currentIndex] : null;

        // ИСПРАВЛЕНИЕ: Убеждаемся, что student_code передается как число
        var studentCode = selectedStudent ?
            parseInt(selectedStudent.studentCode || selectedStudent.student_code || 0) : 0;

        // Преобразуем дату из ДД.ММ.ГГГГ в ГГГГ-ММ-ДД для сервера
        var dateText = dateField.text;
        var formattedDate = dateText;
        if (dateText) {
            var parts = dateText.split('.');
            if (parts.length === 3) {
                formattedDate = parts[2] + "-" + parts[1] + "-" + parts[0];
            }
        }

        // ИСПРАВЛЕНИЕ: Создаем объект с правильными типами данных
        var portfolioData = {
            portfolio_id: portfolioId,
            student_code: studentCode, // Теперь это число
            date: formattedDate,
            decree: decreeField.text
        };

        console.log("📦 Подготовленные данные портфолио:", JSON.stringify(portfolioData));
        return portfolioData;
    }

    function formatDateText(text) {
        // Удаляем все нецифры
        var cleanText = text.replace(/[^\d]/g, '')

        // Форматируем в ДД.ММ.ГГГГ
        if (cleanText.length <= 2) {
            return cleanText
        } else if (cleanText.length <= 4) {
            return cleanText.substring(0, 2) + '.' + cleanText.substring(2)
        } else {
            return cleanText.substring(0, 2) + '.' + cleanText.substring(2, 4) + '.' + cleanText.substring(4, 8)
        }
    }

    function validateDate(text) {
        if (!text) return true

        var parts = text.split('.')
        if (parts.length !== 3) return false

        var day = parseInt(parts[0])
        var month = parseInt(parts[1])
        var year = parseInt(parts[2])

        // Базовая валидация
        if (day < 1 || day > 31) return false
        if (month < 1 || month > 12) return false
        if (year < 1900 || year > 2100) return false

        return true
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
            height: 400
            anchors {
                top: titleBar.bottom
                topMargin: 30
                horizontalCenter: parent.horizontalCenter
            }
            color: "#ffffff"
            opacity: 0.925
            radius: 12

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16

                // Прокручиваемая область с контентом
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    Column {
                        width: parent.width
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
                                enabled: !isSaving && students.length > 0
                                font.pixelSize: 14
                                model: portfolioFormWindow.students
                                textRole: "displayName"
                                KeyNavigation.tab: dateField
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
                                        var studentCode = student.studentCode || student.student_code || ""
                                        return [lastName, firstName, middleName].filter(Boolean).join(" ") + " (" + studentCode + ")"
                                    }
                                    return students.length > 0 ? "Выберите студента" : "Нет студентов"
                                }

                                // Делегат для отображения в выпадающем списке
                                delegate: ItemDelegate {
                                    width: parent.width
                                    text: {
                                        var lastName = modelData.lastName || modelData.last_name || ""
                                        var firstName = modelData.firstName || modelData.first_name || ""
                                        var middleName = modelData.middleName || modelData.middle_name || ""
                                        var studentCode = modelData.studentCode || modelData.student_code || ""
                                        return [lastName, firstName, middleName].filter(Boolean).join(" ") + " (" + studentCode + ")"
                                    }
                                }
                            }

                            Text {
                                text: students.length === 0 ? "❌ Нет доступных студентов" : ""
                                color: "#e74c3c"
                                font.pixelSize: 12
                                anchors.horizontalCenter: parent.horizontalCenter
                                visible: students.length === 0
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
                                placeholderText: "ДД.ММ.ГГГГ"
                                horizontalAlignment: Text.AlignHCenter
                                enabled: !isSaving
                                font.pixelSize: 14
                                KeyNavigation.tab: decreeField
                                Keys.onReturnPressed: navigateToNextField(dateField)
                                Keys.onEnterPressed: navigateToNextField(dateField)
                                Keys.onUpPressed: navigateToPreviousField(dateField)
                                Keys.onDownPressed: navigateToNextField(dateField)

                                // Валидатор для даты
                                validator: RegularExpressionValidator {
                                    regularExpression: /^(\d{0,2}\.?\d{0,2}\.?\d{0,4})$/
                                }

                                // Обработка изменения текста для форматирования
                                onTextChanged: {
                                    if (text.length > 10) {
                                        text = text.substring(0, 10)
                                    }
                                    var cursorPos = cursorPosition
                                    var formatted = formatDateText(text)
                                    if (formatted !== text) {
                                        text = formatted
                                        cursorPosition = Math.min(cursorPos, text.length)
                                    }
                                }

                                background: Rectangle {
                                    radius: 6
                                    color: "#ffffff"
                                    border.color: validateDate(dateField.text) ? "#e0e0e0" : "#e74c3c"
                                    border.width: 2
                                }
                            }

                            Text {
                                text: !validateDate(dateField.text) && dateField.text !== "" ? "❌ Неверный формат даты" : ""
                                color: "#e74c3c"
                                font.pixelSize: 11
                                anchors.horizontalCenter: parent.horizontalCenter
                                visible: !validateDate(dateField.text) && dateField.text !== ""
                            }
                        }

                        // Приказ (decree)
                        Column {
                            width: parent.width
                            spacing: 8

                            Text {
                                text: "Приказ:"
                                color: "#2c3e50"
                                font.bold: true
                                font.pixelSize: 14
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            TextField {
                                id: decreeField
                                width: parent.width - 40
                                height: 40
                                anchors.horizontalCenter: parent.horizontalCenter
                                placeholderText: "Введите номер приказа*"
                                horizontalAlignment: Text.AlignHCenter
                                enabled: !isSaving
                                font.pixelSize: 14
                                KeyNavigation.tab: saveButton
                                Keys.onReturnPressed: navigateToNextField(decreeField)
                                Keys.onEnterPressed: navigateToNextField(decreeField)
                                Keys.onUpPressed: navigateToPreviousField(decreeField)
                                Keys.onDownPressed: saveButton.forceActiveFocus()
                            }
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
                        enabled: !isSaving && studentComboBox.currentIndex >= 0 &&
                                dateField.text.trim() !== "" && validateDate(dateField.text) &&
                                decreeField.text.trim() !== "" &&
                                students.length > 0
                        font.pixelSize: 14
                        KeyNavigation.tab: cancelButton
                        Keys.onReturnPressed: if (enabled && !isSaving) saveButton.clicked()
                        Keys.onEnterPressed: if (enabled && !isSaving) saveButton.clicked()
                        Keys.onUpPressed: decreeField.forceActiveFocus()

                        onClicked: {
                            if (studentComboBox.currentIndex < 0) {
                                showMessage("❌ Выберите студента", "error")
                                return
                            }
                            if (dateField.text.trim() === "") {
                                showMessage("❌ Введите дату", "error")
                                return
                            }
                            if (!validateDate(dateField.text)) {
                                showMessage("❌ Неверный формат даты", "error")
                                return
                            }
                            if (decreeField.text.trim() === "") {
                                showMessage("❌ Введите номер приказа", "error")
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
