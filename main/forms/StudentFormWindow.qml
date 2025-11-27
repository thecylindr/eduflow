import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material
import "../../common" as Common

Window {
    id: studentFormWindow
    width: 420
    height: 530
    flags: Qt.Dialog | Qt.FramelessWindowHint
    modality: Qt.ApplicationModal
    color: "transparent"
    visible: false

    property var currentStudent: null
    property bool isEditMode: false
    property bool isSaving: false
    property var groups: []

    signal saved(var studentData)
    signal cancelled()
    signal saveCompleted(bool success, string message)

    // Порядок навигации между полями
    property var fieldNavigation: [
        lastNameField, firstNameField, middleNameField,
        emailField, phoneField, passportSeriesField,
        passportNumberField, groupComboBox
    ]

    function openForAdd() {
        currentStudent = null
        isEditMode = false
        isSaving = false
        clearForm()
        studentFormWindow.show()
        studentFormWindow.requestActivate()
        studentFormWindow.x = (Screen.width - studentFormWindow.width) / 2
        studentFormWindow.y = (Screen.height - studentFormWindow.height) / 2
        Qt.callLater(function() { lastNameField.forceActiveFocus() })
    }

    function openForEdit(studentData) {
        currentStudent = studentData
        isEditMode = true
        isSaving = false
        fillForm(studentData)
        studentFormWindow.show()
        studentFormWindow.requestActivate()
        studentFormWindow.x = (Screen.width - studentFormWindow.width) / 2
        studentFormWindow.y = (Screen.height - studentFormWindow.height) / 2
        Qt.callLater(function() { lastNameField.forceActiveFocus() })
    }

    // Функция форматирования номера телефона
    function formatPhoneNumber(text) {
        // Удаляем все нецифровые символы
        var digits = text.replace(/\D/g, '')

        // Если номер начинается с 7 или 8, заменяем на +7
        if (digits.startsWith('7') || digits.startsWith('8')) {
            digits = digits.substring(1)
        }

        // Ограничиваем длину до 10 цифр
        digits = digits.substring(0, 10)

        // Форматируем номер в российский формат
        if (digits.length === 0) {
            return "+7 "
        } else if (digits.length <= 3) {
            return "+7 (" + digits
        } else if (digits.length <= 6) {
            return "+7 (" + digits.substring(0, 3) + ") " + digits.substring(3)
        } else if (digits.length <= 8) {
            return "+7 (" + digits.substring(0, 3) + ") " + digits.substring(3, 6) + "-" + digits.substring(6)
        } else {
            return "+7 (" + digits.substring(0, 3) + ") " + digits.substring(3, 6) + "-" + digits.substring(6, 8) + "-" + digits.substring(8)
        }
    }

    function normalizePhoneNumber(phone) {
        // Удаляем все нецифровые символы
        var digits = phone.replace(/\D/g, '')

        // Если номер пустой, возвращаем пустую строку
        if (digits.length === 0) {
            return ""
        }

        // Если номер начинается с 8, заменяем на 7
        if (digits.startsWith('8')) {
            digits = '7' + digits.substring(1)
        }
        // Если номер начинается не с 7 и не с 8, добавляем 7 в начало
        else if (!digits.startsWith('7')) {
            digits = '7' + digits
        }

        // Ограничиваем длину до 11 цифр
        digits = digits.substring(0, 11)

        // Если осталась только одна цифра 7, возвращаем пустую строку
        if (digits === '7') {
            return ""
        }

        return digits
    }

    function closeWindow() {
        studentFormWindow.close()
    }

    function clearForm() {
        lastNameField.text = ""
        firstNameField.text = ""
        middleNameField.text = ""
        emailField.text = ""
        phoneField.text = ""
        passportSeriesField.text = ""
        passportNumberField.text = ""
        groupComboBox.currentIndex = -1
    }

    function fillForm(studentData) {
        lastNameField.text = studentData.lastName || studentData.last_name || ""
        firstNameField.text = studentData.firstName || studentData.first_name || ""
        middleNameField.text = studentData.middleName || studentData.middle_name || ""
        emailField.text = studentData.email || ""
        // Форматируем номер телефона при заполнении формы
        var phoneData = studentData.phoneNumber || studentData.phone_number || ""
        if (phoneData && !phoneData.startsWith("+7")) {
            phoneField.text = formatPhoneNumber(phoneData)
        } else {
            phoneField.text = phoneData
        }
        passportSeriesField.text = studentData.passportSeries || studentData.passport_series || ""
        passportNumberField.text = studentData.passportNumber || studentData.passport_number || ""

        // Находим индекс группы в комбобоксе
        var groupId = studentData.groupId || studentData.group_id
        if (groupId) {
            for (var i = 0; i < groups.length; i++) {
                var group = groups[i]
                var currentGroupId = group.groupId || group.group_id
                if (currentGroupId === groupId) {
                    groupComboBox.currentIndex = i
                    break
                }
            }
        } else {
            groupComboBox.currentIndex = -1
        }
    }

    function getStudentData() {
        var studentCode = ""
        if (isEditMode && currentStudent) {
            studentCode = currentStudent.studentCode || currentStudent.student_code || ""
        }

        var selectedGroup = groupComboBox.currentIndex >= 0 ?
            groups[groupComboBox.currentIndex] : null
        var groupId = selectedGroup ?
            (selectedGroup.groupId || selectedGroup.group_id) : 0

        // Нормализуем телефон перед отправкой - только цифры, начинается с 7
        var normalizedPhone = normalizePhoneNumber(phoneField.text)

        return {
            student_code: studentCode,
            last_name: lastNameField.text,
            first_name: firstNameField.text,
            middle_name: middleNameField.text,
            email: emailField.text,
            phone_number: normalizedPhone, // Используем нормализованный номер
            passport_series: passportSeriesField.text,
            passport_number: passportNumberField.text,
            group_id: groupId
        }
    }

    function handleSaveResponse(response) {
        isSaving = false
        console.log(" Обработка ответа сохранения студента:", JSON.stringify(response, null, 2))

        if (response.success) {
            var message = response.message || (isEditMode ? "Студент успешно обновлен!" : "Студент успешно добавлен!")
            showMessage(message, "success")
            saveCompleted(true, message)
            closeWindow()
        } else {
            var errorMsg = "" + (response.error || "Неизвестная ошибка")
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
            title: isEditMode ? "Редактирование студента" : "Добавление студента"
            window: studentFormWindow
            onClose: {
                cancelled()
                closeWindow()
            }
        }

        // Белая форма
        Rectangle {
            id: whiteForm
            width: 380
            height: 450
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
                anchors.margins: 16
                spacing: 12

                // Контент формы
                Column {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 14

                    // ФИО
                    Column {
                        width: parent.width
                        spacing: 6

                        Text {
                            text: "ФИО:"
                            color: "#2c3e50"
                            font.bold: true
                            font.pixelSize: 13
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Row {
                            width: 300
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 8

                            TextField {
                                id: lastNameField
                                width: 96
                                height: 34
                                placeholderText: "Фамилия*"
                                horizontalAlignment: Text.AlignHCenter
                                enabled: !isSaving
                                font.pixelSize: 12
                                KeyNavigation.tab: firstNameField
                                Keys.onReturnPressed: navigateToNextField(lastNameField)
                                Keys.onEnterPressed: navigateToNextField(lastNameField)
                                Keys.onUpPressed: navigateToPreviousField(lastNameField)
                                Keys.onDownPressed: navigateToNextField(lastNameField)
                            }

                            TextField {
                                id: firstNameField
                                width: 96
                                height: 34
                                placeholderText: "Имя*"
                                horizontalAlignment: Text.AlignHCenter
                                enabled: !isSaving
                                font.pixelSize: 12
                                KeyNavigation.tab: middleNameField
                                Keys.onReturnPressed: navigateToNextField(firstNameField)
                                Keys.onEnterPressed: navigateToNextField(firstNameField)
                                Keys.onUpPressed: navigateToPreviousField(firstNameField)
                                Keys.onDownPressed: navigateToNextField(firstNameField)
                            }

                            TextField {
                                id: middleNameField
                                width: 96
                                height: 34
                                placeholderText: "Отчество"
                                horizontalAlignment: Text.AlignHCenter
                                enabled: !isSaving
                                font.pixelSize: 12
                                KeyNavigation.tab: emailField
                                Keys.onReturnPressed: navigateToNextField(middleNameField)
                                Keys.onEnterPressed: navigateToNextField(middleNameField)
                                Keys.onUpPressed: navigateToPreviousField(middleNameField)
                                Keys.onDownPressed: navigateToNextField(middleNameField)
                            }
                        }
                    }

                    // Контакты
                    Column {
                        width: parent.width
                        spacing: 6

                        Text {
                            text: "Контакты:"
                            color: "#2c3e50"
                            font.bold: true
                            font.pixelSize: 13
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        TextField {
                            id: emailField
                            width: 280
                            height: 34
                            anchors.horizontalCenter: parent.horizontalCenter
                            placeholderText: "Email"
                            horizontalAlignment: Text.AlignHCenter
                            enabled: !isSaving
                            font.pixelSize: 12
                            KeyNavigation.tab: phoneField
                            Keys.onReturnPressed: navigateToNextField(emailField)
                            Keys.onEnterPressed: navigateToNextField(emailField)
                            Keys.onUpPressed: navigateToPreviousField(emailField)
                            Keys.onDownPressed: navigateToNextField(emailField)
                        }

                        TextField {
                            id: phoneField
                            width: 280
                            height: 34
                            anchors.horizontalCenter: parent.horizontalCenter
                            placeholderText: "Номер телефона"
                            horizontalAlignment: Text.AlignHCenter
                            enabled: !isSaving
                            font.pixelSize: 12

                            // Валидатор для ввода только цифр
                            validator: RegularExpressionValidator {
                                regularExpression: /^[0-9+\(\)\-\s]*$/
                            }

                            // Обработчик изменения текста для форматирования
                            onTextChanged: {
                                if (activeFocus) {
                                    var cursorPosition = cursorPosition
                                    var formatted = formatPhoneNumber(text)
                                    if (formatted !== text) {
                                        text = formatted
                                        cursorPosition = Math.min(cursorPosition, formatted.length)
                                        cursorPosition = formatted.length
                                    }
                                }
                            }

                            // Обработчик ввода текста для фильтрации нецифровых символов
                            onActiveFocusChanged: {
                                if (activeFocus && text === "") {
                                    text = "+7 "
                                }
                            }

                            KeyNavigation.tab: passportSeriesField
                            Keys.onReturnPressed: navigateToNextField(phoneField)
                            Keys.onEnterPressed: navigateToNextField(phoneField)
                            Keys.onUpPressed: navigateToPreviousField(phoneField)
                            Keys.onDownPressed: navigateToNextField(phoneField)
                        }
                    }

                    // Паспортные данные
                    Column {
                        width: parent.width
                        spacing: 6

                        Text {
                            text: "Паспортные данные:"
                            color: "#2c3e50"
                            font.bold: true
                            font.pixelSize: 13
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Row {
                            width: 280
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 8

                            TextField {
                                id: passportSeriesField
                                width: 136
                                height: 34
                                placeholderText: "Серия паспорта*"
                                horizontalAlignment: Text.AlignHCenter
                                enabled: !isSaving
                                font.pixelSize: 12
                                validator: IntValidator { bottom: 1000; top: 9999 }
                                KeyNavigation.tab: passportNumberField
                                Keys.onReturnPressed: navigateToNextField(passportSeriesField)
                                Keys.onEnterPressed: navigateToNextField(passportSeriesField)
                                Keys.onUpPressed: navigateToPreviousField(passportSeriesField)
                                Keys.onDownPressed: navigateToNextField(passportSeriesField)
                            }

                            TextField {
                                id: passportNumberField
                                width: 136
                                height: 34
                                placeholderText: "Номер паспорта*"
                                horizontalAlignment: Text.AlignHCenter
                                enabled: !isSaving
                                font.pixelSize: 12
                                validator: IntValidator { bottom: 100000; top: 999999 }
                                KeyNavigation.tab: groupComboBox
                                Keys.onReturnPressed: navigateToNextField(passportNumberField)
                                Keys.onEnterPressed: navigateToNextField(passportNumberField)
                                Keys.onUpPressed: navigateToPreviousField(passportNumberField)
                                Keys.onDownPressed: navigateToNextField(passportNumberField)
                            }
                        }
                    }

                    // Группа
                    Column {
                        width: parent.width
                        spacing: 6

                        Text {
                            text: "Группа:"
                            color: "#2c3e50"
                            font.bold: true
                            font.pixelSize: 13
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        ComboBox {
                            id: groupComboBox
                            width: 280
                            height: 34
                            anchors.horizontalCenter: parent.horizontalCenter
                            enabled: !isSaving
                            font.pixelSize: 12

                            // Белый стиль для ComboBox
                            background: Rectangle {
                                radius: 6
                                color: "#ffffff"
                                border.color: groupComboBox.enabled ? "#e0e0e0" : "#f0f0f0"
                                border.width: 1
                            }

                            contentItem: Text {
                                text: groupComboBox.displayText
                                color: "#000000"
                                horizontalAlignment: Text.AlignLeft
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 10
                                rightPadding: groupComboBox.indicator.width + 10
                                font: groupComboBox.font
                            }

                            indicator: Rectangle {
                                x: groupComboBox.width - width - 5
                                y: groupComboBox.topPadding + (groupComboBox.height - height) / 2
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
                                y: groupComboBox.height - 1
                                width: groupComboBox.width
                                implicitHeight: contentItem.implicitHeight
                                padding: 1

                                contentItem: ListView {
                                    clip: true
                                    implicitHeight: contentHeight
                                    model: groupComboBox.popup.visible ? groupComboBox.delegateModel : null
                                    currentIndex: groupComboBox.highlightedIndex

                                    ScrollIndicator.vertical: ScrollIndicator { }
                                }

                                background: Rectangle {
                                    color: "#ffffff"
                                    border.color: "#e0e0e0"
                                    radius: 6
                                }
                            }

                            delegate: ItemDelegate {
                                width: groupComboBox.width
                                contentItem: Text {
                                    text: modelData.name
                                    color: "#000000"
                                    font: groupComboBox.font
                                    elide: Text.ElideRight
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                                background: Rectangle {
                                    color: highlighted ? "#e0e0e0" : "#ffffff"
                                }
                                highlighted: groupComboBox.highlightedIndex === index
                            }

                            model: studentFormWindow.groups
                            textRole: "name"
                            KeyNavigation.tab: saveButton
                            Keys.onReturnPressed: navigateToNextField(groupComboBox)
                            Keys.onEnterPressed: navigateToNextField(groupComboBox)
                            Keys.onUpPressed: navigateToPreviousField(groupComboBox)
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
                        enabled: !isSaving && lastNameField.text.trim() !== "" &&
                                firstNameField.text.trim() !== "" &&
                                passportSeriesField.text.trim() !== "" &&
                                passportNumberField.text.trim() !== "" &&
                                groupComboBox.currentIndex >= 0
                        font.pixelSize: 14
                        font.bold: true

                        background: Rectangle {
                            radius: 20
                            color: saveButton.enabled ? "#27ae60" : "#95a5a6"
                            border.color: saveButton.enabled ? "#219a52" : "transparent"
                            border.width: 1
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
                        Keys.onEnterPressed: if (enabled && !isSaving) saveButton.clicked()
                        Keys.onUpPressed: groupComboBox.forceActiveFocus()

                        onClicked: {
                            if (lastNameField.text.trim() === "" || firstNameField.text.trim() === "") {
                                showMessage("Заполните обязательные поля (Фамилия и Имя)", "error")
                                return
                            }
                            if (passportSeriesField.text.trim() === "" || passportNumberField.text.trim() === "") {
                                showMessage("Заполните паспортные данные", "error")
                                return
                            }
                            if (groupComboBox.currentIndex < 0) {
                                showMessage("Выберите группу", "error")
                                return
                            }
                            isSaving = true
                            saved(getStudentData())
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
                            border.width: 1
                        }

                        contentItem: Text {
                            text: cancelButton.text
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font: cancelButton.font
                        }

                        KeyNavigation.tab: lastNameField
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
