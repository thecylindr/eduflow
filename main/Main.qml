import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

ApplicationWindow {
    id: mainWindow
    width: 1200
    height: 800
    minimumWidth: 1000
    minimumHeight: 700
    visible: true
    title: "EduFlow - Управление базой данных"
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint

    property bool isWindowMaximized: false
    property bool isSideBarExpanded: true
    property string authToken: "test"
    property string apiBaseUrl: "http://deltablast.fun:5000"

    // Текущая активная вкладка
    property int currentTabIndex: 0

    // Модели данных
    ListModel { id: teachersModel }
    ListModel { id: groupsModel }
    ListModel { id: studentsModel }
    ListModel { id: portfolioModel }
    ListModel { id: eventsModel }

    // Главный контейнер
    Rectangle {
        id: windowContainer
        anchors.fill: parent
        radius: 24
        color: "#f0f0f0"
        clip: true

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#6a11cb" }
                GradientStop { position: 1.0; color: "#2575fc" }
            }
            radius: 20
        }

        // Анимированные многоугольники на фоне
        BackgroundShapes {
            id: backgroundPolygons
            anchors.fill: parent
        }

        // Заголовок
        Rectangle {
            id: titleBar
            height: 25
            color: "#ffffff"
            opacity: 1
            radius: 12
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 10
            }

            Text {
                anchors.centerIn: parent
                text: "🎓 EduFlow - Управление базой данных"
                color: "#2c3e50"
                font.pixelSize: 13
                font.bold: true
            }

            Row {
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    rightMargin: 8
                }
                spacing: 6

                Rectangle {
                    width: 16
                    height: 16
                    radius: 8
                    color: minimizeMouseArea.containsMouse ? "#FFD960" : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "-"
                        color: minimizeMouseArea.containsMouse ? "white" : "#2c3e50"
                        font.pixelSize: 12
                        font.bold: true
                    }

                    MouseArea {
                        id: minimizeMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: mainWindow.showMinimized()
                    }
                }

                Rectangle {
                    width: 16
                    height: 16
                    radius: 8
                    color: maximizeMouseArea.containsMouse ? "#3498db" : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: isWindowMaximized ? "❐" : "⛶"
                        color: maximizeMouseArea.containsMouse ? "white" : "#2c3e50"
                        font.pixelSize: 10
                        font.bold: true
                    }

                    MouseArea {
                        id: maximizeMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: toggleMaximize()
                    }
                }

                Rectangle {
                    width: 16
                    height: 16
                    radius: 8
                    color: closeMouseArea.containsMouse ? "#ff5c5c" : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "×"
                        color: closeMouseArea.containsMouse ? "white" : "#2c3e50"
                        font.pixelSize: 12
                        font.bold: true
                    }

                    MouseArea {
                        id: closeMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: logout()
                    }
                }
            }

            // Область перетаскивания окна
            MouseArea {
                id: resizeMouseArea
                anchors.fill: parent
                cursorShape: Qt.SizeFDiagCursor
                drag{ target: null; axis: Drag.XAndYAxis }

                onPressed: {
                    // Запоминаем начальные размеры
                    resizeMouseArea.previousWidth = mainWindow.width;
                    resizeMouseArea.previousHeight = mainWindow.height;
                }

                onPositionChanged: {
                    if (pressed) {
                        var newWidth = resizeMouseArea.previousWidth + mouse.x;
                        var newHeight = resizeMouseArea.previousHeight + mouse.y;

                        // Ограничиваем размеры в пределах минимальных и максимальных значений
                        newWidth = Math.max(mainWindow.minimumWidth, Math.min(mainWindow.maximumWidth, newWidth));
                        newHeight = Math.max(mainWindow.minimumHeight, Math.min(mainWindow.maximumHeight, newHeight));

                        // Устанавливаем новые размеры
                        mainWindow.width = newWidth;
                        mainWindow.height = newHeight;

                        // Отправляем сигнал об изменении размера
                        windowResized(newWidth, newHeight);
                    }
                }

                property real previousWidth: 0
                property real previousHeight: 0
            }
        }

        // Основное содержимое
        RowLayout {
            anchors {
                top: titleBar.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: 10
                topMargin: 15
            }
            spacing: 10

            // Боковая панель
            Rectangle {
                id: sideBar
                Layout.preferredWidth: isSideBarExpanded ? 200 : 60
                Layout.fillHeight: true
                color: "#ffffff"
                opacity: 0.9
                radius: 12

                Column {
                    width: parent.width
                    spacing: 1
                    padding: 10

                    Repeater {
                        model: [
                            {icon: "👨‍🏫", text: "Преподаватели", tabIndex: 0},
                            {icon: "👥", text: "Группы", tabIndex: 1},
                            {icon: "🎓", text: "Студенты", tabIndex: 2},
                            {icon: "📁", text: "Портфолио", tabIndex: 3},
                            {icon: "📅", text: "Мероприятия", tabIndex: 4}
                        ]

                        Rectangle {
                            width: sideBar.width - 20  // Фиксированное вычисление ширины
                            height: 45
                            color: currentTabIndex === modelData.tabIndex ? "#3498db" : "transparent"
                            radius: 8

                            Row {
                                anchors.centerIn: parent
                                spacing: 10
                                Text {
                                    text: modelData.icon
                                    font.pixelSize: 16
                                    color: currentTabIndex === modelData.tabIndex ? "white" : "#2c3e50"
                                }
                                Text {
                                    text: isSideBarExpanded ? modelData.text : ""
                                    font.pixelSize: 14
                                    color: currentTabIndex === modelData.tabIndex ? "white" : "#2c3e50"
                                    visible: isSideBarExpanded
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: currentTabIndex = modelData.tabIndex
                            }
                        }
                    }

                    Item { height: 20 }

                    // Кнопка выхода
                    Rectangle {
                        width: sideBar.width - 20  // Фиксированное вычисление ширины
                        height: 45
                        color: "transparent"
                        radius: 8

                        Row {
                            anchors.centerIn: parent
                            spacing: 10
                            Text {
                                text: "🚪"
                                font.pixelSize: 16
                                color: "#2c3e50"
                            }
                            Text {
                                text: isSideBarExpanded ? "Выход" : ""
                                font.pixelSize: 14
                                color: "#2c3e50"
                                visible: isSideBarExpanded
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: logout()
                        }
                    }
                }
            }

            // Основная область контента
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#ffffff"
                opacity: 0.9
                radius: 12

                StackLayout {
                    id: contentStack
                    anchors.fill: parent
                    currentIndex: currentTabIndex

                    // Вкладка преподавателей
                    Item {
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 10

                            Button {
                                text: "🔄 Обновить"
                                onClicked: loadTestData()
                                Layout.alignment: Qt.AlignLeft
                            }

                            Text {
                                text: "Преподаватели: " + teachersModel.count
                                font.pixelSize: 16
                                font.bold: true
                            }

                            ScrollView {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                ListView {
                                    id: teachersList
                                    model: teachersModel
                                    spacing: 5

                                    // Исправление: добавляем явную ширину для ListView
                                    width: parent.width

                                    delegate: Item {
                                        width: teachersList.width
                                        height: 70

                                        Rectangle {
                                            anchors.fill: parent
                                            anchors.margins: 2
                                            radius: 8
                                            color: index % 2 ? "#f8f9fa" : "#ffffff"
                                            border.color: "#e9ecef"
                                            border.width: 1

                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.margins: 10
                                                spacing: 10

                                                ColumnLayout {
                                                    Layout.fillWidth: true
                                                    Text {
                                                        text: model.last_name + " " + model.first_name + (model.middle_name ? " " + model.middle_name : "")
                                                        font.bold: true
                                                        font.pixelSize: 14
                                                    }
                                                    Text {
                                                        text: "Специализация: " + model.specialization + " | Опыт: " + model.experience + " лет"
                                                        font.pixelSize: 12
                                                        color: "#6c757d"
                                                    }
                                                }

                                                ColumnLayout {
                                                    Text {
                                                        text: model.email
                                                        font.pixelSize: 12
                                                    }
                                                    Text {
                                                        text: model.phone_number
                                                        font.pixelSize: 12
                                                        color: "#6c757d"
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Вкладка групп
                    Item {
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 10

                            Button {
                                text: "🔄 Обновить"
                                onClicked: loadTestData()
                                Layout.alignment: Qt.AlignLeft
                            }

                            Text {
                                text: "Группы: " + groupsModel.count
                                font.pixelSize: 16
                                font.bold: true
                            }

                            ScrollView {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                ListView {
                                    id: groupsList
                                    model: groupsModel
                                    spacing: 5
                                    width: parent.width

                                    delegate: Item {
                                        width: groupsList.width
                                        height: 50

                                        Rectangle {
                                            anchors.fill: parent
                                            anchors.margins: 2
                                            radius: 8
                                            color: index % 2 ? "#f8f9fa" : "#ffffff"
                                            border.color: "#e9ecef"
                                            border.width: 1

                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.margins: 10

                                                Text {
                                                    text: model.name
                                                    font.bold: true
                                                    font.pixelSize: 14
                                                    Layout.fillWidth: true
                                                }

                                                Text {
                                                    text: "Студентов: " + model.student_count
                                                    font.pixelSize: 12
                                                    color: "#6c757d"
                                                }

                                                Text {
                                                    text: "Преподаватель ID: " + model.teacher_id
                                                    font.pixelSize: 12
                                                    color: "#6c757d"
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Вкладка студентов
                    Item {
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 10

                            Button {
                                text: "🔄 Обновить"
                                onClicked: loadTestData()
                                Layout.alignment: Qt.AlignLeft
                            }

                            Text {
                                text: "Студенты: " + studentsModel.count
                                font.pixelSize: 16
                                font.bold: true
                            }

                            ScrollView {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                ListView {
                                    id: studentsList
                                    model: studentsModel
                                    spacing: 5
                                    width: parent.width

                                    delegate: Item {
                                        width: studentsList.width
                                        height: 60

                                        Rectangle {
                                            anchors.fill: parent
                                            anchors.margins: 2
                                            radius: 8
                                            color: index % 2 ? "#f8f9fa" : "#ffffff"
                                            border.color: "#e9ecef"
                                            border.width: 1

                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.margins: 10
                                                spacing: 10

                                                ColumnLayout {
                                                    Layout.fillWidth: true
                                                    Text {
                                                        text: model.last_name + " " + model.first_name + (model.middle_name ? " " + model.middle_name : "")
                                                        font.bold: true
                                                        font.pixelSize: 14
                                                    }
                                                    Text {
                                                        text: "Группа ID: " + model.group_id
                                                        font.pixelSize: 12
                                                        color: "#6c757d"
                                                    }
                                                }

                                                ColumnLayout {
                                                    Text {
                                                        text: model.email
                                                        font.pixelSize: 12
                                                    }
                                                    Text {
                                                        text: model.phone_number
                                                        font.pixelSize: 12
                                                        color: "#6c757d"
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Вкладка портфолио
                    Item {
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 10

                            Button {
                                text: "🔄 Обновить"
                                onClicked: loadTestData()
                                Layout.alignment: Qt.AlignLeft
                            }

                            Text {
                                text: "Записей в портфолио: " + portfolioModel.count
                                font.pixelSize: 16
                                font.bold: true
                            }

                            ScrollView {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                ListView {
                                    id: portfolioList
                                    model: portfolioModel
                                    spacing: 5
                                    width: parent.width

                                    delegate: Item {
                                        width: portfolioList.width
                                        height: 70

                                        Rectangle {
                                            anchors.fill: parent
                                            anchors.margins: 2
                                            radius: 8
                                            color: index % 2 ? "#f8f9fa" : "#ffffff"
                                            border.color: "#e9ecef"
                                            border.width: 1

                                            ColumnLayout {
                                                anchors.fill: parent
                                                anchors.margins: 10

                                                Text {
                                                    text: "Студент ID: " + model.student_code + " | Мероприятие: " + model.measure_code
                                                    font.bold: true
                                                    font.pixelSize: 14
                                                }

                                                Text {
                                                    text: "Дата: " + model.date + " | Паспорт: " + model.passport_series + " " + model.passport_number
                                                    font.pixelSize: 12
                                                    color: "#6c757d"
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Вкладка мероприятий
                    Item {
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 10

                            Button {
                                text: "🔄 Обновить"
                                onClicked: loadTestData()
                                Layout.alignment: Qt.AlignLeft
                            }

                            Text {
                                text: "Мероприятий: " + eventsModel.count
                                font.pixelSize: 16
                                font.bold: true
                            }

                            ScrollView {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                ListView {
                                    id: eventsList
                                    model: eventsModel
                                    spacing: 5
                                    width: parent.width

                                    delegate: Item {
                                        width: eventsList.width
                                        height: 80

                                        Rectangle {
                                            anchors.fill: parent
                                            anchors.margins: 2
                                            radius: 8
                                            color: index % 2 ? "#f8f9fa" : "#ffffff"
                                            border.color: "#e9ecef"
                                            border.width: 1

                                            ColumnLayout {
                                                anchors.fill: parent
                                                anchors.margins: 10

                                                Text {
                                                    text: model.event_category + " (" + model.event_type + ")"
                                                    font.bold: true
                                                    font.pixelSize: 14
                                                }

                                                Text {
                                                    text: "Период: " + model.start_date + " - " + model.end_date
                                                    font.pixelSize: 12
                                                }

                                                Text {
                                                    text: "Место: " + (model.location || "Не указано")
                                                    font.pixelSize: 12
                                                    color: "#6c757d"
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // ТВОЁ перетаскивание для изменения размера окна
        MouseArea {
            id: resizeMouseArea
            anchors {
                right: parent.right
                bottom: parent.bottom
            }
            width: 15
            height: 15
            cursorShape: Qt.SizeFDiagCursor

            property real previousWidth: 0
            property real previousHeight: 0

            onPressed: {
                previousWidth = mainWindow.width;
                previousHeight = mainWindow.height;
            }

            onPositionChanged: {
                if (pressed) {
                    var newWidth = previousWidth + mouse.x;
                    var newHeight = previousHeight + mouse.y;

                    newWidth = Math.max(mainWindow.minimumWidth, Math.min(mainWindow.maximumWidth, newWidth));
                    newHeight = Math.max(mainWindow.minimumHeight, Math.min(mainWindow.maximumHeight, newHeight));

                    mainWindow.width = newWidth;
                    mainWindow.height = newHeight;
                }
            }
        }
    }

    // Функции
    function toggleMaximize() {
        if (isWindowMaximized) {
            mainWindow.showNormal();
            isWindowMaximized = false;
        } else {
            mainWindow.showMaximized();
            isWindowMaximized = true;
        }
    }

    function logout() {
        console.log("Выход из приложения");
        Qt.quit();
    }

    function loadTestData() {
        console.log("Загрузка тестовых данных");

        // Тестовые данные для преподавателей
        teachersModel.clear();
        for (var i = 0; i < 5; i++) {
            teachersModel.append({
                last_name: "Преподаватель",
                first_name: "Тест",
                middle_name: i + 1,
                specialization: 1,
                experience: 5 + i,
                email: `teacher${i+1}@edu.ru`,
                phone_number: "+7999000000" + i
            });
        }

        // Тестовые данные для групп
        groupsModel.clear();
        for (var j = 0; j < 5; j++) {
            groupsModel.append({
                name: `Группа ${j+1}`,
                student_count: 20 + j,
                teacher_id: j + 1
            });
        }

        // Тестовые данные для студентов
        studentsModel.clear();
        for (var k = 0; k < 5; k++) {
            studentsModel.append({
                last_name: "Студент",
                first_name: "Тест",
                middle_name: k + 1,
                group_id: k + 1,
                email: `student${k+1}@edu.ru`,
                phone_number: "+7999111111" + k
            });
        }

        // Тестовые данные для портфолио
        portfolioModel.clear();
        for (var l = 0; l < 5; l++) {
            portfolioModel.append({
                student_code: l + 1,
                measure_code: l + 100,
                date: "2024-01-01",
                passport_series: "1234",
                passport_number: "567890"
            });
        }

        // Тестовые данные для мероприятий
        eventsModel.clear();
        for (var m = 0; m < 5; m++) {
            eventsModel.append({
                event_category: ["Конференция", "Семинар", "Олимпиада"][m % 3],
                event_type: ["Онлайн", "Оффлайн"][m % 2],
                start_date: "2024-01-01",
                end_date: "2024-01-02",
                location: m % 2 ? "Москва" : ""
            });
        }
    }

    // Инициализация
    Component.onCompleted: {
        console.log("Главное окно инициализировано");
        Qt.callLater(loadTestData);
    }
}
