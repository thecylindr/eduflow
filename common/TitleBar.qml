import QtQuick 2.15

Rectangle {
    id: titleBar
    height: 35
    color: "#ffffff"
    opacity: 0.925
    radius: 12
    z: 10

    property var window: null
    property string currentView: ""
    property bool isWindowMaximized: false
    property bool showGitflicButton: true
    property bool showWindowButtons: true

    signal toggleMaximize
    signal showMinimized
    signal close

    Text {
        anchors.centerIn: parent
        text: currentView + (appName ? " | " + appName : "")
        color: "#2c3e50"
        font.pixelSize: 13
        font.bold: true
    }

    // Кнопка Gitflic (опциональная)
    Rectangle {
        id: gitflicButton
        width: 28  // Увеличил размер
        height: 28
        radius: 14
        color: gitflicMouseArea.containsMouse ? "#4CAF50" : "transparent"
        anchors {
            left: parent.left
            leftMargin: 10
            verticalCenter: parent.verticalCenter
        }
        visible: showGitflicButton

        Image {
            anchors.centerIn: parent
            source: "qrc:/icons/git.png"
            sourceSize: Qt.size(18, 18)  // Увеличил размер иконки
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

    // Кнопки управления окном (опциональные)
    Row {
        id: windowButtons
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            rightMargin: 8
        }
        spacing: 6
        visible: showWindowButtons

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
                onClicked: {
                    if (window && typeof window.showMinimized === "function") {
                        window.showMinimized();
                    } else {
                        titleBar.showMinimized();
                    }
                }
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
                text: isWindowMaximized ? "❐" : "⛶"
                color: maximizeMouseArea.containsMouse ? "white" : "#2c3e50"
                font.pixelSize: 10
                font.bold: true
            }

            MouseArea {
                id: maximizeMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    if (window && typeof window.toggleMaximize === "function") {
                        window.toggleMaximize();
                    } else {
                        titleBar.toggleMaximize();
                    }
                }
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
                onClicked: {
                    if (window && typeof window.close === "function") {
                        Qt.quit();
                    } else {
                        titleBar.close();
                    }
                }
            }
        }
    }

    // Универсальная область для перетаскивания окна (Кроссплатформенная)
    MouseArea {
        id: dragArea
        anchors {
            left: gitflicButton.right
            right: windowButtons.left
            top: parent.top
            bottom: parent.bottom
            leftMargin: 5
        }

        property point clickPos: Qt.point(0, 0)
        property bool dragging: false

        onPressed: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                clickPos = Qt.point(mouse.x, mouse.y)
                dragging = true

                // Для Windows используем системный метод если доступен
                if (window && typeof window.startSystemMove === "function") {
                    window.startSystemMove()
                    dragging = false
                }
            }
        }

        onPositionChanged: function(mouse) {
            if (dragging && mouse.buttons === Qt.LeftButton && window) {
                var delta = Qt.point(mouse.x - clickPos.x, mouse.y - clickPos.y)

                // Прямое перемещение окна - работает на всех платформах
                window.x += delta.x
                window.y += delta.y
            }
        }

        onReleased: {
            dragging = false
        }
    }
}
