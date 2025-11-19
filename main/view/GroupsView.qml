import QtQuick
import QtQuick.Layouts 1.15
import QtQuick.Controls
import "../../enhanced" as Enhanced

Item {
    id: groupsView

    property var groups: []
    property var teachers: []
    property bool isLoading: false
    property bool isMobile: Qt.platform.os === "android" || Qt.platform.os === "ios" ||
                           Qt.platform.os === "tvos" || Qt.platform.os === "wasm"

    function refreshGroups() {
        isLoading = true;
        mainWindow.mainApi.getGroups(function(response) {
            isLoading = false;
            if (response && response.success) {
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
            } else {
                var errorMsg = response && response.error ? response.error : "Неизвестная ошибка";
                showMessage("❌ Ошибка загрузки групп: " + errorMsg, "error");
            }
        });
    }

    function refreshTeachers() {
        mainWindow.mainApi.getTeachers(function(response) {
            if (response && response.success) {
                groupsView.teachers = response.data || [];
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

        mainWindow.mainApi.addGroup(groupData, function(response) {
            isLoading = false;
            if (response && response.success) {
                showMessage("✅ " + ((response.message || response.data && response.data.message) || "Группа успешно добавлена"), "success");
                if (groupFormWindow.item) {
                    groupFormWindow.item.closeWindow();
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

        mainWindow.mainApi.updateGroup(groupId, groupData, function(response) {
            isLoading = false;
            if (response && response.success) {
                showMessage("✅ " + ((response.message || response.data && response.data.message) || "Группа успешно обновлена"), "success");
                if (groupFormWindow.item) {
                    groupFormWindow.item.closeWindow();
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
        return true;
    }

    Component.onCompleted: {
        refreshTeachers();
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 15

        Column {
            Layout.fillWidth: true
            spacing: 8

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10

                Image {
                    source: "qrc:/icons/groups.png"
                    sourceSize: Qt.size(24, 24)
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "Управление группами"
                    font.pixelSize: 20
                    font.bold: true
                    color: "#2c3e50"
                    anchors.verticalCenter: parent.verticalCenter
                }
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

            // Мобильная версия - центрированные большие кнопки
            Row {
                anchors.centerIn: parent
                spacing: isMobile ? 30 : 15
                visible: isMobile

                // Кнопка обновления для мобильных
                Rectangle {
                    width: 50
                    height: 50
                    radius: 25
                    color: refreshMouseAreaMobile.containsPress ? "#c0392b" : "transparent"

                    Image {
                        source: "qrc:/icons/refresh.png"
                        sourceSize: Qt.size(28, 28)
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        id: refreshMouseAreaMobile
                        anchors.fill: parent
                        onClicked: refreshGroups()
                    }
                }

                // Текст счетчика для мобильных
                Text {
                    text: "Всего: " + (groups ? groups.length : 0)
                    color: "white"
                    font.pixelSize: 16
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Кнопка добавления для мобильных
                Rectangle {
                    width: 50
                    height: 50
                    radius: 25
                    color: addMouseAreaMobile.containsPress ? "#c0392b" : "transparent"

                    Text {
                        text: "+"
                        color: "white"
                        font.pixelSize: 32
                        font.bold: true
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        id: addMouseAreaMobile
                        anchors.fill: parent
                        onClicked: openForAdd()
                    }
                }
            }

            // Десктопная версия - без изменений
            Row {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 15
                visible: !isMobile

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
                    color: refreshMouseAreaDesktop.containsMouse ? "#c0392b" : "#e74c3c"
                    border.color: refreshMouseAreaDesktop.containsMouse ? "#a93226" : "white"
                    border.width: 2

                    Row {
                        anchors.centerIn: parent
                        spacing: 5

                        Image {
                            source: "qrc:/icons/refresh.png"
                            sourceSize: Qt.size(20, 20)
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
                        id: refreshMouseAreaDesktop
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
                    color: addMouseAreaDesktop.containsMouse ? "#c0392b" : "#e74c3c"
                    border.color: addMouseAreaDesktop.containsMouse ? "#a93226" : "white"
                    border.width: 2

                    Row {
                        anchors.centerIn: parent
                        spacing: 5

                        Image {
                            source: "qrc:/icons/groups.png"
                            sourceSize: Qt.size(12, 12)
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
                        id: addMouseAreaDesktop
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: openForAdd()
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

                Image {
                    source: "qrc:/icons/loading.png"
                    sourceSize: Qt.size(14, 14)
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
                openForEdit(itemData);
            }

            onItemDeleteRequested: function(itemData) {
                if (!itemData) return;
                var groupId = itemData.groupId;
                var groupName = itemData.name || "Без названия";
                deleteGroup(groupId, groupName);
            }

            onItemDoubleClicked: function(itemData) {
                if (!itemData) return;
                console.log("👥 Двойной клик по группе:", itemData.name);
                openGroupView(itemData);
            }
        }
    }

    // Загрузчик формы группы
    Loader {
        id: groupFormWindow
        source: "../forms/GroupFormWindow.qml"
        active: true

        onLoaded: {
            if (item) {
                item.teachers = groupsView.teachers || [];

                item.saved.connect(function(groupData) {
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
    }

    // Загрузчик окна просмотра группы
    Loader {
        id: groupViewWindow
        source: "../forms/GroupViewFormWindow.qml"
        active: true

        onLoaded: {
            if (item) {
                item.closed.connect(function() {
                });
            }
        }
    }

    function openGroupView(groupData) {
        console.log("👥 Открытие окна просмотра группы:", groupData);

        if (groupViewWindow.status === Loader.Ready) {
            groupViewWindow.item.openForGroup(groupData);
        } else {
            groupViewWindow.active = true;
            groupViewWindow.loaded.connect(function() {
                groupViewWindow.item.openForGroup(groupData);
            });
        }
    }

    function openForAdd() {
        if (groupFormWindow.status === Loader.Ready) {
            groupFormWindow.item.teachers = groupsView.teachers || [];
            groupFormWindow.item.openForAdd();
        } else {
            groupFormWindow.active = true;
            groupFormWindow.loaded.connect(function() {
                groupFormWindow.item.teachers = groupsView.teachers || [];
                groupFormWindow.item.openForAdd();
            });
        }
    }

    function openForEdit(groupData) {
        if (groupFormWindow.status === Loader.Ready) {
            groupFormWindow.item.teachers = groupsView.teachers || [];
            groupFormWindow.item.openForEdit(groupData);
        } else {
            groupFormWindow.active = true;
            groupFormWindow.loaded.connect(function() {
                groupFormWindow.item.teachers = groupsView.teachers || [];
                groupFormWindow.item.openForEdit(groupData);
            });
        }
    }
}
