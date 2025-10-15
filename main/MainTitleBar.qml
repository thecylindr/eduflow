import QtQuick 2.15

Rectangle {
    id: titleBar
    height: 35
    color: "#ffffff"
    opacity: 1
    radius: 12
    z: 10

    property bool isWindowMaximized: false
    property string currentView: "Главная"
    property var mainWindow: null

    signal toggleMaximize
    signal showMinimized
    signal close

    Text {
        anchors.centerIn: parent
        text: currentView + " | " + appName
        color: "#2c3e50"
        font.pixelSize: 13
        font.bold: true
    }

    Rectangle {
        id: gitflicButton
        width: 16
        height: 16
        radius: 8
        color: gitflicMouseArea.containsMouse ? "#4CAF50" : "transparent"
        anchors {
            left: parent.left
            leftMargin: 10
            verticalCenter: parent.verticalCenter
        }

        Text {
            anchors.centerIn: parent
            text: "🌐"
            font.pixelSize: 10
            color: gitflicMouseArea.containsMouse ? "white" : "#2c3e50"
        }

        MouseArea {
            id: gitflicMouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                Qt.openUrlExternally("https://gitflic.ru/project/cylindr/eduflow");
            }
        }
    }

    Row {
        id: windowButtons
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            rightMargin: 8
        }
        spacing: 6

        Rectangle {
            id: minimizeBtn
            width: 16
            height: 16
            radius: 8
            color: minimizeMouseArea.containsMouse ? "#FFD960" : "transparent"

            Text {
                anchors.centerIn: parent
                text: "-"
                color: minimizeMouseArea.containsMouse ? "white" : "#2c3e50"
                font.pixelSize: 12
                font.bold: true
            }

            MouseArea {
                id: minimizeMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: titleBar.showMinimized()
            }
        }

        Rectangle {
            id: maximizeBtn
            width: 16
            height: 16
            radius: 8
            color: maximizeMouseArea.containsMouse ? "#3498db" : "transparent"

            Text {
                anchors.centerIn: parent
                text: titleBar.isWindowMaximized ? "❐" : "⛶"
                color: maximizeMouseArea.containsMouse ? "white" : "#2c3e50"
                font.pixelSize: 10
                font.bold: true
            }

            MouseArea {
                id: maximizeMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: titleBar.toggleMaximize()
            }
        }

        Rectangle {
            id: closeButton
            width: 16
            height: 16
            radius: 8
            color: closeMouseArea.containsMouse ? "#ff5c5c" : "transparent"

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
                onClicked: titleBar.close()
            }
        }
    }

    // Универсальная область для перетаскивания окна (Для Linux & Windows)
    MouseArea {
        id: dragArea
        anchors {
            left: gitflicButton.right
            right: windowButtons.left
            top: parent.top
            bottom: parent.bottom
            leftMargin: 5
        }
        drag.target: null
        property point clickPos: Qt.point(0, 0)
        onPressed: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                clickPos = Qt.point(mouse.x, mouse.y)
                if (titleBar.mainWindow && typeof titleBar.mainWindow.startSystemMove === "function") {
                    titleBar.mainWindow.startSystemMove()
                }
            }
        }
        onPositionChanged: function(mouse) {
            if (mouse.buttons === Qt.LeftButton && titleBar.mainWindow && !titleBar.mainWindow.startSystemMove) {
                var delta = Qt.point(mouse.x - clickPos.x, mouse.y - clickPos.y)
                titleBar.mainWindow.x += delta.x
                titleBar.mainWindow.y += delta.y
            }
        }
    }
}
