import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15
import QtQuick.Controls.Universal
import "../../common" as Common

Window {
    id: studentFormWindow
    width: Math.min(Screen.width * 0.95, 400)
    height: Math.min(Screen.height * 0.9, 700)
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
        currentStudent = null
        isEditMode = false
        isSaving = false
        clearForm()
        studentFormWindow.show()
    }

    function openForEdit(studentData) {
        currentStudent = studentData
        isEditMode = true
        isSaving = false
        fillForm(studentData)
        studentFormWindow.show()
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
        var phoneData = studentData.phoneNumber || studentData.phone_number || ""
        if (phoneData && !phoneData.startsWith("+7")) {
            phoneField.text = formatPhoneNumber(phoneData)
        } else {
            phoneField.text = phoneData
        }
        passportSeriesField.text = studentData.passportSeries || studentData.passport_series || ""
        passportNumberField.text = studentData.passportNumber || studentData.passport_number || ""

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

        var selectedGroup = groupComboBox.currentIndex >= 0 ? groups[groupComboBox.currentIndex] : null
        var groupId = selectedGroup ? (selectedGroup.groupId || selectedGroup.group_id) : 0
        var normalizedPhone = normalizePhoneNumber(phoneField.text)

        return {
            student_code: studentCode,
            last_name: lastNameField.text,
            first_name: firstNameField.text,
            middle_name: middleNameField.text,
            email: emailField.text,
            phone_number: normalizedPhone,
            passport_series: passportSeriesField.text,
            passport_number: passportNumberField.text,
            group_id: groupId
        }
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
            title: isEditMode ? "Редактирование студента" : "Добавление студента"
            window: studentFormWindow
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
                                text: "Паспортные данные:"
                                font.bold: true
                                font.pixelSize: 14
                                color: "#2c3e50"
                            }

                            Grid {
                                width: parent.width
                                columns: 2
                                spacing: 10

                                TextField {
                                    id: passportSeriesField
                                    width: parent.width / 2 - 5
                                    height: 45
                                    placeholderText: "Серия паспорта*"
                                    font.pixelSize: 14
                                    validator: IntValidator { bottom: 1000; top: 9999 }
                                }

                                TextField {
                                    id: passportNumberField
                                    width: parent.width / 2 - 5
                                    height: 45
                                    placeholderText: "Номер паспорта*"
                                    font.pixelSize: 14
                                    validator: IntValidator { bottom: 100000; top: 999999 }
                                }
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: 8

                            Label {
                                text: "Группа:"
                                font.bold: true
                                font.pixelSize: 14
                                color: "#2c3e50"
                            }

                            ComboBox {
                                id: groupComboBox
                                width: parent.width
                                height: 45
                                enabled: !isSaving
                                font.pixelSize: 14

                                background: Rectangle {
                                    radius: 8
                                    color: "#ffffff"
                                    border.color: groupComboBox.enabled ? "#e0e0e0" : "#f0f0f0"
                                    border.width: 1
                                }

                                model: studentFormWindow.groups
                                textRole: "name"
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
                        enabled: !isSaving && lastNameField.text.trim() !== "" &&
                                firstNameField.text.trim() !== "" &&
                                passportSeriesField.text.trim() !== "" &&
                                passportNumberField.text.trim() !== "" &&
                                groupComboBox.currentIndex >= 0
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
                            if (passportSeriesField.text.trim() === "" || passportNumberField.text.trim() === "") return
                            if (groupComboBox.currentIndex < 0) return
                            isSaving = true
                            saved(getStudentData())
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
