import QtQuick 2.15
import QtQuick.Window 2.15
import Qt5Compat.GraphicalEffects

Window {
    id: splashWindow
    width: 700
    height: 450
    flags: Qt.SplashScreen | Qt.FramelessWindowHint
    color: "transparent"
    modality: Qt.ApplicationModal
    visible: true

    property bool loadingComplete: false
    property int nearestCircleIndex: -1

    // ---- Палитра для кружков и искр
    property var circleColors: [
        "#f44336", // красный
        "#ff9800", // оранжевый
        "#ffeb3b", // жёлтый
        "#4caf50", // зелёный
        "#2196f3", // синий
        "#9c27b0"  // фиолетовый
    ]

    // ---- Стандартный фон
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#6a11cb" }
            GradientStop { position: 1.0; color: "#2575fc" }
        }
        radius: 20
    }

    // Анимация ожидания
    Rectangle {
        id: loadingAnimation
        width: 70
        height: 70
        anchors.centerIn: parent
        color: "transparent"
        visible: false
        opacity: 0

        property real spinnerRotation: 0

        Behavior on opacity { NumberAnimation { duration: 300 } }

        Canvas {
            id: spinnerCanvas
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                ctx.strokeStyle = "#8A2BE2";
                ctx.lineWidth = 3;
                ctx.lineCap = "round";

                var centerX = width / 2;
                var centerY = height / 2;
                var radius = Math.min(width, height) / 2 - 8;

                ctx.beginPath();
                ctx.arc(centerX, centerY, radius,
                        loadingAnimation.spinnerRotation * Math.PI / 180,
                        (loadingAnimation.spinnerRotation + 270) * Math.PI / 180,
                        false);
                ctx.stroke();
            }
        }

        RotationAnimation {
            target: loadingAnimation
            property: "spinnerRotation"
            from: 0
            to: 360
            duration: 1200
            loops: Animation.Infinite
            running: loadingAnimation.visible
        }

        Glow {
            anchors.fill: spinnerCanvas
            radius: 6
            samples: 12
            color: "#8A2BE2"
            source: spinnerCanvas
            transparentBorder: true
        }

        onSpinnerRotationChanged: spinnerCanvas.requestPaint()
    }

    // Многоугольники с анимацией
    Repeater {
        id: polygonRepeater
        model: 15

        Item {
            id: polygonContainer
            property real startX: Math.random() * (splashWindow.width + 200) - 60
            property real startY: Math.random() * (splashWindow.height + 200) - 60
            property real targetX: Math.random() * (splashWindow.width + 200) - 60
            property real targetY: Math.random() * (splashWindow.height + 200) - 60
            property real polygonSize: 30 + Math.random() * 45
            property color polygonColor: [
                "#FF5252", "#FF4081", "#E040FB", "#7C4DFF", "#536DFE",
                "#448AFF", "#40C4FF", "#18FFFF", "#64FFDA", "#69F0AE"
            ][Math.floor(Math.random() * 10)]

            x: startX
            y: startY
            opacity: 0
            width: polygonSize * 2
            height: polygonSize * 2

            Canvas {
                id: polygonCanvas
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    drawPolygon(ctx);
                }

                function drawPolygon(ctx) {
                    var sides = 6 + Math.floor(Math.random() * 3);
                    var radius = polygonSize;
                    var centerX = width / 2;
                    var centerY = height / 2;

                    ctx.shadowColor = polygonColor;
                    ctx.shadowBlur = 12;

                    ctx.beginPath();
                    ctx.moveTo(centerX + radius * Math.cos(0), centerY + radius * Math.sin(0));

                    for (var i = 1; i <= sides; i++) {
                        ctx.lineTo(centerX + radius * Math.cos(i * 2 * Math.PI / sides),
                                  centerY + radius * Math.sin(i * 2 * Math.PI / sides));
                    }

                    ctx.closePath();
                    ctx.fillStyle = polygonColor;
                    ctx.fill();
                }
            }

            Glow {
                anchors.fill: polygonCanvas
                radius: 10
                samples: 14
                color: polygonContainer.polygonColor
                source: polygonCanvas
                opacity: polygonContainer.opacity * 0.6
            }

            SequentialAnimation {
                id: appearAnimation
                running: true
                loops: Animation.Infinite
                PauseAnimation { duration: index * 1200 }
                ParallelAnimation {
                    NumberAnimation {
                        target: polygonContainer; property: "opacity"; from: 0; to: 0.6; duration: 3000; easing.type: Easing.InOutQuad }
                    NumberAnimation {
                        target: polygonContainer; property: "x"; from: startX; to: targetX; duration: 12000; easing.type: Easing.InOutQuad }
                    NumberAnimation {
                        target: polygonContainer; property: "y"; from: startY; to: targetY; duration: 12000; easing.type: Easing.InOutQuad }
                    RotationAnimation {
                        target: polygonContainer; from: 0; to: 90 + Math.random() * 90; duration: 10000; easing.type: Easing.InOutQuad }
                }
                PauseAnimation { duration: 3000 }
                ParallelAnimation {
                    NumberAnimation {
                        target: polygonContainer; property: "opacity"; from: 0.6; to: 0; duration: 4000; easing.type: Easing.InOutQuad }
                    NumberAnimation {
                        target: polygonContainer; property: "x"; from: targetX; to: targetX + (Math.random() - 0.5) * 150; duration: 4000; easing.type: Easing.InOutQuad }
                    NumberAnimation {
                        target: polygonContainer; property: "y"; from: targetY; to: targetY + (Math.random() - 0.5) * 150; duration: 4000; easing.type: Easing.InOutQuad }
                }
                PauseAnimation { duration: 2000 + Math.random() * 3000 }
                ScriptAction {
                    script: {
                        polygonContainer.startX = polygonContainer.x;
                        polygonContainer.startY = polygonContainer.y;
                        polygonContainer.polygonColor = [
                            "#FF5252", "#FF4081", "#E040FB", "#7C4DFF", "#536DFE",
                            "#448AFF", "#40C4FF", "#18FFFF", "#64FFDA", "#69F0AE"
                        ][Math.floor(Math.random() * 10)];
                        polygonCanvas.requestPaint();
                    }
                }
            }
            Component.onCompleted: polygonCanvas.requestPaint()
        }
    }

    // Быстрые искры при загрузке
    Repeater {
        id: sparks
        model: 20

        Rectangle {
            id: spark
            width: 2 + Math.random() * 4
            height: width
            radius: width / 2
            color: circleColors[Math.floor(Math.random() * circleColors.length)]
            opacity: 0
            z: 1

            property real startX: Math.random() * splashWindow.width
            property real startY: Math.random() * splashWindow.height
            property real targetX: Math.random() * splashWindow.width
            property real targetY: Math.random() * splashWindow.height
            property real speed: 1000 + Math.random() * 2000

            x: startX
            y: startY

            layer.enabled: true
            layer.effect: Glow {
                color: spark.color
                radius: 8
                samples: 16
                transparentBorder: true
            }

            SequentialAnimation {
                running: true
                loops: Animation.Infinite
                PauseAnimation { duration: Math.random() * 2000 }
                ParallelAnimation {
                    NumberAnimation {
                        target: spark; property: "opacity"; from: 0; to: 0.8; duration: 500; easing.type: Easing.InOutQuad }
                    NumberAnimation {
                        target: spark; property: "x"; from: startX; to: targetX; duration: speed; easing.type: Easing.InOutQuad }
                    NumberAnimation {
                        target: spark; property: "y"; from: startY; to: targetY; duration: speed; easing.type: Easing.InOutQuad }
                }
                NumberAnimation {
                    target: spark; property: "opacity"; to: 0; duration: 500; easing.type: Easing.InOutQuad }
                ScriptAction {
                    script: {
                        spark.startX = Math.random() * splashWindow.width;
                        spark.startY = Math.random() * splashWindow.height;
                        spark.targetX = Math.random() * splashWindow.width;
                        spark.targetY = Math.random() * splashWindow.height;
                        spark.color = circleColors[Math.floor(Math.random() * circleColors.length)];
                        spark.speed = 1000 + Math.random() * 2000;
                    }
                }
            }
        }
    }

    // ---- Кружки (по периметру, под прямоугольником)
    Repeater {
        id: rings
        model: circleColors.length

        Item {
            id: circleContainer
            width: 22
            height: 22
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
                width: circleContainer.isNearest ? 35 : 22
                height: width
                radius: width / 2
                color: circleContainer.circleColor
                opacity: circleContainer.isNearest ? 1 : 0.9

                Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }
                Behavior on opacity { NumberAnimation { duration: 300 } }

                layer.enabled: true
                layer.effect: Glow {
                    color: circle.color
                    radius: circleContainer.isNearest ? 20 : 12
                    samples: 24
                    transparentBorder: true
                }
            }

            // Импульс от круга - увеличенный радиус
            Rectangle {
                id: pulse
                anchors.centerIn: parent
                width: circleContainer.isNearest ? 80 : 0
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
                    pulse.width = 80;
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
        width: 260
        height: 140
        anchors.centerIn: parent
        color: "#ffffff"
        radius: 12
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
            radius: 15
            samples: 35
            transparentBorder: true
        }

        // Иконка
        Text {
            id: iconText
            anchors.top: parent.top
            anchors.topMargin: 18
            anchors.horizontalCenter: parent.horizontalCenter
            text: "🎓"
            font.pixelSize: 34
        }

        // Название
        Text {
            id: appNameText
            anchors.top: iconText.bottom
            anchors.topMargin: 6
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#2c3e50"
            text: appName
            font.pixelSize: 18
            font.family: "Arial"
            font.weight: Font.Bold
        }

        Text {
            id: appTextName
            anchors.top: appNameText.bottom
            anchors.topMargin: 4
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 12
            text: "Курсовая Работа студента"
            color: "#808080"
        }

        // Версия
        Text {
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8
            color: "#7f8c8d"
            text: appVersion
            font.pixelSize: 10
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
        anchors.topMargin: 26
        text: "Инициализация системы..."
        font.pixelSize: 14
        color: "#ffffff"
        opacity: 0.95
    }

    // ---- Прогресс загрузки
    property real loadProgress: 0.0

    Rectangle {
        id: progressBarBackground
        width: infoRectangle.width * 0.78
        height: 8
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: statusText.bottom
        anchors.topMargin: 16
        color: "#ffffff"
        opacity: 0.18
        radius: 6
    }

    Rectangle {
        id: progressBar
        width: progressBarBackground.width * loadProgress
        height: progressBarBackground.height
        anchors.left: progressBarBackground.left
        anchors.verticalCenter: progressBarBackground.verticalCenter
        color: infoRectangle.glowColor
        radius: 6
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
