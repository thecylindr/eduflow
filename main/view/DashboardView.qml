import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

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

    function refreshDashboard() {
        if (loading) return;

        console.log("🔄 Обновление данных дашборда...")
        loading = true

        mainApi.getDashboard(function(response) {
            loading = false

            if (response.success) {
                var data = response.data
                console.log("✅ Данные дашборда получены:", JSON.stringify(data))

                // ИСПРАВЛЕНИЕ: Правильно извлекаем данные из вложенной структуры
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

                console.log("📊 Обновленные счетчики:",
                    "Преподаватели:", teachersCount,
                    "Студенты:", studentsCount,
                    "Группы:", groupsCount,
                    "Портфолио:", portfoliosCount,
                    "События:", eventsCount,
                    "Пользователь:", userLogin)

            } else {
                console.log("❌ Ошибка загрузки дашборда:", response.error)
                // Fallback - используем старые данные если доступны
                refreshStatsFallback()
            }
        })
    }

    function refreshStatsFallback() {
        console.log("🔄 Резервное обновление статистики...")
        teachersCount = mainWindow.teachers ? mainWindow.teachers.length : 0
        studentsCount = mainWindow.students ? mainWindow.students.length : 0
        groupsCount = mainWindow.groups ? mainWindow.groups.length : 0
        portfoliosCount = mainWindow.portfolios ? mainWindow.portfolios.length : 0
        eventsCount = mainWindow.events ? mainWindow.events.length : 0
        userLogin = "Неизвестный"
    }

    Component.onCompleted: {
        refreshDashboard()
    }

    Flickable {
        anchors.fill: parent
        contentHeight: contentColumn.height
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: contentColumn
            width: parent.width
            spacing: 15

            // Заголовок
            Column {
                width: parent.width
                spacing: 8

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 10

                    Image {
                        source: "qrc:/icons/home.png"
                        sourceSize: Qt.size(24, 24)
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "Панель управления"
                        font.pixelSize: 24
                        font.bold: true
                        color: "#2c3e50"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // Индикатор загрузки
                    Rectangle {
                        width: 20
                        height: 20
                        radius: 10
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
                            sourceSize: Qt.size(16, 16)
                        }
                    }
                }

                // ДОБАВЛЕНО: Отображение логина пользователя
                Text {
                    text: {
                        if (loading) return "Загрузка данных..."
                        if (userLogin) return "Вы вошли как: " + userLogin + " | Обзор системы и ключевые метрики"
                        return "Обзор системы и ключевые метрики"
                    }
                    font.pixelSize: 12
                    color: "#7f8c8d"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Rectangle {
                    width: parent.width
                    height: 2
                    color: "#3498db"
                    opacity: 0.3
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            // Компактная статистика
            Grid {
                columns: 3
                rowSpacing: 10
                columnSpacing: 10
                width: parent.width

                // Преподаватели
                Rectangle {
                    width: (parent.width - 20) / 3
                    height: 80
                    radius: 12
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
                        anchors.margins: 10
                        spacing: 10

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 8
                            color: "#3498db"
                            anchors.verticalCenter: parent.verticalCenter

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/teachers.png"
                                sourceSize: Qt.size(26, 26)
                                fillMode: Image.PreserveAspectFit
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                text: loading ? "..." : teachersCount
                                font.pixelSize: 20
                                font.bold: true
                                color: loading ? "#bdc3c7" : "#2c3e50"
                            }

                            Text {
                                text: "Преподаватели"
                                font.pixelSize: 10
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
                    width: (parent.width - 20) / 3
                    height: 80
                    radius: 12
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
                        anchors.margins: 10
                        spacing: 10

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 8
                            color: "#2ecc71"
                            anchors.verticalCenter: parent.verticalCenter

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/students.png"
                                sourceSize: Qt.size(26, 26)
                                fillMode: Image.PreserveAspectFit
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                text: loading ? "..." : studentsCount
                                font.pixelSize: 20
                                font.bold: true
                                color: loading ? "#bdc3c7" : "#2c3e50"
                            }

                            Text {
                                text: "Студенты"
                                font.pixelSize: 10
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
                    width: (parent.width - 20) / 3
                    height: 80
                    radius: 12
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
                        anchors.margins: 10
                        spacing: 10

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 8
                            color: "#e74c3c"
                            anchors.verticalCenter: parent.verticalCenter

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/groups.png"
                                sourceSize: Qt.size(26, 26)
                                fillMode: Image.PreserveAspectFit
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                text: loading ? "..." : groupsCount
                                font.pixelSize: 20
                                font.bold: true
                                color: loading ? "#bdc3c7" : "#2c3e50"
                            }

                            Text {
                                text: "Группы"
                                font.pixelSize: 10
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
                    width: (parent.width - 20) / 3
                    height: 80
                    radius: 12
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
                        anchors.margins: 10
                        spacing: 10

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 8
                            color: "#9b59b6"
                            anchors.verticalCenter: parent.verticalCenter

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/portfolio.png"
                                sourceSize: Qt.size(26, 26)
                                fillMode: Image.PreserveAspectFit
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                text: loading ? "..." : portfoliosCount
                                font.pixelSize: 20
                                font.bold: true
                                color: loading ? "#bdc3c7" : "#2c3e50"
                            }

                            Text {
                                text: "Портфолио"
                                font.pixelSize: 10
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
                    width: (parent.width - 20) / 3
                    height: 80
                    radius: 12
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
                        anchors.margins: 10
                        spacing: 10

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 8
                            color: "#e67e22"
                            anchors.verticalCenter: parent.verticalCenter

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/events.png"
                                sourceSize: Qt.size(26, 26)
                                fillMode: Image.PreserveAspectFit
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                text: loading ? "..." : eventsCount
                                font.pixelSize: 20
                                font.bold: true
                                color: loading ? "#bdc3c7" : "#2c3e50"
                            }

                            Text {
                                text: "События"
                                font.pixelSize: 10
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
                    width: (parent.width - 20) / 3
                    height: 80
                    radius: 12
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
                        anchors.margins: 10
                        spacing: 10

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 8
                            color: "#95a5a6"
                            anchors.verticalCenter: parent.verticalCenter

                            Loader {
                                id: settingsIconLoader
                                anchors.centerIn: parent
                                sourceComponent: settingsMouseArea.containsMouse ? animatedSettingsIcon : staticSettingsIcon
                            }

                            Component {
                                id: staticSettingsIcon
                                Image {
                                    source: "qrc:/icons/settings.png"
                                    sourceSize: Qt.size(26, 26)
                                    fillMode: Image.PreserveAspectFit
                                }
                            }

                            Component {
                                id: animatedSettingsIcon
                                AnimatedImage {
                                    source: "qrc:/icons/settings.gif"
                                    sourceSize: Qt.size(26, 26)
                                    fillMode: Image.PreserveAspectFit
                                    playing: true
                                    speed: 1.0
                                }
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                text: "Настройки системы"
                                font.pixelSize: 14
                                font.bold: true
                                color: "#2c3e50"
                            }

                            Text {
                                text: "изменить параметры"
                                font.pixelSize: 10
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
            Row {
                width: parent.width
                spacing: 20

                // Статус системы
                Rectangle {
                    width: (parent.width - 20) / 2
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
                                        if (loading) {
                                            return "Обновление данных...";
                                        } else {
                                            return "Все службы работают стабильно";
                                        }
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
                    width: (parent.width - 20) / 2
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
        }
    }

    // Автоматическое обновление каждые 1 минуту 30 секунд
    Timer {
        id: autoRefreshTimer
        interval: 90000
        running: true
        repeat: true
        onTriggered: refreshDashboard()
    }
}
