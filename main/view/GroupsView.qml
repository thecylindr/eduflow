// main/view/GroupsView.qml
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "../../enhanced" as Enhanced

Item {
    id: groupsView

    property var groups: []
    property var teachers: []
    property bool isLoading: false

    function refreshGroups() {
        console.log("🔄 Загрузка групп...");
        isLoading = true;
        mainWindow.mainApi.getGroups(function(response) {
            isLoading = false;
            if (response && response.success) {
                console.log("✅ Данные групп получены:", JSON.stringify(response.data));
                var groupsData = response.data || [];
                var processedGroups = [];

                for (var i = 0; i < groupsData.length; i++) {
                    var group = groupsData[i];
                    var processedGroup = {
                        groupId: group.groupId || group.group_id,
                        name: group.name || "",
                        teacherId: group.teacherId || group.teacher_id,
                        teacherName: getTeacherName(group.teacherId || group.teacher_id),
                        studentCount: group.studentCount || group.student_count || 0
                    };
                    processedGroups.push(processedGroup);
                }

                groupsView.groups = processedGroups;
                console.log("✅ Группы обработаны:", groupsView.groups.length);
            } else {
                var errorMsg = response && response.error ? response.error : "Неизвестная ошибка";
                showMessage("❌ Ошибка загрузки групп: " + errorMsg, "error");
            }
        });
    }

    function refreshTeachers() {
        console.log("👨‍🏫 Загрузка преподавателей для групп...");
        mainWindow.mainApi.getTeachers(function(response) {
            if (response && response.success) {
                groupsView.teachers = response.data || [];
                console.log("✅ Преподаватели загружены для групп:", groupsView.teachers.length);
                refreshGroups();
            } else {
                var errorMsg = response && response.error ? response.error : "Неизвестная ошибка";
                showMessage("❌ Ошибка загрузки преподавателей: " + errorMsg, "error");
            }
        });
    }

    function showMessage(text, type) {
        if (mainWindow && mainWindow.showMessage) {
            mainWindow.showMessage(text, type);
        }
    }

    function getTeacherName(teacherId) {
        if (!teacherId || teacherId === 0) {
            return "Не указан";
        }

        var teachersList = teachers || [];
        for (var i = 0; i < teachersList.length; i++) {
            var teacher = teachersList[i];
            var currentTeacherId = teacher.teacherId || teacher.teacher_id;

            if (currentTeacherId === teacherId) {
                var lastName = teacher.lastName || teacher.last_name || "";
                var firstName = teacher.firstName || teacher.first_name || "";
                var middleName = teacher.middleName || teacher.middle_name || "";
                return [lastName, firstName, middleName].filter(Boolean).join(" ") || "Неизвестный преподаватель";
            }
        }
        return "Неизвестный преподаватель";
    }

    // CRUD функции для групп
    function addGroup(groupData) {
        if (!groupData) {
            showMessage("❌ Данные группы не указаны", "error");
            return;
        }

        isLoading = true;
        console.log("➕ Добавление группы:", JSON.stringify(groupData));

        mainWindow.mainApi.addGroup(groupData, function(response) {
            isLoading = false;
            if (response && response.success) {
                showMessage("✅ " + ((response.message || response.data && response.data.message) || "Группа успешно добавлена"), "success");
                if (groupFormWindow.item) {
                    groupFormWindow.close();
                }
                refreshGroups();
            } else {
                var errorMsg = response && response.error ? response.error : "Неизвестная ошибка";
                showMessage("❌ Ошибка добавления группы: " + errorMsg, "error");
                if (groupFormWindow.item) {
                    groupFormWindow.item.isSaving = false;
                }
            }
        });
    }

    function updateGroup(groupData) {
        if (!groupData) {
            showMessage("❌ Данные группы не указаны", "error");
            return;
        }

        var groupId = groupData.group_id || groupData.groupId;
        if (!groupId) {
            showMessage("❌ ID группы не указан", "error");
            return;
        }

        isLoading = true;
        console.log("🔄 Обновление группы ID:", groupId, "Данные:", JSON.stringify(groupData));

        mainWindow.mainApi.updateGroup(groupId, groupData, function(response) {
            isLoading = false;
            if (response && response.success) {
                showMessage("✅ " + ((response.message || response.data && response.data.message) || "Группа успешно обновлена"), "success");
                if (groupFormWindow.item) {
                    groupFormWindow.close();
                }
                refreshGroups();
            } else {
                var errorMsg = response && response.error ? response.error : "Неизвестная ошибка";
                showMessage("❌ Ошибка обновления группы: " + errorMsg, "error");
                if (groupFormWindow.item) {
                    groupFormWindow.item.isSaving = false;
                }
            }
        });
    }

    function deleteGroup(groupId, groupName) {
        if (!groupId) {
            showMessage("❌ ID группы не указан", "error");
            return;
        }

        if (confirm("Вы уверены, что хотите удалить группу:\n" + (groupName || "Без названия") + "?")) {
            isLoading = true;
            mainWindow.mainApi.deleteGroup(groupId, function(response) {
                isLoading = false;
                if (response && response.success) {
                    showMessage("✅ " + ((response.message || response.data && response.data.message) || "Группа успешно удалена"), "success");
                    refreshGroups();
                } else {
                    var errorMsg = response && response.error ? response.error : "Неизвестная ошибка";
                    showMessage("❌ Ошибка удаления группы: " + errorMsg, "error");
                }
            });
        }
    }

    function confirm(message) {
        console.log("Подтверждение:", message);
        return true;
    }

    Component.onCompleted: {
        console.log("GroupsView: Component.onCompleted");
        refreshTeachers();
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 15

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

        Rectangle {
            Layout.fillWidth: true
            height: 50
            radius: 8
            color: "#e74c3c"
            border.color: "#c0392b"
            border.width: 1

            Row {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 15

                Text {
                    text: "Всего групп: " + (groups ? groups.length : 0)
                    color: "white"
                    font.pixelSize: 14
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }

                Item { width: 20 }

                Rectangle {
                    width: 100
                    height: 30
                    radius: 6
                    color: refreshMouseArea.containsMouse ? "#c0392b" : "#e74c3c"
                    border.color: refreshMouseArea.containsMouse ? "#a93226" : "white"
                    border.width: 2

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

                Rectangle {
                    width: 150
                    height: 30
                    radius: 6
                    color: addMouseArea.containsMouse ? "#c0392b" : "#e74c3c"
                    border.color: addMouseArea.containsMouse ? "#a93226" : "white"
                    border.width: 2

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
                        onClicked: {
                            if (groupFormWindow.item) {
                                groupFormWindow.openForAdd();
                            } else {
                                groupFormWindow.active = true;
                            }
                        }
                    }
                }
            }
        }

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

        Enhanced.EnhancedTableView {
            id: groupsTable
            Layout.fillWidth: true
            Layout.fillHeight: true
            sourceModel: groupsView.groups || []
            itemType: "group"
            searchPlaceholder: "Поиск групп..."
            sortOptions: ["По названию", "По преподавателю", "По количеству студентов"]
            sortRoles: ["name", "teacherName", "studentCount"]

            onItemEditRequested: function(itemData) {
                if (!itemData) return;
                console.log("✏️ GroupsView: редактирование запрошено для", itemData);
                if (groupFormWindow.item) {
                    groupFormWindow.openForEdit(itemData);
                } else {
                    groupFormWindow.active = true;
                }
            }

            onItemDeleteRequested: function(itemData) {
                if (!itemData) return;
                var groupId = itemData.groupId;
                var groupName = itemData.name || "Без названия";
                console.log("🗑️ GroupsView: удаление запрошено для", groupName, "ID:", groupId);
                deleteGroup(groupId, groupName);
            }
        }
    }

    // Загрузчик формы группы
    Loader {
        id: groupFormWindow
        source: "../forms/GroupFormWindow.qml"
        active: true

        onLoaded: {
            console.log("✅ GroupFormWindow загружен");

            if (item) {
                item.saved.connect(function(groupData) {
                    console.log("💾 Сохранение группы:", JSON.stringify(groupData));
                    if (!groupData) return;

                    if (groupData.group_id && groupData.group_id !== 0) {
                        updateGroup(groupData);
                    } else {
                        addGroup(groupData);
                    }
                });

                item.cancelled.connect(function() {
                    console.log("❌ Отмена редактирования группы");
                    if (item) {
                        item.closeWindow();
                    }
                });
            }
        }

        function openForAdd() {
            if (groupFormWindow.item) {
                groupFormWindow.item.teachers = groupsView.teachers || [];
                groupFormWindow.item.openForAdd();
            } else {
                groupFormWindow.active = true;
            }
        }

        function openForEdit(groupData) {
            if (groupFormWindow.item) {
                groupFormWindow.item.teachers = groupsView.teachers || [];
                groupFormWindow.item.openForEdit(groupData);
            } else {
                groupFormWindow.active = true;
            }
        }

        function close() {
            if (groupFormWindow.item) {
                groupFormWindow.item.closeWindow();
            }
        }
    }
}
