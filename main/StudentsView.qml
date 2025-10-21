import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "../enhanced" as Enhanced

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

    Component.onCompleted: {
        refreshStudents();
        refreshGroups();
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 15

        // Заголовок с полоской
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

        // Панель управления
        Rectangle {
            Layout.fillWidth: true
            height: 50
            radius: 8
            color: "#2ecc71"

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

                // Кнопка обновления
                Rectangle {
                    width: 100
                    height: 30
                    radius: 6
                    color: refreshMouseArea.containsMouse ? "#27ae60" : "#2ecc71"
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
                        onClicked: refreshStudents()
                    }
                }

                Item { Layout.fillWidth: true }

                // Кнопка добавления
                Rectangle {
                    width: 150
                    height: 30
                    radius: 6
                    color: addMouseArea.containsMouse ? "#27ae60" : "#2ecc71"
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

        // Расширенная таблица студентов
        Enhanced.EnhancedTableView {
            id: studentsTable
            Layout.fillWidth: true
            Layout.fillHeight: true
            sourceModel: mainWindow.students
            searchPlaceholder: "Поиск студентов..."

            // Делегат для режима списка
            property Component listDelegate: Component {
                Row {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 15

                    // Аватар
                    Rectangle {
                        width: 50
                        height: 50
                        radius: 25
                        color: "#2ecc71"
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: "👨‍🎓"
                            font.pixelSize: 20
                            anchors.centerIn: parent
                        }
                    }

                    // Основная информация
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
                            text: "Группа: " + (getGroupName(modelData.groupId) || "Не назначена")
                            font.pixelSize: 11
                            color: "#7f8c8d"
                        }

                        Text {
                            text: "Паспорт: " + (modelData.passportSeries || "") + " " + (modelData.passportNumber || "")
                            font.pixelSize: 11
                            color: "#7f8c8d"
                        }
                    }

                    // Контакты
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2

                        Text {
                            text: modelData.email || "Нет email"
                            font.pixelSize: 11
                            color: "#7f8c8d"
                        }

                        Text {
                            text: modelData.phoneNumber || "Нет телефона"
                            font.pixelSize: 11
                            color: "#7f8c8d"
                        }
                    }

                    // Кнопки действий
                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 5

                        // Кнопка редактирования
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
                                onClicked: studentFormWindow.openForEdit(modelData)
                            }
                        }

                        // Кнопка удаления
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
                                    var studentName = (modelData.lastName || "") + " " + (modelData.firstName || "");
                                    deleteStudent(modelData.studentCode, studentName);
                                }
                            }
                        }
                    }
                }
            }

            // Делегат для режима плиток
            property Component gridDelegate: Component {
                Column {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 5

                    Rectangle {
                        width: 40
                        height: 40
                        radius: 20
                        color: "#2ecc71"
                        anchors.horizontalCenter: parent.horizontalCenter

                        Text {
                            text: "👨‍🎓"
                            font.pixelSize: 16
                            anchors.centerIn: parent
                        }
                    }

                    Text {
                        text: (modelData.lastName || "") + " " + (modelData.firstName || "")
                        font.pixelSize: 12
                        font.bold: true
                        color: "#2c3e50"
                        anchors.horizontalCenter: parent.horizontalCenter
                        elide: Text.ElideRight
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        text: (modelData.middleName || "")
                        font.pixelSize: 10
                        color: "#7f8c8d"
                        anchors.horizontalCenter: parent.horizontalCenter
                        elide: Text.ElideRight
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        text: "Группа: " + (getGroupName(modelData.groupId) || "Не назначена")
                        font.pixelSize: 9
                        color: "#7f8c8d"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 5

                        Rectangle {
                            width: 25
                            height: 25
                            radius: 5
                            color: tileEditMouseArea.containsMouse ? "#3498db" : "#2980b9"

                            Text {
                                anchors.centerIn: parent
                                text: "✏️"
                                font.pixelSize: 10
                            }

                            MouseArea {
                                id: tileEditMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: studentFormWindow.openForEdit(modelData)
                            }
                        }

                        Rectangle {
                            width: 25
                            height: 25
                            radius: 5
                            color: tileDeleteMouseArea.containsMouse ? "#e74c3c" : "#c0392b"

                            Text {
                                anchors.centerIn: parent
                                text: "🗑️"
                                font.pixelSize: 10
                            }

                            MouseArea {
                                id: tileDeleteMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    var studentName = (modelData.lastName || "") + " " + (modelData.firstName || "");
                                    deleteStudent(modelData.studentCode, studentName);
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function getGroupName(groupId) {
        for (var i = 0; i < groups.length; i++) {
            if (groups[i].groupId === groupId) {
                return groups[i].name;
            }
        }
        return "";
    }

    // Окно формы студента
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
