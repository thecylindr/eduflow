import QtQuick

Item {
    id: dragPointRoot
    width: 60
    height: 60

    property point currentPoint: Qt.point(0, 0)

    x: currentPoint.x - width / 2
    y: currentPoint.y - height / 2
    z: 9999 // Поверх всех окон

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

    // Эффект частиц (упрощенный)
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
