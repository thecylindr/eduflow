// main/view/StudentsView.qml
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "../../enhanced" as Enhanced

Item {
    id: studentsView

    property var students: []
    property var groups: []
    property bool isLoading: false

    function refreshStudents() {
        console.log("🔄 Загрузка студентов...");
        isLoading = true;
        mainWindow.mainApi.getStudents(function(response) {
            isLoading = false;
            if (response.success) {
                console.log("✅ Данные студентов получены:", JSON.stringify(response.data));

                var studentsData = response.data || [];
                var processedStudents = [];

                for (var i = 0; i < studentsData.length; i++) {
                    var student = studentsData[i];
                    var processedStudent = {
                        studentCode: student.studentCode || student.student_code,
                        // Исправлено: используем единообразные названия полей
                        first_name: student.firstName || student.first_name || "",
                        last_name: student.lastName || student.last_name || "",
                        middle_name: student.middleName || student.middle_name || "",
                        email: student.email || "",
                        phone_number: student.phoneNumber || student.phone_number || "",
                        group_id: student.groupId || student.group_id || 0,
                        passportSeries: student.passportSeries || student.passport_series || "",
                        passportNumber: student.passportNumber || student.passport_number || "",
                        group_name: getGroupName(student.groupId || student.group_id)  // Добавлено название группы
                    };
                    processedStudents.push(processedStudent);
                }

                students = processedStudents;
                console.log("✅ Студенты обработаны:", students.length);
            } else {
                showMessage("❌ Ошибка загрузки студентов: " + response.error, "error");
            }
        });
    }

    function refreshGroups() {
        console.log("👥 Загрузка групп для студентов...");
        mainWindow.mainApi.getGroups(function(response) {
            if (response.success) {
                groups = response.data || [];
                console.log("✅ Группы загружены для студентов:", groups.length);
                refreshStudents();
            } else {
                showMessage("❌ Ошибка загрузки групп: " + response.error, "error");
            }
        });
    }

    function showMessage(text, type) {
        mainWindow.showMessage(text, type);
    }

    function getGroupName(groupId) {
        if (!groupId || groupId === 0) {
            return "Не указана";
        }

        for (var i = 0; i < groups.length; i++) {
            var group = groups[i];
            var currentGroupId = group.groupId || group.group_id;

            if (currentGroupId === groupId) {
                return group.name || "Без названия";
            }
        }
        return "Не найдена";
    }

    // Функции для работы со студентами через MainAPI
    function addStudent(studentData) {
        isLoading = true;
        mainWindow.mainApi.addStudent(studentData, function(response) {
            isLoading = false;
            if (response.success) {
                showMessage("✅ " + response.message, "success");
                studentFormWindow.closeForm();
                refreshStudents();
            } else {
                showMessage("❌ Ошибка добавления студента: " + response.error, "error");
                if (studentFormWindow.item) {
                    studentFormWindow.item.isSaving = false;
                }
            }
        });
    }

    function updateStudent(studentData) {
        isLoading = true;
        var studentCode = studentData.student_code || studentData.studentCode;

        if (!studentCode) {
            showMessage("❌ Ошибка: ID студента не найден", "error");
            isLoading = false;
            if (studentFormWindow.item) {
                studentFormWindow.item.isSaving = false;
            }
            return;
        }

        mainWindow.mainApi.updateStudent(studentCode, studentData, function(response) {
            isLoading = false;
            if (response.success) {
                showMessage("✅ " + response.message, "success");
                studentFormWindow.closeForm();
                refreshStudents();
            } else {
                showMessage("❌ Ошибка обновления студента: " + response.error, "error");
                if (studentFormWindow.item) {
                    studentFormWindow.item.isSaving = false;
                }
            }
        });
    }

    function deleteStudent(studentCode, studentName) {
        if (confirm("Вы уверены, что хотите удалить студента:\n" + studentName + "?")) {
            isLoading = true;
            mainWindow.mainApi.deleteStudent(studentCode, function(response) {
                isLoading = false;
                if (response.success) {
                    showMessage("✅ " + response.message, "success");
                    refreshStudents();
                } else {
                    showMessage("❌ Ошибка удаления студента: " + response.error, "error");
                }
            });
        }
    }

    function confirm(message) {
        console.log("❓ Подтверждение:", message);
        return true;
    }

    Component.onCompleted: {
        console.log("🎯 StudentsView создан");
        refreshGroups();
    }

    onStudentsChanged: {
        console.log("🔄 StudentsView: students изменен, длина:", students.length);
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 15

        Column {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: "👨‍🎓 Управление студентами"
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
            color: "#2ecc71"
            border.color: "#27ae60"
            border.width: 1

            Row {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 15

                Text {
                    text: "Всего студентов: " + students.length
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
                    color: refreshMouseArea.containsMouse ? "#27ae60" : "#2ecc71"
                    border.color: refreshMouseArea.containsMouse ? "#219652" : "white"
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
                        onClicked: refreshStudents()
                    }
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    width: 150
                    height: 30
                    radius: 6
                    color: addMouseArea.containsMouse ? "#27ae60" : "#2ecc71"
                    border.color: addMouseArea.containsMouse ? "#219652" : "white"
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
                            text: "Добавить студента"
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
                        onClicked: studentFormWindow.openForAdd()
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
            id: studentsTable
            Layout.fillWidth: true
            Layout.fillHeight: true
            sourceModel: studentsView.students
            itemType: "student"
            searchPlaceholder: "Поиск студентов..."
            sortOptions: ["По ФИО", "По группе", "По email", "По телефону"]
            sortRoles: ["full_name", "group_name", "email", "phone_number"]

            onItemEditRequested: function(itemData) {
                console.log("✏️ StudentsView: редактирование запрошено для", itemData);
                studentFormWindow.openForEdit(itemData);
            }

            onItemDeleteRequested: function(itemData) {
                var studentName = (itemData.last_name || "") + " " + (itemData.first_name || "");
                var studentCode = itemData.studentCode;
                console.log("🗑️ StudentsView: удаление запрошено для", studentName, "ID:", studentCode);
                deleteStudent(studentCode, studentName);
            }
        }
    }

    // Загрузчик формы студента
    Loader {
        id: studentFormWindow
        source: "../forms/StudentFormWindow.qml"
        active: true

        onLoaded: {
            console.log("✅ StudentFormWindow загружен");

            item.saved.connect(function(studentData) {
                console.log("💾 Сохранение студента:", JSON.stringify(studentData));

                if (studentData.student_code && studentData.student_code !== "") {
                    updateStudent(studentData);
                } else {
                    addStudent(studentData);
                }
            });

            item.cancelled.connect(function() {
                console.log("❌ Отмена редактирования студента");
                closeForm();
            });
        }

        function openForAdd() {
            if (studentFormWindow.item) {
                studentFormWindow.item.groups = studentsView.groups;
                studentFormWindow.item.openForAdd();
            }
        }

        function openForEdit(studentData) {
            if (studentFormWindow.item) {
                studentFormWindow.item.groups = studentsView.groups;
                studentFormWindow.item.openForEdit(studentData);
            }
        }

        function closeForm() {
            if (studentFormWindow.item) {
                studentFormWindow.item.closeWindow();
            }
        }
    }
}
