import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts 1.15
import "../../common" as Common

Window {
    id: teacherFormWindow
    width: 450
    height: 640
    flags: Qt.Dialog | Qt.FramelessWindowHint
    modality: Qt.ApplicationModal
    color: "transparent"
    visible: false

    property var currentTeacher: null
    property bool isEditMode: false
    property bool isSaving: false
    property var existingSpecializations: []

    signal saved(var teacherData)
    signal cancelled()
    signal saveCompleted(bool success, string message)

    // Обновленный порядок навигации с зацикливанием
    property var fieldNavigation: [
        lastNameField, firstNameField, middleNameField,
        emailField, phoneField, experienceField,
        existingSpecializationsCombo, newSpecializationField,
        saveButton, cancelButton
    ]

    function openForAdd() {
        currentTeacher = null
        isEditMode = false
        isSaving = false
        clearForm()
        teacherFormWindow.show()
        teacherFormWindow.requestActivate()
        teacherFormWindow.x = (Screen.width - teacherFormWindow.width) / 2
        teacherFormWindow.y = (Screen.height - teacherFormWindow.height) / 2
        Qt.callLater(function() { lastNameField.forceActiveFocus() })

        loadExistingSpecializations();
    }

    function openForEdit(teacherData) {
        currentTeacher = teacherData
        isEditMode = true
        isSaving = false
        fillForm(teacherData)
        teacherFormWindow.show()
        teacherFormWindow.requestActivate()
        teacherFormWindow.x = (Screen.width - teacherFormWindow.width) / 2
        teacherFormWindow.y = (Screen.height - teacherFormWindow.height) / 2
        Qt.callLater(function() { lastNameField.forceActiveFocus() })

        loadExistingSpecializations();
    }

    function closeWindow() {
        teacherFormWindow.close()
    }

    function clearForm() {
        lastNameField.text = ""
        firstNameField.text = ""
        middleNameField.text = ""
        emailField.text = ""
        phoneField.text = ""
        experienceField.value = 0
        specializationModel.clear()
        existingSpecializationsCombo.currentIndex = -1
        newSpecializationField.text = ""
    }

    function fillForm(teacherData) {
        lastNameField.text = teacherData.lastName || ""
        firstNameField.text = teacherData.firstName || ""
        middleNameField.text = teacherData.middleName || ""
        emailField.text = teacherData.email || ""
        var phoneData = teacherData.phoneNumber || teacherData.phone_number || ""
        if (phoneData && !phoneData.startsWith("+7")) {
            phoneField.text = formatPhoneNumber(phoneData)
        } else {
            phoneField.text = phoneData
        }
        experienceField.value = teacherData.experience || 0

        specializationModel.clear()
        var specs = []

        if (teacherData.specializations && Array.isArray(teacherData.specializations)) {
            for (var i = 0; i < teacherData.specializations.length; i++) {
                var specName = teacherData.specializations[i].name || teacherData.specializations[i]
                if (specName && specName.trim() !== "") {
                    specializationModel.append({name: specName.trim()})
                }
            }
        } else if (teacherData.specialization) {
            var specArray = teacherData.specialization.split(",").map(function(s) { return s.trim() }).filter(function(s) { return s !== "" })
            for (var j = 0; j < specArray.length; j++) {
                specializationModel.append({name: specArray[j]})
            }
        }

        existingSpecializationsCombo.currentIndex = -1
        newSpecializationField.text = ""
    }

    function loadExistingSpecializations() {
        var excludeTeacherId = 0;
        if (isEditMode && currentTeacher) {
            excludeTeacherId = currentTeacher.teacherId || currentTeacher.teacher_id || 0;
        }

        mainWindow.mainApi.getAllTeachersSpecializations(excludeTeacherId, function(response) {
            if (response.success) {
                var uniqueSpecs = response.data || [];
                existingSpecializations = uniqueSpecs;
                existingSpecializationsCombo.model = uniqueSpecs;

                existingSpecializationsCombo.displayText = existingSpecializations.length > 0 ?
                    "Выберите специализацию (" + existingSpecializations.length + " доступно)" :
                    "Нет доступных специализаций";
            } else {
                existingSpecializations = [];
                existingSpecializationsCombo.model = [];
            }
        });
    }

    function getTeacherData() {
        var specs = []
        for (var i = 0; i < specializationModel.count; i++) {
            var specName = specializationModel.get(i).name.trim()
            if (specName !== "") {
                specs.push(specName)
            }
        }

        var teacherId = 0;
        if (isEditMode && currentTeacher) {
            teacherId = currentTeacher.teacherId || currentTeacher.teacher_id || 0;
        }

        return {
            teacher_id: teacherId,
            last_name: lastNameField.text.trim(),
            first_name: firstNameField.text.trim(),
            middle_name: middleNameField.text.trim(),
            email: emailField.text.trim(),
            phone_number: normalizePhoneNumber(phoneField.text),
            experience: experienceField.value,
            specialization: specs.join(", "),
            specializations: specs
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

    function handleSaveResponse(response) {
        isSaving = false
        if (response.success) {
            var message = response.message || (isEditMode ? "Преподаватель успешно обновлен!" : "Преподаватель успешно добавлен!")
            showMessage(message, "success")
            saveCompleted(true, message)
            closeWindow()
        } else {
            var errorMsg = (response.error || "Неизвестная ошибка")
            showMessage(errorMsg, "error")
            saveCompleted(false, errorMsg)
        }
    }

    function addSpecialization() {
        var newSpec = newSpecializationField.text.trim()
        if (newSpec !== "") {
            addSpecializationByName(newSpec)
            newSpecializationField.text = ""
            newSpecializationField.forceActiveFocus()
        }
    }

    function addExistingSpecialization() {
        var existingSpec = existingSpecializationsCombo.currentText.trim()
        if (existingSpec !== "") {
            addSpecializationByName(existingSpec)
            existingSpecializationsCombo.currentIndex = -1
        }
    }

    function addSpecializationByName(name) {
        var trimmedName = name.trim()
        if (trimmedName !== "") {
            var isDuplicate = false
            for (var i = 0; i < specializationModel.count; i++) {
                if (specializationModel.get(i).name === trimmedName) {
                    isDuplicate = true
                    break
                }
            }

            if (!isDuplicate) {
                specializationModel.append({name: trimmedName})
            }
        }
    }

    function showMessage(text, type) {
        console.log("Сообщение [" + type + "]: " + text)
    }

    function navigateToPreviousField(currentField) {
        var currentIndex = fieldNavigation.indexOf(currentField)
        var previousIndex = currentIndex > 0 ? currentIndex - 1 : fieldNavigation.length - 1
        fieldNavigation[previousIndex].forceActiveFocus()
    }

    function navigateToNextField(currentField) {
        var currentIndex = fieldNavigation.indexOf(currentField)
        var nextIndex = currentIndex < fieldNavigation.length - 1 ? currentIndex + 1 : 0
        fieldNavigation[nextIndex].forceActiveFocus()
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
            title: isEditMode ? "Редактирование преподавателя" : "Добавление преподавателя"
            window: teacherFormWindow
            onClose: {
                cancelled()
                closeWindow()
            }
        }

        // Белая форма
        Rectangle {
            id: whiteForm
            width: 420
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

                // Прокручиваемая область с контентом
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    Column {
                        width: parent.width
                        spacing: 12

                        Column {
                            width: parent.width
                            spacing: 5

                            Text {
                                text: "Фамилия, Имя, Отчество:"
                                color: "#2c3e50"
                                font.pixelSize: 13
                                font.bold: true
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Row {
                                width: parent.width
                                spacing: 8  // Уменьшен промежуток
                                anchors.horizontalCenter: parent.horizontalCenter

                                // Фамилия
                                TextField {
                                    id: lastNameField
                                    width: (parent.width - 16) / 3
                                    height: 32
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

                                // Имя
                                TextField {
                                    id: firstNameField
                                    width: (parent.width - 16) / 3
                                    height: 32
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

                                // Отчество
                                TextField {
                                    id: middleNameField
                                    width: (parent.width - 16) / 3
                                    height: 32
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

                        // Остальные поля в вертикальном расположении
                        GridLayout {
                            columns: 2
                            columnSpacing: 10
                            rowSpacing: 4
                            width: parent.width

                            TextField {
                                id: emailField
                                Layout.fillWidth: true
                                Layout.preferredHeight: 36
                                placeholderText: "Email (опционально)"
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
                                Layout.fillWidth: true
                                Layout.preferredHeight: 36
                                placeholderText: "Введите номер"
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

                                onActiveFocusChanged: {
                                    if (activeFocus && text === "") {
                                        text = "+7 "
                                    }
                                }

                                KeyNavigation.tab: experienceField
                                Keys.onReturnPressed: navigateToNextField(phoneField)
                                Keys.onEnterPressed: navigateToNextField(phoneField)
                                Keys.onUpPressed: navigateToPreviousField(phoneField)
                                Keys.onDownPressed: navigateToNextField(phoneField)
                            }
                        }

                        RowLayout {
                            width: parent.width
                            spacing: 4
                            Layout.preferredHeight: 36

                            Text {
                                text: "Стаж (лет):"
                                color: "#2c3e50"
                                font.pixelSize: 11
                                Layout.alignment: Qt.AlignLeft
                                Layout.preferredWidth: 60
                            }

                            SpinBox {
                                id: experienceField
                                width: 60
                                Layout.preferredHeight: 36
                                from: 0
                                to: 100
                                value: 0
                                editable: true
                                enabled: !isSaving
                                font.pixelSize: 12
                                KeyNavigation.tab: existingSpecializationsCombo
                                Keys.onReturnPressed: navigateToNextField(experienceField)
                                Keys.onEnterPressed: navigateToNextField(experienceField)
                                Keys.onUpPressed: navigateToPreviousField(experienceField)
                                Keys.onDownPressed: navigateToNextField(experienceField)
                            }
                        }

                        // Блок специализаций
                        Column {
                            width: parent.width
                            spacing: 8

                            Text {
                                text: "Специализации преподавателя:"
                                color: "#2c3e50"
                                font.pixelSize: 13
                                font.bold: true
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            // Список ВСЕХ специализаций текущего преподавателя
                            Rectangle {
                                width: parent.width
                                height: 120
                                anchors.horizontalCenter: parent.horizontalCenter
                                color: "#f8f9fa"
                                radius: 6
                                border.color: "#dee2e6"
                                border.width: 1

                                ListView {
                                    id: specializationList
                                    anchors.fill: parent
                                    anchors.margins: 4
                                    model: ListModel { id: specializationModel }
                                    clip: true
                                    spacing: 3

                                    delegate: Row {
                                        width: parent.width
                                        spacing: 8
                                        height: 26

                                        Rectangle {
                                            width: parent.width - 48
                                            height: 26
                                            color: "white"
                                            radius: 4
                                            border.color: "#e9ecef"
                                            border.width: 1

                                            Text {
                                                anchors.fill: parent
                                                anchors.margins: 2
                                                text: name
                                                verticalAlignment: Text.AlignVCenter
                                                horizontalAlignment: Text.AlignHCenter
                                                font.pixelSize: 10
                                                color: "#2c3e50"
                                                elide: Text.ElideRight
                                            }
                                        }

                                        Button {
                                            width: 26
                                            height: 26
                                            enabled: !isSaving

                                            background: Rectangle {
                                                anchors.fill: parent
                                                color: "#e74c3c"
                                                radius: 4
                                                border.color: "#c0392b"
                                                border.width: 1

                                                states: [
                                                    State {
                                                        name: "hovered"
                                                        when: parent.hovered && parent.enabled
                                                        PropertyChanges {
                                                            target: background
                                                            color: "#c0392b"
                                                        }
                                                    },
                                                    State {
                                                        name: "pressed"
                                                        when: parent.pressed && parent.enabled
                                                        PropertyChanges {
                                                            target: background
                                                            color: "#a93226"
                                                        }
                                                    }
                                                ]

                                                Behavior on color {
                                                    ColorAnimation { duration: 150 }
                                                }
                                            }

                                            contentItem: Text {
                                                text: "×"
                                                color: "white"
                                                font.pixelSize: 16
                                                font.bold: true
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                                anchors.centerIn: parent
                                            }

                                            padding: 0
                                            topInset: 0
                                            bottomInset: 0
                                            leftInset: 0
                                            rightInset: 0

                                            onClicked: specializationModel.remove(index)
                                        }
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: "Нет специализаций"
                                        color: "#7f8c8d"
                                        font.italic: true
                                        font.pixelSize: 11
                                        visible: specializationModel.count === 0
                                    }
                                }
                            }

                            // Выбор из существующих специализаций ДРУГИХ преподавателей
                            Column {
                                width: parent.width
                                spacing: 4

                                Text {
                                    text: "Существующие специализации:"
                                    color: "#2c3e50"
                                    font.pixelSize: 11
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                Row {
                                    width: parent.width
                                    spacing: 8
                                    anchors.horizontalCenter: parent.horizontalCenter

                                    ComboBox {
                                        id: existingSpecializationsCombo
                                        width: parent.width - 48
                                        height: 40
                                        model: teacherFormWindow.existingSpecializations
                                        enabled: !isSaving && teacherFormWindow.existingSpecializations.length > 0

                                        // Добавляем отображение элементов списка
                                        delegate: ItemDelegate {
                                            width: existingSpecializationsCombo.width
                                            text: modelData
                                            font.pixelSize: 11
                                            highlighted: existingSpecializationsCombo.highlightedIndex === index
                                        }

                                        // Добавляем popup для отображения списка
                                        popup: Popup {
                                            y: existingSpecializationsCombo.height
                                            width: existingSpecializationsCombo.width
                                            implicitHeight: contentItem.implicitHeight
                                            padding: 1

                                            contentItem: ListView {
                                                clip: true
                                                implicitHeight: contentHeight
                                                model: existingSpecializationsCombo.popup.visible ? existingSpecializationsCombo.delegateModel : null
                                                currentIndex: existingSpecializationsCombo.highlightedIndex

                                                ScrollIndicator.vertical: ScrollIndicator { }
                                            }

                                            background: Rectangle {
                                                border.color: "#dee2e6"
                                                radius: 4
                                            }
                                        }

                                        property string placeholderText: teacherFormWindow.existingSpecializations.length > 0 ?
                                            "Выберите специализацию (" + teacherFormWindow.existingSpecializations.length + " доступно)" :
                                            "Нет доступных специализаций"

                                        displayText: currentIndex === -1 ? placeholderText : currentText

                                        background: Rectangle {
                                            color: enabled ? "white" : "#f8f9fa"
                                            border.color: enabled ? "#dee2e6" : "#e9ecef"
                                            border.width: 1
                                            radius: 4
                                        }

                                        contentItem: Text {
                                            text: existingSpecializationsCombo.displayText
                                            color: enabled ? "#2c3e50" : "#6c757d"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                            elide: Text.ElideRight
                                            font.pixelSize: 11
                                        }

                                        KeyNavigation.tab: newSpecializationField
                                        Keys.onReturnPressed: addExistingSpecialization()
                                        Keys.onEnterPressed: addExistingSpecialization()
                                        Keys.onUpPressed: navigateToPreviousField(existingSpecializationsCombo)
                                        Keys.onDownPressed: navigateToNextField(existingSpecializationsCombo)
                                    }

                                    Button {
                                        width: 40
                                        height: 40
                                        enabled: !isSaving && existingSpecializationsCombo.currentIndex >= 0

                                        background: Rectangle {
                                            anchors.fill: parent
                                            radius: 6
                                            color: parent.enabled ? "#28a745" : "#6c757d"

                                            states: [
                                                State {
                                                    name: "hovered"
                                                    when: parent.hovered && parent.enabled
                                                    PropertyChanges {
                                                        target: background
                                                        color: "#218838"
                                                    }
                                                },
                                                State {
                                                    name: "pressed"
                                                    when: parent.pressed && parent.enabled
                                                    PropertyChanges {
                                                        target: background
                                                        color: "#1e7e34"
                                                    }
                                                }
                                            ]

                                            Behavior on color {
                                                ColorAnimation { duration: 150 }
                                            }
                                        }

                                        contentItem: Text {
                                            text: "+"
                                            color: "white"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                            font.pixelSize: 18
                                            font.bold: true
                                            anchors.centerIn: parent
                                        }

                                        padding: 0
                                        topInset: 0
                                        bottomInset: 0
                                        leftInset: 0
                                        rightInset: 0

                                        onClicked: addExistingSpecialization()
                                    }
                                }
                            }

                            // Добавление новой специализации
                            Column {
                                width: parent.width
                                spacing: 4

                                Row {
                                    width: parent.width
                                    spacing: 8
                                    anchors.horizontalCenter: parent.horizontalCenter

                                    TextField {
                                        id: newSpecializationField
                                        width: parent.width - 48
                                        height: 40
                                        placeholderText: "Введите новую специализацию"
                                        horizontalAlignment: Text.AlignHCenter
                                        enabled: !isSaving
                                        font.pixelSize: 12
                                        KeyNavigation.tab: saveButton
                                        Keys.onReturnPressed: addSpecialization()
                                        Keys.onEnterPressed: addSpecialization()
                                        Keys.onUpPressed: navigateToPreviousField(newSpecializationField)
                                        Keys.onDownPressed: navigateToNextField(newSpecializationField)
                                    }

                                    Button {
                                        width: 40
                                        height: 40
                                        enabled: !isSaving && newSpecializationField.text.trim() !== ""

                                        background: Rectangle {
                                            anchors.fill: parent
                                            radius: 6
                                            color: parent.enabled ? "#28a745" : "#6c757d"

                                            states: [
                                                State {
                                                    name: "hovered"
                                                    when: parent.hovered && parent.enabled
                                                    PropertyChanges {
                                                        target: background
                                                        color: "#218838"
                                                    }
                                                },
                                                State {
                                                    name: "pressed"
                                                    when: parent.pressed && parent.enabled
                                                    PropertyChanges {
                                                        target: background
                                                        color: "#1e7e34"
                                                    }
                                                }
                                            ]

                                            Behavior on color {
                                                ColorAnimation { duration: 150 }
                                            }
                                        }

                                        contentItem: Text {
                                            text: "+"
                                            color: "white"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                            font.pixelSize: 18
                                            font.bold: true
                                            anchors.centerIn: parent
                                        }

                                        padding: 0
                                        topInset: 0
                                        bottomInset: 0
                                        leftInset: 0
                                        rightInset: 0

                                        onClicked: addSpecialization()
                                    }
                                }
                            }
                        }
                    }
                }

                // Кнопки действий
                Row {
                    spacing: 15
                    anchors.horizontalCenter: parent.horizontalCenter

                    Button {
                        id: saveButton
                        implicitWidth: 130
                        implicitHeight: 36
                        enabled: !isSaving && lastNameField.text.trim() !== "" && firstNameField.text.trim() !== ""
                        font.pixelSize: 13
                        font.bold: true

                        background: Rectangle {
                            radius: 18
                            color: saveButton.enabled ? "#27ae60" : "#95a5a6"
                            border.color: saveButton.enabled ? "#219a52" : "transparent"
                            border.width: 2
                        }

                        contentItem: Item {
                            anchors.fill: parent

                            Row {
                                anchors.centerIn: parent
                                spacing: 5

                                Image {
                                    source: isSaving ? "qrc:/icons/loading.png" : "qrc:/icons/save.png"
                                    sourceSize: Qt.size(14, 14)
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: isSaving ? "Сохранение..." : "Сохранить"
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font: saveButton.font
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }

                        KeyNavigation.tab: cancelButton
                        Keys.onReturnPressed: if (enabled && !isSaving) saveButton.clicked()
                        Keys.onEnterPressed: if (enabled && !isSaving) saveButton.clicked()
                        Keys.onUpPressed: navigateToPreviousField(saveButton)
                        Keys.onDownPressed: navigateToNextField(saveButton)
                        Keys.onLeftPressed: navigateToPreviousField(saveButton)
                        Keys.onRightPressed: navigateToNextField(saveButton)

                        onClicked: {
                            if (lastNameField.text.trim() === "" || firstNameField.text.trim() === "") {
                                showMessage("Заполните обязательные поля (Фамилия и Имя)", "error")
                                return
                            }
                            isSaving = true
                            saved(getTeacherData())
                        }
                    }

                    Button {
                        id: cancelButton
                        implicitWidth: 130
                        implicitHeight: 36
                        enabled: !isSaving
                        font.pixelSize: 13
                        font.bold: true

                        background: Rectangle {
                            radius: 18
                            color: "#e74c3c"
                            border.color: "#c0392b"
                            border.width: 2
                        }

                        contentItem: Item {
                            anchors.fill: parent

                            Row {
                                anchors.centerIn: parent
                                spacing: 5

                                Image {
                                    source: "qrc:/icons/cross.png"
                                    sourceSize: Qt.size(14, 14)
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: "Отмена"
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font: cancelButton.font
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }

                        KeyNavigation.tab: lastNameField
                        Keys.onReturnPressed: if (enabled) cancelButton.clicked()
                        Keys.onEnterPressed: if (enabled) cancelButton.clicked()
                        Keys.onUpPressed: navigateToPreviousField(cancelButton)
                        Keys.onDownPressed: navigateToNextField(cancelButton)
                        Keys.onLeftPressed: navigateToPreviousField(cancelButton)
                        Keys.onRightPressed: navigateToNextField(cancelButton)

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
