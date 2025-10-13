// main/Main.qml
import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: mainWindow
    width: 1200
    height: 800
    visible: true
    title: "EduFlow - Система управления образованием"
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint
    minimumWidth: 1000
    minimumHeight: 700

    property string authToken: ""
    property bool isWindowMaximized: false
    property string currentView: "dashboard"
    property bool isLoading: false

    // Сообщения
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

    // API ошибки
    property var apiErrors: ({
        "teachers": "",
        "students": "",
        "groups": "",
        "portfolio": "",
        "events": "",
        "dashboard": ""
    })

    Component.onCompleted: {
        console.log("Main window initialized with token:", authToken ? "***" + authToken.slice(-8) : "none")

        // Инициализация API
        var serverAddress = settingsManager.useLocalServer ?
            settingsManager.serverAddress :
            (mainApi.remoteApiBaseUrl + ":" + mainApi.remotePort)

        mainApi.setConfig(authToken, serverAddress, settingsManager.useLocalServer)

        loadInitialData()
    }

    function loadInitialData() {
        isLoading = true
        clearAllErrors()

        // Параллельная загрузка данных
        var loadPromises = [
            { name: "teachers", func: loadTeachers },
            { name: "students", func: loadStudents },
            { name: "groups", func: loadGroups }
        ]

        var loadedCount = 0
        var totalToLoad = loadPromises.length

        function checkAllLoaded() {
            loadedCount++
            if (loadedCount >= totalToLoad) {
                isLoading = false
                if (!hasAnyError()) {
                    showSuccess("Данные успешно загружены")
                }
            }
        }

        loadPromises.forEach(function(promise) {
            promise.func.call(this, checkAllLoaded)
        })

        loadTimeoutTimer.start()
    }

    function loadTeachers(callback) {
        mainApi.getTeachers(function(result) {
            loadTimeoutTimer.stop()
            if (result.success) {
                teachers = result.data || []
                console.log("Loaded teachers:", teachers.length)
                clearError("teachers")
            } else {
                setError("teachers", "Ошибка загрузки преподавателей: " + result.error)
                showError("Ошибка загрузки преподавателей: " + result.error)
            }
            if (callback) callback()
        })
    }

    function loadStudents(callback) {
        mainApi.getStudents(function(result) {
            if (result.success) {
                students = result.data || []
                console.log("Loaded students:", students.length)
                clearError("students")
            } else {
                setError("students", "Ошибка загрузки студентов: " + result.error)
                showError("Ошибка загрузки студентов: " + result.error)
            }
            if (callback) callback()
        })
    }

    function loadGroups(callback) {
        mainApi.getGroups(function(result) {
            if (result.success) {
                groups = result.data || []
                console.log("Loaded groups:", groups.length)
                clearError("groups")
            } else {
                setError("groups", "Ошибка загрузки групп: " + result.error)
                showError("Ошибка загрузки групп: " + result.error)
            }
            if (callback) callback()
        })
    }

    function loadPortfolio(callback) {
        mainApi.getPortfolios(function(result) {
            if (result.success) {
                portfolio = result.data || []
                console.log("Loaded portfolio items:", portfolio.length)
                clearError("portfolio")
            } else {
                setError("portfolio", "Ошибка загрузки портфолио: " + result.error)
                showError("Ошибка загрузки портфолио: " + result.error)
            }
            if (callback) callback()
        })
    }

    function loadEvents(callback) {
        mainApi.getEvents(function(result) {
            if (result.success) {
                events = result.data || []
                console.log("Loaded events:", events.length)
                clearError("events")
            } else {
                setError("events", "Ошибка загрузки событий: " + result.error)
                showError("Ошибка загрузки событий: " + result.error)
            }
            if (callback) callback()
        })
    }

    // Управление ошибками
    function setError(section, message) {
        apiErrors[section] = message
        console.error("Error in", section + ":", message)
    }

    function clearError(section) {
        apiErrors[section] = ""
    }

    function clearAllErrors() {
        for (var key in apiErrors) {
            apiErrors[key] = ""
        }
    }

    function hasError(section) {
        return apiErrors[section] !== ""
    }

    function hasAnyError() {
        for (var key in apiErrors) {
            if (apiErrors[key] !== "") return true
        }
        return false
    }

    function getError(section) {
        return apiErrors[section] || ""
    }

    function showError(message) {
        _successMessage = ""
        _showingSuccess = false
        _errorMessage = message
        _showingError = message !== ""

        if (_showingError) {
            errorAutoHideTimer.restart()
        }
    }

    function showSuccess(message) {
        _errorMessage = ""
        _showingError = false
        _successMessage = message
        _showingSuccess = message !== ""

        if (_showingSuccess) {
            successAutoHideTimer.restart()
        }
    }

    function toggleMaximize() {
        if (isWindowMaximized) {
            showNormal()
            isWindowMaximized = false
        } else {
            showMaximized()
            isWindowMaximized = true
        }
    }

    function navigateTo(view) {
        currentView = view
        console.log("Navigated to:", view)

        // Загружаем данные для выбранного раздела если они еще не загружены
        if (view === "portfolio" && portfolio.length === 0 && !hasError("portfolio")) {
            loadPortfolio()
        } else if (view === "events" && events.length === 0 && !hasError("events")) {
            loadEvents()
        }
    }

    // Основной контейнер
    Rectangle {
        id: windowContainer
        anchors.fill: parent
        radius: 16
        color: "#f0f0f0"
        clip: true

        // Градиентный фон
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#667eea" }
                GradientStop { position: 1.0; color: "#764ba2" }
            }
        }

        // Упрощенный фон с полигонами
        PolygonBackground {
            anchors.fill: parent
        }

        // Заголовок
        MainTitleBar {
            id: titleBar
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 10
            }
            isWindowMaximized: mainWindow.isWindowMaximized
            currentView: getViewTitle(mainWindow.currentView)

            onToggleMaximize: toggleMaximize()
            onShowMinimized: showMinimized()
            onClose: Qt.quit()
        }

        function getViewTitle(view) {
            var titles = {
                "dashboard": "Главная панель",
                "teachers": "Преподаватели",
                "students": "Студенты",
                "groups": "Группы",
                "portfolio": "Портфолио",
                "events": "События"
            }
            return titles[view] || "Главная панель"
        }

        // Сообщения
        MainMessage {
            id: errorMessage
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: titleBar.bottom
                topMargin: 8
            }
            width: Math.min(parent.width * 0.8, 600)
            messageText: _errorMessage
            showingMessage: _showingError
            messageType: "error"
            onCloseMessage: showError("")
        }

        MainMessage {
            id: successMessage
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: errorMessage.bottom
                topMargin: 4
            }
            width: Math.min(parent.width * 0.8, 600)
            messageText: _successMessage
            showingMessage: _showingSuccess
            messageType: "success"
            onCloseMessage: showSuccess("")
        }

        // Основной контент
        Rectangle {
            id: mainContent
            anchors {
                top: successMessage.bottom
                bottom: parent.bottom
                left: parent.left
                right: parent.right
                margins: 10
                topMargin: 15
            }
            color: "transparent"

            // Боковая панель навигации (слева)
            Rectangle {
                id: sideBar
                width: 280
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: parent.left
                }
                color: "#f8f8f8"
                radius: 12
                opacity: 0.95

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10

                    Text {
                        text: "🎯 Панель управления"
                        font.pixelSize: 18
                        font.bold: true
                        color: "#2c3e50"
                        Layout.alignment: Qt.AlignHCenter
                        Layout.bottomMargin: 10
                    }

                    // Основные разделы
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Text {
                            text: "📊 Основные разделы"
                            font.pixelSize: 12
                            font.bold: true
                            color: "#7f8c8d"
                            Layout.bottomMargin: 5
                        }

                        Repeater {
                            model: [
                                {icon: "🏠", name: "Главная панель", view: "dashboard", errorKey: "dashboard"},
                                {icon: "👨‍🏫", name: "Преподаватели", view: "teachers", errorKey: "teachers"},
                                {icon: "👨‍🎓", name: "Студенты", view: "students", errorKey: "students"},
                                {icon: "👥", name: "Группы", view: "groups", errorKey: "groups"},
                                {icon: "📁", name: "Портфолио", view: "portfolio", errorKey: "portfolio"},
                                {icon: "📅", name: "События", view: "events", errorKey: "events"}
                            ]

                            Rectangle {
                                Layout.fillWidth: true
                                height: 50
                                radius: 8
                                color: mainWindow.currentView === modelData.view ? "#3498db" :
                                      (navMouseArea.containsMouse ? "#ecf0f1" : "transparent")
                                border.color: mainWindow.currentView === modelData.view ? "#2980b9" : "transparent"
                                border.width: 2

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 12

                                    Text {
                                        text: modelData.icon
                                        font.pixelSize: 16
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 2

                                        Text {
                                            text: modelData.name
                                            color: mainWindow.currentView === modelData.view ? "white" : "#2c3e50"
                                            font.pixelSize: 13
                                            font.bold: true
                                        }

                                        // Показать ошибку для раздела
                                        Text {
                                            text: hasError(modelData.errorKey) ? "❌ Ошибка загрузки" : ""
                                            font.pixelSize: 9
                                            color: "#e74c3c"
                                            visible: hasError(modelData.errorKey)
                                        }
                                    }

                                    Item {
                                        Layout.fillWidth: true
                                    }

                                    // Индикатор загрузки/ошибки
                                    Rectangle {
                                        width: 8
                                        height: 8
                                        radius: 4
                                        anchors.verticalCenter: parent.verticalCenter
                                        color: {
                                            if (hasError(modelData.errorKey)) return "#e74c3c"
                                            if (isLoading && mainWindow.currentView === modelData.view) return "#f39c12"
                                            return mainWindow.currentView === modelData.view ? "#2ecc71" : "transparent"
                                        }
                                    }
                                }

                                MouseArea {
                                    id: navMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: navigateTo(modelData.view)
                                }
                            }
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                    }

                    // Статистика и быстрые действия
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        // Статистика
                        Rectangle {
                            Layout.fillWidth: true
                            height: 100
                            radius: 8
                            color: "#e8f4f8"
                            border.color: "#bde0fe"
                            border.width: 1

                            Column {
                                anchors.centerIn: parent
                                spacing: 3

                                Text {
                                    text: "📈 Статистика системы"
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: "#2c3e50"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                Text {
                                    text: "👨‍🏫 " + teachers.length + " преподавателей"
                                    font.pixelSize: 10
                                    color: hasError("teachers") ? "#e74c3c" : "#7f8c8d"
                                }

                                Text {
                                    text: "👨‍🎓 " + students.length + " студентов"
                                    font.pixelSize: 10
                                    color: hasError("students") ? "#e74c3c" : "#7f8c8d"
                                }

                                Text {
                                    text: "👥 " + groups.length + " групп"
                                    font.pixelSize: 10
                                    color: hasError("groups") ? "#e74c3c" : "#7f8c8d"
                                }

                                Text {
                                    text: "📊 " + (portfolio.length + events.length) + " записей"
                                    font.pixelSize: 10
                                    color: (hasError("portfolio") || hasError("events")) ? "#e74c3c" : "#7f8c8d"
                                }
                            }
                        }

                        // Быстрые действия
                        Rectangle {
                            Layout.fillWidth: true
                            height: 80
                            radius: 8
                            color: "#fff3cd"
                            border.color: "#ffeaa7"
                            border.width: 1

                            Column {
                                anchors.centerIn: parent
                                spacing: 5

                                Text {
                                    text: "🚀 Быстрые действия"
                                    font.pixelSize: 11
                                    font.bold: true
                                    color: "#856404"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                Row {
                                    spacing: 8
                                    anchors.horizontalCenter: parent.horizontalCenter

                                    Rectangle {
                                        width: 70
                                        height: 25
                                        radius: 5
                                        color: quickAddMouseArea.pressed ? "#2980b9" : "#3498db"

                                        Text {
                                            anchors.centerIn: parent
                                            text: "+ Студент"
                                            font.pixelSize: 9
                                            color: "white"
                                            font.bold: true
                                        }

                                        MouseArea {
                                            id: quickAddMouseArea
                                            anchors.fill: parent
                                            onClicked: showError("Функция добавления студента в разработке")
                                        }
                                    }

                                    Rectangle {
                                        width: 70
                                        height: 25
                                        radius: 5
                                        color: quickEventMouseArea.pressed ? "#27ae60" : "#2ecc71"

                                        Text {
                                            anchors.centerIn: parent
                                            text: "+ Событие"
                                            font.pixelSize: 9
                                            color: "white"
                                            font.bold: true
                                        }

                                        MouseArea {
                                            id: quickEventMouseArea
                                            anchors.fill: parent
                                            onClicked: showError("Функция добавления события в разработке")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Область контента (справа)
            Rectangle {
                id: contentArea
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: sideBar.right
                    right: parent.right
                    leftMargin: 15
                }
                color: "#f8f8f8"
                radius: 12
                opacity: 0.95

                Loader {
                    id: contentLoader
                    anchors.fill: parent
                    anchors.margins: 10
                    source: getViewComponent(mainWindow.currentView)
                }

                function getViewComponent(view) {
                    var components = {
                        "dashboard": "DashboardView.qml",
                        "teachers": "TeachersView.qml",
                        "students": "StudentsView.qml",
                        "groups": "GroupsView.qml",
                        "portfolio": "PortfolioView.qml",
                        "events": "EventsView.qml"
                    }
                    return components[view] || "DashboardView.qml"
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
                    horizontalCenter: parent.horizontalCenter
                    top: parent.verticalCenter
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
        id: errorAutoHideTimer
        interval: 8000
        onTriggered: showError("")
    }

    Timer {
        id: successAutoHideTimer
        interval: 4000
        onTriggered: showSuccess("")
    }

    Timer {
        id: loadTimeoutTimer
        interval: 15000
        onTriggered: {
            isLoading = false
            showError("Таймаут загрузки данных. Проверьте подключение к серверу.")
        }
    }
}
