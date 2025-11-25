import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15
import QtQuick.Controls.Universal
import "../../common" as Common

Window {
    id: portfolioFormWindow
    width: Math.min(Screen.width * 0.95, 400)
    height: Math.min(Screen.height * 0.8, 600)
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

    ListModel {
        id: studentDisplayModel
    }

    function updateStudentModel() {
        studentDisplayModel.clear()
        for (var i = 0; i < students.length; i++) {
            var student = students[i]
            var displayName = formatStudentName(student)
            var studentCode = student.studentCode || student.student_code || ""
            studentDisplayModel.append({
                displayName: displayName,
                studentCode: studentCode,
                originalIndex: i
            })
        }
        if (isEditMode && currentPortfolio) {
            restoreSelectedStudent()
        }
    }

    function formatStudentName(student) {
        var lastName = student.lastName || student.last_name || ""
        var firstName = student.firstName || student.first_name || ""
        var middleName = student.middleName || student.middle_name || ""
        var studentCode = student.studentCode || student.student_code || ""
        return [lastName, firstName, middleName].filter(Boolean).join(" ") + " (" + studentCode + ")"
    }

    function restoreSelectedStudent() {
        var studentCode = currentPortfolio.studentCode || currentPortfolio.student_code
        if (studentCode) {
            var numericStudentCode = parseInt(studentCode)
            for (var i = 0; i < studentDisplayModel.count; i++) {
                var currentCode = parseInt(studentDisplayModel.get(i).studentCode || 0)
                if (currentCode === numericStudentCode) {
                    studentComboBox.currentIndex = i
                    break
                }
            }
        }
    }

    function openForAdd() {
        currentPortfolio = null
        isEditMode = false
        isSaving = false
        clearForm()
        updateStudentModel()
        portfolioFormWindow.show()
    }

    function openForEdit(portfolioData) {
        currentPortfolio = portfolioData
        isEditMode = true
        isSaving = false
        updateStudentModel()
        fillForm(portfolioData)
        portfolioFormWindow.show()
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
        var studentCode = portfolioData.studentCode || portfolioData.student_code
        if (studentCode) {
            var numericStudentCode = parseInt(studentCode)
            for (var i = 0; i < studentDisplayModel.count; i++) {
                var currentCode = parseInt(studentDisplayModel.get(i).studentCode || 0)
                if (currentCode === numericStudentCode) {
                    studentComboBox.currentIndex = i
                    break
                }
            }
        } else {
            studentComboBox.currentIndex = -1
        }

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
        var portfolioId = 0
        if (isEditMode && currentPortfolio) {
            portfolioId = currentPortfolio.portfolioId || currentPortfolio.portfolio_id || 0
        }

        var studentCode = 0
        if (studentComboBox.currentIndex >= 0) {
            var selectedItem = studentDisplayModel.get(studentComboBox.currentIndex)
            studentCode = parseInt(selectedItem.studentCode || 0)
        }

        var dateText = dateField.text
        var formattedDate = dateText
        if (dateText) {
            var parts = dateText.split('.')
            if (parts.length === 3) {
                formattedDate = parts[2] + "-" + parts[1] + "-" + parts[0]
            }
        }

        return {
            portfolio_id: portfolioId,
            student_code: studentCode,
            date: formattedDate,
            decree: decreeField.text
        }
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

    onStudentsChanged: {
        updateStudentModel()
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
            title: isEditMode ? "Редактирование портфолио" : "Добавление портфолио"
            window: portfolioFormWindow
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
                                text: "Студент:"
                                font.bold: true
                                font.pixelSize: 14
                                color: "#2c3e50"
                            }

                            ComboBox {
                                id: studentComboBox
                                width: parent.width
                                height: 45
                                enabled: !isSaving && studentDisplayModel.count > 0
                                font.pixelSize: 14

                                background: Rectangle {
                                    radius: 8
                                    color: "#ffffff"
                                    border.color: studentComboBox.enabled ? "#e0e0e0" : "#f0f0f0"
                                    border.width: 1
                                }

                                model: studentDisplayModel
                                textRole: "displayName"
                            }

                            Label {
                                text: studentDisplayModel.count === 0 ? "Нет доступных студентов" : ""
                                color: "#e74c3c"
                                font.pixelSize: 12
                                visible: studentDisplayModel.count === 0
                            }

                            Label {
                                visible: studentDisplayModel.count > 0
                                text: "Доступно студентов: " + studentDisplayModel.count
                                color: "#27ae60"
                                font.pixelSize: 12
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: 8

                            Label {
                                text: "Дата:"
                                font.bold: true
                                font.pixelSize: 14
                                color: "#2c3e50"
                            }

                            TextField {
                                id: dateField
                                width: parent.width
                                height: 45
                                placeholderText: "ДД.ММ.ГГГГ"
                                font.pixelSize: 14
                                validator: RegularExpressionValidator {
                                    regularExpression: /^[\d\.]*$/
                                }

                                onTextChanged: {
                                    if (text.length > 10) {
                                        text = text.substring(0, 10)
                                    }
                                }
                            }

                            Label {
                                text: !validateDate(dateField.text) && dateField.text !== "" ?
                                      "Неверный формат даты" : "Формат: ДД.ММ.ГГГГ"
                                color: !validateDate(dateField.text) && dateField.text !== "" ? "#e74c3c" : "#7f8c8d"
                                font.pixelSize: 12
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: 8

                            Label {
                                text: "Приказ:"
                                font.bold: true
                                font.pixelSize: 14
                                color: "#2c3e50"
                            }

                            TextField {
                                id: decreeField
                                width: parent.width
                                height: 45
                                placeholderText: "Введите номер приказа*"
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
                        enabled: !isSaving && studentComboBox.currentIndex >= 0 &&
                                dateField.text.trim() !== "" && validateDate(dateField.text) &&
                                decreeField.text.trim() !== "" && studentDisplayModel.count > 0
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
                            if (studentComboBox.currentIndex < 0) return
                            if (dateField.text.trim() === "") return
                            if (!validateDate(dateField.text)) return
                            if (decreeField.text.trim() === "") return
                            isSaving = true
                            saved(getPortfolioData())
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
