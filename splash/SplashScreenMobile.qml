import QtQuick
import Qt5Compat.GraphicalEffects
import "../common" as Common

Window {
    id: splashWindow
    width: Screen.width
    height: Screen.height
    flags: Qt.SplashScreen
    color: "transparent"
    modality: Qt.ApplicationModal
    visible: true

    property bool isMobile: true
    property real scaleFactor: Math.min(width / 700, height / 450, 1.0)
    property bool loadingComplete: false
    property int nearestCircleIndex: -1

    // ---- Палитра для кружков и искр
    property var circleColors: [
        "#f44336", "#ff9800", "#ffeb3b", "#4caf50", "#2196f3", "#9c27b0"
    ]

    // ---- Стандартный фон
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#6a11cb" }
            GradientStop { position: 1.0; color: "#2575fc" }
        }
    }

    // ---- Фоновые многоугольники
    Common.PolygonBackground {
        anchors.fill: parent
        polygonCount: 12
        isMobile: true
    }

    // ---- Быстрые искры
    Common.SparksBackground {
        anchors.fill: parent
        sparkCount: 24
        isMobile: true
        colors: circleColors
    }

    // ---- Кружки (по периметру, под прямоугольником)
    Repeater {
        id: rings
        model: circleColors.length

        Item {
            id: circleContainer
            width: 18 * scaleFactor
            height: 18 * scaleFactor
            z: 0

            property color circleColor: circleColors[index]
            property real t: index / circleColors.length
            property real speed: 12000 + Math.random() * 6000
            property bool isNearest: false

            function posAt(t) {
                var w = infoRectangle.width;
                var h = infoRectangle.height;
                var per = 2 * (w + h);
                var d = (t % 1) * per;
                var localX = 0, localY = 0;

                // Равномерное распределение по периметру
                if (d < w) {
                    localX = d;
                    localY = 0;
                }
                else if (d < w + h) {
                    localX = w;
                    localY = d - w;
                }
                else if (d < 2 * w + h) {
                    localX = w - (d - (w + h));
                    localY = h;
                }
                else {
                    localX = 0;
                    localY = h - (d - (2 * w + h));
                }

                return {
                    x: infoRectangle.x + localX - circleContainer.width / 2,
                    y: infoRectangle.y + localY - circleContainer.height / 2
                };
            }

            x: posAt(t).x
            y: posAt(t).y

            Rectangle {
                id: circle
                anchors.centerIn: parent
                width: circleContainer.isNearest ? 28 * scaleFactor : 18 * scaleFactor
                height: width
                radius: width / 2
                color: circleContainer.circleColor
                opacity: circleContainer.isNearest ? 1 : 0.9

                Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }
                Behavior on opacity { NumberAnimation { duration: 300 } }

                layer.enabled: true
                layer.effect: Glow {
                    color: circle.color
                    radius: circleContainer.isNearest ? 16 * scaleFactor : 10 * scaleFactor
                    samples: 20
                    transparentBorder: true
                }
            }

            // Импульс от круга
            Rectangle {
                id: pulse
                anchors.centerIn: parent
                width: circleContainer.isNearest ? 60 * scaleFactor : 0
                height: width
                radius: width / 2
                color: circleContainer.circleColor
                opacity: 0

                Behavior on width { NumberAnimation { duration: 800; easing.type: Easing.OutQuad } }
                Behavior on opacity { NumberAnimation { duration: 800 } }
            }

            NumberAnimation on t {
                from: circleContainer.t
                to: circleContainer.t + 1
                duration: circleContainer.speed
                loops: Animation.Infinite
                running: true
                easing.type: Easing.Linear
            }

            // Запуск импульса при приближении
            onIsNearestChanged: {
                if (isNearest) {
                    pulse.width = 60 * scaleFactor;
                    pulse.opacity = 0.5;
                    pulseTimer.restart();
                }
            }

            Timer {
                id: pulseTimer
                interval: 800
                onTriggered: {
                    pulse.width = 0;
                    pulse.opacity = 0;
                }
            }
        }
    }

    // ---- Основной прямоугольник (поверх кружков)
    Rectangle {
        id: infoRectangle
        width: parent.width * 0.6
        height: 120 * scaleFactor
        anchors.centerIn: parent
        color: "#ffffff"
        radius: 16 * scaleFactor
        opacity: 0.98
        z: 2

        property color glowColor: "#4caf50"

        // Радужная рамка
        border.width: 1
        border.color: "transparent"

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            border.width: parent.border.width
            border.color: "transparent"
            color: "transparent"

            layer.enabled: true
            layer.effect: LinearGradient {
                start: Qt.point(0, 0)
                end: Qt.point(width, height)
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#f44336" }
                    GradientStop { position: 0.2; color: "#ff9800" }
                    GradientStop { position: 0.4; color: "#ffeb3b" }
                    GradientStop { position: 0.6; color: "#4caf50" }
                    GradientStop { position: 0.8; color: "#2196f3" }
                    GradientStop { position: 1.0; color: "#9c27b0" }
                }
            }
        }

        // Glow подсветка
        layer.enabled: true
        layer.effect: Glow {
            color: infoRectangle.glowColor
            radius: 12 * scaleFactor
            samples: 25
            transparentBorder: true
        }

        // Иконка
        Text {
            id: iconText
            anchors.top: parent.top
            anchors.topMargin: 16 * scaleFactor
            anchors.horizontalCenter: parent.horizontalCenter
            text: "🎓"
            font.pixelSize: 28 * scaleFactor
        }

        // Название
        Text {
            id: appNameText
            anchors.top: iconText.bottom
            anchors.topMargin: 6 * scaleFactor
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#2c3e50"
            text: appName
            font.pixelSize: Math.max(14, 16 * scaleFactor)
            font.family: "SF Pro Display, Helvetica Neue, sans-serif"
            font.weight: Font.Medium
        }

        Text {
            id: appTextName
            anchors.top: appNameText.bottom
            anchors.topMargin: 3 * scaleFactor
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: Math.max(9, 11 * scaleFactor)
            text: "Курсовая Работа студента"
            color: "#808080"
            font.family: "SF Pro Text, Helvetica Neue, sans-serif"
        }

        // Версия
        Text {
            anchors.right: parent.right
            anchors.rightMargin: 10 * scaleFactor
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 6 * scaleFactor
            color: "#7f8c8d"
            text: appVersion
            font.pixelSize: Math.max(7, 9 * scaleFactor)
            font.family: "SF Mono, Monospace"
        }
    }

    // ---- Логика: подсветка рамки цветом ближайшего кружка
    Timer {
        interval: 450
        running: true
        repeat: true
        onTriggered: {
            var nearestColor = "#4caf50";
            var minDist = 999999;
            var currentNearestIndex = -1;

            for (var i = 0; i < rings.count; i++) {
                var c = rings.itemAt(i);
                if (!c) continue;
                var dx = (c.x + c.width / 2) - (infoRectangle.x + infoRectangle.width / 2);
                var dy = (c.y + c.height / 2) - (infoRectangle.y + infoRectangle.height / 2);
                var d = Math.sqrt(dx * dx + dy * dy);
                if (d < minDist) {
                    minDist = d;
                    nearestColor = c.circleColor;
                    currentNearestIndex = i;
                }

                c.isNearest = false;
            }

            if (currentNearestIndex !== -1) {
                rings.itemAt(currentNearestIndex).isNearest = true;
                infoRectangle.glowColor = nearestColor;

                if (nearestCircleIndex !== currentNearestIndex) {
                    nearestCircleIndex = currentNearestIndex;
                }
            }
        }
    }

    // ---- Статус загрузки и проценты
    Text {
        id: statusText
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: infoRectangle.bottom
        anchors.topMargin: 25 * scaleFactor
        text: "Инициализация системы..."
        font.pixelSize: Math.max(11, 13 * scaleFactor)
        color: "#ffffff"
        opacity: 0.95
        font.family: "SF Pro Text, Helvetica Neue, sans-serif"
    }

    // ---- Проценты загрузки
    Text {
        id: percentText
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: statusText.bottom
        anchors.topMargin: 8 * scaleFactor
        text: Math.floor(loadProgress * 100) + "%"
        font.pixelSize: Math.max(14, 16 * scaleFactor)
        color: "#ffffff"
        opacity: 0.9
        font.family: "SF Pro Display, Helvetica Neue, sans-serif"
        font.weight: Font.Medium
    }

    // ---- Прогресс загрузки
    property real loadProgress: 0.0

    Rectangle {
        id: progressBarBackground
        width: infoRectangle.width * 0.7
        height: 6 * scaleFactor
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: percentText.bottom
        anchors.topMargin: 15 * scaleFactor
        color: "#ffffff"
        opacity: 0.2
        radius: 4 * scaleFactor
    }

    Rectangle {
        id: progressBar
        width: progressBarBackground.width * loadProgress
        height: progressBarBackground.height
        anchors.left: progressBarBackground.left
        anchors.verticalCenter: progressBarBackground.verticalCenter
        color: infoRectangle.glowColor
        radius: 4 * scaleFactor
        Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
    }

    // ---- Таймер для загрузки (3 секунды)
    Timer {
        id: progressTimer
        interval: 30 // Обновление каждые 30мс для плавности
        running: true
        repeat: true
        onTriggered: {
            if (loadProgress < 1.0) {
                loadProgress += 0.01; // 100 шагов за 3 секунды

                // Обновляем текст статуса в зависимости от прогресса
                if (loadProgress < 0.3) {
                    statusText.text = "Инициализация системы...";
                } else if (loadProgress < 0.6) {
                    statusText.text = "Загрузка модулей...";
                } else if (loadProgress < 0.9) {
                    statusText.text = "Проверка лицензии...";
                } else {
                    statusText.text = "Завершение загрузки...";
                }
            } else {
                running = false;
                loadingComplete = true;
                splashWindow.close();

                // Решение о переходе в зависимости от первого запуска
                if (settingsManager.getFirstRun()) {
                    settingsManager.setFirstRun(false);
                    welcomeLoader.active = true;
                } else {
                    authLoader.active = true;
                }
            }
        }
    }

    Loader {
        id: welcomeLoader
        active: false
        source: "WelcomeScreen.qml"
        onLoaded: if (item) item.show()
    }

    Loader {
        id: authLoader
        active: false
        source: "../auth/Auth.qml"
        onLoaded: if (item) item.show()
    }
}
