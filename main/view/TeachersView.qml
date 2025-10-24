// main/view/TeachersView.qml
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "../../enhanced" as Enhanced

Item {
    id: teachersView

    property var teachers: []
    property bool isLoading: false

    function refreshTeachers() {
        console.log("🔄 Загрузка преподавателей...");
        isLoading = true;
        mainWindow.mainApi.getTeachers(function(response) {
            isLoading = false;
            if (response.success) {
                console.log("✅ Данные преподавателей получены:", response.data);

                var teachersData = response.data || [];
                var processedTeachers = [];

                for (var i = 0; i < teachersData.length; i++) {
                    var teacher = teachersData[i];
                    var processedTeacher = {
                        teacherId: teacher.teacherId || teacher.teacher_id,
                        firstName: teacher.firstName || teacher.first_name || "",
                        lastName: teacher.lastName || teacher.last_name || "",
                        middleName: teacher.middleName || teacher.middle_name || "",
                        email: teacher.email || "",
                        phoneNumber: teacher.phoneNumber || teacher.phone_number || "",
                        experience: teacher.experience || 0,
                        specialization: teacher.specialization || ""
                    };
                    processedTeachers.push(processedTeacher);
                }

                teachers = processedTeachers;
                console.log("✅ Преподаватели обработаны:", teachers.length);

                if (teachersTable) {
                    teachersTable.sourceModel = teachers;
                }
            } else {
                showMessage("❌ Ошибка загрузки преподавателей: " + response.error, "error");
            }
        });
    }

    function showMessage(text, type) {
        mainWindow.showMessage(text, type);
    }

    Component.onCompleted: {
        console.log("🎯 TeachersView создан");
        refreshTeachers();
    }

    onTeachersChanged: {
        console.log("🔄 TeachersView: teachers изменен, длина:", teachers.length);
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 15

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

        Rectangle {
            Layout.fillWidth: true
            height: 50
            radius: 8
            color: "#3498db"
            border.color: "#2980b9"
            border.width: 1

            Row {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 15

                Text {
                    text: "Всего преподавателей: " + teachers.length
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
                    color: refreshMouseArea.containsMouse ? "#2980b9" : "#3498db"
                    border.color: refreshMouseArea.containsMouse ? "#1a5276" : "white"
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
                        onClicked: refreshTeachers()
                    }
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    width: 180
                    height: 30
                    radius: 6
                    color: addMouseArea.containsMouse ? "#2980b9" : "#3498db"
                    border.color: addMouseArea.containsMouse ? "#1a5276" : "white"
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
                        onClicked: {
                            console.log("➕ Добавить преподавателя");
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
            id: teachersTable
            Layout.fillWidth: true
            Layout.fillHeight: true
            sourceModel: teachersView.teachers
            itemType: "teacher"
            searchPlaceholder: "Поиск преподавателей..."
            sortOptions: ["По ФИО", "По специализации", "По опыту", "По email"]
            sortRoles: ["lastName", "specialization", "experience", "email"]

            onItemEditRequested: function(itemData) {
                console.log("✏️ TeachersView: редактирование запрошено для", itemData);
            }

            onItemDeleteRequested: function(itemData) {
                var teacherName = (itemData.lastName || "") + " " + (itemData.firstName || "");
                var teacherId = itemData.teacherId;
                console.log("🗑️ TeachersView: удаление запрошено для", teacherName, "ID:", teacherId);

                if (confirm("Вы уверены, что хотите удалить преподавателя:\n" + teacherName + "?")) {
                    console.log("✅ Подтверждено удаление преподавателя:", teacherId);
                }
            }
        }
    }

    function confirm(message) {
        console.log("❓ Подтверждение:", message);
        return true;
    }
}
