import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Window {
    id: teacherFormWindow
    width: 600
    height: 700
    title: "Форма преподавателя"
    modality: Qt.ApplicationModal
    flags: Qt.Dialog | Qt.FramelessWindowHint

    property bool isEditMode: false
    property var currentTeacher: null
    property bool isLoading: false
    property var specializations: []
    property var currentSpecializations: []

    signal saved(var teacherData)
    signal cancelled
    signal specializationAdded(var specializationData)

    function openForEdit(teacher) {
        currentTeacher = teacher;
        isEditMode = true;
        title = "✏️ Редактирование преподавателя";

        console.log("📝 Редактирование преподавателя:", JSON.stringify(teacher));

        lastNameField.text = teacher.last_name || teacher.lastName || "";
        firstNameField.text = teacher.first_name || teacher.firstName || "";
        middleNameField.text = teacher.middle_name || teacher.middleName || "";
        emailField.text = teacher.email || "";
        phoneField.text = teacher.phone_number || teacher.phoneNumber || "";
        experienceField.text = teacher.experience || "0";

        // Загружаем специализации преподавателя
        loadTeacherSpecializations(teacher.teacher_id);

        show();
    }

    function openForAdd() {
        currentTeacher = null;
        isEditMode = false;
        title = "➕ Добавление преподавателя";

        console.log("➕ Добавление нового преподавателя");

        lastNameField.text = "";
        firstNameField.text = "";
        middleNameField.text = "";
        emailField.text = "";
        phoneField.text = "";
        experienceField.text = "1";
        currentSpecializations = [];

        show();
    }

    function loadTeacherSpecializations(teacherId) {
        mainWindow.mainApi.sendRequest("GET", "/teachers/" + teacherId + "/specializations", null, function(response) {
            if (response.success) {
                currentSpecializations = response.data || [];
                updateSpecializationsList();
            }
        });
    }

    function updateSpecializationsList() {
        specializationsListModel.clear();
        currentSpecializations.forEach(function(spec) {
            specializationsListModel.append({
                "specialization_id": spec.specialization_id,
                "name": spec.name
            });
        });
    }

    function validateForm() {
        errorText.text = "";

        if (!lastNameField.text.trim()) {
            errorText.text = "Фамилия обязательна для заполнения";
            lastNameField.forceActiveFocus();
            return false;
        }

        if (!firstNameField.text.trim()) {
            errorText.text = "Имя обязательно для заполнения";
            firstNameField.forceActiveFocus();
            return false;
        }

        var experience = parseInt(experienceField.text);
        if (isNaN(experience) || experience < 0 || experience > 50) {
            errorText.text = "Опыт работы должен быть числом от 0 до 50";
            experienceField.forceActiveFocus();
            return false;
        }

        return true;
    }

    Rectangle {
        anchors.fill: parent
        color: "#ffffff"
        border.color: "#3498db"
        border.width: 2
        radius: 12

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // Заголовок
            Rectangle {
                Layout.fillWidth: true
                height: 60
                color: "#3498db"
                radius: 10

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 15

                    Text {
                        text: teacherFormWindow.title
                        color: "white"
                        font.pixelSize: 16
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        width: 30
                        height: 30
                        radius: 15
                        color: closeMouseArea.containsMouse ? "#2980b9" : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "×"
                            color: "white"
                            font.pixelSize: 18
                            font.bold: true
                        }

                        MouseArea {
                            id: closeMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: teacherFormWindow.cancelled()
                        }
                    }
                }

                // Перемещение окна
                MouseArea {
                    anchors.fill: parent
                    property point lastMousePos: Qt.point(0, 0)
                    onPressed: lastMousePos = Qt.point(mouseX, mouseY)
                    onMouseXChanged: teacherFormWindow.x += (mouseX - lastMousePos.x)
                    onMouseYChanged: teacherFormWindow.y += (mouseY - lastMousePos.y)
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

                    Text {
                        text: "Основная информация"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#2c3e50"
                        Layout.fillWidth: true
                    }

                    // ФИО
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

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
                                background: Rectangle {
                                    radius: 6
                                    border.color: "#e0e0e0"
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
                                selectByMouse: true
                                background: Rectangle {
                                    radius: 6
                                    border.color: "#e0e0e0"
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
                                selectByMouse: true
                                background: Rectangle {
                                    radius: 6
                                    border.color: "#e0e0e0"
                                    border.width: 1
                                }
                            }
                        }
                    }

                    // Контакты
                    Text {
                        text: "Контактная информация"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#2c3e50"
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

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
                                background: Rectangle {
                                    radius: 6
                                    border.color: "#e0e0e0"
                                    border.width: 1
                                }
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
                                background: Rectangle {
                                    radius: 6
                                    border.color: "#e0e0e0"
                                    border.width: 1
                                }
                            }
                        }
                    }

                    // Профессиональная информация
                    Text {
                        text: "Профессиональная информация"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#2c3e50"
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            Text {
                                text: "Опыт работы (лет) *"
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
                                background: Rectangle {
                                    radius: 6
                                    border.color: "#e0e0e0"
                                    border.width: 1
                                }
                            }
                        }
                    }

                    // Специализации
                    Text {
                        text: "Специализации"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#2c3e50"
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        TextField {
                            id: newSpecializationField
                            Layout.fillWidth: true
                            placeholderText: "Новая специализация..."
                            font.pixelSize: 14
                            background: Rectangle {
                                radius: 6
                                border.color: "#e0e0e0"
                                border.width: 1
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 40
                            radius: 6
                            color: addSpecMouseArea.containsMouse ? "#2980b9" : "#3498db"

                            Text {
                                anchors.centerIn: parent
                                text: "+"
                                color: "white"
                                font.pixelSize: 18
                                font.bold: true
                            }

                            MouseArea {
                                id: addSpecMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    if (newSpecializationField.text.trim()) {
                                        var newSpec = {
                                            "name": newSpecializationField.text.trim()
                                        };

                                        // Если редактируем, добавляем к преподавателю
                                        if (isEditMode && currentTeacher) {
                                            newSpec.teacher_id = currentTeacher.teacher_id;
                                            specializationAdded(newSpec);
                                        }

                                        // Добавляем в локальный список
                                        currentSpecializations.push(newSpec);
                                        updateSpecializationsList();
                                        newSpecializationField.text = "";
                                    }
                                }
                            }
                        }
                    }

                    // Список специализаций
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 150
                        radius: 6
                        color: "#f8f9fa"
                        border.color: "#e0e0e0"
                        border.width: 1

                        ListView {
                            id: specializationsListView
                            anchors.fill: parent
                            anchors.margins: 5
                            model: ListModel { id: specializationsListModel }
                            clip: true

                            delegate: Rectangle {
                                width: specializationsListView.width
                                height: 40
                                color: index % 2 === 0 ? "#ffffff" : "#f8f9fa"

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    spacing: 10

                                    Text {
                                        text: model.name
                                        font.pixelSize: 12
                                        color: "#2c3e50"
                                        Layout.fillWidth: true
                                    }

                                    Rectangle {
                                        Layout.preferredWidth: 25
                                        Layout.preferredHeight: 25
                                        radius: 4
                                        color: removeSpecMouseArea.containsMouse ? "#e74c3c" : "#c0392b"

                                        Text {
                                            anchors.centerIn: parent
                                            text: "×"
                                            color: "white"
                                            font.pixelSize: 12
                                            font.bold: true
                                        }

                                        MouseArea {
                                            id: removeSpecMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: {
                                                currentSpecializations.splice(index, 1);
                                                updateSpecializationsList();
                                            }
                                        }
                                    }
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "Нет специализаций"
                                color: "#7f8c8d"
                                font.pixelSize: 12
                                visible: specializationsListModel.count === 0
                            }
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

                Rectangle {
                    Layout.fillWidth: true
                    height: 45
                    radius: 10
                    color: cancelMouseArea2.containsMouse ? "#95a5a6" : "#bdc3c7"

                    Text {
                        anchors.centerIn: parent
                        text: "Отмена"
                        color: "white"
                        font.pixelSize: 14
                        font.bold: true
                    }

                    MouseArea {
                        id: cancelMouseArea2
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: teacherFormWindow.cancelled()
                    }
                }

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
                                var teacherData = {
                                    "last_name": lastNameField.text.trim(),
                                    "first_name": firstNameField.text.trim(),
                                    "middle_name": middleNameField.text.trim(),
                                    "email": emailField.text.trim() || "",
                                    "phone_number": phoneField.text.trim() || "",
                                    "experience": parseInt(experienceField.text) || 0,
                                    "specializations": currentSpecializations
                                };

                                if (isEditMode && currentTeacher) {
                                    teacherData.teacher_id = currentTeacher.teacher_id || currentTeacher.teacherId;
                                }

                                console.log("💾 Сохранение преподавателя:", JSON.stringify(teacherData));
                                teacherFormWindow.saved(teacherData);
                            }
                        }
                    }
                }
            }
        }
    }

    onVisibleChanged: {
        if (visible) {
            lastNameField.forceActiveFocus();
            errorText.text = "";
        }
    }

    Keys.onEscapePressed: teacherFormWindow.cancelled()
    Keys.onReturnPressed: saveMouseArea.clicked()
}
