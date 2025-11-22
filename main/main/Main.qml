// Main.qml
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
                           Qt.platform.os === "tvos" || Qt.platform.os === "wasm"

    // УПРОЩЕННЫЕ ОТСТУПЫ - безопасные значения по умолчанию
    property int mobileTopMargin: isMobile ? 24 : 0
    property int mobileBottomMargin: isMobile ? 48 : 0

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

    // Обработчик кнопки "Назад" для Android
    onClosing: (close) => {
        if (isMobile) {
            close.accepted = false
            handleBackButton()
        }
    }

    // Вспомогательные функции
    function handleBackButton() {
        showExitDialog()
    }

    function showExitDialog() {
        // Снимаем фокус с любых активных элементов
        windowContainer.forceActiveFocus()
        var dialog = exitDialogComponent.createObject(mainWindow);
        dialog.open();
    }

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
        mobileMenuOpen = false;

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
            case "news": return "Новости";
            case "settings": return "Настройки";
            case "faq": return "Справочник"
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

    // УЛУЧШЕННАЯ зона жестов для открытия меню
    Rectangle {
        id: globalSwipeArea
        anchors.fill: parent
        color: "transparent"
        enabled: isMobile && !mobileMenuOpen
        z: 3 // ПОД ЗАТЕМНЕНИЕМ

        property real startX: 0
        property real startY: 0
        property bool tracking: false
        property bool isHorizontalSwipe: false

        MouseArea {
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            width: 60 // УВЕЛИЧЕНА зона жестов до 60px
            propagateComposedEvents: true

            onPressed: (mouse) => {
                globalSwipeArea.startX = mouse.x
                globalSwipeArea.startY = mouse.y
                globalSwipeArea.tracking = true
                globalSwipeArea.isHorizontalSwipe = false
                mouse.accepted = true
            }

            onPositionChanged: (mouse) => {
                if (!globalSwipeArea.tracking) return

                var deltaX = mouse.x - globalSwipeArea.startX
                var deltaY = mouse.y - globalSwipeArea.startY

                // Определяем, это горизонтальный или вертикальный свайп
                if (!globalSwipeArea.isHorizontalSwipe) {
                    if (Math.abs(deltaX) > Math.abs(deltaY) && Math.abs(deltaX) > 10) {
                        globalSwipeArea.isHorizontalSwipe = true
                    } else if (Math.abs(deltaY) > Math.abs(deltaX) && Math.abs(deltaY) > 10) {
                        globalSwipeArea.tracking = false // Вертикальный свайп - игнорируем
                        return
                    }
                }

                if (globalSwipeArea.isHorizontalSwipe && deltaX > 50) { // Свайп вправо для открытия
                    mobileMenuOpen = true
                    globalSwipeArea.tracking = false
                }
            }

            onReleased: {
                globalSwipeArea.tracking = false
            }

            // Визуальный индикатор зоны жестов (только для отладки)
            Rectangle {
                anchors.fill: parent
                color: "#3498db"
                opacity: 0.1
                visible: false // Установите true для отладки зоны жестов
            }
        }
    }

    // Основной интерфейс
    Rectangle {
        id: windowContainer
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            topMargin: isMobile ? 15 + mobileTopMargin : 0
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

        Common.PolygonBackground {
            anchors.fill: parent
            polygonCount: 4
            isMobile: mainWindow.isMobile
            z: 1
        }

        // Искры на фоне
        Common.SparksBackground {
            anchors.fill: parent
            isMobile: mainWindow.isMobile
            sparkCount: 24
            z: 1

        }

        Common.BottomBlur {
            id: bottomBlur
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            blurHeight: 48
            blurOpacity: 0.8
            z: 2
            isMobile: mainWindow.isMobile
        }

        // Панель для Десктопных версий
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
            isMobile: mainWindow.isMobile

            onToggleMaximize: mainWindow.toggleMaximize()
            onShowMinimized: mainWindow.showMinimized()
            onClose: Qt.quit()
        }

        // Мобильный заголовок
        Common.TitleBarMobile {
            id: mobileHeader
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                leftMargin: 10
                rightMargin: 10
                topMargin: mobileTopMargin
            }
            currentView: getCurrentViewTitle()
            menuOpen: mobileMenuOpen
            onToggleMenu: toggleMobileMenu()
            visible: isMobile
            z: 2
        }

        // Контейнер для сообщений
        MainMessage {
            id: messageContainer
            anchors {
                top: isMobile ? mobileHeader.bottom : titleBar.bottom
                left: parent.left
                right: parent.right
                margins: 10
                topMargin: isMobile ? 5 : 10
            }
        }

        Rectangle {
            id: mainContent
            anchors {
                top: messageContainer.bottom
                bottom: isMobile ? bottomBlur.top : parent.bottom
                left: parent.left
                right: parent.right
                margins: 10
                topMargin: 5
                bottomMargin: isMobile ? 5 : 10
            }
            color: "transparent"

            // Адаптивная боковая панель для десктопа
            AdaptiveSideBar {
                id: sideBar
                anchors { top: parent.top; bottom: parent.bottom; left: parent.left }
                currentView: mainWindow.currentView
                visible: !isMobile
            }

            // Мобильное меню
            AdaptiveSideBarMobile {
                id: mobileMenu
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                width: Math.min(parent.width * 0.7, 300)
                currentView: mainWindow.currentView
                isOpen: mobileMenuOpen
                onCloseRequested: mobileMenuOpen = false
                visible: isMobile
                topMargin: mobileTopMargin
                swipeEnabled: true
                z: 1000
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
                                "news": "../view/NewsView.qml",
                                "settings": "../view/SettingsView.qml",
                                "faq": "../view/FAQView.qml"
                            }
                            return components[currentView] || "../view/DashboardView.qml"
                    }
                    z: 3

                    onLoaded: {
                        if (item && item.hasOwnProperty("isMobile")) {
                            item.isMobile = mainWindow.isMobile;
                        }
                    }
                }
            }
        }

        // ЗОНА СВАЙПА ДЛЯ ЗАКРЫТИЯ САЙДБАРА - работает когда меню открыто
        Rectangle {
            id: swipeCloseArea
            anchors.fill: parent
            color: "transparent"
            enabled: isMobile && mobileMenuOpen
            z: 950 // МЕЖДУ САЙДБАРОМ И ЗАТЕМНЕНИЕМ

            property real startX: 0
            property bool tracking: false

            MouseArea {
                anchors.fill: parent
                propagateComposedEvents: true

                onPressed: (mouse) => {
                    swipeCloseArea.startX = mouse.x
                    swipeCloseArea.tracking = true
                    mouse.accepted = true
                }

                onPositionChanged: (mouse) => {
                    if (!swipeCloseArea.tracking) return

                    var dragDistance = mouse.x - swipeCloseArea.startX
                    // Свайп влево для закрытия меню
                    if (dragDistance < -50) {
                        mobileMenuOpen = false
                        swipeCloseArea.tracking = false
                    }
                }

                onReleased: {
                    swipeCloseArea.tracking = false
                }
            }
        }
    }

    Component.onCompleted: {
        console.log("🚀 Main window initialized - Mobile:", isMobile, "Platform:", Qt.platform.os);

        // Проверяем, есть ли сохраненный токен в настройках
        var savedToken = settingsManager.authToken || "";

        if (savedToken && savedToken.length > 0) {
            console.log("🔑 Using saved token");
            initializeProfile(savedToken, null);
        } else {
            console.log("🔑 No saved token, showing auth window");
            var baseUrl = settingsManager.useLocalServer ?
                settingsManager.serverAddress :
                mainApi.remoteApiBaseUrl + ":" + mainApi.remotePort;
            initializeProfile("", baseUrl);
        }
    }
}
