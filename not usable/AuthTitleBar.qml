import QtQuick 2.15

Rectangle {
    id: titleBar
    height: 25
    color: "#ffffff"
    opacity: 1
    radius: 12
    z: 10

    property bool isWindowMaximized: false
    property bool useLocalServer: false
    property int windowWidth: 420
    property int windowHeight: 500

    signal toggleMaximize
    signal showMinimized
    signal close
    signal windowResized(int newWidth, int newHeight)

    Text {
        anchors.centerIn: parent
        text: {
            var baseText = "Вход в систему | " + appName;
            return baseText;
        }
        color: "#2c3e50"
        font.pixelSize: {
            if (windowWidth < 450) return 12;
            if (windowWidth < 500) return 13;
            return 13;
        }
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
            leftMargin: 1
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
        id: buttonRowsPanel
        z: 11
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            rightMargin: 8
        }
        spacing: 6

        Rectangle {
            id: minimizeButton
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
                onClicked: showMinimized()
            }
        }

        Rectangle {
            id: maximizeButton
            width: 16
            height: 16
            radius: 8
            color: maximizeMouseArea.containsMouse ? "#3498db" : "transparent"

            Text {
                anchors.centerIn: parent
                text: isWindowMaximized ? "❐" : "⛶"
                color: maximizeMouseArea.containsMouse ? "white" : "#2c3e50"
                font.pixelSize: 10
                font.bold: true
            }

            MouseArea {
                id: maximizeMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: toggleMaximize()
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
                onClicked: close()
            }
        }
    }

    // Универсальная область для перетаскивания окна (Для Linux & Windows)
    MouseArea {
        id: dragArea
        anchors {
            left: gitflicButton.right
            right: buttonRowsPanel.left
            top: parent.top
            bottom: parent.bottom
            leftMargin: 5
        }
        drag.target: null
        property point clickPos: Qt.point(0, 0)
        onPressed: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                clickPos = Qt.point(mouse.x, mouse.y)
                    authWindow.startSystemMove()
                    }
                }
                onPositionChanged: function(mouse) {
                    if (mouse.buttons === Qt.LeftButton && !authWindow.startSystemMove) {
                        var delta = Qt.point(mouse.x - clickPos.x, mouse.y - clickPos.y)
                        authWindow.x += delta.x
                        authWindow.y += delta.y
                    }
                }
            }


    // Элементы для изменения размера окна
    Rectangle {
        id: resizeHandle
        width: 10
        height: 10
        color: "transparent"
        anchors {
            right: parent.right
            bottom: parent.bottom
        }

        MouseArea {
            id: resizeMouseArea
            anchors.fill: parent
            cursorShape: Qt.SizeFDiagCursor
            drag{ target: null; axis: Drag.XAndYAxis }

            onPressed: {
                // Запоминаем начальные размеры
                resizeMouseArea.previousWidth = authWindow.width;
                resizeMouseArea.previousHeight = authWindow.height;
            }

            onPositionChanged: {
                if (pressed) {
                    var newWidth = resizeMouseArea.previousWidth + mouse.x;
                    var newHeight = resizeMouseArea.previousHeight + mouse.y;

                    // Ограничиваем размеры в пределах минимальных и максимальных значений
                    newWidth = Math.max(authWindow.minimumWidth, Math.min(authWindow.maximumWidth, newWidth));
                    newHeight = Math.max(authWindow.minimumHeight, Math.min(authWindow.maximumHeight, newHeight));

                    // Устанавливаем новые размеры
                    authWindow.width = newWidth;
                    authWindow.height = newHeight;

                    // Отправляем сигнал об изменении размера
                    windowResized(newWidth, newHeight);
                }
            }

            property real previousWidth: 0
            property real previousHeight: 0
        }
    }
}
