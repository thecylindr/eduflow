import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../../common" as Common

ApplicationWindow {
    id: teacherFormWindow
    width: 500
    height: 650
    flags: Qt.Dialog | Qt.FramelessWindowHint
    modality: Qt.ApplicationModal
    color: "transparent"
    visible: false

    property var currentTeacher: null
    property bool isEditMode: false
    property bool isSaving: false

    signal saved(var teacherData)
    signal cancelled()
    signal saveCompleted(bool success, string message)

    // Порядок навигации между полями
    property var fieldNavigation: [
        lastNameField, firstNameField, middleNameField,
        emailField, phoneField, experienceField,
        newSpecializationField
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
        // Устанавливаем фокус на первое поле
        Qt.callLater(function() { lastNameField.forceActiveFocus() })
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
        // Устанавливаем фокус на первое поле
        Qt.callLater(function() { lastNameField.forceActiveFocus() })
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
    }

    function fillForm(teacherData) {
        lastNameField.text = teacherData.lastName || ""
        firstNameField.text = teacherData.firstName || ""
        middleNameField.text = teacherData.middleName || ""
        emailField.text = teacherData.email || ""
        phoneField.text = teacherData.phoneNumber || ""
        experienceField.value = teacherData.experience || 0

        specializationModel.clear()
        if (teacherData.specialization) {
            var specs = teacherData.specialization.split(",")
            for (var i = 0; i < specs.length; i++) {
                var spec = specs[i].trim()
                if (spec !== "") {
                    specializationModel.append({name: spec})
                }
            }
        }
    }

    function getTeacherData() {
        var specs = []
        for (var i = 0; i < specializationModel.count; i++) {
            specs.push(specializationModel.get(i).name)
        }

        // ИСПРАВЛЕНИЕ: Правильно получаем teacher_id из currentTeacher
        var teacherId = 0;
        if (isEditMode && currentTeacher) {
            // Пробуем разные возможные названия свойства
            teacherId = currentTeacher.teacherId || currentTeacher.teacher_id || 0;
            console.log("🆔 Получен teacherId для редактирования:", teacherId);
        }

        return {
            teacher_id: teacherId,
            last_name: lastNameField.text,
            first_name: firstNameField.text,
            middle_name: middleNameField.text,
            email: emailField.text,
            phone_number: phoneField.text,
            experience: experienceField.value,
            specialization: specs.join(", ")
        }
    }

    function handleSaveResponse(response) {
        isSaving = false
        console.log("🔔 Обработка ответа сохранения:", JSON.stringify(response, null, 2))

        if (response.success) {
            var message = response.message || (isEditMode ? "✅ Преподаватель успешно обновлен!" : "✅ Преподаватель успешно добавлен!")
            showMessage(message, "success")
            saveCompleted(true, message)
            closeWindow()
        } else {
            var errorMsg = "❌ " + (response.error || "Неизвестная ошибка")
            showMessage(errorMsg, "error")
            saveCompleted(false, errorMsg)
        }
    }

    function addSpecialization() {
        if (newSpecializationField.text.trim() !== "") {
            specializationModel.append({name: newSpecializationField.text.trim()})
            newSpecializationField.text = ""
            newSpecializationField.forceActiveFocus()
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
            // Если достигли последнего поля, переходим к кнопке сохранения
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
        radius: 21
        color: "transparent"
        clip: true

        // Градиентный фон
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#6a11cb" }
                GradientStop { position: 1.0; color: "#2575fc" }
            }
            radius: 20
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
                margins: 10
            }
            height: 30
            title: isEditMode ? "Редактирование преподавателя" : "Добавление преподавателя"
            window: teacherFormWindow
            onClose: {
                cancelled()
                closeWindow()
            }
        }

        // Белая форма с улучшенной компоновкой
        Rectangle {
            id: whiteForm
            width: 450
            height: 550
            anchors.centerIn: parent
            color: "#ffffff"
            opacity: 0.925
            radius: 12


            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 12

                // Прокручиваемая область с контентом
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    Column {
                        width: parent.width
                        spacing: 15

                        // ФИО - теперь горизонтально
                        Column {
                            width: parent.width
                            spacing: 8

                            Text {
                                text: "ФИО:"
                                color: "#2c3e50"
                                font.bold: true
                                font.pixelSize: 14
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Row {
                                width: 350
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: 10

                                TextField {
                                    id: lastNameField
                                    width: 110
                                    placeholderText: "Фамилия*"
                                    horizontalAlignment: Text.AlignHCenter
                                    enabled: !isSaving
                                    KeyNavigation.tab: firstNameField
                                    Keys.onReturnPressed: navigateToNextField(lastNameField)
                                    Keys.onEnterPressed: navigateToNextField(lastNameField)
                                    Keys.onUpPressed: navigateToPreviousField(lastNameField)
                                    Keys.onDownPressed: navigateToNextField(lastNameField)
                                }

                                TextField {
                                    id: firstNameField
                                    width: 110
                                    placeholderText: "Имя*"
                                    horizontalAlignment: Text.AlignHCenter
                                    enabled: !isSaving
                                    KeyNavigation.tab: middleNameField
                                    Keys.onReturnPressed: navigateToNextField(firstNameField)
                                    Keys.onEnterPressed: navigateToNextField(firstNameField)
                                    Keys.onUpPressed: navigateToPreviousField(firstNameField)
                                    Keys.onDownPressed: navigateToNextField(firstNameField)
                                }

                                TextField {
                                    id: middleNameField
                                    width: 110
                                    placeholderText: "Отчество"
                                    horizontalAlignment: Text.AlignHCenter
                                    enabled: !isSaving
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
                            spacing: 8

                            Text {
                                text: "Контакты:"
                                color: "#2c3e50"
                                font.bold: true
                                font.pixelSize: 14
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            TextField {
                                id: emailField
                                width: 350
                                anchors.horizontalCenter: parent.horizontalCenter
                                placeholderText: "Email"
                                horizontalAlignment: Text.AlignHCenter
                                enabled: !isSaving
                                KeyNavigation.tab: phoneField
                                Keys.onReturnPressed: navigateToNextField(emailField)
                                Keys.onEnterPressed: navigateToNextField(emailField)
                                Keys.onUpPressed: navigateToPreviousField(emailField)
                                Keys.onDownPressed: navigateToNextField(emailField)
                            }

                            TextField {
                                id: phoneField
                                width: 350
                                anchors.horizontalCenter: parent.horizontalCenter
                                placeholderText: "Телефон"
                                horizontalAlignment: Text.AlignHCenter
                                enabled: !isSaving
                                KeyNavigation.tab: experienceField
                                Keys.onReturnPressed: navigateToNextField(phoneField)
                                Keys.onEnterPressed: navigateToNextField(phoneField)
                                Keys.onUpPressed: navigateToPreviousField(phoneField)
                                Keys.onDownPressed: navigateToNextField(phoneField)
                            }
                        }

                        // Опыт работы
                        Column {
                            width: parent.width
                            spacing: 8

                            Text {
                                text: "Опыт работы (лет):"
                                color: "#2c3e50"
                                font.bold: true
                                font.pixelSize: 14
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            SpinBox {
                                id: experienceField
                                width: 150
                                anchors.horizontalCenter: parent.horizontalCenter
                                from: 0
                                to: 50
                                value: 0
                                enabled: !isSaving
                                KeyNavigation.tab: newSpecializationField
                                Keys.onReturnPressed: navigateToNextField(experienceField)
                                Keys.onEnterPressed: navigateToNextField(experienceField)
                                Keys.onUpPressed: navigateToPreviousField(experienceField)
                                Keys.onDownPressed: navigateToNextField(experienceField)

                                contentItem: Text {
                                    text: experienceField.value
                                    color: enabled ? "#2c3e50" : "#7f8c8d"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }

                        // Специализации
                        Column {
                            width: parent.width
                            spacing: 8

                            Text {
                                text: "Специализации:"
                                color: "#2c3e50"
                                font.bold: true
                                font.pixelSize: 14
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            // Список специализаций
                            Rectangle {
                                width: 350
                                height: 100
                                anchors.horizontalCenter: parent.horizontalCenter
                                color: "#f8f9fa"
                                radius: 8
                                border.color: "#e0e0e0"
                                border.width: 1

                                ListView {
                                    id: specializationListView
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    model: ListModel { id: specializationModel }
                                    spacing: 3
                                    clip: true

                                    delegate: Rectangle {
                                        width: specializationListView.width
                                        height: 25
                                        radius: 6
                                        color: index % 2 === 0 ? "#e3f2fd" : "#f3e5f5"
                                        border.color: "#bbdefb"

                                        Row {
                                            anchors.fill: parent
                                            anchors.margins: 3
                                            spacing: 5

                                            Text {
                                                text: model.name
                                                width: parent.width - 30
                                                height: parent.height
                                                verticalAlignment: Text.AlignVCenter
                                                horizontalAlignment: Text.AlignHCenter
                                                font.pixelSize: 11
                                                color: "#2c3e50"
                                                elide: Text.ElideRight
                                            }

                                            Button {
                                                width: 20
                                                height: 20
                                                text: "❌"
                                                enabled: !isSaving
                                                onClicked: specializationModel.remove(index)
                                            }
                                        }
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: "Нет специализаций"
                                        color: "#7f8c8d"
                                        font.italic: true
                                        visible: specializationModel.count === 0
                                    }
                                }
                            }

                            // Добавление новой специализации
                            Item {
                                width: 350
                                height: 40
                                anchors.horizontalCenter: parent.horizontalCenter

                                RowLayout {
                                    anchors.fill: parent
                                    spacing: 10

                                    TextField {
                                        id: newSpecializationField
                                        Layout.fillWidth: true
                                        placeholderText: "Новая специализация"
                                        horizontalAlignment: Text.AlignHCenter
                                        enabled: !isSaving
                                        KeyNavigation.tab: saveButton
                                        Keys.onReturnPressed: addSpecialization()
                                        Keys.onEnterPressed: addSpecialization()
                                        Keys.onUpPressed: navigateToPreviousField(newSpecializationField)
                                        Keys.onDownPressed: saveButton.forceActiveFocus()
                                    }

                                    Button {
                                        Layout.preferredWidth: 40
                                        Layout.preferredHeight: 40
                                        text: "➕"
                                        enabled: !isSaving
                                        onClicked: addSpecialization()
                                    }
                                }
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
                        enabled: !isSaving && lastNameField.text.trim() !== "" && firstNameField.text.trim() !== ""
                        KeyNavigation.tab: cancelButton
                        Keys.onReturnPressed: if (enabled && !isSaving) saveButton.clicked()
                        Keys.onEnterPressed: if (enabled && !isSaving) saveButton.clicked()
                        Keys.onUpPressed: newSpecializationField.forceActiveFocus()
                        onClicked: {
                            if (lastNameField.text.trim() === "" || firstNameField.text.trim() === "") {
                                showMessage("❌ Заполните обязательные поля (Фамилия и Имя)", "error")
                                return
                            }
                            isSaving = true
                            saved(getTeacherData())
                        }
                    }

                    Button {
                        id: cancelButton
                        text: "❌ Отмена"
                        implicitWidth: 140
                        implicitHeight: 40
                        enabled: !isSaving
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
