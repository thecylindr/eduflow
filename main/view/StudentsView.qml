// main/view/StudentsView.qml
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "../../enhanced" as Enhanced

Item {
    id: studentsView

    property var groups: []
    property bool isLoading: false

    function refreshStudents() {
        isLoading = true;
        mainWindow.mainApi.getStudents(function(response) {
            isLoading = false;
            if (response.success) {
                mainWindow.students = response.data || [];
                console.log("✅ Студенты загружены:", mainWindow.students.length);
            } else {
                showMessage("❌ Ошибка загрузки студентов: " + response.error, "error");
            }
        });
    }

    function refreshGroups() {
        mainWindow.mainApi.getGroups(function(response) {
            if (response.success) {
                studentsView.groups = response.data || [];
                if (studentFormWindow.item) {
                    studentFormWindow.item.groups = studentsView.groups;
                }
                console.log("✅ Группы загружены:", studentsView.groups.length);
            } else {
                showMessage("❌ Ошибка загрузки групп: " + response.error, "error");
            }
        });
    }

    function showMessage(text, type) {
        mainWindow.showMessage(text, type);
    }

    function addStudent(studentData) {
        isLoading = true;
        mainWindow.mainApi.sendRequest("POST", "/students", studentData, function(response) {
            isLoading = false;
            if (response.success) {
                showMessage("✅ Студент успешно добавлен", "success");
                studentFormWindow.close();
                refreshStudents();
            } else {
                showMessage("❌ Ошибка добавления студента: " + response.error, "error");
            }
        });
    }

    function updateStudent(studentData) {
        isLoading = true;
        var url = "/students/" + studentData.studentCode;
        mainWindow.mainApi.sendRequest("PUT", url, studentData, function(response) {
            isLoading = false;
            if (response.success) {
                showMessage("✅ Данные студента обновлены", "success");
                studentFormWindow.close();
                refreshStudents();
            } else {
                showMessage("❌ Ошибка обновления студента: " + response.error, "error");
            }
        });
    }

    function deleteStudent(studentCode, studentName) {
        if (confirm("Вы уверены, что хотите удалить студента:\n" + studentName + "?")) {
            isLoading = true;
            mainWindow.mainApi.sendRequest("DELETE", "/students/" + studentCode, null, function(response) {
                isLoading = false;
                if (response.success) {
                    showMessage("✅ Студент успешно удален", "success");
                    refreshStudents();
                } else {
                    showMessage("❌ Ошибка удаления студента: " + response.error, "error");
                }
            });
        }
    }

    function getGroupName(groupId) {
        for (var i = 0; i < groups.length; i++) {
            if (groups[i].group_id === groupId) {
                return groups[i].name;
            }
        }
        return "";
    }

    Component.onCompleted: {
        refreshStudents();
        refreshGroups();
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
                    text: "Всего студентов: " + mainWindow.students.length
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
            sourceModel: mainWindow.students
            itemType: "student"
            searchPlaceholder: "Поиск студентов..."
            sortOptions: ["По ФИО", "По группе", "По email", "По телефону"]
            sortRoles: ["last_name", "group_id", "email", "phone_number"]

            onItemEditRequested: studentFormWindow.openForEdit(itemData)
            onItemDeleteRequested: {
                var studentName = (itemData.last_name || "") + " " + (itemData.first_name || "");
                var studentCode = itemData.student_code;
                deleteStudent(studentCode, studentName);
            }

            listDelegate: Component {
                Enhanced.ListDelegate {
                    itemType: "student"

                    function getSubtitleText(data) {
                        var group = studentsView.getGroupName(data.group_id);
                        var passport = (data.passport_series || "") + " " + (data.passport_number || "");
                        var contact = data.email ? data.email : (data.phone_number || "Нет контактов");
                        return "Группа: " + group + " · " + contact;
                    }
                }
            }

            gridDelegate: Component {
                Enhanced.GridDelegate {
                    itemType: "student"

                    function getSubtitleText(data) {
                        var group = studentsView.getGroupName(data.group_id);
                        return "Группа: " + group;
                    }
                }
            }
        }
    }

    Loader {
        id: studentFormWindow
        source: "StudentFormWindow.qml"

        onLoaded: {
            item.groups = studentsView.groups;
            item.saved.connect(function(studentData) {
                if (studentData.studentCode) {
                    updateStudent(studentData);
                } else {
                    addStudent(studentData);
                }
            });
            item.cancelled.connect(function() {
                item.close();
            });
        }

        function openForAdd() {
            if (studentFormWindow.item) {
                studentFormWindow.item.openForAdd();
            }
        }

        function openForEdit(studentData) {
            if (studentFormWindow.item) {
                studentFormWindow.item.openForEdit(studentData);
            }
        }

        function close() {
            if (studentFormWindow.item) {
                studentFormWindow.item.close();
            }
        }
    }
}
