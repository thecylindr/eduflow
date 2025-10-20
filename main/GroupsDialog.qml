// main/GroupsDialog.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Popup {
    id: groupDialog
    width: 450
    height: 400
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    padding: 0

    property bool isEditMode: false
    property var currentGroup: null
    property var teachers: []
    property bool isLoading: false

    signal saved(var groupData)
    signal cancelled

    function openForEdit(group) {
        currentGroup = group;
        isEditMode = true;

        nameField.text = group.name || "";
        studentCountField.text = group.studentCount || "0";

        // Находим индекс преподавателя в ComboBox
        var teacherIndex = findTeacherIndex(group.teacherId);
        teacherCombo.currentIndex = teacherIndex >= 0 ? teacherIndex : 0;

        groupDialog.open();
    }

    function openForAdd() {
        currentGroup = null;
        isEditMode = false;

        nameField.text = "";
        studentCountField.text = "0";
        teacherCombo.currentIndex = 0;

        groupDialog.open();
    }

    function findTeacherIndex(teacherId) {
        if (!teacherId) return -1;

        for (var i = 0; i < teachers.length; i++) {
            if (teachers[i].teacherId === teacherId) {
                return i;
            }
        }
        return -1;
    }

    function validateForm() {
        errorText.text = "";

        if (!nameField.text.trim()) {
            errorText.text = "Название группы обязательно для заполнения";
            return false;
        }

        if (teachers.length === 0) {
            errorText.text = "Нет доступных преподавателей";
            return false;
        }

        var studentCount = parseInt(studentCountField.text);
        if (isNaN(studentCount) || studentCount < 0) {
            errorText.text = "Количество студентов должно быть числом ≥ 0";
            return false;
        }

        return true;
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
                color: "#e74c3c"
                radius: 12

                Text {
                    anchors.centerIn: parent
                    text: isEditMode ? "✏️ Редактирование группы" : "➕ Добавление группы"
                    color: "white"
                    font.pixelSize: 16
                    font.bold: true
                }

                Rectangle {
                    width: 30
                    height: 30
                    radius: 15
                    color: closeMouseArea.containsMouse ? "#c0392b" : "transparent"
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
                        onClicked: {
                            groupDialog.cancelled();
                            groupDialog.close();
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

                    // Название группы
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Text {
                            text: "Название группы *"
                            font.pixelSize: 12
                            font.bold: true
                            color: "#2c3e50"
                        }

                        TextField {
                            id: nameField
                            Layout.fillWidth: true
                            placeholderText: "Введите название группы"
                            font.pixelSize: 14
                            selectByMouse: true
                        }
                    }

                    // Количество студентов
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Text {
                            text: "Количество студентов"
                            font.pixelSize: 12
                            font.bold: true
                            color: "#2c3e50"
                        }

                        TextField {
                            id: studentCountField
                            Layout.fillWidth: true
                            placeholderText: "0"
                            font.pixelSize: 14
                            validator: IntValidator { bottom: 0; top: 1000 }
                            selectByMouse: true
                            inputMethodHints: Qt.ImhDigitsOnly
                        }
                    }

                    // Куратор
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Text {
                            text: "Куратор *"
                            font.pixelSize: 12
                            font.bold: true
                            color: "#2c3e50"
                        }

                        ComboBox {
                            id: teacherCombo
                            Layout.fillWidth: true
                            model: teachers
                            textRole: "displayName"
                            font.pixelSize: 14
                            enabled: teachers.length > 0 && !isLoading

                            // Определяем displayName для модели
                            property string displayName: {
                                if (modelData && modelData.lastName && modelData.firstName) {
                                    return modelData.lastName + " " + modelData.firstName;
                                }
                                return "Не указан";
                            }

                            delegate: ItemDelegate {
                                width: teacherCombo.width
                                height: 40
                                text: modelData.lastName + " " + modelData.firstName +
                                      (modelData.middleName ? " " + modelData.middleName : "")
                                font.pixelSize: 12
                                highlighted: teacherCombo.highlightedIndex === index
                            }

                            contentItem: Text {
                                text: teacherCombo.displayText
                                font: teacherCombo.font
                                color: teachers.length === 0 ? "#7f8c8d" : "#2c3e50"
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                            }
                        }

                        // Сообщение если нет преподавателей
                        Text {
                            text: teachers.length === 0 ? "❌ Нет доступных преподавателей" : ""
                            font.pixelSize: 11
                            color: "#e74c3c"
                            visible: teachers.length === 0
                        }
                    }

                    // Индикатор загрузки
                    Rectangle {
                        Layout.fillWidth: true
                        height: 30
                        radius: 6
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
                        onClicked: {
                            groupDialog.cancelled();
                            groupDialog.close();
                        }
                    }
                }

                // Кнопка сохранения
                Rectangle {
                    Layout.fillWidth: true
                    height: 45
                    radius: 8
                    color: saveMouseArea.containsMouse ? "#c0392b" : "#e74c3c"
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
                                var selectedTeacher = teachers[teacherCombo.currentIndex];
                                if (!selectedTeacher) {
                                    errorText.text = "Выберите преподавателя";
                                    return;
                                }

                                var groupData = {
                                    name: nameField.text.trim(),
                                    student_count: parseInt(studentCountField.text) || 0,
                                    teacher_id: selectedTeacher.teacherId
                                };

                                // Добавляем ID группы для режима редактирования
                                if (isEditMode && currentGroup) {
                                    groupData.groupId = currentGroup.groupId;
                                }

                                console.log("💾 Сохранение группы:", JSON.stringify(groupData));
                                groupDialog.saved(groupData);
                            }
                        }
                    }
                }
            }
        }
    }

    onOpened: {
        nameField.forceActiveFocus();
        errorText.text = "";
    }

    onClosed: {
        // Сбрасываем состояние при закрытии
        isLoading = false;
    }

    // Обработчики клавиш
    Keys.onEscapePressed: {
        groupDialog.cancelled();
        groupDialog.close();
    }

    Keys.onReturnPressed: {
        if (validateForm()) {
            var selectedTeacher = teachers[teacherCombo.currentIndex];
            if (selectedTeacher) {
                var groupData = {
                    name: nameField.text.trim(),
                    student_count: parseInt(studentCountField.text) || 0,
                    teacher_id: selectedTeacher.teacherId
                };

                if (isEditMode && currentGroup) {
                    groupData.groupId = currentGroup.groupId;
                }

                groupDialog.saved(groupData);
            }
        }
    }
}
