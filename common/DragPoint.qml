import QtQuick

Item {
    id: dragPointRoot
    width: 60
    height: 60

    property point currentPoint: Qt.point(0, 0)
    property point startPoint: Qt.point(0, 0)
    property bool dragging: false

    x: currentPoint.x - width / 2
    y: currentPoint.y - height / 2
    z: 9999

    // Начальная точка (фиксированная)
    Rectangle {
        id: startPointVisual
        width: 30
        height: 30
        radius: 15
        x: startPoint.x - width / 2
        y: startPoint.y - height / 2
        color: "#3498db"
        opacity: dragging ? 0.7 : 0
        visible: dragging

        Behavior on opacity {
            NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
        }

        // Анимация пульсации для начальной точки
        SequentialAnimation on scale {
            running: dragging
            loops: Animation.Infinite
            NumberAnimation { from: 0.9; to: 1.1; duration: 1000; easing.type: Easing.InOutQuad }
            NumberAnimation { from: 1.1; to: 0.9; duration: 1000; easing.type: Easing.InOutQuad }
        }
    }

    // Промежуточные точки для отображения траектории
    Repeater {
        model: dragging ? 3 : 0

        Rectangle {
            id: trajectoryPoint
            width: 15 + index * 3
            height: 15 + index * 3
            radius: (15 + index * 3) / 2
            color: "#3498db"
            opacity: 0.4 - (index * 0.1)

            // Распределяем точки между начальной и текущей позицией
            x: startPoint.x + (currentPoint.x - startPoint.x) * (index + 1) / 4 - width / 2
            y: startPoint.y + (currentPoint.y - startPoint.y) * (index + 1) / 4 - height / 2

            // Анимация появления/исчезновения
            Behavior on opacity {
                NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }
        }
    }

    // Основная точка
    Rectangle {
        id: mainPoint
        width: 40
        height: 40
        radius: 20
        anchors.centerIn: parent

        gradient: Gradient {
            GradientStop { position: 0.0; color: "#6a11cb" }
            GradientStop { position: 0.5; color: "#8A2BE2" }
            GradientStop { position: 1.0; color: "#2575fc" }
        }

        opacity: 0.9

        // Анимация пульсации
        SequentialAnimation on scale {
            running: dragPointRoot.visible
            loops: Animation.Infinite
            NumberAnimation { from: 0.8; to: 1.2; duration: 800; easing.type: Easing.InOutQuad }
            NumberAnimation { from: 1.2; to: 0.8; duration: 800; easing.type: Easing.InOutQuad }
        }
    }

    // Внешнее свечение
    Rectangle {
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
        radius: width / 2
        color: "transparent"
        border.color: "#6a11cb"
        border.width: 2
        opacity: 0.6

        SequentialAnimation on scale {
            running: dragPointRoot.visible
            loops: Animation.Infinite
            NumberAnimation { from: 0.8; to: 1.5; duration: 1200; easing.type: Easing.OutQuad }
            NumberAnimation { from: 1.5; to: 0.8; duration: 1200; easing.type: Easing.InQuad }
        }
    }

    // Эффект частиц
    Repeater {
        model: 4
        Rectangle {
            width: 8
            height: 8
            radius: 3
            color: "#6a11cb"
            opacity: 0.7

            property real angle: index * 120 * Math.PI / 180
            property real distance: 25

            x: mainPoint.width / 2 + Math.cos(angle) * distance - width / 2
            y: mainPoint.height / 2 + Math.sin(angle) * distance - height / 2

            SequentialAnimation on scale {
                running: dragPointRoot.visible
                loops: Animation.Infinite
                NumberAnimation { from: 0.5; to: 1.5; duration: 1000 + index * 200; easing.type: Easing.InOutQuad }
                NumberAnimation { from: 1.5; to: 0.5; duration: 1000 + index * 200; easing.type: Easing.InOutQuad }
            }
        }
    }
}
