import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../../common" as Common

ApplicationWindow {
    id: groupFormWindow
    width: 400
    height: 450
    flags: Qt.Dialog | Qt.FramelessWindowHint
    modality: Qt.ApplicationModal
    color: "transparent"
    visible: false

    property var currentGroup: null
    property bool isEditMode: false
    property bool isSaving: false
    property var teachers: []

    signal saved(var groupData)
    signal cancelled()
    signal saveCompleted(bool success, string message)

    // Порядок навигации между полями
    property var fieldNavigation: [
        nameField, teacherComboBox
    ]

    function openForAdd() {
        currentGroup = null
        isEditMode = false
        isSaving = false
        clearForm()
        groupFormWindow.show()
        groupFormWindow.requestActivate()
        groupFormWindow.x = (Screen.width - groupFormWindow.width) / 2
        groupFormWindow.y = (Screen.height - groupFormWindow.height) / 2
        Qt.callLater(function() { nameField.forceActiveFocus() })
    }

    function openForEdit(groupData) {
        currentGroup = groupData
        isEditMode = true
        isSaving = false
        fillForm(groupData)
        groupFormWindow.show()
        groupFormWindow.requestActivate()
        groupFormWindow.x = (Screen.width - groupFormWindow.width) / 2
        groupFormWindow.y = (Screen.height - groupFormWindow.height) / 2
        Qt.callLater(function() { nameField.forceActiveFocus() })
    }

    function closeWindow() {
        groupFormWindow.close()
    }

    function clearForm() {
        nameField.text = ""
        teacherComboBox.currentIndex = -1
    }

    function fillForm(groupData) {
        nameField.text = groupData.name || ""

        // Находим индекс преподавателя в комбобоксе
        var teacherId = groupData.teacherId || groupData.teacher_id
        if (teacherId) {
            for (var i = 0; i < teachers.length; i++) {
                var teacher = teachers[i]
                var currentTeacherId = teacher.teacherId || teacher.teacher_id
                if (currentTeacherId === teacherId) {
                    teacherComboBox.currentIndex = i
                    break
                }
            }
        } else {
            teacherComboBox.currentIndex = -1
        }
    }

    function getGroupData() {
        var groupId = 0
        if (isEditMode && currentGroup) {
            groupId = currentGroup.groupId || currentGroup.group_id || 0
        }

        var selectedTeacher = teacherComboBox.currentIndex >= 0 ?
            teachers[teacherComboBox.currentIndex] : null
        var teacherId = selectedTeacher ?
            (selectedTeacher.teacherId || selectedTeacher.teacher_id) : 0

        return {
            group_id: groupId,
            name: nameField.text,
            teacher_id: teacherId,
            student_count: 0
        }
    }

    function handleSaveResponse(response) {
        isSaving = false
        console.log("🔔 Обработка ответа сохранения группы:", JSON.stringify(response, null, 2))

        if (response.success) {
            var message = response.message || (isEditMode ? "✅ Группа успешно обновлена!" : "✅ Группа успешно добавлена!")
            showMessage(message, "success")
            saveCompleted(true, message)
            closeWindow()
        } else {
            var errorMsg = "❌ " + (response.error || "Неизвестная ошибка")
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
            title: isEditMode ? "Редактирование группы" : "Добавление группы"
            window: groupFormWindow
            onClose: {
                cancelled()
                closeWindow()
            }
        }

        // Белая форма
        Rectangle {
            id: whiteForm
            width: 360
            height: 360
            anchors {
                top: titleBar.bottom
                topMargin: 30
                horizontalCenter: parent.horizontalCenter
            }
            color: "#ffffff"
            opacity: 0.925
            radius: 12

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16

                // Прокручиваемая область с контентом
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    Column {
                        width: parent.width
                        spacing: 20

                        // Название группы
                        Column {
                            width: parent.width
                            spacing: 8

                            Text {
                                text: "Название группы:"
                                color: "#2c3e50"
                                font.bold: true
                                font.pixelSize: 14
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            TextField {
                                id: nameField
                                width: parent.width - 40
                                height: 40
                                anchors.horizontalCenter: parent.horizontalCenter
                                placeholderText: "Введите название группы*"
                                horizontalAlignment: Text.AlignHCenter
                                enabled: !isSaving
                                font.pixelSize: 14
                                KeyNavigation.tab: teacherComboBox
                                Keys.onReturnPressed: navigateToNextField(nameField)
                                Keys.onEnterPressed: navigateToNextField(nameField)
                                Keys.onUpPressed: navigateToPreviousField(nameField)
                                Keys.onDownPressed: navigateToNextField(nameField)
                            }
                        }

                        // Преподаватель (куратор)
                        Column {
                            width: parent.width
                            spacing: 8

                            Text {
                                text: "Преподаватель (куратор):"
                                color: "#2c3e50"
                                font.bold: true
                                font.pixelSize: 14
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            ComboBox {
                                id: teacherComboBox
                                width: parent.width - 40
                                height: 40
                                anchors.horizontalCenter: parent.horizontalCenter
                                enabled: !isSaving
                                font.pixelSize: 14
                                model: groupFormWindow.teachers
                                textRole: "name"
                                KeyNavigation.tab: saveButton
                                Keys.onReturnPressed: navigateToNextField(teacherComboBox)
                                Keys.onEnterPressed: navigateToNextField(teacherComboBox)
                                Keys.onUpPressed: navigateToPreviousField(teacherComboBox)
                                Keys.onDownPressed: saveButton.forceActiveFocus()
                            }
                        }

                        // Информация
                        Rectangle {
                            width: parent.width - 40
                            height: 70
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: "#e8f4fd"
                            radius: 10
                            border.color: "#3498db"
                            border.width: 1

                            Row {
                                anchors.centerIn: parent
                                spacing: 12
                                width: parent.width - 24

                                Text {
                                    text: "💡"
                                    font.pixelSize: 20
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Column {
                                    width: parent.width - 36
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 4

                                    Text {
                                        text: "Информация о группе"
                                        color: "#2c3e50"
                                        font.bold: true
                                        font.pixelSize: 12
                                    }

                                    Text {
                                        width: parent.width
                                        text: "Количество студентов автоматически рассчитывается при добавлении студентов в группу"
                                        color: "#34495e"
                                        font.pixelSize: 10
                                        wrapMode: Text.WordWrap
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
                        enabled: !isSaving && nameField.text.trim() !== "" && teacherComboBox.currentIndex >= 0
                        font.pixelSize: 14
                        KeyNavigation.tab: cancelButton
                        Keys.onReturnPressed: if (enabled && !isSaving) saveButton.clicked()
                        Keys.onEnterPressed: if (enabled && !isSaving) saveButton.clicked()
                        Keys.onUpPressed: teacherComboBox.forceActiveFocus()

                        onClicked: {
                            if (nameField.text.trim() === "") {
                                showMessage("❌ Введите название группы", "error")
                                return
                            }
                            if (teacherComboBox.currentIndex < 0) {
                                showMessage("❌ Выберите преподавателя", "error")
                                return
                            }
                            isSaving = true
                            saved(getGroupData())
                        }
                    }

                    Button {
                        id: cancelButton
                        text: "❌ Отмена"
                        implicitWidth: 140
                        implicitHeight: 40
                        enabled: !isSaving
                        font.pixelSize: 14
                        KeyNavigation.tab: nameField
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
