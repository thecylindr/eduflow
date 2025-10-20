// Обновленный импорт в Main.qml
import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../common" as Common

ApplicationWindow {
    id: mainWindow
    width: 1200
    height: 800
    visible: false
    title: "EduFlow"
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint
    minimumWidth: 1000
    minimumHeight: 700

    property bool isWindowMaximized: false
    property string currentView: "dashboard"

    // Данные
    property var teachers: []
    property var students: []
    property var groups: []

    // API объект - исправленная инициализация
    property MainAPI mainApi: mainApiObject

    // Флаг инициализации API
    property bool apiInitialized: false

    function navigateTo(view) {
        console.log("🧭 Навигация на:", view);
        currentView = view;

        // Автоматически загружаем данные при переходе
        if (view === "students") {
            loadStudents();
        } else if (view === "groups") {
            loadGroups();
        } else if (view === "teachers") {
            loadTeachers();
        }
    }

    function getCurrentViewTitle() {
        switch(currentView) {
            case "dashboard": return "Главная панель";
            case "teachers": return "Преподаватели";
            case "students": return "Студенты";
            case "groups": return "Группы";
            case "portfolio": return "Портфолио";
            case "events": return "События";
            default: return "Главная панель";
        }
    }

    function logout() {
        console.log("🚪 Выход из системы...");
        ////mainApi.clearAuth();
        // Здесь будет дополнительная логика выхода
    }

    function toggleMaximize() {
        if (isWindowMaximized) {
            showNormal();
            isWindowMaximized = false;
        } else {
            showMaximized();
            isWindowMaximized = true;
        }
    }

    // Функция инициализации API из Auth окна
    function initializeProfile(token, baseUrl) {

        var actualToken = token;
        var actualBaseUrl = baseUrl;

        if (!actualToken || actualToken.length === 0) {
            actualToken = settingsManager.authToken || "";
        }

        if (!actualBaseUrl || actualBaseUrl.length === 0) {
            actualBaseUrl = settingsManager.useLocalServer ?
                settingsManager.serverAddress :
                mainApi.remoteApiBaseUrl + ":" + mainApi.remotePort;
        }
        // Инициализируем API объект
        mainApi.initialize(actualToken, actualBaseUrl);
        apiInitialized = true;

        // ЖДЕМ проверки токена перед загрузкой данных
        mainApi.validateToken(function(response) {

            if (response.success) {
                loadTeachers();
                loadStudents();
                loadGroups();
            } else {
                showMessage("⚠️ Требуется авторизация", "warning");
            }
        });
    }

    // Функции загрузки данных с улучшенной обработкой ошибок
    function loadStudents() {
        if (!mainApi.isAuthenticated) {
            showMessage("❌ Требуется аутентификация", "error");
            return;
        }

        mainApi.getStudents(function(response) {
            if (response.success) {
                mainWindow.students = response.data || [];
                showMessage("✅ Студенты успешно загружены", "success");
            } else {
                showMessage("❌ Ошибка загрузки студентов: " + response.error, "error");
            }
        });
    }

    function loadGroups() {
        console.log("📥 Загрузка групп...");
        console.log("   API аутентифицирован:", mainApi.isAuthenticated);

        if (!mainApi.isAuthenticated) {
            showMessage("❌ Требуется аутентификация", "error");
            return;
        }

        mainApi.getGroups(function(response) {
            console.log("📨 Ответ от сервера (группы):", response);
            if (response.success) {
                mainWindow.groups = response.data || [];
                showMessage("✅ Группы успешно загружены", "success");
            } else {
                showMessage("❌ Ошибка загрузки групп: " + response.error, "error");
            }
        });
    }

    function loadTeachers() {
        if (!mainApi.isAuthenticated) {
            showMessage("❌ Требуется аутентификация", "error");
            return;
        }

        mainApi.getTeachers(function(response) {
            if (response.success) {
                mainWindow.teachers = response.data || [];
                showMessage("✅ Преподаватели успешно загружены", "success");
            } else {
                showMessage("❌ Ошибка загрузки преподавателей: " + response.error, "error");
            }
        });
    }

    function showMessage(text, type) {
        if (messageContainer) {
            messageContainer.messageText = text;
            messageContainer.messageType = type;
            messageContainer.showingMessage = true;
        }
    }

    // Инициализация мок данных
    function initializeMockData() {
        console.log("🔄 Инициализация мок данных...");
        mainWindow.teachers = [
            {teacherId: 1, firstName: "Иван", lastName: "Петров", middleName: "Сергеевич", email: "ivan@edu.ru", experience: 5, specialization: "Математика"},
            {teacherId: 2, firstName: "Мария", lastName: "Иванова", middleName: "Александровна", email: "maria@edu.ru", experience: 8, specialization: "Физика"}
        ];
        mainWindow.students = [
            {studentCode: "S001", firstName: "Алексей", lastName: "Сидоров", middleName: "Дмитриевич", email: "alex@edu.ru", phoneNumber: "+79991234567", groupId: 1, passportSeries: "1234", passportNumber: "567890"},
            {studentCode: "S002", firstName: "Елена", lastName: "Козлова", middleName: "Викторовна", email: "elena@edu.ru", phoneNumber: "+79997654321", groupId: 1, passportSeries: "4321", passportNumber: "098765"}
        ];
        mainWindow.groups = [
            {groupId: 1, name: "Группа 1", studentCount: 2, teacherId: 1},
            {groupId: 2, name: "Группа 2", studentCount: 0, teacherId: 2}
        ];
        console.log("✅ Мок данные инициализированы");
    }

    // API объект
    MainAPI {
        id: mainApiObject
    }

    // Основной интерфейс (остается без изменений)
    Rectangle {
        id: windowContainer
        anchors.fill: parent
        radius: 21
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

        // Обновленный импорт из common
        PolygonBackground {
            id: polygonRepeater
            anchors.fill: parent
            visible: parent !== null
        }

        // Обновленный импорт из common
        Common.TitleBar {
            id: titleBar
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 10
            }
            isWindowMaximized: mainWindow.isWindowMaximized
            currentView: getCurrentViewTitle()
            window: mainWindow

            onToggleMaximize: mainWindow.toggleMaximize()
            onShowMinimized: mainWindow.showMinimized()
            onClose: Qt.quit()
        }

        // Контейнер для сообщений ПОД заголовком
        MainMessage {
            id: messageContainer
            anchors {
                top: titleBar.bottom
                left: parent.left
                right: parent.right
                margins: 10
            }
        }

        Rectangle {
            id: mainContent
            anchors {
                top: messageContainer.bottom
                bottom: parent.bottom
                left: parent.left
                right: parent.right
                margins: 10
                topMargin: 5
            }
            color: "transparent"

            // Адаптивная боковая панель
            AdaptiveSideBar {
                id: sideBar
                anchors { top: parent.top; bottom: parent.bottom; left: parent.left }
                currentView: mainWindow.currentView
            }

            // Область контента
            Rectangle {
                id: contentArea
                anchors {
                    top: parent.top;
                    bottom: parent.bottom;
                    left: sideBar.right;
                    right: parent.right;
                    leftMargin: 15
                }
                color: "#f8f8f8"
                radius: 12
                opacity: 0.925

                Loader {
                    id: contentLoader
                    anchors.fill: parent
                    anchors.margins: 10
                    source: {
                        var components = {
                            "dashboard": "DashboardView.qml",
                            "teachers": "TeachersView.qml",
                            "students": "StudentsView.qml",
                            "groups": "GroupsView.qml",
                            "portfolio": "PortfolioView.qml",
                            "events": "EventsView.qml"
                        }
                        return components[currentView] || "DashboardView.qml"
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        // Проверяем, есть ли сохраненный токен в настройках
            var savedToken = settingsManager.authToken || "";

            if (savedToken && savedToken.length > 0) {
                initializeProfile(savedToken, null);
            } else {
                var baseUrl = settingsManager.useLocalServer ?
                    settingsManager.serverAddress :
                    mainApi.remoteApiBaseUrl + ":" + mainApi.remotePort;
                initializeProfile("", baseUrl);
            }
    }
}
