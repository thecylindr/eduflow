import QtQuick
import Qt5Compat.GraphicalEffects
import "common" as Common

Window {
    id: splashWindow
    width: isMobile ? Screen.width : 700
    height: isMobile ? Screen.height : 450
    flags: Qt.SplashScreen | (isMobile ? Qt.Window : Qt.FramelessWindowHint)
    color: "transparent"
    modality: Qt.ApplicationModal
    visible: true

    // Определяем мобильное устройство
    property bool isMobile: Screen.width < 768 || Screen.height < 768

    // Масштабирующий коэффициент для мобильных
    property real scaleFactor: isMobile ? Math.min(width / 700, height / 450, 1.0) : 1.0

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
        radius: isMobile ? 0 : 20
    }

    // ---- Фоновые многоугольники
    Common.PolygonBackground {
        anchors.fill: parent
        polygonCount: isMobile ? 4 : 15
        isMobile: isMobile
    }

    // ---- Быстрые искры
    Common.SparksBackground {
        anchors.fill: parent
        sparkCount: isMobile ? 4 : 32
        isMobile: isMobile
        colors: circleColors
    }

    // ---- Кружки (по периметру, под прямоугольником)
    Repeater {
        id: rings
        model: circleColors.length

        Item {
            id: circleContainer
            width: 22 * scaleFactor
            height: 22 * scaleFactor
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
                width: circleContainer.isNearest ? 35 * scaleFactor : 22 * scaleFactor
                height: width
                radius: width / 2
                color: circleContainer.circleColor
                opacity: circleContainer.isNearest ? 1 : 0.9

                Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }
                Behavior on opacity { NumberAnimation { duration: 300 } }

                layer.enabled: true
                layer.effect: Glow {
                    color: circle.color
                    radius: circleContainer.isNearest ? 20 * scaleFactor : 12 * scaleFactor
                    samples: 24
                    transparentBorder: true
                }
            }

            // Импульс от круга - увеличенный радиус
            Rectangle {
                id: pulse
                anchors.centerIn: parent
                width: circleContainer.isNearest ? 80 * scaleFactor : 0
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
                    pulse.width = 80 * scaleFactor;
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
        width: isMobile ? Math.min(parent.width * 0.8, 400) : 260
        height: isMobile ? 160 * scaleFactor : 140
        anchors.centerIn: parent
        color: "#ffffff"
        radius: 12 * scaleFactor
        opacity: 0.98
        z: 2

        // Добавляем свойство для цвета свечения
        property color glowColor: "#4caf50"

        // рамка всегда многоцветная (радужная)
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

        // Glow подсветка под цвет ближайшего кружка - увеличенная
        layer.enabled: true
        layer.effect: Glow {
            color: infoRectangle.glowColor
            radius: 15 * scaleFactor
            samples: 35
            transparentBorder: true
        }

        // Иконка
        Text {
            id: iconText
            anchors.top: parent.top
            anchors.topMargin: 20 * scaleFactor
            anchors.horizontalCenter: parent.horizontalCenter
            text: "🎓"
            font.pixelSize: 36 * scaleFactor
        }

        // Название
        Text {
            id: appNameText
            anchors.top: iconText.bottom
            anchors.topMargin: 8 * scaleFactor
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#2c3e50"
            text: appName
            font.pixelSize: Math.max(16, 18 * scaleFactor)
            font.family: "Arial"
            font.weight: Font.Bold
        }

        Text {
            id: appTextName
            anchors.top: appNameText.bottom
            anchors.topMargin: 4 * scaleFactor
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: Math.max(10, 12 * scaleFactor)
            text: "Курсовая Работа студента"
            color: "#808080"
        }

        // Версия
        Text {
            anchors.right: parent.right
            anchors.rightMargin: 12 * scaleFactor
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8 * scaleFactor
            color: "#7f8c8d"
            text: appVersion
            font.pixelSize: Math.max(8, 10 * scaleFactor)
            font.family: "Monospace"
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

                // Сбрасываем состояние isNearest для всех кругов
                c.isNearest = false;
            }

            // Устанавливаем isNearest только для ближайшего круга
            if (currentNearestIndex !== -1) {
                rings.itemAt(currentNearestIndex).isNearest = true;
                infoRectangle.glowColor = nearestColor;

                // Запоминаем индекс ближайшего круга
                if (nearestCircleIndex !== currentNearestIndex) {
                    nearestCircleIndex = currentNearestIndex;
                }
            }
        }
    }

    // ---- Статус загрузки
    Text {
        id: statusText
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: infoRectangle.bottom
        anchors.topMargin: 30 * scaleFactor
        text: "Инициализация системы..."
        font.pixelSize: Math.max(12, 14 * scaleFactor)
        color: "#ffffff"
        opacity: 0.95
    }

    // ---- Прогресс загрузки
    property real loadProgress: 0.0

    Rectangle {
        id: progressBarBackground
        width: infoRectangle.width * 0.78
        height: 8 * scaleFactor
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: statusText.bottom
        anchors.topMargin: 20 * scaleFactor
        color: "#ffffff"
        opacity: 0.18
        radius: 6 * scaleFactor
    }

    Rectangle {
        id: progressBar
        width: progressBarBackground.width * loadProgress
        height: progressBarBackground.height
        anchors.left: progressBarBackground.left
        anchors.verticalCenter: progressBarBackground.verticalCenter
        color: infoRectangle.glowColor
        radius: 6 * scaleFactor
        Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
    }

    // ---- Таймер для имитации загрузки
    Timer {
        id: progressTimer
        interval: 50
        running: true
        repeat: true
        onTriggered: {
            if (loadProgress < 1.0) {
                loadProgress += 0.01;

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
                authLoader.active = true;
            }
        }
    }

    Loader {
        id: authLoader
        active: false
        source: "auth/Auth.qml"
        onLoaded: if (item) item.show()
    }
}
