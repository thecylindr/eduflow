// StudentFormWindow.qml
import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3

Window {
    id: studentFormWindow
    width: 600
    height: 700
    minimumWidth: 500
    minimumHeight: 600
    title: "Форма студента"
    modality: Qt.ApplicationModal
    flags: Qt.Dialog | Qt.WindowTitleHint | Qt.WindowCloseButtonHint

    property bool isEditMode: false
    property var currentStudent: null
    property var groups: []

    signal saved(var studentData)
    signal cancelled()

    // Цвета для оформления
    property color primaryColor: "#3498db"
    property color backgroundColor: "#f8f9fa"
    property color cardColor: "#ffffff"
    property color borderColor: "#e0e0e0"

    function openForEdit(student) {
        currentStudent = student;
        isEditMode = true;
        title = "✏️ Редактирование студента";

        console.log("📝 Открытие формы для редактирования:", student);

        // Заполняем поля
        lastNameField.text = student.last_name || "";
        firstNameField.text = student.first_name || "";
        middleNameField.text = student.middle_name || "";
        phoneField.text = student.phone_number || "";
        emailField.text = student.email || "";
        passportSeriesField.text = student.passport_series || "";
        passportNumberField.text = student.passport_number || "";
        addressField.text = student.address || "";
        birthDateField.text = student.birth_date || "";

        // Устанавливаем группу
        var groupIndex = findGroupIndex(student.group_id);
        if (groupIndex >= 0) {
            groupCombo.currentIndex = groupIndex;
        }

        show();
        lastNameField.forceActiveFocus();
    }

    function openForAdd() {
        currentStudent = null;
        isEditMode = false;
        title = "➕ Добавление студента";

        console.log("📝 Открытие формы для добавления");

        // Очищаем поля
        lastNameField.text = "";
        firstNameField.text = "";
        middleNameField.text = "";
        phoneField.text = "";
        emailField.text = "";
        passportSeriesField.text = "";
        passportNumberField.text = "";
        addressField.text = "";
        birthDateField.text = "";
        groupCombo.currentIndex = 0;

        show();
        lastNameField.forceActiveFocus();
    }

    function findGroupIndex(groupId) {
        for (var i = 0; i < groups.length; i++) {
            if (groups[i].group_id === groupId) {
                return i;
            }
        }
        return -1;
    }

    function validateForm() {
        errorText.text = "";

        if (!lastNameField.text.trim()) {
            errorText.text = "❌ Фамилия обязательна для заполнения";
            lastNameField.forceActiveFocus();
            return false;
        }

        if (!firstNameField.text.trim()) {
            errorText.text = "❌ Имя обязательно для заполнения";
            firstNameField.forceActiveFocus();
            return false;
        }

        if (!passportSeriesField.text || passportSeriesField.text.length !== 4) {
            errorText.text = "❌ Серия паспорта должна содержать 4 цифры";
            passportSeriesField.forceActiveFocus();
            return false;
        }

        if (!passportNumberField.text || passportNumberField.text.length !== 6) {
            errorText.text = "❌ Номер паспорта должен содержать 6 цифр";
            passportNumberField.forceActiveFocus();
            return false;
        }

        if (groups.length === 0) {
            errorText.text = "❌ Нет доступных групп";
            return false;
        }

        return true;
    }

    Rectangle {
        anchors.fill: parent
        color: backgroundColor

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 0
            spacing: 0

            // Заголовок с градиентом
            Rectangle {
                Layout.fillWidth: true
                height: 70
                gradient: Gradient {
                    GradientStop { position: 0.0; color: primaryColor }
                    GradientStop { position: 1.0; color: Qt.darker(primaryColor, 1.2) }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    spacing: 15

                    Text {
                        text: studentFormWindow.title
                        color: "white"
                        font.pixelSize: 18
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    // Кнопка закрытия
                    Rectangle {
                        width: 36
                        height: 36
                        radius: 18
                        color: closeMouseArea.containsMouse ? Qt.darker(primaryColor, 1.4) : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "×"
                            color: "white"
                            font.pixelSize: 20
                            font.bold: true
                        }

                        MouseArea {
                            id: closeMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: studentFormWindow.cancelled()
                        }
                    }
                }
            }

            // Основной контент
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: 20
                clip: true

                ColumnLayout {
                    width: parent.width
                    spacing: 20

                    // Карточка с основной информацией
                    Rectangle {
                        Layout.fillWidth: true
                        height: mainInfoColumn.height + 40
                        radius: 12
                        color: cardColor
                        border.color: borderColor
                        border.width: 1

                        ColumnLayout {
                            id: mainInfoColumn
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 15

                            Text {
                                text: "👤 Основная информация"
                                font.pixelSize: 16
                                font.bold: true
                                color: "#2c3e50"
                                Layout.fillWidth: true
                            }

                            // ФИО в одной строке
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 15

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
                                        background: Rectangle {
                                            radius: 6
                                            border.color: borderColor
                                            border.width: 1
                                        }
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
                                        background: Rectangle {
                                            radius: 6
                                            border.color: borderColor
                                            border.width: 1
                                        }
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
                                        background: Rectangle {
                                            radius: 6
                                            border.color: borderColor
                                            border.width: 1
                                        }
                                    }
                                }
                            }

                            // Группа и дата рождения
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 15

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
                                        background: Rectangle {
                                            radius: 6
                                            border.color: borderColor
                                            border.width: 1
                                        }
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 5

                                    Text {
                                        text: "Дата рождения"
                                        font.pixelSize: 12
                                        font.bold: true
                                        color: "#2c3e50"
                                    }

                                    TextField {
                                        id: birthDateField
                                        Layout.fillWidth: true
                                        placeholderText: "ДД.ММ.ГГГГ"
                                        font.pixelSize: 14
                                        background: Rectangle {
                                            radius: 6
                                            border.color: borderColor
                                            border.width: 1
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Карточка с контактной информацией
                    Rectangle {
                        Layout.fillWidth: true
                        height: contactInfoColumn.height + 40
                        radius: 12
                        color: cardColor
                        border.color: borderColor
                        border.width: 1

                        ColumnLayout {
                            id: contactInfoColumn
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 15

                            Text {
                                text: "📞 Контактная информация"
                                font.pixelSize: 16
                                font.bold: true
                                color: "#2c3e50"
                                Layout.fillWidth: true
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 15

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
                                        background: Rectangle {
                                            radius: 6
                                            border.color: borderColor
                                            border.width: 1
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
                                        background: Rectangle {
                                            radius: 6
                                            border.color: borderColor
                                            border.width: 1
                                        }
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 5

                                Text {
                                    text: "Адрес"
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: "#2c3e50"
                                }

                                TextField {
                                    id: addressField
                                    Layout.fillWidth: true
                                    placeholderText: "Введите адрес проживания"
                                    font.pixelSize: 14
                                    background: Rectangle {
                                        radius: 6
                                        border.color: borderColor
                                        border.width: 1
                                    }
                                }
                            }
                        }
                    }

                    // Карточка с паспортными данными
                    Rectangle {
                        Layout.fillWidth: true
                        height: passportColumn.height + 40
                        radius: 12
                        color: cardColor
                        border.color: borderColor
                        border.width: 1

                        ColumnLayout {
                            id: passportColumn
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 15

                            Text {
                                text: "📄 Паспортные данные *"
                                font.pixelSize: 16
                                font.bold: true
                                color: "#2c3e50"
                                Layout.fillWidth: true
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 15

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 5

                                    Text {
                                        text: "Серия"
                                        font.pixelSize: 12
                                        font.bold: true
                                        color: "#2c3e50"
                                    }

                                    TextField {
                                        id: passportSeriesField
                                        Layout.fillWidth: true
                                        placeholderText: "XXXX"
                                        font.pixelSize: 14
                                        maximumLength: 4
                                        validator: RegularExpressionValidator {
                                            regularExpression: /^\d{0,4}$/
                                        }
                                        background: Rectangle {
                                            radius: 6
                                            border.color: borderColor
                                            border.width: 1
                                        }
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 5

                                    Text {
                                        text: "Номер"
                                        font.pixelSize: 12
                                        font.bold: true
                                        color: "#2c3e50"
                                    }

                                    TextField {
                                        id: passportNumberField
                                        Layout.fillWidth: true
                                        placeholderText: "XXXXXX"
                                        font.pixelSize: 14
                                        maximumLength: 6
                                        validator: RegularExpressionValidator {
                                            regularExpression: /^\d{0,6}$/
                                        }
                                        background: Rectangle {
                                            radius: 6
                                            border.color: borderColor
                                            border.width: 1
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Сообщение об ошибке
                    Text {
                        id: errorText
                        Layout.fillWidth: true
                        color: "#e74c3c"
                        font.pixelSize: 14
                        font.bold: true
                        wrapMode: Text.WordWrap
                        visible: text !== ""
                        horizontalAlignment: Text.AlignHCenter
                        padding: 10
                    }
                }
            }

            // Кнопки действий
            RowLayout {
                Layout.fillWidth: true
                Layout.margins: 20
                spacing: 15

                // Кнопка отмены
                Rectangle {
                    Layout.fillWidth: true
                    height: 50
                    radius: 10
                    color: cancelMouseArea.containsMouse ? "#95a5a6" : "#bdc3c7"

                    Text {
                        anchors.centerIn: parent
                        text: "❌ Отмена"
                        color: "white"
                        font.pixelSize: 14
                        font.bold: true
                    }

                    MouseArea {
                        id: cancelMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: studentFormWindow.cancelled()
                    }
                }

                // Кнопка сохранения
                Rectangle {
                    Layout.fillWidth: true
                    height: 50
                    radius: 10
                    color: saveMouseArea.containsMouse ? "#27ae60" : "#2ecc71"

                    Text {
                        anchors.centerIn: parent
                        text: isEditMode ? "💾 Сохранить" : "✅ Добавить"
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
                                    groupId: groups[groupCombo.currentIndex].group_id,
                                    passportSeries: passportSeriesField.text,
                                    passportNumber: passportNumberField.text,
                                    address: addressField.text,
                                    birthDate: birthDateField.text
                                };

                                if (isEditMode && currentStudent) {
                                    studentData.studentCode = currentStudent.student_code;
                                }

                                console.log("💾 Сохранение данных студента:", studentData);
                                studentFormWindow.saved(studentData);
                            }
                        }
                    }
                }
            }
        }
    }

    onVisibleChanged: {
        if (visible) {
            console.log("🎯 Окно формы студента открыто");
            errorText.text = "";
        }
    }

    Keys.onEscapePressed: studentFormWindow.cancelled()
    Keys.onReturnPressed: saveMouseArea.clicked()

    // Анимация появления
    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 200 }
    }

    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 200 }
    }
}
