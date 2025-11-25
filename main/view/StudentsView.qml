import QtQuick
import QtQuick.Layouts 1.15
import QtQuick.Controls
import "../../enhanced" as Enhanced

Item {
    id: studentsView

    property var students: []
    property var groups: []
    property bool isLoading: false
    property bool isMobile: Qt.platform.os === "android" || Qt.platform.os === "ios" ||
                           Qt.platform.os === "tvos" || Qt.platform.os === "wasm"

    function refreshStudents() {
        isLoading = true;
        mainWindow.mainApi.getStudents(function(response) {
            isLoading = false;
            if (response.success) {

                var studentsData = response.data || [];
                var processedStudents = [];

                for (var i = 0; i < studentsData.length; i++) {
                    var student = studentsData[i];
                    var processedStudent = {
                        studentCode: student.studentCode || student.student_code,
                        first_name: student.firstName || student.first_name || "",
                        last_name: student.lastName || student.last_name || "",
                        middle_name: student.middleName || student.middle_name || "",
                        email: student.email || "",
                        phone_number: student.phoneNumber || student.phone_number || "",
                        group_id: student.groupId || student.group_id || 0,
                        passportSeries: student.passportSeries || student.passport_series || "",
                        passportNumber: student.passportNumber || student.passport_number || "",
                        group_name: getGroupName(student.groupId || student.group_id)
                    };
                    processedStudents.push(processedStudent);
                }

                students = processedStudents;
            } else {
                showMessage("Ошибка загрузки студентов: " + response.error, "error");
            }
        });
    }

    function refreshGroups() {
        mainWindow.mainApi.getGroups(function(response) {
            if (response.success) {
                groups = response.data || [];
                refreshStudents();
            } else {
                showMessage("Ошибка загрузки групп: " + response.error, "error");
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

    function addStudent(studentData) {
        isLoading = true;
        mainWindow.mainApi.addStudent(studentData, function(response) {
            isLoading = false;
            if (response.success) {
                showMessage("" + response.message, "success");
                studentFormWindow.closeForm();
                refreshStudents();
            } else {
                showMessage("Ошибка добавления студента: " + response.error, "error");
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
            showMessage("Ошибка: ID студента не найден", "error");
            isLoading = false;
            if (studentFormWindow.item) {
                studentFormWindow.item.isSaving = false;
            }
            return;
        }

        mainWindow.mainApi.updateStudent(studentCode, studentData, function(response) {
            isLoading = false;
            if (response.success) {
                showMessage("" + response.message, "success");
                studentFormWindow.closeForm();
                refreshStudents();
            } else {
                showMessage("Ошибка обновления студента: " + response.error, "error");
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
                    showMessage("" + response.message, "success");
                    refreshStudents();
                } else {
                    showMessage("Ошибка удаления студента: " + response.error, "error");
                }
            });
        }
    }

    function confirm(message) {
        console.log("Подтверждение:", message);
        return true;
    }

    Component.onCompleted: {
        refreshGroups();
    }

    onStudentsChanged: {
        console.log("StudentsView: students изменен, длина:", students.length);
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
                    source: "qrc:/icons/students.png"
                    sourceSize: Qt.size(24, 24)
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "Управление студентами"
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
            color: "#2ecc71"
            border.color: "#27ae60"
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
                    color: refreshMouseAreaMobile.containsPress ? "#27ae60" : "transparent"

                    Image {
                        source: "qrc:/icons/refresh.png"
                        sourceSize: Qt.size(28, 28)
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        id: refreshMouseAreaMobile
                        anchors.fill: parent
                        onClicked: refreshStudents()
                    }
                }

                // Текст счетчика для мобильных
                Text {
                    text: "Всего: " + students.length
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
                    color: addMouseAreaMobile.containsPress ? "#27ae60" : "transparent"

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
                        onClicked: studentFormWindow.openForAdd()
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
                    color: refreshMouseAreaDesktop.containsMouse ? "#27ae60" : "#2ecc71"
                    border.color: refreshMouseAreaDesktop.containsMouse ? "#219652" : "white"
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
                        onClicked: refreshStudents()
                    }
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    width: 150
                    height: 30
                    radius: 6
                    color: addMouseAreaDesktop.containsMouse ? "#27ae60" : "#2ecc71"
                    border.color: addMouseAreaDesktop.containsMouse ? "#219652" : "white"
                    border.width: 2

                    Row {
                        anchors.centerIn: parent
                        spacing: 5

                        Image {
                            source: "qrc:/icons/students.png"
                            sourceSize: Qt.size(12, 12)
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
                        id: addMouseAreaDesktop
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
            id: studentsTable
            Layout.fillWidth: true
            Layout.fillHeight: true
            sourceModel: studentsView.students
            itemType: "student"
            searchPlaceholder: "Поиск студентов..."
            sortOptions: ["По ФИО", "По группе", "По email", "По телефону"]
            sortRoles: ["full_name", "group_name", "email", "phone_number"]

            onItemEditRequested: function(itemData) {
                studentFormWindow.openForEdit(itemData);
            }

            onItemDoubleClicked: function(itemData) {
                studentFormWindow.openForEdit(itemData);
            }

            onItemDeleteRequested: function(itemData) {
                var studentName = (itemData.last_name || "") + " " + (itemData.first_name || "");
                var studentCode = itemData.studentCode;
                deleteStudent(studentCode, studentName);
            }
        }
    }

    // Загрузчик формы студента
    Loader {
        id: studentFormWindow
        source: isMobile ? "../forms/StudentFormMobile.qml" : "../forms/StudentFormWindow.qml"
        active: true

        onLoaded: {
            item.saved.connect(function(studentData) {
                if (studentData.student_code && studentData.student_code !== "") {
                    updateStudent(studentData);
                } else {
                    addStudent(studentData);
                }
            });

            item.cancelled.connect(function() {
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
