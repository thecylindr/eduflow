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
        isLoading = true;
        mainWindow.mainApi.getGroups(function(response) {
            isLoading = false;
            if (response.success) {
                console.log("📦 Сырые данные групп с сервера:", JSON.stringify(response.data));

                var groupsData = response.data || [];
                var processedGroups = [];

                for (var i = 0; i < groupsData.length; i++) {
                    var group = groupsData[i];
                    var processedGroup = {
                        groupId: group.groupId || group.group_id,
                        name: group.name || group.group_name || "Без названия",
                        studentCount: group.studentCount || group.student_count || 0,
                        teacherId: group.teacherId || group.teacher_id,
                        teacherName: getTeacherName(group.teacherId || group.teacher_id)
                    };
                    processedGroups.push(processedGroup);
                }

                groups = processedGroups;
                console.log("✅ Группы загружены и обработаны:", groups.length);
            } else {
                showMessage("❌ Ошибка загрузки групп: " + response.error, "error");
            }
        });
    }

    function refreshTeachers() {
        console.log("👨‍🏫 Загрузка преподавателей для групп...");
        mainWindow.mainApi.getTeachers(function(response) {
            if (response.success) {
                teachers = response.data || [];
                console.log("✅ Преподаватели загружены для групп:", teachers.length);
                refreshGroups();
            } else {
                showMessage("❌ Ошибка загрузки преподавателей: " + response.error, "error");
            }
        });
    }

    function showMessage(text, type) {
        mainWindow.showMessage(text, type);
    }

    function getTeacherName(teacherId) {
        if (!teacherId) {
            console.log("❌ teacherId не указан");
            return "Не назначен";
        }

        for (var i = 0; i < teachers.length; i++) {
            var teacher = teachers[i];
            var currentTeacherId = teacher.teacherId || teacher.teacher_id;

            if (currentTeacherId == teacherId) {
                var lastName = teacher.lastName || teacher.last_name || "";
                var firstName = teacher.firstName || teacher.first_name || "";
                var middleName = teacher.middleName || teacher.middle_name || "";
                return [lastName, firstName, middleName].filter(Boolean).join(" ") || "Неизвестный преподаватель";
            }
        }

        return "Не назначен";
    }

    Component.onCompleted: {
        console.log("GroupsView: Component.onCompleted");
        refreshTeachers();
    }

    onGroupsChanged: {
        console.log("🔄 GroupsView: groups изменен, длина:", groups.length);
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
                    text: "Всего групп: " + groups.length
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
                            console.log("Добавить группу");
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
            sourceModel: groupsView.groups
            itemType: "group"
            searchPlaceholder: "Поиск групп..."
            sortOptions: ["По названию", "По количеству студентов", "По куратору"]
            sortRoles: ["name", "studentCount", "teacherName"]

            onItemEditRequested: function(itemData) {
                console.log("Редактировать группу:", itemData);
            }

            onItemDeleteRequested: function(itemData) {
                var groupId = itemData.groupId;
                if (confirm("Вы уверены, что хотите удалить группу:\n" + (itemData.name || "Без названия") + "?")) {
                    console.log("Удалить группу:", groupId);
                }
            }
        }
    }

    function confirm(message) {
        return true;
    }
}
