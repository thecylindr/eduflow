// common/DialogTitleBar.qml
import QtQuick 2.15

Rectangle {
    id: dialogTitleBar
    height: 35
    color: "#ffffff"
    opacity: 0.925
    radius: 12
    z: 10

    property string title: ""
    property var window: null

    signal close

    Text {
        anchors.centerIn: parent
        text: title
        color: "#2c3e50"
        font.pixelSize: 13
        font.bold: true
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
            onClicked: dialogTitleBar.close()
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
                dragging = true

                if (window && typeof window.startSystemMove === "function") {
                    window.startSystemMove()
                    dragging = false
                }
            }
        }

        onPositionChanged: function(mouse) {
            if (dragging && mouse.buttons === Qt.LeftButton && window) {
                var delta = Qt.point(mouse.x - clickPos.x, mouse.y - clickPos.y)
                window.x += delta.x
                window.y += delta.y
            }
        }

        onReleased: {
            dragging = false
        }
    }
}
