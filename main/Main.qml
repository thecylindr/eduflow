import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: mainWindow
    width: 1200
    height: 800
    visible: true
    title: appName
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint
    minimumWidth: 1000
    minimumHeight: 700

    // Свойства для передачи параметров
    //property string authToken: ""
    //property string serverAddress: ""
    //property bool useLocalServer: false

    property var viewTitles: ({
        "dashboard": "Главная панель",
        "teachers": "Преподаватели",
        "students": "Студенты",
        "groups": "Группы",
        "portfolio": "Портфолио",
        "events": "События"
    })

    property bool isWindowMaximized: false
    property string currentView: "dashboard"
    property bool isLoading: false
    property string _previousView: ""

    property string _errorMessage: ""
    property bool _showingError: false
    property string _successMessage: ""
    property bool _showingSuccess: false

    // Данные
    property var teachers: []
    property var students: []
    property var groups: []
    property var portfolio: []
    property var events: []

    Component.onCompleted: {
        console.log("🔧 Инициализация главного окна");
        console.log("📡 Токен доступен:", authToken ? "да, длина " + authToken.length : "нет");
        console.log("🌐 Адрес сервера:", serverAddress);
        console.log("💻 Локальный сервер:", useLocalServer);

        // Инициализируем боковую панель
        if (sideBar) {
            sideBar.setCurrentView(currentView);
        }

        // Всегда показываем интерфейс, даже без данных
        if (authToken && authToken.length > 0) {
            console.log("🚀 Токен передан, инициализируем API...");
            initializeApiAndLoadData();
        } else if (settingsManager.authToken && settingsManager.authToken.length > 0) {
            console.log("🔄 Токен найден в настройках, используем его...");
            authToken = settingsManager.authToken;
            serverAddress = settingsManager.useLocalServer ?
                settingsManager.serverAddress :
                (mainApi.remoteApiBaseUrl + ":" + mainApi.remotePort);
            useLocalServer = settingsManager.useLocalServer;
            initializeApiAndLoadData();
        } else {
            showSuccess("Добро пожаловать в " + appName + "! Для загрузки данных войдите в систему.");
        }
    }

    // Сделать чтобы прятало auth здесь
    // function hideAuthForm() {
    //     authWindow.hide;
    // }

    function getCurrentViewName() {
        switch(currentView) {
            case "dashboard": return "Главная панель";
            case "teachers": return "Преподаватели";
            case "students": return "Студенты";
            case "groups": return "Группы";
            case "portfolio": return "Портфолио";
            case "events": return "События";
            default: return "Главная";
        }
    }

    function initializeApiAndLoadData() {
        if (!authToken || authToken.length === 0) {
            console.error("❌ Токен не доступен для инициализации API");
            showError("Токен авторизации не найден. Пожалуйста, войдите заново.");
            return;
        }

        // Убедимся, что serverAddress установлен
        if (!serverAddress || serverAddress === "") {
            serverAddress = settingsManager.useLocalServer ?
                settingsManager.serverAddress :
                (mainApi.remoteApiBaseUrl + ":" + mainApi.remotePort);
            useLocalServer = settingsManager.useLocalServer;
        }

        console.log("🔧 Настройка API:");
        console.log("   🔑 Токен:", authToken ? "***" + authToken.slice(-8) : "нет");
        console.log("   🌐 Адрес:", serverAddress);
        console.log("   💻 Локальный:", useLocalServer);

        // Настройка API
        mainApi.setConfig(authToken, serverAddress, useLocalServer);

        // Пытаемся загрузить данные, но не блокируем интерфейс при ошибках
        loadAllData();
    }

    function loadAllData() {
        console.log("📥 Начинаем загрузку данных...");
        isLoading = true;

        // Используем задержку для предотвращения рекурсии
        Qt.callLater(function() {
            var teachersLoaded = false;
            var studentsLoaded = false;
            var groupsLoaded = false;

            function checkAllLoaded() {
                if (teachersLoaded && studentsLoaded && groupsLoaded) {
                    isLoading = false;
                    var hasData = teachers.length > 0 || students.length > 0 || groups.length > 0;
                    if (hasData) {
                        showSuccess("✅ Данные успешно загружены!");
                    } else {
                        showError("⚠️ Не удалось загрузить данные. Проверьте подключение к серверу.");
                    }
                }
            }

            // Загружаем преподавателей
            loadTeachers(function() {
                teachersLoaded = true;
                checkAllLoaded();
            });

            // Загружаем студентов
            loadStudents(function() {
                studentsLoaded = true;
                checkAllLoaded();
            });

            // Загружаем группы
            loadGroups(function() {
                groupsLoaded = true;
                checkAllLoaded();
            });
        });
    }

    function loadTeachers(callback) {
        console.log("👨‍🏫 Загрузка преподавателей...");

        if (!authToken || authToken.length === 0) {
            console.error("❌ Токен не доступен для загрузки преподавателей");
            if (callback) callback();
            return;
        }

        mainApi.getTeachers(function(result) {
            if (result.success) {
                teachers = result.data || [];
                console.log("✅ Преподаватели загружены:", teachers.length);
            } else {
                console.log("⚠️ Ошибка загрузки преподавателей:", result.error);
                if (result.status === 401) {
                    console.log("🔐 Ошибка авторизации при загрузке преподавателей");
                    showError("Ошибка авторизации. Пожалуйста, войдите заново.");
                }
            }
            if (callback) callback();
        });
    }

    function loadStudents(callback) {
        console.log("👨‍🎓 Загрузка студентов...");

        if (!authToken || authToken.length === 0) {
            console.error("❌ Токен не доступен для загрузки студентов");
            if (callback) callback();
            return;
        }

        mainApi.getStudents(function(result) {
            if (result.success) {
                students = result.data || [];
                console.log("✅ Студенты загружены:", students.length);
            } else {
                console.log("⚠️ Ошибка загрузки студентов:", result.error);
                if (result.status === 401) {
                    console.log("🔐 Ошибка авторизации при загрузке студентов");
                    showError("Ошибка авторизации. Пожалуйста, войдите заново.");
                }
            }
            if (callback) callback();
        });
    }

    function loadGroups(callback) {
        console.log("👥 Загрузка групп...");

        if (!authToken || authToken.length === 0) {
            console.error("❌ Токен не доступен для загрузки групп");
            if (callback) callback();
            return;
        }

        mainApi.getGroups(function(result) {
            if (result.success) {
                groups = result.data || [];
                console.log("✅ Группы загружены:", groups.length);
            } else {
                console.log("⚠️ Ошибка загрузки групп:", result.error);
                if (result.status === 401) {
                    console.log("🔐 Ошибка авторизации при загрузке групп");
                    showError("Ошибка авторизации. Пожалуйста, войдите заново.");
                }
            }
            if (callback) callback();
        });
    }

    function loadPortfolio() {
        if (!authToken || authToken.length === 0) {
            console.error("❌ Токен не доступен для загрузки портфолио");
            return;
        }

        mainApi.getPortfolios(function(result) {
            if (result.success) {
                portfolio = result.data || [];
                console.log("✅ Портфолио загружено:", portfolio.length);
            } else {
                console.log("⚠️ Ошибка загрузки портфолио:", result.error);
            }
        });
    }

    function loadEvents() {
        if (!authToken || authToken.length === 0) {
            console.error("❌ Токен не доступен для загрузки событий");
            return;
        }

        mainApi.getEvents(function(result) {
            if (result.success) {
                events = result.data || [];
                console.log("✅ События загружены:", events.length);
            } else {
                console.log("⚠️ Ошибка загрузки событий:", result.error);
            }
        });
    }

    function navigateTo(view) {
        console.log("🧭 Навигация запрошена:", view, "текущий вид:", currentView);

        // Проверяем, не пытаемся ли перейти на тот же вид
        if (currentView === view) {
            console.log("Уже на запрошенном виде, навигация пропущена");
            return;
        }

        // Сохраняем предыдущий вид
        _previousView = currentView;

        // Устанавливаем новый вид
        currentView = view;
        console.log("✅ Навигация выполнена. Новый вид:", currentView);

        // Обновляем боковую панель
        if (sideBar) {
            sideBar.setCurrentView(view);
        }

        // Загружаем данные если нужно
        if (view === "portfolio" && portfolio.length === 0) {
            loadPortfolio();
        } else if (view === "events" && events.length === 0) {
            loadEvents();
        }
    }

    function logout() {
        console.log("🚪 Выход из системы...");

        // Очищаем токены
        authToken = "";
        settingsManager.authToken = "";

        // Очищаем данные
        teachers = [];
        students = [];
        groups = [];
        portfolio = [];
        events = [];

        showAuthWindow();
    }

    function showAuthWindow() {
        console.log("🔄 Переход к окну авторизации...");

        try {
            var component = Qt.createComponent("../auth/Auth.qml");
            if (component.status === Component.Ready) {
                var window = component.createObject(mainWindow, {
                    "x": mainWindow.x + (mainWindow.width - 420) / 2,
                    "y": mainWindow.y + (mainWindow.height - 500) / 2,
                    "width": 420,
                    "height": 500
                });
                if (window) {
                    console.log("✅ Окно авторизации создано");
                    window.show();
                } else {
                    console.error("❌ Не удалось создать окно авторизации");
                    showError("Не удалось открыть окно авторизации");
                }
            } else {
                console.error("❌ Ошибка создания компонента авторизации:", component.errorString());
                showError("Ошибка загрузки интерфейса авторизации");
            }
        } catch (error) {
            console.error("❌ Критическая ошибка при создании окна авторизации:", error);
            Qt.quit();
        }
    }

    function showError(message) {
        _successMessage = "";
        _showingSuccess = false;
        _errorMessage = message;
        _showingError = message !== "";
        if (_showingError) errorAutoHideTimer.restart();
    }

    function showSuccess(message) {
        _errorMessage = "";
        _showingError = false;
        _successMessage = message;
        _showingSuccess = message !== "";
        if (_showingSuccess) successAutoHideTimer.restart();
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

    // Основной интерфейс
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

        PolygonBackground {
            anchors.fill: parent
        }

        MainTitleBar {
            id: titleBar
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 10
            }
            isWindowMaximized: mainWindow.isWindowMaximized
            currentView: getCurrentViewName()
            mainWindow: mainWindow

            onToggleMaximize: mainWindow.toggleMaximize()
            onShowMinimized: mainWindow.showMinimized()
            onClose: Qt.quit()
        }

        MainMessage {
            id: errorMessage
            anchors { horizontalCenter: parent.horizontalCenter; top: titleBar.bottom; topMargin: 8 }
            width: Math.min(parent.width * 0.8, 600)
            messageText: _errorMessage
            showingMessage: _showingError
            messageType: "error"
            onCloseMessage: showError("")
        }

        MainMessage {
            id: successMessage
            anchors { horizontalCenter: parent.horizontalCenter; top: errorMessage.bottom; topMargin: 4 }
            width: Math.min(parent.width * 0.8, 600)
            messageText: _successMessage
            showingMessage: _showingSuccess
            messageType: "success"
            onCloseMessage: showSuccess("")
        }

        Rectangle {
            id: mainContent
            anchors {
                top: successMessage.bottom;
                bottom: parent.bottom;
                left: parent.left;
                right: parent.right;
                margins: 10;
                topMargin: 15
            }
            color: "transparent"

            // Адаптивная боковая панель
            AdaptiveSideBar {
                id: sideBar
                anchors { top: parent.top; bottom: parent.bottom; left: parent.left }

                onNavigateTo: function(view) {
                    navigateTo(view)
                }

                onLogout: {
                    logout()
                }
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

        // Индикатор загрузки
        Rectangle {
            id: loadingOverlay
            anchors.fill: mainContent
            color: "#80000000"
            radius: 12
            visible: isLoading
            z: 10

            Rectangle {
                width: 80
                height: 80
                radius: 40
                color: "#40000000"
                anchors.centerIn: parent

                RotationAnimation on rotation {
                    from: 0
                    to: 360
                    duration: 1200
                    running: loadingOverlay.visible
                    loops: Animation.Infinite
                }

                Text {
                    anchors.centerIn: parent
                    text: "⏳"
                    font.pixelSize: 24
                    color: "white"
                }
            }

            Column {
                anchors {
                    horizontalCenter: parent.horizontalCenter;
                    top: parent.verticalCenter;
                    topMargin: 60
                }
                spacing: 5

                Text {
                    text: "Загрузка данных..."
                    font.pixelSize: 14
                    color: "white"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: "Пожалуйста, подождите"
                    font.pixelSize: 11
                    color: "#cccccc"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }

    MainAPI {
        id: mainApi
        property string remoteApiBaseUrl: "https://deltablast.fun"
        property int remotePort: 5000
    }

    Timer {
        id: errorAutoHideTimer;
        interval: 8000;
        onTriggered: showError("")
    }

    Timer {
        id: successAutoHideTimer;
        interval: 4000;
        onTriggered: showSuccess("")
    }
}
