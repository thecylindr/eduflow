import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15
import "../../common" as Common

Window {
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

    property bool isMobile: Qt.platform.os === "android" || Qt.platform.os === "ios" ||
                           Qt.platform.os === "tvos" || Qt.platform.os === "wasm" ||
                           Screen.width < 768 || Screen.height < 768

    // Отступы для Android системных кнопок
    property int androidTopMargin: (Qt.platform.os === "android") ? 24 : 0
    property int androidBottomMargin: (Qt.platform.os === "android") ? 48 : 0

    // Данные
    property var teachers: []
    property var students: []
    property var groups: []

    // API объект - исправленная инициализация
    property MainAPI mainApi: mainApiObject

    // Флаг инициализации API
    property bool apiInitialized: false

    // Мобильное меню
    property bool mobileMenuOpen: false

    function showAuthWindow() {
            // Если окно авторизации не существует, создаем его
            var component = Qt.createComponent("../../auth/Auth.qml");
            if (component.status === Component.Ready) {
                var authWin = component.createObject(mainWindow);
                authWin.show();
            } else {
                console.error("❌ Ошибка создания окна авторизации:", component.errorString());
        }
    }

    function navigateTo(view) {
        currentView = view;
        mobileMenuOpen = false; // Закрываем меню при переходе

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
            case "settings": return "Настройки";
            default: return "Главная панель";
        }
    }

    function toggleMobileMenu() {
        mobileMenuOpen = !mobileMenuOpen;
    }

    function logout() {
        // Очищаем токен аутентификации
        settingsManager.authToken = "";
        authToken = "";

        // Очищаем авторизацию в API
        mainApi.clearAuth();

        // Показываем окно авторизации
        showAuthWindow();
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
        loadTeachers();
        loadStudents();
        loadGroups();
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
            } else {
                showMessage("❌ Ошибка загрузки студентов: " + response.error, "error");
            }
        });
    }

    function loadGroups() {
        if (!mainApi.isAuthenticated) {
            showMessage("❌ Требуется аутентификация", "error");
            return;
        }

        mainApi.getGroups(function(response) {
            if (response.success) {
                mainWindow.groups = response.data || [];
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

    // API объект
    MainAPI {
        id: mainApiObject
    }

    // Основной интерфейс
    Rectangle {
        id: windowContainer
        anchors {
            fill: parent
            topMargin: mainWindow.androidTopMargin
            bottomMargin: mainWindow.androidBottomMargin
        }
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

        // Полигоны (8-угольники на фоне)
        Common.PolygonBackground {
            id: polygonRepeater
            anchors.fill: parent
            visible: parent !== null && !isMobile
            isMobile: mainWindow.isMobile
        }

        // Панель для Десктопных версий
        Common.TitleBar {
            id: titleBar
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                topMargin: 10 + mainWindow.androidTopMargin
                leftMargin: 10
                rightMargin: 10
            }
            isWindowMaximized: mainWindow.isWindowMaximized
            currentView: getCurrentViewTitle()
            window: mainWindow
            isMobile: mainWindow.isMobile

            onToggleMaximize: mainWindow.toggleMaximize()
            onShowMinimized: mainWindow.showMinimized()
            onClose: Qt.quit()
        }

        // Мобильный заголовок - опускаем ниже
        Common.TitleBarMobile {
            id: mobileHeader
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                topMargin: mainWindow.androidTopMargin
                leftMargin: 10
                rightMargin: 10
            }
            currentView: getCurrentViewTitle()
            menuOpen: mobileMenuOpen
            onToggleMenu: toggleMobileMenu()
            visible: isMobile
        }

        // Контейнер для сообщений
        MainMessage {
            id: messageContainer
            anchors {
                top: isMobile ? mobileHeader.bottom : titleBar.bottom
                left: parent.left
                right: parent.right
                margins: 10
                topMargin: isMobile ? 5 : 0
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

            // Адаптивная боковая панель для десктопа - ТЕПЕРЬ ВИДИМА
            AdaptiveSideBar {
                id: sideBar
                anchors { top: parent.top; bottom: parent.bottom; left: parent.left }
                currentView: mainWindow.currentView
                visible: !isMobile
            }

            // Мобильное меню - опускаем еще ниже
            AdaptiveSideBarMobile {
                id: mobileMenu
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    topMargin: 10
                }
                width: Math.min(parent.width * 0.8, 300)
                currentView: mainWindow.currentView
                isOpen: mobileMenuOpen
                onCloseRequested: mobileMenuOpen = false
                visible: isMobile
            }

            // Область контента
            Rectangle {
                id: contentArea
                anchors {
                    top: parent.top;
                    bottom: parent.bottom;
                    left: isMobile ? parent.left : sideBar.right;
                    right: parent.right;
                    leftMargin: isMobile ? 0 : 15
                }
                color: "#f8f8f8"
                radius: 12
                opacity: 0.925

                // Затемнение фона при открытом мобильном меню
                Rectangle {
                    anchors.fill: parent
                    color: "#000000"
                    opacity: mobileMenuOpen ? 0.3 : 0
                    visible: isMobile
                    z: 4

                    MouseArea {
                        anchors.fill: parent
                        enabled: mobileMenuOpen
                        onClicked: mobileMenuOpen = false
                    }
                }

                Loader {
                    id: contentLoader
                    anchors.fill: parent
                    anchors.margins: isMobile ? 5 : 10
                    source: {
                            var components = {
                                "dashboard": "../view/DashboardView.qml",
                                "teachers": "../view/TeachersView.qml",
                                "students": "../view/StudentsView.qml",
                                "groups": "../view/GroupsView.qml",
                                "portfolio": "../view/PortfolioView.qml",
                                "events": "../view/EventsView.qml",
                                "settings": "../view/SettingsView.qml"
                            }
                            return components[currentView] || "../view/DashboardView.qml"
                    }
                    z: 3
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
