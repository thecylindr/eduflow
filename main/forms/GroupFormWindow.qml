import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Controls.Universal
import QtQuick.Layouts 1.15
import "../../common" as Common

Window {
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

    property var fieldNavigation: [
        nameField, teacherComboBox
    ]

    ListModel {
        id: teacherDisplayModel
    }

    function updateTeacherModel() {
        teacherDisplayModel.clear()

        for (var i = 0; i < teachers.length; i++) {
            var teacher = teachers[i]
            var displayName = formatTeacherName(teacher)
            var teacherId = teacher.teacher_id || teacher.teacherId || teacher.id || 0

            teacherDisplayModel.append({
                displayName: displayName,
                teacherId: teacherId,
                originalIndex: i
            })
        }

        if (isEditMode && currentGroup) {
            restoreSelectedTeacher()
        }
    }

    function formatTeacherName(teacher) {
        var lastName = teacher.last_name || teacher.lastName || ""
        var firstName = teacher.first_name || teacher.firstName || ""
        var middleName = teacher.middle_name || teacher.middleName || ""
        return [lastName, firstName, middleName].filter(Boolean).join(" ").trim()
    }

    function restoreSelectedTeacher() {
        var teacherId = currentGroup.teacher_id || currentGroup.teacherId
        if (teacherId) {
            for (var i = 0; i < teacherDisplayModel.count; i++) {
                if (teacherDisplayModel.get(i).teacherId === teacherId) {
                    teacherComboBox.currentIndex = i
                    break
                }
            }
        }
    }

    function openForAdd() {
        currentGroup = null
        isEditMode = false
        isSaving = false
        clearForm()
        updateTeacherModel()
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
        updateTeacherModel()
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
    }

    function getGroupData() {
        var groupId = 0
        if (isEditMode && currentGroup) {
            groupId = currentGroup.groupId || currentGroup.group_id || 0
        }

        var selectedTeacher = null
        var teacherId = 0

        if (teacherComboBox.currentIndex >= 0) {
            var selectedItem = teacherDisplayModel.get(teacherComboBox.currentIndex)
            teacherId = selectedItem.teacherId
            selectedTeacher = teachers[selectedItem.originalIndex]
        }

        return {
            group_id: groupId,
            name: nameField.text,
            teacher_id: teacherId,
            student_count: 0
        }
    }

    function handleSaveResponse(response) {
        isSaving = false

        if (response.success) {
            var message = response.message || (isEditMode ? "Группа успешно обновлена!" : "Группа успешно добавлена!")
            showMessage(message, "success")
            saveCompleted(true, message)
            closeWindow()
        } else {
            var errorMsg = (response.error || "Неизвестная ошибка")
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

    onTeachersChanged: {
        updateTeacherModel()
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
            title: isEditMode ? "Редактирование группы" : "Добавление группы"
            window: groupFormWindow
            onClose: {
                cancelled()
                closeWindow()
            }
        }

        Rectangle {
            id: whiteForm
            width: 360
            height: 360
            anchors {
                top: titleBar.bottom
                topMargin: 16
                horizontalCenter: parent.horizontalCenter
            }
            color: "#ffffff"
            opacity: 0.925
            radius: 12

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16

                Column {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 20

                    Column {
                        width: parent.width
                        spacing: 8

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
                            enabled: !isSaving && teacherDisplayModel.count > 0
                            font.pixelSize: 14

                            model: teacherDisplayModel
                            textRole: "displayName"

                            KeyNavigation.tab: saveButton
                            Keys.onReturnPressed: navigateToNextField(teacherComboBox)
                            Keys.onEnterPressed: navigateToNextField(teacherComboBox)
                            Keys.onUpPressed: navigateToPreviousField(teacherComboBox)
                            Keys.onDownPressed: saveButton.forceActiveFocus()

                            onCurrentIndexChanged: {
                                if (currentIndex >= 0) {
                                    var selected = teacherDisplayModel.get(currentIndex)
                                    console.log("Выбран преподаватель:", selected.displayName, "ID:", selected.teacherId)
                                }
                            }
                        }

                        Text {
                            visible: teacherDisplayModel.count === 0
                            text: teachers.length === 0 ? "Нет доступных преподавателей" : "Загрузка преподавателей..."
                            color: "#e74c3c"
                            font.pixelSize: 12
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            visible: teacherDisplayModel.count > 0
                            text: "Доступно преподавателей: " + teacherDisplayModel.count
                            color: "#27ae60"
                            font.pixelSize: 11
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }

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

                            Image {
                                source: "qrc:/icons/info.png"
                                width: 32
                                height: 32
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

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 20

                    Button {
                        id: saveButton
                        text: isSaving ? "Сохранение..." : "Сохранить"
                        implicitWidth: 140
                        implicitHeight: 40
                        enabled: !isSaving &&
                                nameField.text.trim() !== "" &&
                                teacherComboBox.currentIndex >= 0
                        font.pixelSize: 14
                        font.bold: true

                        background: Rectangle {
                            radius: 20
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

                        KeyNavigation.tab: cancelButton
                        Keys.onReturnPressed: if (enabled && !isSaving) saveButton.clicked()
                        Keys.onEnterPressed: if (enabled && !isSaving) saveButton.clicked()
                        Keys.onUpPressed: teacherComboBox.forceActiveFocus()

                        onClicked: {
                            if (nameField.text.trim() === "") {
                                showMessage("Введите название группы", "error")
                                return
                            }
                            if (teacherComboBox.currentIndex < 0) {
                                showMessage("Выберите преподавателя", "error")
                                return
                            }
                            isSaving = true
                            saved(getGroupData())
                        }
                    }

                    Button {
                        id: cancelButton
                        text: "Отмена"
                        implicitWidth: 140
                        implicitHeight: 40
                        enabled: !isSaving
                        font.pixelSize: 14
                        font.bold: true

                        background: Rectangle {
                            radius: 20
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
