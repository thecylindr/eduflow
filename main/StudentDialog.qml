// main/StudentDialog.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Popup {
    id: studentDialog
    width: 500
    height: 600
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    padding: 0

    property bool isEditMode: false
    property var currentStudent: null
    property var groups: []

    signal saved(var studentData)
    signal cancelled

    function openForEdit(student) {
        currentStudent = student;
        isEditMode = true;

        // Заполняем поля данными студента
        lastNameField.text = student.lastName || "";
        firstNameField.text = student.firstName || "";
        middleNameField.text = student.middleName || "";
        phoneField.text = student.phoneNumber || "";
        emailField.text = student.email || "";
        groupCombo.currentIndex = findGroupIndex(student.groupId);
        passportSeriesField.text = student.passportSeries || "";
        passportNumberField.text = student.passportNumber || "";

        studentDialog.open();
    }

    function openForAdd() {
        currentStudent = null;
        isEditMode = false;

        // Очищаем поля
        lastNameField.text = "";
        firstNameField.text = "";
        middleNameField.text = "";
        phoneField.text = "";
        emailField.text = "";
        groupCombo.currentIndex = 0;
        passportSeriesField.text = "";
        passportNumberField.text = "";

        studentDialog.open();
    }

    function findGroupIndex(groupId) {
        for (var i = 0; i < groups.length; i++) {
            if (groups[i].groupId === groupId) {
                return i;
            }
        }
        return 0;
    }

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: "#ffffff"

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // Заголовок
            Rectangle {
                Layout.fillWidth: true
                height: 50
                color: "#3498db"
                radius: 12

                Text {
                    anchors.centerIn: parent
                    text: isEditMode ? "✏️ Редактирование студента" : "➕ Добавление студента"
                    color: "white"
                    font.pixelSize: 16
                    font.bold: true
                }

                Rectangle {
                    width: 30
                    height: 30
                    radius: 15
                    color: closeMouseArea.containsMouse ? "#e74c3c" : "transparent"
                    anchors {
                        right: parent.right
                        rightMargin: 10
                        verticalCenter: parent.verticalCenter
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "×"
                        color: closeMouseArea.containsMouse ? "white" : "#2c3e50"
                        font.pixelSize: 18
                        font.bold: true
                    }

                    MouseArea {
                        id: closeMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: studentDialog.cancelled()
                    }
                }
            }

            // Форма
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: 20
                clip: true

                ColumnLayout {
                    width: parent.width
                    spacing: 15

                    // ФИО
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Text {
                            text: "Фамилия *"
                            font.pixelSize: 12
                            font.bold: true
                            color: "#2c3e50"
                        }

                        TextField {
                            id: lastNameField
                            Layout.fillWidth: true
                            placeholderText: "Введите фамилию"
                            font.pixelSize: 14
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Text {
                            text: "Имя *"
                            font.pixelSize: 12
                            font.bold: true
                            color: "#2c3e50"
                        }

                        TextField {
                            id: firstNameField
                            Layout.fillWidth: true
                            placeholderText: "Введите имя"
                            font.pixelSize: 14
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Text {
                            text: "Отчество"
                            font.pixelSize: 12
                            font.bold: true
                            color: "#2c3e50"
                        }

                        TextField {
                            id: middleNameField
                            Layout.fillWidth: true
                            placeholderText: "Введите отчество"
                            font.pixelSize: 14
                        }
                    }

                    // Контакты
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Text {
                            text: "Телефон"
                            font.pixelSize: 12
                            font.bold: true
                            color: "#2c3e50"
                        }

                        TextField {
                            id: phoneField
                            Layout.fillWidth: true
                            placeholderText: "+7 (XXX) XXX-XX-XX"
                            font.pixelSize: 14
                            validator: RegularExpressionValidator {
                                regularExpression: /^[\d\s\-\+\(\)]{0,20}$/
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Text {
                            text: "Email"
                            font.pixelSize: 12
                            font.bold: true
                            color: "#2c3e50"
                        }

                        TextField {
                            id: emailField
                            Layout.fillWidth: true
                            placeholderText: "example@domain.ru"
                            font.pixelSize: 14
                            validator: RegularExpressionValidator {
                                regularExpression: /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/
                            }
                        }
                    }

                    // Группа
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Text {
                            text: "Группа *"
                            font.pixelSize: 12
                            font.bold: true
                            color: "#2c3e50"
                        }

                        ComboBox {
                            id: groupCombo
                            Layout.fillWidth: true
                            model: groups
                            textRole: "name"
                            font.pixelSize: 14
                        }
                    }

                    // Паспортные данные
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Text {
                            text: "Паспортные данные *"
                            font.pixelSize: 12
                            font.bold: true
                            color: "#2c3e50"
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            TextField {
                                id: passportSeriesField
                                Layout.fillWidth: true
                                placeholderText: "Серия"
                                font.pixelSize: 14
                                maximumLength: 4
                                validator: RegularExpressionValidator {
                                    regularExpression: /^\d{0,4}$/
                                }
                            }

                            TextField {
                                id: passportNumberField
                                Layout.fillWidth: true
                                placeholderText: "Номер"
                                font.pixelSize: 14
                                maximumLength: 6
                                validator: RegularExpressionValidator {
                                    regularExpression: /^\d{0,6}$/
                                }
                            }
                        }
                    }

                    // Сообщение об ошибке
                    Text {
                        id: errorText
                        Layout.fillWidth: true
                        color: "#e74c3c"
                        font.pixelSize: 12
                        wrapMode: Text.WordWrap
                        visible: text !== ""
                    }
                }
            }

            // Кнопки
            RowLayout {
                Layout.fillWidth: true
                Layout.margins: 20
                spacing: 10

                Rectangle {
                    Layout.fillWidth: true
                    height: 45
                    radius: 8
                    color: cancelMouseArea.containsMouse ? "#95a5a6" : "#bdc3c7"

                    Text {
                        anchors.centerIn: parent
                        text: "Отмена"
                        color: "white"
                        font.pixelSize: 14
                        font.bold: true
                    }

                    MouseArea {
                        id: cancelMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: studentDialog.cancelled()
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 45
                    radius: 8
                    color: saveMouseArea.containsMouse ? "#27ae60" : "#2ecc71"

                    Text {
                        anchors.centerIn: parent
                        text: isEditMode ? "Сохранить" : "Добавить"
                        color: "white"
                        font.pixelSize: 14
                        font.bold: true
                    }

                    MouseArea {
                        id: saveMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (validateForm()) {
                                var studentData = {
                                    lastName: lastNameField.text,
                                    firstName: firstNameField.text,
                                    middleName: middleNameField.text,
                                    phoneNumber: phoneField.text,
                                    email: emailField.text,
                                    groupId: groups[groupCombo.currentIndex].groupId,
                                    passportSeries: passportSeriesField.text,
                                    passportNumber: passportNumberField.text
                                };

                                if (isEditMode && currentStudent) {
                                    studentData.studentCode = currentStudent.studentCode;
                                }

                                studentDialog.saved(studentData);
                            }
                        }
                    }
                }
            }
        }
    }

    function validateForm() {
        errorText.text = "";

        if (!lastNameField.text.trim()) {
            errorText.text = "Фамилия обязательна для заполнения";
            return false;
        }

        if (!firstNameField.text.trim()) {
            errorText.text = "Имя обязательно для заполнения";
            return false;
        }

        if (!passportSeriesField.text || passportSeriesField.text.length !== 4) {
            errorText.text = "Серия паспорта должна содержать 4 цифры";
            return false;
        }

        if (!passportNumberField.text || passportNumberField.text.length !== 6) {
            errorText.text = "Номер паспорта должен содержать 6 цифр";
            return false;
        }

        if (groups.length === 0) {
            errorText.text = "Нет доступных групп";
            return false;
        }

        return true;
    }

    onOpened: {
        lastNameField.forceActiveFocus();
    }
}
