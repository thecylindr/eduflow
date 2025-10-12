import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    property ListModel groupsModel
    property ListModel teachersModel
    signal refresh()
    signal addGroup(var groupData)

    color: "transparent"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10

        RowLayout {
            Button {
                text: "🔄 Обновить"
                onClicked: refresh()
            }
            Button {
                text: "➕ Добавить группу"
                onClicked: addGroupDialog.open()
            }
            Item { Layout.fillWidth: true }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: groupsList
                model: groupsModel
                spacing: 2

                delegate: Rectangle {
                    width: groupsList.width
                    height: 50
                    color: index % 2 ? "#f8f9fa" : "#ffffff"
                    border.color: "#e9ecef"
                    border.width: 1
                    radius: 4

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10

                        Text {
                            text: model.name
                            font.bold: true
                            font.pixelSize: 14
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "Студентов: " + model.student_count
                            font.pixelSize: 12
                            color: "#6c757d"
                        }

                        Text {
                            text: "Преподаватель ID: " + model.teacher_id
                            font.pixelSize: 12
                            color: "#6c757d"
                        }
                    }
                }
            }
        }
    }

    Dialog {
        id: addGroupDialog
        title: "Добавить группу"
        standardButtons: Dialog.Ok | Dialog.Cancel
        modal: true

        ColumnLayout {
            width: 400
            spacing: 10

            TextField { id: groupNameField; placeholderText: "Название группы *"; Layout.fillWidth: true }
            TextField { id: studentCountField; placeholderText: "Количество студентов"; validator: IntValidator { bottom: 0 } }
            TextField { id: teacherIdField; placeholderText: "ID преподавателя *"; validator: IntValidator { bottom: 0 } }
        }

        onAccepted: {
            if (groupNameField.text && teacherIdField.text) {
                addGroup({
                    name: groupNameField.text,
                    student_count: studentCountField.text ? parseInt(studentCountField.text) : 0,
                    teacher_id: parseInt(teacherIdField.text)
                });
                [groupNameField, studentCountField, teacherIdField].forEach(field => field.text = "");
            }
        }
    }
}