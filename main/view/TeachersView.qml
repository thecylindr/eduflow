import QtQuick
import QtQuick.Layouts 1.15
import QtQuick.Controls
import "../../enhanced" as Enhanced

Item {
    id: teachersView

    property var teachers: []
    property bool isLoading: false
    property bool isMobile: Qt.platform.os === "android" || Qt.platform.os === "ios" ||
                           Qt.platform.os === "tvos" || Qt.platform.os === "wasm"

    function refreshTeachers() {
        isLoading = true;
        mainWindow.mainApi.getTeachers(function(response) {
            isLoading = false;
            if (response.success) {

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

                    // Обрабатываем специализации из массива, если есть
                    if (teacher.specializations && teacher.specializations.length > 0) {
                        var specNames = [];
                        for (var j = 0; j < teacher.specializations.length; j++) {
                            if (teacher.specializations[j].name) {
                                specNames.push(teacher.specializations[j].name);
                            }
                        }
                        if (specNames.length > 0) {
                            processedTeacher.specialization = specNames.join(", ");
                        }
                    }

                    processedTeachers.push(processedTeacher);
                }

                teachers = processedTeachers;

                if (teachersTable) {
                    teachersTable.sourceModel = teachers;
                }
            } else {
                showMessage("Ошибка загрузки преподавателей: " + response.error, "error");
            }
        });
    }

    function showMessage(text, type) {
        mainWindow.showMessage(text, type);
    }

    // Функции для работы с преподавателями - ИСПРАВЛЕННЫЕ
    function addTeacher(teacherData) {
        isLoading = true;

        mainWindow.mainApi.addTeacher(teacherData, function(response) {
            isLoading = false;

            if (response.success) {
                showMessage("" + (response.message || "Преподаватель успешно добавлен"), "success");
                if (teacherFormWindow.item) {
                    teacherFormWindow.item.closeWindow();
                }
                refreshTeachers();
            } else {
                showMessage("Ошибка добавления преподавателя: " + (response.error || "Неизвестная ошибка"), "error");
                // Разблокируем форму в случае ошибки
                if (teacherFormWindow.item) {
                    teacherFormWindow.item.isSaving = false;
                }
            }
        });
    }

    function updateTeacher(teacherData) {
        isLoading = true;

        var teacherId = teacherData.teacher_id || teacherData.teacherId;

        if (!teacherId || teacherId === 0) {
            showMessage("Ошибка: ID преподавателя не найден", "error");
            isLoading = false;
            if (teacherFormWindow.item) {
                teacherFormWindow.item.isSaving = false;
            }
            return;
        }

        mainWindow.mainApi.updateTeacher(teacherId, teacherData, function(response) {
            isLoading = false;

            if (response.success) {
                showMessage((response.message || "Данные преподавателя обновлены"), "success");
                if (teacherFormWindow.item) {
                    teacherFormWindow.item.closeWindow();
                }
                refreshTeachers();
            } else {
                showMessage("Ошибка обновления преподавателя: " + (response.error || "Неизвестная ошибка"), "error");
                // Разблокируем форму в случае ошибки
                if (teacherFormWindow.item) {
                    teacherFormWindow.item.isSaving = false;
                }
            }
        });
    }

    function deleteTeacher(teacherId, teacherName) {
        if (confirm("Вы уверены, что хотите удалить преподавателя:\n" + teacherName + "?")) {
            isLoading = true;
            mainWindow.mainApi.sendRequest("DELETE", "/teachers/" + teacherId, null, function(response) {
                isLoading = false;
                if (response.success) {
                    showMessage("Преподаватель успешно удален", "success");
                    refreshTeachers();
                } else {
                    showMessage("Ошибка удаления преподавателя: " + response.error, "error");
                }
            });
        }
    }

    function openFormForAdd() {
            if (!teacherFormWindow.item) {
                teacherFormWindow.active = true;
                teacherFormWindow.onLoaded = function() {
                    teacherFormWindow.item.openForAdd();
                };
            } else {
                teacherFormWindow.item.openForAdd();
            }
        }

        function openFormForEdit(teacherData) {
            if (!teacherFormWindow.item) {
                teacherFormWindow.active = true;
                teacherFormWindow.onLoaded = function() {
                    teacherFormWindow.item.openForEdit(teacherData);
                };
            } else {
                teacherFormWindow.item.openForEdit(teacherData);
            }
        }

    Component.onCompleted: {
        refreshTeachers();
    }

    onTeachersChanged: {
        console.log("TeachersView: teachers изменен, длина:", teachers.length);
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
                    source: "qrc:/icons/teachers.png"
                    sourceSize: Qt.size(24, 24)
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "Управление преподавателями"
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
            color: "#3498db"
            border.color: "#2980b9"
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
                    color: refreshMouseAreaMobile.containsPress ? "#2980b9" : "transparent"

                    Image {
                        source: "qrc:/icons/refresh.png"
                        sourceSize: Qt.size(28, 28)
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        id: refreshMouseAreaMobile
                        anchors.fill: parent
                        onClicked: refreshTeachers()
                    }
                }

                // Текст счетчика для мобильных
                Text {
                    text: "Всего: " + teachers.length
                    color: "white"
                    font.pixelSize: 16
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Кнопка добавления для мобильных - увеличенная с плюсом
                Rectangle {
                    width: 50
                    height: 50
                    radius: 25
                    color: addMouseAreaMobile.containsPress ? "#2980b9" : "transparent"

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
                        onClicked: {
                            if (!teacherFormWindow.item) {
                                teacherFormWindow.active = true;
                                teacherFormWindow.onLoaded = function() {
                                    openFormForAdd();
                                };
                            } else {
                                openFormForAdd();
                            }
                        }
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
                    color: refreshMouseAreaDesktop.containsMouse ? "#2980b9" : "#3498db"
                    border.color: refreshMouseAreaDesktop.containsMouse ? "#1a5276" : "white"
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
                        onClicked: refreshTeachers()
                    }
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    width: 180
                    height: 30
                    radius: 6
                    color: addMouseAreaDesktop.containsMouse ? "#2980b9" : "#3498db"
                    border.color: addMouseAreaDesktop.containsMouse ? "#1a5276" : "white"
                    border.width: 2

                    Row {
                        anchors.centerIn: parent
                        spacing: 5

                        Image {
                            source: "qrc:/icons/teachers.png"
                            sourceSize: Qt.size(12, 12)
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
                        id: addMouseAreaDesktop
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (!teacherFormWindow.item) {
                                teacherFormWindow.active = true;
                                teacherFormWindow.onLoaded = function() {
                                    openFormForAdd();
                                };
                            } else {
                                openFormForAdd();
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
            id: teachersTable
            Layout.fillWidth: true
            Layout.fillHeight: true
            sourceModel: teachersView.teachers
            itemType: "teacher"
            searchPlaceholder: "Поиск преподавателей..."
            sortOptions: ["По ФИО", "По специализации", "По опыту", "По email"]
            sortRoles: ["lastName", "specialization", "experience", "email"]

            onItemEditRequested: function(itemData) {
                openFormForEdit(itemData);
            }

            onItemDoubleClicked: function(itemData) {
                if (teacherFormWindow.item) {
                    teacherFormWindow.openForEdit(itemData);
                } else {
                    teacherFormWindow.active = true;
                    teacherFormWindow.onLoaded = function() {
                        teacherFormWindow.item.openForEdit(itemData);
                    };
                }
            }

            onItemDeleteRequested: function(itemData) {
                var teacherName = (itemData.lastName || "") + " " + (itemData.firstName || "");
                var teacherId = itemData.teacherId;
                deleteTeacher(teacherId, teacherName);
            }
        }
    }

    // Загрузчик формы преподавателя - РАБОЧАЯ ВЕРСИЯ
    Loader {
        id: teacherFormWindow
        source: isMobile ? "../forms/TeacherFormMobile.qml" : "../forms/TeacherFormWindow.qml"
        active: true

        onLoaded: {
            item.saved.connect(function(teacherData) {
                var teacherId = teacherData.teacher_id || teacherData.teacherId;
                if (teacherId && teacherId !== 0) {
                    updateTeacher(teacherData)
                } else {
                    addTeacher(teacherData)
                }
            })

            item.cancelled.connect(function() {
                if (item) {
                    item.closeWindow();
                }
            })
        }

        function openForAdd() {
            if (item) {
                item.openForAdd()
            }
        }

        function openForEdit(teacherData) {
            if (item) {
                item.openForEdit(teacherData)
            }
        }
    }

    function confirm(message) {
        console.log("Подтверждение:", message);
        return true;
    }
}
