import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15
import QtQuick.Controls.Universal
import "../../common" as Common

Window {
    id: teacherFormWindow
    width: Math.min(Screen.width * 0.95, 400)
    height: Math.min(Screen.height * 0.9, 700)
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

    ListModel {
        id: specializationModel
    }

    function formatPhoneNumber(text) {
        var digits = text.replace(/\D/g, '')
        if (digits.startsWith('7') || digits.startsWith('8')) {
            digits = digits.substring(1)
        }
        digits = digits.substring(0, 10)

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
        var digits = phone.replace(/\D/g, '')
        if (digits.length === 0) return ""
        if (digits.startsWith('8')) digits = '7' + digits.substring(1)
        else if (!digits.startsWith('7')) digits = '7' + digits
        digits = digits.substring(0, 11)
        if (digits === '7') return ""
        return digits
    }

    function openForAdd() {
        currentTeacher = null
        isEditMode = false
        isSaving = false
        clearForm()
        loadExistingSpecializations()
        teacherFormWindow.show()
    }

    function openForEdit(teacherData) {
        currentTeacher = teacherData
        isEditMode = true
        isSaving = false
        fillForm(teacherData)
        loadExistingSpecializations()
        teacherFormWindow.show()
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

    function getTeacherData() {
        var specs = []
        for (var i = 0; i < specializationModel.count; i++) {
            var specName = specializationModel.get(i).name.trim()
            if (specName !== "") {
                specs.push(specName)
            }
        }

        var teacherId = 0
        if (isEditMode && currentTeacher) {
            teacherId = currentTeacher.teacherId || currentTeacher.teacher_id || 0
        }

        var normalizedPhone = normalizePhoneNumber(phoneField.text)

        return {
            teacher_id: teacherId,
            last_name: lastNameField.text.trim(),
            first_name: firstNameField.text.trim(),
            middle_name: middleNameField.text.trim(),
            email: emailField.text.trim(),
            phone_number: normalizedPhone,
            experience: experienceField.value,
            specialization: specs.join(", "),
            specializations: specs
        }
    }

    function addSpecialization() {
        var newSpec = newSpecializationField.text.trim()
        if (newSpec !== "") {
            addSpecializationByName(newSpec)
            newSpecializationField.text = ""
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

    function loadExistingSpecializations() {
        var excludeTeacherId = 0
        if (isEditMode && currentTeacher) {
            excludeTeacherId = currentTeacher.teacherId || currentTeacher.teacher_id || 0
        }

        mainWindow.mainApi.getAllTeachersSpecializations(excludeTeacherId, function(response) {
            if (response.success) {
                var uniqueSpecs = response.data || []
                existingSpecializations = uniqueSpecs
                existingSpecializationsCombo.model = uniqueSpecs
            } else {
                existingSpecializations = []
                existingSpecializationsCombo.model = []
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
            title: isEditMode ? "Редактирование преподавателя" : "Добавление преподавателя"
            window: teacherFormWindow
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
                                text: "ФИО:"
                                font.bold: true
                                font.pixelSize: 14
                                color: "#2c3e50"
                            }

                            TextField {
                                id: lastNameField
                                width: parent.width
                                height: 45
                                placeholderText: "Фамилия*"
                                font.pixelSize: 14
                            }

                            TextField {
                                id: firstNameField
                                width: parent.width
                                height: 45
                                placeholderText: "Имя*"
                                font.pixelSize: 14
                            }

                            TextField {
                                id: middleNameField
                                width: parent.width
                                height: 45
                                placeholderText: "Отчество"
                                font.pixelSize: 14
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: 8

                            Label {
                                text: "Контакты:"
                                font.bold: true
                                font.pixelSize: 14
                                color: "#2c3e50"
                            }

                            TextField {
                                id: emailField
                                width: parent.width
                                height: 45
                                placeholderText: "Email"
                                font.pixelSize: 14
                            }

                            TextField {
                                id: phoneField
                                width: parent.width
                                height: 45
                                placeholderText: "Номер телефона"
                                font.pixelSize: 14
                                validator: RegularExpressionValidator {
                                    regularExpression: /^[0-9+\(\)\-\s]*$/
                                }

                                onTextChanged: {
                                    if (activeFocus) {
                                        var formatted = formatPhoneNumber(text)
                                        if (formatted !== text) {
                                            text = formatted
                                        }
                                    }
                                }

                                onActiveFocusChanged: {
                                    if (activeFocus && text === "") {
                                        text = "+7 "
                                    }
                                }
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: 8

                            Label {
                                text: "Стаж (лет):"
                                font.bold: true
                                font.pixelSize: 14
                                color: "#2c3e50"
                            }

                            SpinBox {
                                id: experienceField
                                width: parent.width
                                height: 45
                                from: 0
                                to: 100
                                value: 0
                                editable: true
                                font.pixelSize: 14
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: 8

                            Label {
                                text: "Специализации преподавателя:"
                                font.bold: true
                                font.pixelSize: 14
                                color: "#2c3e50"
                            }

                            Rectangle {
                                width: parent.width
                                height: 150
                                color: "#f8f9fa"
                                radius: 8
                                border.color: "#dee2e6"
                                border.width: 1

                                ListView {
                                    id: specializationList
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    model: specializationModel
                                    clip: true
                                    spacing: 5

                                    delegate: Rectangle {
                                        width: parent.width
                                        height: 40
                                        color: "white"
                                        radius: 6
                                        border.color: "#e9ecef"
                                        border.width: 1

                                        Row {
                                            anchors.fill: parent
                                            anchors.margins: 5
                                            spacing: 10

                                            Text {
                                                text: name
                                                font.pixelSize: 14
                                                color: "#2c3e50"
                                                anchors.verticalCenter: parent.verticalCenter
                                                width: parent.width - 50
                                                elide: Text.ElideRight
                                            }

                                            Button {
                                                width: 30
                                                height: 30
                                                anchors.verticalCenter: parent.verticalCenter
                                                background: Rectangle {
                                                    color: "#e74c3c"
                                                    radius: 4
                                                }
                                                contentItem: Text {
                                                    text: "×"
                                                    color: "white"
                                                    font.pixelSize: 16
                                                    font.bold: true
                                                    anchors.centerIn: parent
                                                }
                                                onClicked: specializationModel.remove(index)
                                            }
                                        }
                                    }

                                    Label {
                                        anchors.centerIn: parent
                                        text: "Нет специализаций"
                                        color: "#7f8c8d"
                                        font.italic: true
                                        font.pixelSize: 14
                                        visible: specializationModel.count === 0
                                    }
                                }
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: 8

                            Label {
                                text: "Добавить специализацию:"
                                font.bold: true
                                font.pixelSize: 14
                                color: "#2c3e50"
                            }

                            ComboBox {
                                id: existingSpecializationsCombo
                                width: parent.width
                                height: 45
                                enabled: !isSaving && existingSpecializations.length > 0
                                font.pixelSize: 14

                                background: Rectangle {
                                    radius: 8
                                    color: "#ffffff"
                                    border.color: existingSpecializationsCombo.enabled ? "#e0e0e0" : "#f0f0f0"
                                    border.width: 1
                                }

                                model: existingSpecializations
                                displayText: currentIndex === -1 ?
                                    (existingSpecializations.length > 0 ?
                                     "Выберите специализацию (" + existingSpecializations.length + " доступно)" :
                                     "Нет доступных специализаций") : currentText
                            }

                            Row {
                                width: parent.width
                                spacing: 10

                                TextField {
                                    id: newSpecializationField
                                    width: parent.width - 60
                                    height: 45
                                    placeholderText: "Введите новую специализацию"
                                    font.pixelSize: 14
                                }

                                Button {
                                    width: 45
                                    height: 45
                                    enabled: !isSaving && newSpecializationField.text.trim() !== ""
                                    background: Rectangle {
                                        color: parent.enabled ? "#28a745" : "#6c757d"
                                        radius: 6
                                    }
                                    contentItem: Text {
                                        text: "+"
                                        color: "white"
                                        font.pixelSize: 20
                                        font.bold: true
                                        anchors.centerIn: parent
                                    }
                                    onClicked: addSpecialization()
                                }
                            }

                            Button {
                                width: parent.width
                                height: 45
                                text: "Добавить выбранную специализацию"
                                enabled: !isSaving && existingSpecializationsCombo.currentIndex >= 0
                                background: Rectangle {
                                    color: parent.enabled ? "#17a2b8" : "#6c757d"
                                    radius: 6
                                }
                                contentItem: Row {
                                    spacing: 8
                                    anchors.centerIn: parent

                                    Image {
                                        source: "qrc:/icons/add.png"
                                        width: 16
                                        height: 16
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        text: parent.parent.text
                                        color: "white"
                                        font.pixelSize: 14
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                                onClicked: addExistingSpecialization()
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
                        enabled: !isSaving && lastNameField.text.trim() !== "" && firstNameField.text.trim() !== ""
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
                            if (lastNameField.text.trim() === "" || firstNameField.text.trim() === "") return
                            isSaving = true
                            saved(getTeacherData())
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
