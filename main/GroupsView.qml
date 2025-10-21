import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "../enhanced" as Enhanced

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
                // Логируем первую группу для отладки
                if (mainWindow.groups.length > 0) {
                    console.log("📋 Пример данных группы:", JSON.stringify(mainWindow.groups[0]));
                }
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

                if (groupFormWindow.item) {
                    groupFormWindow.item.teachers = groupsView.teachers;
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
        if (groupFormWindow.item) {
            groupFormWindow.item.isLoading = true;
        }

        var apiData = {
            "name": groupData.name,
            "student_count": parseInt(groupData.student_count) || 0,
            "teacher_id": groupData.teacher_id,
            "description": groupData.description || ""
        };

        mainWindow.mainApi.sendRequest("POST", "/groups", apiData, function(response) {
            if (groupFormWindow.item) {
                groupFormWindow.item.isLoading = false;
            }

            if (response.success) {
                showMessage("✅ Группа успешно добавлена", "success");
                groupFormWindow.close();
                refreshGroups();
            } else {
                showMessage("❌ Ошибка добавления группы: " + response.error, "error");
            }
        });
    }

    function updateGroup(groupData) {
        if (groupFormWindow.item) {
            groupFormWindow.item.isLoading = true;
        }

        var apiData = {
            "name": groupData.name,
            "student_count": parseInt(groupData.student_count) || 0,
            "teacher_id": groupData.teacher_id,
            "description": groupData.description || ""
        };

        var url = "/groups/" + groupData.groupId;
        mainWindow.mainApi.sendRequest("PUT", url, apiData, function(response) {
            if (groupFormWindow.item) {
                groupFormWindow.item.isLoading = false;
            }

            if (response.success) {
                showMessage("✅ Данные группы обновлены", "success");
                groupFormWindow.close();
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
            if (teachers[i].teacher_id === teacherId) {
                return teachers[i].last_name + " " + teachers[i].first_name +
                       (teachers[i].middle_name ? " " + teachers[i].middle_name : "");
            }
        }
        return "Не назначен";
    }

    Component.onCompleted: {
        refreshGroups();
        refreshTeachers();
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 15

        // Заголовок
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
                        onClicked: groupFormWindow.openForAdd()
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

        // Таблица групп
        Enhanced.EnhancedTableView {
            id: groupsTable
            Layout.fillWidth: true
            Layout.fillHeight: true
            sourceModel: mainWindow.groups
            searchPlaceholder: "Поиск групп..."
            sortOptions: ["По названию", "По количеству студентов", "По куратору"]
            sortRoles: ["name", "student_count", "teacher_id"]
            itemType: "group"

            onItemEditRequested: groupFormWindow.openForEdit(itemData)
            onItemDeleteRequested: {
                var groupId = itemData.group_id;
                deleteGroup(groupId, itemData.name);
            }

            // Делегат для режима списка
            listDelegate: Component {
                Row {
                    id: listDelegateRow
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
                            text: itemData.name || "Без названия"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#2c3e50"
                            elide: Text.ElideRight
                        }

                        Text {
                            text: "Студентов: " + (itemData.student_count || "0")
                            font.pixelSize: 11
                            color: "#7f8c8d"
                        }

                        Text {
                            text: "Классный руководитель: " + getTeacherName(itemData.teacher_id)
                            font.pixelSize: 11
                            color: "#7f8c8d"
                            font.bold: true
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
                                onClicked: listDelegateRow.editRequested(itemData)
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
                                onClicked: listDelegateRow.deleteRequested(itemData)
                            }
                        }
                    }

                    signal editRequested(var itemData)
                    signal deleteRequested(var itemData)
                }
            }

            // Делегат для режима плиток
            gridDelegate: Component {
                Column {
                    id: gridDelegateColumn
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 4

                    Rectangle {
                        width: 35
                        height: 35
                        radius: 18
                        color: "#e74c3c"
                        anchors.horizontalCenter: parent.horizontalCenter

                        Text {
                            text: "👥"
                            font.pixelSize: 14
                            anchors.centerIn: parent
                        }
                    }

                    Text {
                        text: itemData.name || "Без названия"
                        font.pixelSize: 11
                        font.bold: true
                        color: "#2c3e50"
                        anchors.horizontalCenter: parent.horizontalCenter
                        elide: Text.ElideRight
                        width: parent.width - 10
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        text: "Студентов: " + (itemData.student_count || "0")
                        font.pixelSize: 9
                        color: "#7f8c8d"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: getTeacherName(itemData.teacher_id)
                        font.pixelSize: 9
                        color: "#e74c3c"
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                        elide: Text.ElideRight
                        width: parent.width - 10
                        horizontalAlignment: Text.AlignHCenter
                        maximumLineCount: 2
                        wrapMode: Text.WordWrap
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 4

                        Rectangle {
                            width: 22
                            height: 22
                            radius: 4
                            color: tileEditMouseArea.containsMouse ? "#3498db" : "#2980b9"

                            Text {
                                anchors.centerIn: parent
                                text: "✏️"
                                font.pixelSize: 9
                            }

                            MouseArea {
                                id: tileEditMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: gridDelegateColumn.editRequested(itemData)
                            }
                        }

                        Rectangle {
                            width: 22
                            height: 22
                            radius: 4
                            color: tileDeleteMouseArea.containsMouse ? "#e74c3c" : "#c0392b"

                            Text {
                                anchors.centerIn: parent
                                text: "🗑️"
                                font.pixelSize: 9
                            }

                            MouseArea {
                                id: tileDeleteMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: gridDelegateColumn.deleteRequested(itemData)
                            }
                        }
                    }

                    signal editRequested(var itemData)
                    signal deleteRequested(var itemData)
                }
            }
        }
    }

    // Окно формы группы
    Loader {
        id: groupFormWindow
        source: "GroupFormWindow.qml"

        onLoaded: {
            item.teachers = groupsView.teachers;
            item.saved.connect(function(groupData) {
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
            if (groupFormWindow.item) {
                groupFormWindow.item.teachers = groupsView.teachers;
                groupFormWindow.item.openForAdd();
            }
        }

        function openForEdit(groupData) {
            if (groupFormWindow.item) {
                groupFormWindow.item.teachers = groupsView.teachers;
                groupFormWindow.item.openForEdit(groupData);
            }
        }

        function close() {
            if (groupFormWindow.item) {
                groupFormWindow.item.close();
            }
        }
    }

    function confirm(message) {
        return true;
    }
}
