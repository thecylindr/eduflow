import QtQuick
import QtQuick.Layouts 1.15
import QtQuick.Controls

Item {
    id: dashboardView

    // Используем отдельные свойства для принудительного обновления
    property int teachersCount: 0
    property int studentsCount: 0
    property int groupsCount: 0
    property int portfoliosCount: 0
    property int eventsCount: 0
    property string userLogin: ""

    property bool loading: false
    property bool firstLoad: true // Флаг первой загрузки

    // Определяем мобильное устройство из родительского окна
    property bool isMobile: mainWindow ? mainWindow.isMobile : false

    function refreshDashboard() {
        loading = true

        mainApi.getDashboard(function(response) {
            loading = false
            firstLoad = false

            if (response.success) {
                var data = response.data

                var dashboardData = data.data || {}
                var stats = dashboardData.stats || {}
                var user = dashboardData.user || {}

                // Принудительно обновляем каждое свойство
                teachersCount = stats.teachers || 0
                studentsCount = stats.students || 0
                groupsCount = stats.groups || 0
                portfoliosCount = stats.portfolios || 0
                eventsCount = stats.events || 0
                userLogin = user.login || ""

            } else {
                refreshStatsFallback()
            }
        })
    }

    function refreshStatsFallback() {
        teachersCount = mainWindow.teachers ? mainWindow.teachers.length : 0
        studentsCount = mainWindow.students ? mainWindow.students.length : 0
        groupsCount = mainWindow.groups ? mainWindow.groups.length : 0
        portfoliosCount = mainWindow.portfolios ? mainWindow.portfolios.length : 0
        eventsCount = mainWindow.events ? mainWindow.events.length : 0
        userLogin = "Неизвестный"
    }

    onVisibleChanged: {
        if (visible) {
            refreshTimer.start()
        }
    }

    Timer {
        id: refreshTimer
        interval: 100
        onTriggered: {
            refreshDashboard()
        }
    }

    Component.onCompleted: {
        refreshTimer.start()
    }

    Flickable {
        anchors.fill: parent
        contentHeight: contentColumn.height
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: contentColumn
            width: parent.width
            spacing: isMobile ? 10 : 15

            // Заголовок (упрощенный для мобильных)
            Column {
                width: parent.width
                spacing: isMobile ? 5 : 8

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 8

                    Image {
                        source: "qrc:/icons/home.png"
                        sourceSize: Qt.size(isMobile ? 20 : 24, isMobile ? 20 : 24)
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "Панель управления"
                        font.pixelSize: isMobile ? 18 : 24
                        font.bold: true
                        color: "#2c3e50"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // Индикатор загрузки
                    Rectangle {
                        width: isMobile ? 16 : 20
                        height: isMobile ? 16 : 20
                        radius: isMobile ? 8 : 10
                        color: "transparent"
                        visible: loading

                        RotationAnimator on rotation {
                            from: 0
                            to: 360
                            duration: 1000
                            running: loading
                            loops: Animation.Infinite
                        }

                        Image {
                            anchors.fill: parent
                            source: "qrc:/icons/refresh.png"
                            sourceSize: Qt.size(isMobile ? 12 : 16, isMobile ? 12 : 16)
                        }
                    }
                }

                // ДОБАВЛЕНО: Отображение логина пользователя
                Text {
                    text: {
                        if (loading && firstLoad) return "Загрузка данных..."
                        if (loading) return "Обновление данных..."
                        if (userLogin) return "Вы вошли как: " + userLogin
                        return "Обзор системы и ключевые метрики"
                    }
                    font.pixelSize: isMobile ? 10 : 12
                    color: "#7f8c8d"
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignHCenter
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#3498db"
                    opacity: 0.3
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            // Компактная статистика - адаптивная сетка
            Grid {
                columns: isMobile ? 2 : 3
                rowSpacing: isMobile ? 8 : 10
                columnSpacing: isMobile ? 8 : 10
                width: parent.width

                // Преподаватели
                Rectangle {
                    width: (parent.width - (isMobile ? 8 : 20)) / (isMobile ? 2 : 3)
                    height: isMobile ? 70 : 80
                    radius: 10
                    color: teachersMouseArea.containsMouse ? "#e3f2fd" : "#ffffff"
                    border.color: teachersMouseArea.containsMouse ? "#3498db" : "#e0e0e0"
                    border.width: 1

                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }
                    Behavior on border.color {
                        ColorAnimation { duration: 200 }
                    }

                    Row {
                        anchors.fill: parent
                        anchors.margins: isMobile ? 8 : 10
                        spacing: isMobile ? 8 : 10

                        Rectangle {
                            width: isMobile ? 32 : 40
                            height: isMobile ? 32 : 40
                            radius: 6
                            color: "#3498db"
                            anchors.verticalCenter: parent.verticalCenter

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/teachers.png"
                                sourceSize: Qt.size(isMobile ? 24 : 28, isMobile ? 24 : 28)
                                fillMode: Image.PreserveAspectFit
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                text: loading && firstLoad ? "..." : teachersCount
                                font.pixelSize: isMobile ? 16 : 20
                                font.bold: true
                                color: (loading && firstLoad) ? "#bdc3c7" : "#2c3e50"
                            }

                            Text {
                                text: "Преподаватели"
                                font.pixelSize: isMobile ? 11 : 12
                                color: "#7f8c8d"
                            }
                        }
                    }

                    MouseArea {
                        id: teachersMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mainWindow.navigateTo("teachers")
                    }
                }

                // Студенты
                Rectangle {
                    width: (parent.width - (isMobile ? 8 : 20)) / (isMobile ? 2 : 3)
                    height: isMobile ? 70 : 80
                    radius: 10
                    color: studentsMouseArea.containsMouse ? "#e8f5e8" : "#ffffff"
                    border.color: studentsMouseArea.containsMouse ? "#2ecc71" : "#e0e0e0"
                    border.width: 1

                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }
                    Behavior on border.color {
                        ColorAnimation { duration: 200 }
                    }

                    Row {
                        anchors.fill: parent
                        anchors.margins: isMobile ? 8 : 10
                        spacing: isMobile ? 8 : 10

                        Rectangle {
                            width: isMobile ? 32 : 40
                            height: isMobile ? 32 : 40
                            radius: 6
                            color: "#2ecc71"
                            anchors.verticalCenter: parent.verticalCenter

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/students.png"
                                sourceSize: Qt.size(isMobile ? 24 : 28, isMobile ? 24 : 28)
                                fillMode: Image.PreserveAspectFit
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                text: loading && firstLoad ? "..." : studentsCount
                                font.pixelSize: isMobile ? 16 : 20
                                font.bold: true
                                color: (loading && firstLoad) ? "#bdc3c7" : "#2c3e50"
                            }

                            Text {
                                text: "Студенты"
                                font.pixelSize: isMobile ? 11 : 12
                                color: "#7f8c8d"
                            }
                        }
                    }

                    MouseArea {
                        id: studentsMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mainWindow.navigateTo("students")
                    }
                }

                // Группы
                Rectangle {
                    width: (parent.width - (isMobile ? 8 : 20)) / (isMobile ? 2 : 3)
                    height: isMobile ? 70 : 80
                    radius: 10
                    color: groupsMouseArea.containsMouse ? "#fdedec" : "#ffffff"
                    border.color: groupsMouseArea.containsMouse ? "#e74c3c" : "#e0e0e0"
                    border.width: 1

                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }
                    Behavior on border.color {
                        ColorAnimation { duration: 200 }
                    }

                    Row {
                        anchors.fill: parent
                        anchors.margins: isMobile ? 8 : 10
                        spacing: isMobile ? 8 : 10

                        Rectangle {
                            width: isMobile ? 32 : 40
                            height: isMobile ? 32 : 40
                            radius: 6
                            color: "#e74c3c"
                            anchors.verticalCenter: parent.verticalCenter

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/groups.png"
                                sourceSize: Qt.size(isMobile ? 24 : 28, isMobile ? 24 : 28)
                                fillMode: Image.PreserveAspectFit
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                text: loading && firstLoad ? "..." : groupsCount
                                font.pixelSize: isMobile ? 16 : 20
                                font.bold: true
                                color: (loading && firstLoad) ? "#bdc3c7" : "#2c3e50"
                            }

                            Text {
                                text: "Группы"
                                font.pixelSize: isMobile ? 11 : 12
                                color: "#7f8c8d"
                            }
                        }
                    }

                    MouseArea {
                        id: groupsMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mainWindow.navigateTo("groups")
                    }
                }

                // Портфолио
                Rectangle {
                    width: (parent.width - (isMobile ? 8 : 20)) / (isMobile ? 2 : 3)
                    height: isMobile ? 70 : 80
                    radius: 10
                    color: portfolioMouseArea.containsMouse ? "#f3e8fd" : "#ffffff"
                    border.color: portfolioMouseArea.containsMouse ? "#9b59b6" : "#e0e0e0"
                    border.width: 1

                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }
                    Behavior on border.color {
                        ColorAnimation { duration: 200 }
                    }

                    Row {
                        anchors.fill: parent
                        anchors.margins: isMobile ? 8 : 10
                        spacing: isMobile ? 8 : 10

                        Rectangle {
                            width: isMobile ? 32 : 40
                            height: isMobile ? 32 : 40
                            radius: 6
                            color: "#9b59b6"
                            anchors.verticalCenter: parent.verticalCenter

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/portfolio.png"
                                sourceSize: Qt.size(isMobile ? 24 : 28, isMobile ? 24 : 28)
                                fillMode: Image.PreserveAspectFit
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                text: loading && firstLoad ? "..." : portfoliosCount
                                font.pixelSize: isMobile ? 16 : 20
                                font.bold: true
                                color: (loading && firstLoad) ? "#bdc3c7" : "#2c3e50"
                            }

                            Text {
                                text: "Портфолио"
                                font.pixelSize: isMobile ? 11 : 12
                                color: "#7f8c8d"
                            }
                        }
                    }

                    MouseArea {
                        id: portfolioMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mainWindow.navigateTo("portfolio")
                    }
                }

                // События
                Rectangle {
                    width: (parent.width - (isMobile ? 8 : 20)) / (isMobile ? 2 : 3)
                    height: isMobile ? 70 : 80
                    radius: 10
                    color: eventsMouseArea.containsMouse ? "#fef5e7" : "#ffffff"
                    border.color: eventsMouseArea.containsMouse ? "#e67e22" : "#e0e0e0"
                    border.width: 1

                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }
                    Behavior on border.color {
                        ColorAnimation { duration: 200 }
                    }

                    Row {
                        anchors.fill: parent
                        anchors.margins: isMobile ? 8 : 10
                        spacing: isMobile ? 8 : 10

                        Rectangle {
                            width: isMobile ? 32 : 40
                            height: isMobile ? 32 : 40
                            radius: 6
                            color: "#e67e22"
                            anchors.verticalCenter: parent.verticalCenter

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/events.png"
                                sourceSize: Qt.size(isMobile ? 24 : 28, isMobile ? 24 : 28)
                                fillMode: Image.PreserveAspectFit
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                text: loading && firstLoad ? "..." : eventsCount
                                font.pixelSize: isMobile ? 16 : 20
                                font.bold: true
                                color: (loading && firstLoad) ? "#bdc3c7" : "#2c3e50"
                            }

                            Text {
                                text: "События"
                                font.pixelSize: isMobile ? 11 : 12
                                color: "#7f8c8d"
                            }
                        }
                    }

                    MouseArea {
                        id: eventsMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mainWindow.navigateTo("events")
                    }
                }

                // Настройки системы
                Rectangle {
                    width: (parent.width - (isMobile ? 8 : 20)) / (isMobile ? 2 : 3)
                    height: isMobile ? 70 : 80
                    radius: 10
                    color: settingsMouseArea.containsMouse ? "#f2f3f4" : "#ffffff"
                    border.color: settingsMouseArea.containsMouse ? "#95a5a6" : "#e0e0e0"
                    border.width: 1

                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }
                    Behavior on border.color {
                        ColorAnimation { duration: 200 }
                    }

                    Row {
                        anchors.fill: parent
                        anchors.margins: isMobile ? 8 : 10
                        spacing: isMobile ? 8 : 10

                        Rectangle {
                            width: isMobile ? 32 : 40
                            height: isMobile ? 32 : 40
                            radius: 6
                            color: "#95a5a6"
                            anchors.verticalCenter: parent.verticalCenter

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/settings.png"
                                sourceSize: Qt.size(isMobile ? 24 : 28, isMobile ? 24 : 28)
                                fillMode: Image.PreserveAspectFit
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                text: "Настройки"
                                font.pixelSize: isMobile ? 14 : 16
                                font.bold: true
                                color: "#2c3e50"
                            }

                            Text {
                                text: "Системы, вашего профиля и т.д."
                                font.pixelSize: isMobile ? 11 : 12
                                color: "#7f8c8d"
                            }
                        }
                    }

                    MouseArea {
                        id: settingsMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mainWindow.navigateTo("settings")
                    }
                }
            }

            // Системная информация и кнопка обновления
            Column {
                width: parent.width
                spacing: isMobile ? 10 : 20
                visible: !isMobile // На мобильных скрываем эту секцию для экономии места

                // Статус системы
                Rectangle {
                    width: parent.width
                    height: 120
                    radius: 12
                    color: "#ffffff"
                    border.color: "#e0e0e0"
                    border.width: 1

                    Column {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 10

                        Row {
                            width: parent.width
                            spacing: 15
                            topPadding: 5

                            AnimatedImage {
                                width: 60
                                height: 60
                                source: "qrc:/icons/test.gif"
                                playing: true
                                speed: 0.85
                                clip: true
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 6

                                Text {
                                    text: "Система активна"
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: "#2c3e50"
                                }

                                Text {
                                    text: {
                                        if (loading && firstLoad) return "Загрузка данных..."
                                        if (loading) return "Обновление данных..."
                                        return "Все службы работают стабильно"
                                    }
                                    font.pixelSize: 12
                                    color: "#7f8c8d"
                                }
                            }
                        }

                        Text {
                            text: {
                                var now = new Date();
                                return "Последняя проверка: " + now.toLocaleTimeString(Qt.locale(), "hh:mm:ss");
                            }
                            font.pixelSize: 10
                            color: "#bdc3c7"
                            width: parent.width
                        }
                    }
                }

                // Кнопка обновления
                Rectangle {
                    width: parent.width
                    height: 50
                    radius: 8
                    color: refreshMouseArea.containsMouse ? "#2c81ba" : "#3498db"

                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }

                    Row {
                        anchors.centerIn: parent
                        spacing: 8

                        Image {
                            source: "qrc:/icons/refresh.png"
                            sourceSize: Qt.size(20, 20)
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: loading ? "Обновление..." : "Обновить данные"
                            font.pixelSize: 14
                            color: "white"
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: refreshMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: refreshDashboard()
                    }
                }
            }

            // Мобильная кнопка обновления
            Rectangle {
                width: parent.width
                height: 45
                radius: 8
                color: mobileRefreshMouseArea.containsMouse ? "#2c81ba" : "#3498db"
                visible: isMobile

                Row {
                    anchors.centerIn: parent
                    spacing: 8

                    Image {
                        source: "qrc:/icons/refresh.png"
                        sourceSize: Qt.size(18, 18)
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: loading ? "Обновление..." : "Обновить"
                        font.pixelSize: 14
                        color: "white"
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: mobileRefreshMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: refreshDashboard()
                }
            }
        }
    }

    // Автоматическое обновление каждые 1 минуту 30 секунд
    Timer {
        id: autoRefreshTimer
        interval: 90000
        running: true
        repeat: true
        onTriggered: {
            refreshDashboard()
        }
    }
}
