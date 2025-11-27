import QtQuick

Rectangle {
    id: dialogTitleBar
    height: 35
    color: "#ffffff"
    opacity: 0.925
    radius: 12
    z: 10

    property string title: ""
    property var window: null
    property bool isMobile: false
    property bool isDragging: false
    property point dragCurrentPoint: Qt.point(0, 0)

    signal close
    signal androidDragStarted(real startX, real startY)
    signal androidDragUpdated(real currentX, real currentY)
    signal androidDragEnded(real endX, real endY)

    Text {
        anchors.centerIn: parent
        text: title
        color: "#2c3e50"
        font.pixelSize: 13
        font.bold: true
    }

    // Визуальная точка перетаскивания для Android
    Rectangle {
        id: dragPoint
        width: 40
        height: 40
        radius: 20
        visible: isDragging && isMobile
        x: dragCurrentPoint.x - width / 2
        y: dragCurrentPoint.y - height / 2
        z: 1000

        gradient: Gradient {
            GradientStop { position: 0.0; color: "#6a11cb" }
            GradientStop { position: 0.5; color: "#8A2BE2" }
            GradientStop { position: 1.0; color: "#2575fc" }
        }

        opacity: 0.8

        // Анимация пульсации
        SequentialAnimation on scale {
            running: dragPoint.visible
            loops: Animation.Infinite
            NumberAnimation { from: 0.8; to: 1.2; duration: 800; easing.type: Easing.InOutQuad }
            NumberAnimation { from: 1.2; to: 0.8; duration: 800; easing.type: Easing.InOutQuad }
        }

        // Свечение
        Rectangle {
            anchors.centerIn: parent
            width: parent.width * 1.5
            height: parent.height * 1.5
            radius: width / 2
            color: "transparent"
            border.color: "#6a11cb"
            border.width: 2
            opacity: 0.4

            SequentialAnimation on scale {
                running: dragPoint.visible
                loops: Animation.Infinite
                NumberAnimation { from: 0.5; to: 1.5; duration: 1200; easing.type: Easing.OutQuad }
                NumberAnimation { from: 1.5; to: 0.5; duration: 1200; easing.type: Easing.InQuad }
            }
        }
    }

    // Кнопка закрытия
    Rectangle {
        id: closeButton
        width: 16
        height: 16
        radius: 8
        color: closeMouseArea.containsMouse ? "#ff5c5c" : "transparent"
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            rightMargin: 10
        }

        Text {
            anchors.centerIn: parent
            text: "×"
            color: closeMouseArea.containsMouse ? "white" : "#2c3e50"
            font.pixelSize: 12
            font.bold: true
        }

        MouseArea {
            id: closeMouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                Qt.callLater(function() {
                    dialogTitleBar.close()
                })
            }
        }
    }

    // Область для перетаскивания окна
    MouseArea {
        id: dragArea
        anchors {
            left: parent.left
            right: closeButton.left
            top: parent.top
            bottom: parent.bottom
            leftMargin: 10
        }

        property point clickPos: Qt.point(0, 0)
        property bool dragging: false

        onPressed: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                clickPos = Qt.point(mouse.x, mouse.y)

                if (isMobile) {
                    // Для мобильных устройств - запускаем перетаскивание с визуальной точкой
                    var globalPos = mapToItem(null, mouse.x, mouse.y)
                    androidDragStarted(globalPos.x, globalPos.y)
                } else {
                    // Для Windows/Linux - стандартное перетаскивание
                    dragging = true
                    if (window && typeof window.startSystemMove === "function") {
                        window.startSystemMove()
                        dragging = false
                    }
                }
            }
        }

        onPositionChanged: function(mouse) {
            if (isMobile) {
                // Для Android - обновляем позицию визуальной точки
                var globalPos = mapToItem(null, mouse.x, mouse.y)
                androidDragUpdated(globalPos.x, globalPos.y)
            } else if (dragging && mouse.buttons === Qt.LeftButton && window) {
                // Для Windows/Linux - стандартное перетаскивание окна
                var delta = Qt.point(mouse.x - clickPos.x, mouse.y - clickPos.y)
                window.x += delta.x
                window.y += delta.y
            }
        }

        onReleased: function(mouse) {
            if (isMobile) {
                // Для Android - завершаем перетаскивание
                var globalPos = mapToItem(null, mouse.x, mouse.y)
                androidDragEnded(globalPos.x, globalPos.y)
            } else {
                dragging = false
            }
        }

        onCanceled: {
            if (isMobile) {
                // Если перетаскивание отменено на Android
                androidDragEnded(dragArea.mouseX, dragArea.mouseY)
            } else {
                dragging = false
            }
        }
    }
}
