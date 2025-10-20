// main/GroupsView.qml
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

Item {
    id: groupsView

    property var teachers: []
    property bool isLoading: false

    function refreshGroups() {
        isLoading = true;
        mainWindow.mainApi.getGroups(function(response) {
            isLoading = false;
            if (response.success) {
                mainWindow.groups = response.data || [];
                console.log("✅ Группы загружены:", mainWindow.groups.length);
            } else {
                showMessage("❌ Ошибка загрузки групп: " + response.error, "error");
            }
        });
    }

    function refreshTeachers() {
        mainWindow.mainApi.getTeachers(function(response) {
            if (response.success) {
                groupsView.teachers = response.data || [];
                console.log("✅ Преподаватели загружены для групп:", groupsView.teachers.length);

                // Обновляем teachers в диалоге если он загружен
                if (groupDialogLoader.item) {
                    groupDialogLoader.item.teachers = groupsView.teachers;
                }
            } else {
                showMessage("❌ Ошибка загрузки преподавателей: " + response.error, "error");
            }
        });
    }

    function showMessage(text, type) {
        mainWindow.showMessage(text, type);
    }

    function addGroup(groupData) {
        if (groupDialogLoader.item) {
            groupDialogLoader.item.isLoading = true;
        }

        mainWindow.mainApi.sendRequest("POST", "/groups", groupData, function(response) {
            if (groupDialogLoader.item) {
                groupDialogLoader.item.isLoading = false;
            }

            if (response.success) {
                showMessage("✅ Группа успешно добавлена", "success");
                groupDialogLoader.close();
                refreshGroups();
            } else {
                showMessage("❌ Ошибка добавления группы: " + response.error, "error");
            }
        });
    }

    function updateGroup(groupData) {
        if (groupDialogLoader.item) {
            groupDialogLoader.item.isLoading = true;
        }

        var url = "/groups/" + groupData.groupId;
        mainWindow.mainApi.sendRequest("PUT", url, groupData, function(response) {
            if (groupDialogLoader.item) {
                groupDialogLoader.item.isLoading = false;
            }

            if (response.success) {
                showMessage("✅ Данные группы обновлены", "success");
                groupDialogLoader.close();
                refreshGroups();
            } else {
                showMessage("❌ Ошибка обновления группы: " + response.error, "error");
            }
        });
    }

    function deleteGroup(groupId, groupName) {
        if (confirm("Вы уверены, что хотите удалить группу:\n" + groupName + "?")) {
            isLoading = true;
            mainWindow.mainApi.sendRequest("DELETE", "/groups/" + groupId, null, function(response) {
                isLoading = false;
                if (response.success) {
                    showMessage("✅ Группа успешно удалена", "success");
                    refreshGroups();
                } else {
                    showMessage("❌ Ошибка удаления группы: " + response.error, "error");
                }
            });
        }
    }

    function getTeacherName(teacherId) {
        for (var i = 0; i < teachers.length; i++) {
            if (teachers[i].teacherId === teacherId) {
                return teachers[i].lastName + " " + teachers[i].firstName;
            }
        }
        return "";
    }

    Component.onCompleted: {
        refreshGroups();
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
                text: "👥 Управление группами"
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
            radius: 8
            color: "#e74c3c"

            Row {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 15

                Text {
                    text: "Всего групп: " + mainWindow.groups.length
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
                    radius: 6
                    color: refreshMouseArea.containsMouse ? "#c0392b" : "#e74c3c"
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
                        onClicked: refreshGroups()
                    }
                }

                Item { Layout.fillWidth: true }

                // Кнопка добавления
                Rectangle {
                    width: 150
                    height: 30
                    radius: 6
                    color: addMouseArea.containsMouse ? "#c0392b" : "#e74c3c"
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
                            text: "Добавить группу"
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
                        onClicked: groupDialogLoader.openForAdd()
                    }
                }
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

        // Список групп
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: mainWindow.groups
            spacing: 5
            clip: true

            delegate: Rectangle {
                width: ListView.view.width
                height: 70
                radius: 8
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
                        color: "#e74c3c"
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: "👥"
                            font.pixelSize: 20
                            anchors.centerIn: parent
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        width: parent.width - 200

                        Text {
                            text: modelData.name || "Без названия"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#2c3e50"
                            elide: Text.ElideRight
                        }

                        Text {
                            text: "Студентов: " + (modelData.studentCount || "0")
                            font.pixelSize: 11
                            color: "#7f8c8d"
                        }

                        Text {
                            text: "Куратор: " + (getTeacherName(modelData.teacherId) || "Не назначен")
                            font.pixelSize: 11
                            color: "#7f8c8d"
                        }
                    }

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 5

                        Rectangle {
                            width: 30
                            height: 30
                            radius: 6
                            color: editMouseArea.containsMouse ? "#3498db" : "#2980b9"

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
                                    groupDialogLoader.openForEdit(modelData);
                                }
                            }
                        }

                        Rectangle {
                            width: 30
                            height: 30
                            radius: 6
                            color: deleteMouseArea.containsMouse ? "#e74c3c" : "#c0392b"

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
                                    deleteGroup(modelData.groupId, modelData.name);
                                }
                            }
                        }
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                text: "Нет данных о группах"
                color: "#7f8c8d"
                font.pixelSize: 14
                visible: mainWindow.groups.length === 0 && !isLoading
            }
        }
    }

    // Диалог группы - исправленный Loader
    Loader {
        id: groupDialogLoader
        source: "GroupsDialog.qml"

        onLoaded: {
            item.teachers = groupsView.teachers;
            item.saved.connect(function(groupData) {
                console.log("💾 Получены данные группы:", JSON.stringify(groupData));
                if (groupData.groupId) {
                    updateGroup(groupData);
                } else {
                    addGroup(groupData);
                }
            });
            item.cancelled.connect(function() {
                item.close();
            });
        }

        function openForAdd() {
            if (groupDialogLoader.item) {
                // Обновляем список преподавателей перед открытием
                groupDialogLoader.item.teachers = groupsView.teachers;
                groupDialogLoader.item.openForAdd();
            }
        }

        function openForEdit(groupData) {
            if (groupDialogLoader.item) {
                // Обновляем список преподавателей перед открытием
                groupDialogLoader.item.teachers = groupsView.teachers;
                groupDialogLoader.item.openForEdit(groupData);
            }
        }

        function close() {
            if (groupDialogLoader.item) {
                groupDialogLoader.item.close();
            }
        }
    }
}
