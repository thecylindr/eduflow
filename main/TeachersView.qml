import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "../enhanced" as Enhanced

Item {
    id: teachersView

    // Свойства должны передаваться извне
    property var teachers: []
    property var mainApi
    property var showMessage: function(text, type) { console.log(text); }

    property bool isLoading: false
    property var specializations: []

    function refreshTeachers() {
        isLoading = true;
        if (mainApi && mainApi.getTeachers) {
            mainApi.getTeachers(function(response) {
                isLoading = false;
                if (response.success) {
                    teachers = response.data || [];
                    console.log("✅ Преподаватели загружены:", teachers.length);
                } else {
                    showMessage("❌ Ошибка загрузки преподавателей: " + response.error, "error");
                }
            });
        } else {
            isLoading = false;
            console.error("❌ mainApi не доступен");
        }
    }

    function loadSpecializations() {
        if (mainApi && mainApi.sendRequest) {
            mainApi.sendRequest("GET", "/specializations", null, function(response) {
                if (response.success) {
                    specializations = response.data || [];
                    console.log("✅ Специализации загружены:", specializations.length);

                    if (teacherFormWindow.item) {
                        teacherFormWindow.item.specializations = specializations;
                    }
                } else {
                    console.log("❌ Ошибка загрузки специализаций:", response.error);
                    specializations = [];
                }
            });
        }
    }

    function addTeacher(teacherData) {
        isLoading = true;

        var apiData = {
            "last_name": teacherData.last_name,
            "first_name": teacherData.first_name,
            "middle_name": teacherData.middle_name || "",
            "email": teacherData.email || "",
            "phone_number": teacherData.phone_number || "",
            "experience": parseInt(teacherData.experience) || 0,
            "specialization_id": teacherData.specialization_id
        };

        if (mainApi && mainApi.sendRequest) {
            mainApi.sendRequest("POST", "/teachers", apiData, function(response) {
                isLoading = false;

                if (response.success) {
                    showMessage("✅ Преподаватель успешно добавлен", "success");
                    teacherFormWindow.close();
                    refreshTeachers();
                } else {
                    showMessage("❌ Ошибка добавления преподавателя: " + response.error, "error");
                }
            });
        }
    }

    function updateTeacher(teacherData) {
        isLoading = true;

        var apiData = {
            "last_name": teacherData.last_name,
            "first_name": teacherData.first_name,
            "middle_name": teacherData.middle_name || "",
            "email": teacherData.email || "",
            "phone_number": teacherData.phone_number || "",
            "experience": parseInt(teacherData.experience) || 0,
            "specialization_id": teacherData.specialization_id
        };

        var url = "/teachers/" + teacherData.teacher_id;
        if (mainApi && mainApi.sendRequest) {
            mainApi.sendRequest("PUT", url, apiData, function(response) {
                isLoading = false;

                if (response.success) {
                    showMessage("✅ Данные преподавателя обновлены", "success");
                    teacherFormWindow.close();
                    refreshTeachers();
                } else {
                    showMessage("❌ Ошибка обновления преподавателя: " + response.error, "error");
                }
            });
        }
    }

    function deleteTeacher(teacherId, teacherName) {
        if (confirm("Вы уверены, что хотите удалить преподавателя:\n" + teacherName + "?")) {
            isLoading = true;
            if (mainApi && mainApi.sendRequest) {
                mainApi.sendRequest("DELETE", "/teachers/" + teacherId, null, function(response) {
                    isLoading = false;
                    if (response.success) {
                        showMessage("✅ Преподаватель успешно удален", "success");
                        refreshTeachers();
                    } else {
                        showMessage("❌ Ошибка удаления преподавателя: " + response.error, "error");
                    }
                });
            }
        }
    }

    function getSpecializationName(specializationId) {
        for (var i = 0; i < specializations.length; i++) {
            if (specializations[i].specialization_id === specializationId) {
                return specializations[i].name;
            }
        }
        return "Специализация #" + specializationId;
    }

    function confirm(message) {
        // В реальном приложении нужно показать диалог подтверждения
        console.log("Подтверждение:", message);
        return true;
    }

    Component.onCompleted: {
        refreshTeachers();
        loadSpecializations();
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 15

        // Заголовок
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

        // Панель управления
        Rectangle {
            Layout.fillWidth: true
            height: 50
            radius: 10
            color: "#3498db"

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

                // Кнопка обновления
                Rectangle {
                    width: 100
                    height: 30
                    radius: 8
                    color: refreshMouseArea.containsMouse ? "#2980b9" : "#3498db"
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
                        onClicked: refreshTeachers()
                    }
                }

                Item { Layout.fillWidth: true }

                // Кнопка добавления
                Rectangle {
                    width: 180
                    height: 30
                    radius: 8
                    color: addMouseArea.containsMouse ? "#2980b9" : "#3498db"
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
                        onClicked: teacherFormWindow.openForAdd()
                    }
                }
            }
        }

        // Индикатор загрузки
        Rectangle {
            Layout.fillWidth: true
            height: 30
            radius: 8
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

        // Таблица преподавателей
        Enhanced.EnhancedTableView {
            id: teachersTable
            Layout.fillWidth: true
            Layout.fillHeight: true
            sourceModel: teachers
            itemType: "teacher"
            searchPlaceholder: "Поиск преподавателей..."
            sortOptions: ["По ФИО", "По специализации", "По опыту", "По email"]
            sortRoles: ["last_name", "specialization_id", "experience", "email"]

            onItemEditRequested: teacherFormWindow.openForEdit(itemData)
            onItemDeleteRequested: {
                var teacherName = (itemData.last_name || "") + " " + (itemData.first_name || "");
                var teacherId = itemData.teacher_id;
                deleteTeacher(teacherId, teacherName);
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
                        color: "#3498db"
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: "👨‍🏫"
                            font.pixelSize: 20
                            anchors.centerIn: parent
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        width: parent.width - 200

                        Text {
                            text: (itemData.last_name || "") + " " +
                                  (itemData.first_name || "") + " " +
                                  (itemData.middle_name || "")
                            font.pixelSize: 14
                            font.bold: true
                            color: "#2c3e50"
                            elide: Text.ElideRight
                        }

                        Text {
                            text: "Опыт: " + (itemData.experience || "0") + " лет"
                            font.pixelSize: 11
                            color: "#7f8c8d"
                        }

                        Text {
                            text: "Специализация: " + getSpecializationName(itemData.specialization_id)
                            font.pixelSize: 11
                            color: "#7f8c8d"
                            font.bold: true
                        }

                        Text {
                            text: itemData.email || "Нет email"
                            font.pixelSize: 11
                            color: "#7f8c8d"
                        }
                    }

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 5

                        Rectangle {
                            width: 30
                            height: 30
                            radius: 8
                            color: editMouseArea.containsMouse ? "#2980b9" : "#3498db"

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
                            radius: 8
                            color: deleteMouseArea.containsMouse ? "#c0392b" : "#e74c3c"

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
                        color: "#3498db"
                        anchors.horizontalCenter: parent.horizontalCenter

                        Text {
                            text: "👨‍🏫"
                            font.pixelSize: 14
                            anchors.centerIn: parent
                        }
                    }

                    Text {
                        text: (itemData.last_name || "") + " " + (itemData.first_name || "")
                        font.pixelSize: 11
                        font.bold: true
                        color: "#2c3e50"
                        anchors.horizontalCenter: parent.horizontalCenter
                        elide: Text.ElideRight
                        width: parent.width - 10
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        text: (itemData.middle_name || "")
                        font.pixelSize: 9
                        color: "#7f8c8d"
                        anchors.horizontalCenter: parent.horizontalCenter
                        elide: Text.ElideRight
                        width: parent.width - 10
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        text: "Опыт: " + (itemData.experience || "0") + " лет"
                        font.pixelSize: 9
                        color: "#7f8c8d"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: getSpecializationName(itemData.specialization_id)
                        font.pixelSize: 9
                        color: "#3498db"
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
                            color: tileEditMouseArea.containsMouse ? "#2980b9" : "#3498db"

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
                            color: tileDeleteMouseArea.containsMouse ? "#c0392b" : "#e74c3c"

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

    // Окно формы преподавателя
    Loader {
        id: teacherFormWindow
        source: "TeacherFormWindow.qml"

        onLoaded: {
            item.specializations = teachersView.specializations;
            item.mainApi = teachersView.mainApi;
            item.showMessage = teachersView.showMessage;

            item.saved.connect(function(teacherData) {
                if (teacherData.teacher_id) {
                    updateTeacher(teacherData);
                } else {
                    addTeacher(teacherData);
                }
            });

            item.cancelled.connect(function() {
                item.close();
            });
        }

        function openForAdd() {
            if (teacherFormWindow.item) {
                teacherFormWindow.item.specializations = teachersView.specializations;
                teacherFormWindow.item.openForAdd();
            }
        }

        function openForEdit(teacherData) {
            if (teacherFormWindow.item) {
                teacherFormWindow.item.specializations = teachersView.specializations;
                teacherFormWindow.item.openForEdit(teacherData);
            }
        }

        function close() {
            if (teacherFormWindow.item) {
                teacherFormWindow.item.close();
            }
        }
    }
}
