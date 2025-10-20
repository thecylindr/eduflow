// main/TeachersDialog.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Popup {
    id: teacherDialog
    width: 500
    height: 550
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    padding: 0

    property bool isEditMode: false
    property var currentTeacher: null
    property bool isLoading: false

    signal saved(var teacherData)
    signal cancelled

    function openForEdit(teacher) {
        currentTeacher = teacher;
        isEditMode = true;

        lastNameField.text = teacher.lastName || "";
        firstNameField.text = teacher.firstName || "";
        middleNameField.text = teacher.middleName || "";
        emailField.text = teacher.email || "";
        phoneField.text = teacher.phoneNumber || "";
        experienceField.text = teacher.experience || "0";
        specializationField.text = teacher.specialization || "";

        teacherDialog.open();
    }

    function openForAdd() {
        currentTeacher = null;
        isEditMode = false;

        lastNameField.text = "";
        firstNameField.text = "";
        middleNameField.text = "";
        emailField.text = "";
        phoneField.text = "";
        experienceField.text = "0";
        specializationField.text = "";

        teacherDialog.open();
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

        if (!specializationField.text.trim()) {
            errorText.text = "Специализация обязательна для заполнения";
            return false;
        }

        var experience = parseInt(experienceField.text);
        if (isNaN(experience) || experience < 0) {
            errorText.text = "Опыт работы должен быть числом ≥ 0";
            return false;
        }

        return true;
    }

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: "#ffffff"
        border.color: "#e0e0e0"
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // Заголовок
            Rectangle {
                Layout.fillWidth: true
                height: 60
                color: "#3498db"
                radius: 16

                Text {
                    anchors.centerIn: parent
                    text: isEditMode ? "✏️ Редактирование преподавателя" : "➕ Добавление преподавателя"
                    color: "white"
                    font.pixelSize: 16
                    font.bold: true
                }

                Rectangle {
                    width: 30
                    height: 30
                    radius: 15
                    color: closeMouseArea.containsMouse ? "#2980b9" : "transparent"
                    anchors {
                        right: parent.right
                        rightMargin: 15
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
                        onClicked: {
                            teacherDialog.cancelled();
                            teacherDialog.close();
                        }
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
                            selectByMouse: true
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
                            selectByMouse: true
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
                            selectByMouse: true
                        }
                    }

                    // Контакты
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
                            selectByMouse: true
                        }
                    }

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
                            selectByMouse: true
                        }
                    }

                    // Профессиональная информация
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Text {
                            text: "Опыт работы (лет)"
                            font.pixelSize: 12
                            font.bold: true
                            color: "#2c3e50"
                        }

                        TextField {
                            id: experienceField
                            Layout.fillWidth: true
                            placeholderText: "0"
                            font.pixelSize: 14
                            validator: IntValidator { bottom: 0; top: 50 }
                            selectByMouse: true
                            inputMethodHints: Qt.ImhDigitsOnly
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Text {
                            text: "Специализация *"
                            font.pixelSize: 12
                            font.bold: true
                            color: "#2c3e50"
                        }

                        TextField {
                            id: specializationField
                            Layout.fillWidth: true
                            placeholderText: "Введите специализацию"
                            font.pixelSize: 14
                            selectByMouse: true
                        }
                    }

                    // Индикатор загрузки
                    Rectangle {
                        Layout.fillWidth: true
                        height: 30
                        radius: 8
                        color: "#fff3cd"
                        border.color: "#ffeaa7"
                        border.width: 1
                        visible: isLoading

                        Row {
                            anchors.centerIn: parent
                            spacing: 10

                            Text {
                                text: "⏳"
                                font.pixelSize: 14
                            }

                            Text {
                                text: "Загрузка данных..."
                                color: "#856404"
                                font.pixelSize: 12
                                font.bold: true
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

                // Кнопка отмены
                Rectangle {
                    Layout.fillWidth: true
                    height: 45
                    radius: 10
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
                        onClicked: {
                            teacherDialog.cancelled();
                            teacherDialog.close();
                        }
                    }
                }

                // Кнопка сохранения
                Rectangle {
                    Layout.fillWidth: true
                    height: 45
                    radius: 10
                    color: saveMouseArea.containsMouse ? "#2980b9" : "#3498db"
                    enabled: !isLoading

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
                                // ИСПРАВЛЕНИЕ: используем snake_case для бэкенда
                                var teacherData = {
                                    "last_name": lastNameField.text.trim(),
                                    "first_name": firstNameField.text.trim(),
                                    "middle_name": middleNameField.text.trim(),
                                    "email": emailField.text.trim() || "",
                                    "phone_number": phoneField.text.trim() || "",
                                    "experience": parseInt(experienceField.text) || 0,
                                    "specialization": specializationField.text.trim()
                                };

                                if (isEditMode && currentTeacher) {
                                    teacherData.teacherId = currentTeacher.teacherId;
                                }

                                console.log("💾 Сохранение преподавателя:", JSON.stringify(teacherData));
                                teacherDialog.saved(teacherData);
                            }
                        }
                    }
                }
            }
        }
    }

    onOpened: {
        lastNameField.forceActiveFocus();
        errorText.text = "";
    }

    onClosed: {
        isLoading = false;
    }

    Keys.onEscapePressed: {
        teacherDialog.cancelled();
        teacherDialog.close();
    }

    Keys.onReturnPressed: {
        if (validateForm()) {
            // ИСПРАВЛЕНИЕ: используем snake_case для бэкенда
            var teacherData = {
                "last_name": lastNameField.text.trim(),
                "first_name": firstNameField.text.trim(),
                "middle_name": middleNameField.text.trim(),
                "email": emailField.text.trim() || "",
                "phone_number": phoneField.text.trim() || "",
                "experience": parseInt(experienceField.text) || 0,
                "specialization": specializationField.text.trim()
            };

            if (isEditMode && currentTeacher) {
                teacherData.teacherId = currentTeacher.teacherId;
            }

            teacherDialog.saved(teacherData);
        }
    }
}
