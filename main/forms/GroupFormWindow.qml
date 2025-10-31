// main/forms/GroupFormWindow.qml
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
            student_count: 0 // Будет вычисляться автоматически на сервере
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
            anchors.centerIn: parent
            color: "#ffffff"
            opacity: 0.925
            radius: 12

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                // Прокручиваемая область с контентом
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    Column {
                        width: parent.width
                        spacing: 16

                        // Название группы
                        Column {
                            width: parent.width
                            spacing: 6

                            Text {
                                text: "Название группы:"
                                color: "#2c3e50"
                                font.bold: true
                                font.pixelSize: 13
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            TextField {
                                id: nameField
                                width: 280
                                height: 36
                                anchors.horizontalCenter: parent.horizontalCenter
                                placeholderText: "Название группы*"
                                horizontalAlignment: Text.AlignHCenter
                                enabled: !isSaving
                                font.pixelSize: 13
                                KeyNavigation.tab: teacherComboBox
                                Keys.onReturnPressed: navigateToNextField(nameField)
                                Keys.onEnterPressed: navigateToNextField(nameField)
                                Keys.onUpPressed: navigateToPreviousField(nameField)
                                Keys.onDownPressed: navigateToNextField(nameField)

                                background: Rectangle {
                                    radius: 8
                                    border.color: nameField.activeFocus ? "#3498db" : "#bdc3c7"
                                    border.width: 1
                                    color: nameField.enabled ? "#ffffff" : "#f8f9fa"
                                }
                            }
                        }

                        // Преподаватель (куратор)
                        Column {
                            width: parent.width
                            spacing: 6

                            Text {
                                text: "Преподаватель (куратор):"
                                color: "#2c3e50"
                                font.bold: true
                                font.pixelSize: 13
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            ComboBox {
                                id: teacherComboBox
                                width: 280
                                height: 36
                                anchors.horizontalCenter: parent.horizontalCenter
                                enabled: !isSaving
                                font.pixelSize: 13
                                model: groupFormWindow.teachers
                                textRole: "display"
                                KeyNavigation.tab: saveButton
                                Keys.onReturnPressed: navigateToNextField(teacherComboBox)
                                Keys.onEnterPressed: navigateToNextField(teacherComboBox)
                                Keys.onUpPressed: navigateToPreviousField(teacherComboBox)
                                Keys.onDownPressed: saveButton.forceActiveFocus()

                                delegate: ItemDelegate {
                                    width: teacherComboBox.width - 20
                                    height: 36
                                    contentItem: Text {
                                        text: {
                                            var teacher = modelData
                                            var lastName = teacher.lastName || teacher.last_name || ""
                                            var firstName = teacher.firstName || teacher.first_name || ""
                                            var middleName = teacher.middleName || teacher.middle_name || ""
                                            return [lastName, firstName, middleName].filter(Boolean).join(" ") || "Неизвестный преподаватель"
                                        }
                                        color: "#2c3e50"
                                        font: teacherComboBox.font
                                        elide: Text.ElideRight
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    background: Rectangle {
                                        color: parent.highlighted ? "#3498db" : "transparent"
                                    }
                                    highlighted: teacherComboBox.highlightedIndex === index
                                }

                                contentItem: Text {
                                    text: teacherComboBox.currentIndex >= 0 ?
                                        teacherComboBox.displayText : "Выберите преподавателя"
                                    color: teacherComboBox.currentIndex >= 0 ? "#2c3e50" : "#7f8c8d"
                                    font: teacherComboBox.font
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                }

                                background: Rectangle {
                                    radius: 8
                                    border.color: teacherComboBox.activeFocus ? "#3498db" : "#bdc3c7"
                                    border.width: 1
                                    color: teacherComboBox.enabled ? "#ffffff" : "#f8f9fa"
                                }

                                popup: Popup {
                                    y: teacherComboBox.height
                                    width: teacherComboBox.width
                                    implicitHeight: contentItem.implicitHeight
                                    padding: 1

                                    contentItem: ListView {
                                        clip: true
                                        implicitHeight: contentHeight
                                        model: teacherComboBox.popup.visible ? teacherComboBox.delegateModel : null
                                        currentIndex: teacherComboBox.highlightedIndex

                                        ScrollIndicator.vertical: ScrollIndicator { }
                                    }

                                    background: Rectangle {
                                        radius: 8
                                        border.color: "#bdc3c7"
                                        color: "#ffffff"
                                    }
                                }
                            }
                        }

                        // Информация
                        Rectangle {
                            width: 280
                            height: 60
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: "#f8f9fa"
                            radius: 8
                            border.color: "#e0e0e0"
                            border.width: 1

                            Column {
                                anchors.centerIn: parent
                                spacing: 4

                                Text {
                                    text: "💡 Информация"
                                    color: "#2c3e50"
                                    font.bold: true
                                    font.pixelSize: 11
                                }

                                Text {
                                    text: "Количество студентов будет автоматически\nвычисляться на основе данных системы"
                                    color: "#7f8c8d"
                                    font.pixelSize: 9
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }
                    }
                }

                // Кнопки действий
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 16

                    Button {
                        id: saveButton
                        text: isSaving ? "⏳ Сохранение..." : "💾 Сохранить"
                        implicitWidth: 120
                        implicitHeight: 36
                        enabled: !isSaving && nameField.text.trim() !== "" && teacherComboBox.currentIndex >= 0
                        font.pixelSize: 13
                        KeyNavigation.tab: cancelButton
                        Keys.onReturnPressed: if (enabled && !isSaving) saveButton.clicked()
                        Keys.onEnterPressed: if (enabled && !isSaving) saveButton.clicked()
                        Keys.onUpPressed: teacherComboBox.forceActiveFocus()

                        background: Rectangle {
                            radius: 8
                            color: saveButton.enabled ? (saveButton.down ? "#27ae60" : "#2ecc71") : "#bdc3c7"
                        }

                        contentItem: Text {
                            text: saveButton.text
                            color: "#ffffff"
                            font: saveButton.font
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

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
                        implicitWidth: 120
                        implicitHeight: 36
                        enabled: !isSaving
                        font.pixelSize: 13
                        KeyNavigation.tab: nameField
                        Keys.onReturnPressed: if (enabled) cancelButton.clicked()
                        Keys.onEnterPressed: if (enabled) cancelButton.clicked()
                        Keys.onUpPressed: saveButton.forceActiveFocus()

                        background: Rectangle {
                            radius: 8
                            color: cancelButton.down ? "#e74c3c" : "#ecf0f1"
                        }

                        contentItem: Text {
                            text: cancelButton.text
                            color: cancelButton.down ? "#ffffff" : "#2c3e50"
                            font: cancelButton.font
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
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

    Component.onCompleted: {
        // Устанавливаем отображение для модели преподавателей
        for (var i = 0; i < teachers.length; i++) {
            var teacher = teachers[i]
            var displayName = (teacher.lastName || teacher.last_name || "") + " " +
                            (teacher.firstName || teacher.first_name || "") + " " +
                            (teacher.middleName || teacher.middle_name || "")
            teachers[i].display = displayName.trim()
        }
    }
}
