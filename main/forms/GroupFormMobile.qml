import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15
import QtQuick.Controls.Universal
import "../../common" as Common

Window {
    id: groupFormWindow
    width: Math.min(Screen.width * 0.95, 400)
    height: Math.min(Screen.height * 0.8, 600)
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
    }

    function openForEdit(groupData) {
        currentGroup = groupData
        isEditMode = true
        isSaving = false
        updateTeacherModel()
        fillForm(groupData)
        groupFormWindow.show()
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

        var teacherId = 0
        if (teacherComboBox.currentIndex >= 0) {
            var selectedItem = teacherDisplayModel.get(teacherComboBox.currentIndex)
            teacherId = selectedItem.teacherId
        }

        return {
            group_id: groupId,
            name: nameField.text,
            teacher_id: teacherId,
            student_count: 0
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
                                text: "Название группы:"
                                font.bold: true
                                font.pixelSize: 14
                                color: "#2c3e50"
                            }

                            TextField {
                                id: nameField
                                width: parent.width
                                height: 45
                                placeholderText: "Введите название группы*"
                                font.pixelSize: 14
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: 8

                            Label {
                                text: "Преподаватель (куратор):"
                                font.bold: true
                                font.pixelSize: 14
                                color: "#2c3e50"
                            }

                            ComboBox {
                                id: teacherComboBox
                                width: parent.width
                                height: 45
                                enabled: !isSaving && teacherDisplayModel.count > 0
                                font.pixelSize: 14

                                background: Rectangle {
                                    radius: 8
                                    color: "#ffffff"
                                    border.color: teacherComboBox.enabled ? "#e0e0e0" : "#f0f0f0"
                                    border.width: 1
                                }

                                model: teacherDisplayModel
                                textRole: "displayName"
                            }

                            Label {
                                visible: teacherDisplayModel.count === 0
                                text: teachers.length === 0 ? "Нет доступных преподавателей" : "Загрузка преподавателей..."
                                color: "#e74c3c"
                                font.pixelSize: 12
                            }

                            Label {
                                visible: teacherDisplayModel.count > 0
                                text: "Доступно преподавателей: " + teacherDisplayModel.count
                                color: "#27ae60"
                                font.pixelSize: 12
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 80
                            color: "#e8f4fd"
                            radius: 10
                            border.color: "#3498db"
                            border.width: 1

                            Row {
                                anchors.centerIn: parent
                                spacing: 12
                                width: parent.width - 20

                                Image {
                                    source: "qrc:/icons/info.png"
                                    width: 24
                                    height: 24
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Column {
                                    width: parent.width - 36
                                    spacing: 4
                                    anchors.verticalCenter: parent.verticalCenter

                                    Label {
                                        text: "Информация о группе"
                                        font.bold: true
                                        font.pixelSize: 12
                                        color: "#2c3e50"
                                    }

                                    Label {
                                        width: parent.width
                                        text: "Количество студентов автоматически рассчитывается при добавлении студентов в группу"
                                        font.pixelSize: 11
                                        color: "#34495e"
                                        wrapMode: Text.WordWrap
                                    }
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
                        implicitHeight: 45
                        enabled: !isSaving && nameField.text.trim() !== "" && teacherComboBox.currentIndex >= 0
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
                            if (nameField.text.trim() === "") return
                            if (teacherComboBox.currentIndex < 0) return
                            isSaving = true
                            saved(getGroupData())
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
