// main/TeachersView.qml
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

Item {
    id: teachersView

    property bool isLoading: false

    function refreshTeachers() {
        isLoading = true;
        mainWindow.mainApi.getTeachers(function(response) {
            isLoading = false;
            if (response.success) {
                mainWindow.teachers = response.data || [];
                console.log("✅ Преподаватели загружены:", mainWindow.teachers.length);
            } else {
                showMessage("❌ Ошибка загрузки преподавателей: " + response.error, "error");
            }
        });
    }

    function showMessage(text, type) {
        mainWindow.showMessage(text, type);
    }

    function addTeacher(teacherData) {
        if (teacherDialogLoader.item) {
            teacherDialogLoader.item.isLoading = true;
        }

        // ИСПРАВЛЕНИЕ: убираем teacherId из данных для добавления
        var dataToSend = {
            "last_name": teacherData.last_name,
            "first_name": teacherData.first_name,
            "middle_name": teacherData.middle_name,
            "email": teacherData.email,
            "phone_number": teacherData.phone_number,
            "experience": teacherData.experience,
            "specialization": teacherData.specialization
        };

        console.log("📤 Отправка данных добавления:", JSON.stringify(dataToSend));

        mainWindow.mainApi.sendRequest("POST", "/teachers", dataToSend, function(response) {
            if (teacherDialogLoader.item) {
                teacherDialogLoader.item.isLoading = false;
            }

            if (response.success) {
                showMessage("✅ Преподаватель успешно добавлен", "success");
                teacherDialogLoader.close();
                refreshTeachers();
            } else {
                showMessage("❌ Ошибка добавления преподавателя: " + response.error, "error");
            }
        });
    }

    function updateTeacher(teacherData) {
        if (teacherDialogLoader.item) {
            teacherDialogLoader.item.isLoading = true;
        }

        // ИСПРАВЛЕНИЕ: убираем teacherId из данных для обновления
        var dataToSend = {
            "last_name": teacherData.last_name,
            "first_name": teacherData.first_name,
            "middle_name": teacherData.middle_name,
            "email": teacherData.email,
            "phone_number": teacherData.phone_number,
            "experience": teacherData.experience,
            "specialization": teacherData.specialization
        };

        var url = "/teachers/" + teacherData.teacherId;
        console.log("📤 Отправка данных обновления:", JSON.stringify(dataToSend));

        mainWindow.mainApi.sendRequest("PUT", url, dataToSend, function(response) {
            if (teacherDialogLoader.item) {
                teacherDialogLoader.item.isLoading = false;
            }

            if (response.success) {
                showMessage("✅ Данные преподавателя обновлены", "success");
                teacherDialogLoader.close();
                refreshTeachers();
            } else {
                showMessage("❌ Ошибка обновления преподавателя: " + response.error, "error");
            }
        });
    }

    function deleteTeacher(teacherId, teacherName) {
        if (confirm("Вы уверены, что хотите удалить преподавателя:\n" + teacherName + "?")) {
            isLoading = true;
            mainWindow.mainApi.sendRequest("DELETE", "/teachers/" + teacherId, null, function(response) {
                isLoading = false;
                if (response.success) {
                    showMessage("✅ Преподаватель успешно удален", "success");
                    refreshTeachers();
                } else {
                    showMessage("❌ Ошибка удаления преподавателя: " + response.error, "error");
                }
            });
        }
    }

    Component.onCompleted: {
        refreshTeachers();
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 15

        // Заголовок с полоской
        Column {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: "👨‍🏫 Управление преподавателями"
                font.pixelSize: 20
                font.bold: true
                color: "#2c3e50"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Rectangle {
                width: parent.width
                height: 1
                color: "#e0e0e0"
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        // Панель управления
        Rectangle {
            Layout.fillWidth: true
            height: 50
            radius: 10
            color: "#3498db"

            Row {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 15

                Text {
                    text: "Всего преподавателей: " + mainWindow.teachers.length
                    color: "white"
                    font.pixelSize: 14
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }

                Item { width: 20 }

                // Кнопка обновления
                Rectangle {
                    width: 100
                    height: 30
                    radius: 8
                    color: refreshMouseArea.containsMouse ? "#2980b9" : "#3498db"
                    border.color: "white"
                    border.width: 1
                    anchors.verticalCenter: parent.verticalCenter

                    Row {
                        anchors.centerIn: parent
                        spacing: 5

                        Text {
                            text: "🔄"
                            font.pixelSize: 12
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "Обновить"
                            color: "white"
                            font.pixelSize: 12
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: refreshMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: refreshTeachers()
                    }
                }

                Item { Layout.fillWidth: true }

                // Кнопка добавления
                Rectangle {
                    width: 180
                    height: 30
                    radius: 8
                    color: addMouseArea.containsMouse ? "#2980b9" : "#3498db"
                    border.color: "white"
                    border.width: 1
                    anchors.verticalCenter: parent.verticalCenter

                    Row {
                        anchors.centerIn: parent
                        spacing: 5

                        Text {
                            text: "➕"
                            font.pixelSize: 12
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "Добавить преподавателя"
                            color: "white"
                            font.pixelSize: 12
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: addMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: teacherDialogLoader.openForAdd()
                    }
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

        // Список преподавателей
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: mainWindow.teachers
            spacing: 5
            clip: true

            delegate: Rectangle {
                width: ListView.view.width
                height: 70
                radius: 10
                color: index % 2 === 0 ? "#f8f9fa" : "#ffffff"
                border.color: "#e9ecef"
                border.width: 1

                Row {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 15

                    Rectangle {
                        width: 50
                        height: 50
                        radius: 25
                        color: "#3498db"
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: "👨‍🏫"
                            font.pixelSize: 20
                            anchors.centerIn: parent
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        width: parent.width - 200

                        Text {
                            text: (modelData.lastName || "") + " " + (modelData.firstName || "") + " " + (modelData.middleName || "")
                            font.pixelSize: 14
                            font.bold: true
                            color: "#2c3e50"
                            elide: Text.ElideRight
                        }

                        Text {
                            text: "Опыт: " + (modelData.experience || "0") + " лет | " + (modelData.specialization || "")
                            font.pixelSize: 11
                            color: "#7f8c8d"
                        }

                        Text {
                            text: modelData.email || "Нет email"
                            font.pixelSize: 11
                            color: "#7f8c8d"
                        }
                    }

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 5

                        // Кнопка редактирования
                        Rectangle {
                            width: 30
                            height: 30
                            radius: 8
                            color: editMouseArea.containsMouse ? "#2980b9" : "#3498db"

                            Text {
                                anchors.centerIn: parent
                                text: "✏️"
                                font.pixelSize: 12
                            }

                            MouseArea {
                                id: editMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    teacherDialogLoader.openForEdit(modelData);
                                }
                            }
                        }

                        // Кнопка удаления
                        Rectangle {
                            width: 30
                            height: 30
                            radius: 8
                            color: deleteMouseArea.containsMouse ? "#c0392b" : "#e74c3c"

                            Text {
                                anchors.centerIn: parent
                                text: "🗑️"
                                font.pixelSize: 12
                            }

                            MouseArea {
                                id: deleteMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    var teacherName = (modelData.lastName || "") + " " + (modelData.firstName || "");
                                    deleteTeacher(modelData.teacherId, teacherName);
                                }
                            }
                        }
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                text: "Нет данных о преподавателях"
                color: "#7f8c8d"
                font.pixelSize: 14
                visible: mainWindow.teachers.length === 0 && !isLoading
            }
        }
    }

    // Диалог преподавателя
    Loader {
        id: teacherDialogLoader
        source: "TeachersDialog.qml"

        onLoaded: {
            item.saved.connect(function(teacherData) {
                console.log("💾 Получены данные преподавателя:", JSON.stringify(teacherData));
                if (teacherData.teacherId) {
                    updateTeacher(teacherData);
                } else {
                    addTeacher(teacherData);
                }
            });
            item.cancelled.connect(function() {
                item.close();
            });
        }

        function openForAdd() {
            if (teacherDialogLoader.item) {
                teacherDialogLoader.item.openForAdd();
            }
        }

        function openForEdit(teacherData) {
            if (teacherDialogLoader.item) {
                teacherDialogLoader.item.openForEdit(teacherData);
            }
        }

        function close() {
            if (teacherDialogLoader.item) {
                teacherDialogLoader.item.close();
            }
        }
    }
}
