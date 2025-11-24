import QtQuick
import QtQuick.Controls
import "../common" as Common

Window {
    id: welcomeWindow
    width: Screen.width
    height: Screen.height
    flags: Qt.SplashScreen
    visible: true
    color: "transparent"

    property real scaleFactor: Math.min(width / 700, height / 450, 1.0)

    // Градиент такой же как в сплеш-скринах
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#6a11cb" }
            GradientStop { position: 1.0; color: "#2575fc" }
        }
    }

    // Основной контент
    Column {
        id: mainContent
        anchors.centerIn: parent
        spacing: 30 * scaleFactor
        width: parent.width * 0.8

        // Анимированное появление текста приветствия
        Text {
            id: welcomeText
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: "Добро пожаловать"
            color: "white"
            font.pixelSize: 42 * scaleFactor
            font.family: "Segoe Script, Comic Sans MS, cursive"
            font.weight: Font.Normal
            wrapMode: Text.WordWrap
            opacity: 0

            Component.onCompleted: {
                welcomeAppear.start()
            }

            // Легкое дрожание как у рукописного текста
            RotationAnimation on rotation {
                id: textShake
                from: -0.5
                to: 0.5
                duration: 4000
                loops: Animation.Infinite
                easing.type: Easing.InOutQuad
                direction: RotationAnimation.Alternate
                running: false
            }
        }

        // Декоративный элемент под текстом
        Rectangle {
            width: 100 * scaleFactor
            height: 2 * scaleFactor
            anchors.horizontalCenter: parent.horizontalCenter
            color: "white"
            opacity: 0.5
            radius: 1 * scaleFactor
        }
    }

    // Нижняя панель с инструкцией
    Column {
        id: bottomPanel
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 60 * scaleFactor
        }
        spacing: 15 * scaleFactor
        width: parent.width * 0.8

        // Стрелка, указывающая вверх на текст
        Text {
            id: arrow
            anchors.horizontalCenter: parent.horizontalCenter
            text: "↑"
            font.pixelSize: 24 * scaleFactor
            color: "white"
            opacity: 0

            // Плавающая анимация
            SequentialAnimation on y {
                id: arrowFloat
                running: false
                loops: Animation.Infinite
                NumberAnimation {
                    to: arrow.y - 10 * scaleFactor;
                    duration: 1000;
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    to: arrow.y + 10 * scaleFactor;
                    duration: 1000;
                    easing.type: Easing.InOutQuad
                }
            }
        }

        // Текст инструкции
        Text {
            id: instructionText
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: "Коснитесь экрана в любом месте\nдля продолжения"
            color: "white"
            font.pixelSize: 16 * scaleFactor
            font.family: "Segoe Script, Comic Sans MS, cursive"
            font.weight: Font.Normal
            lineHeight: 1.3
            wrapMode: Text.WordWrap
            opacity: 0
        }
    }

    // Анимация появления элементов
    SequentialAnimation {
        id: welcomeAppear
        running: false

        // Появление основного текста
        NumberAnimation {
            target: welcomeText
            property: "opacity"
            from: 0
            to: 1
            duration: 1200
            easing.type: Easing.InOutQuad
        }

        ScriptAction {
            script: {
                textShake.running = true
            }
        }

        PauseAnimation { duration: 500 }

        // Появление стрелки и инструкции
        ParallelAnimation {
            NumberAnimation {
                target: arrow
                property: "opacity"
                from: 0
                to: 0.8
                duration: 800
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                target: instructionText
                property: "opacity"
                from: 0
                to: 0.9
                duration: 800
                easing.type: Easing.InOutQuad
            }
        }

        ScriptAction {
            script: {
                arrowFloat.running = true
            }
        }
    }

    // Область для нажатия на весь экран
    MouseArea {
        anchors.fill: parent
        onClicked: {
            // Останавливаем таймер автоматического перехода
            autoTransitionTimer.stop()
            // Анимация исчезновения перед переходом
            exitAnimation.start()
        }
    }

    // Таймер для автоматического перехода (10 секунд)
    Timer {
        id: autoTransitionTimer
        interval: 10000
        running: true
        onTriggered: {
            exitAnimation.start()
        }
    }

    // Анимация выхода
    SequentialAnimation {
        id: exitAnimation

        // Одновременное исчезновение всех элементов
        ParallelAnimation {
            NumberAnimation {
                target: welcomeText
                property: "opacity"
                to: 0
                duration: 500
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                target: instructionText
                property: "opacity"
                to: 0
                duration: 500
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                target: arrow
                property: "opacity"
                to: 0
                duration: 500
                easing.type: Easing.InOutQuad
            }
        }

        ScriptAction {
            script: {
                welcomeWindow.close()
                authLoader.active = true
            }
        }
    }

    // Прогресс-бар для визуализации оставшегося времени
    Rectangle {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: 10
            leftMargin: 20 * scaleFactor
            rightMargin: 20 * scaleFactor
        }
        height: 3 * scaleFactor
        color: "white"
        opacity: 0.2
        radius: 1.5 * scaleFactor

        Rectangle {
            id: progressFill
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
            }
            width: 0
            color: "white"
            opacity: 0.6
            radius: 1.5 * scaleFactor
        }
    }

    // Таймер для обновления прогресс-бара (теперь на 10 секунд)
    Timer {
        id: progressTimer
        interval: 50
        running: true
        repeat: true
        onTriggered: {
            var elapsed = 10000 - autoTransitionTimer.interval
            progressFill.width = parent.width * (elapsed / 10000)
        }
    }

    Loader {
        id: authLoader
        active: false
        source: "../auth/Auth.qml"
        onLoaded: if (item) item.show()
    }

    // Эффект плавного появления всего экрана
    OpacityAnimator {
        target: welcomeWindow
        from: 0
        to: 1
        duration: 800
        running: true
    }

    Component.onCompleted: {
        welcomeAppear.start()
    }
}
