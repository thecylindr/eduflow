import QtQuick 2.15
import Qt5Compat.GraphicalEffects

Item {
    id: root
    anchors.fill: parent

    Repeater {
        id: shapesRepeater
        model: 8

        Item {
            id: shapeContainer
            property real startX: 0
            property real startY: 0
            property real targetX: 0
            property real targetY: 0
            property real shapeSize: 60 + Math.random() * 80
            property bool isCircle: Math.random() > 0.5
            property color shapeColor: [
                "#FF5252", "#FF4081", "#E040FB", "#7C4DFF", "#536DFE",
                "#448AFF", "#40C4FF", "#18FFFF", "#64FFDA", "#69F0AE"
            ][Math.floor(Math.random() * 10)]

            width: shapeSize * 2
            height: shapeSize * 2
            opacity: 0

            Component.onCompleted: {
                // Инициализируем позиции после создания компонента
                startX = Math.random() * (root.width + 100) - 50
                startY = Math.random() * (root.height + 100) - 50
                targetX = Math.random() * (root.width + 100) - 50
                targetY = Math.random() * (root.height + 100) - 50
                x = startX
                y = startY

                // Запускаем анимацию после установки позиций
                shapeAnimation.start()
            }

            Rectangle {
                id: shapeRect
                anchors.centerIn: parent
                width: shapeSize
                height: shapeSize
                radius: isCircle ? width / 2 : 20
                color: shapeContainer.shapeColor
            }

            Glow {
                anchors.fill: shapeRect
                radius: 12
                samples: 16
                color: shapeContainer.shapeColor
                source: shapeRect
                opacity: shapeContainer.opacity * 0.5
            }

            SequentialAnimation {
                id: shapeAnimation
                loops: Animation.Infinite

                PauseAnimation { duration: index * 800 }

                ParallelAnimation {
                    NumberAnimation {
                        target: shapeContainer
                        property: "opacity"
                        from: 0
                        to: 0.4
                        duration: 2000
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        target: shapeContainer
                        property: "x"
                        from: shapeContainer.startX
                        to: shapeContainer.targetX
                        duration: 15000
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        target: shapeContainer
                        property: "y"
                        from: shapeContainer.startY
                        to: shapeContainer.targetY
                        duration: 15000
                        easing.type: Easing.InOutQuad
                    }
                    RotationAnimation {
                        target: shapeContainer
                        from: 0
                        to: 360
                        duration: 20000
                        easing.type: Easing.InOutQuad
                    }
                    ScaleAnimator {
                        target: shapeContainer
                        from: 0.8
                        to: 1.2
                        duration: 8000
                        easing.type: Easing.InOutQuad
                    }
                }

                PauseAnimation { duration: 2000 }

                ParallelAnimation {
                    NumberAnimation {
                        target: shapeContainer
                        property: "opacity"
                        from: 0.4
                        to: 0
                        duration: 3000
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        target: shapeContainer
                        property: "x"
                        from: shapeContainer.targetX
                        to: shapeContainer.targetX + (Math.random() - 0.5) * 200
                        duration: 3000
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        target: shapeContainer
                        property: "y"
                        from: shapeContainer.targetY
                        to: shapeContainer.targetY + (Math.random() - 0.5) * 200
                        duration: 3000
                        easing.type: Easing.InOutQuad
                    }
                }

                PauseAnimation { duration: 1000 + Math.random() * 2000 }

                ScriptAction {
                    script: {
                        // Обновляем позиции для следующей итерации
                        shapeContainer.startX = shapeContainer.x
                        shapeContainer.startY = shapeContainer.y
                        shapeContainer.targetX = Math.random() * (root.width + 120) - 60
                        shapeContainer.targetY = Math.random() * (root.height + 120) - 60
                        shapeContainer.shapeColor = [
                            "#FF5252", "#FF4081", "#E040FB", "#7C4DFF", "#536DFE",
                            "#448AFF", "#40C4FF", "#18FFFF", "#64FFDA", "#69F0AE"
                        ][Math.floor(Math.random() * 10)]
                        shapeContainer.isCircle = Math.random() > 0.5
                    }
                }
            }
        }
    }
}
