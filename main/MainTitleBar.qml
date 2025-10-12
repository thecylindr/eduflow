// MainTitleBar.qml (обновленная версия)
import QtQuick 2.15
import QtQuick.Layouts 2.15

Rectangle {
    id: titleBar
    height: 35
    color: "#ffffff"
    opacity: 0.9
    radius: 12
    z: 10

    property bool isWindowMaximized: false

    signal toggleMaximize()
    signal showMinimized()
    signal close()
    signal toggleSideBar()

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 8
        spacing: 15

        // Кнопка меню для боковой панели
        Rectangle {
            id: menuButton
            width: 25
            height: 25
            radius: 12
            color: menuMouseArea.containsMouse ? "#bdc3c7" : "transparent"

            Text {
                anchors.centerIn: parent
                text: "☰"
                color: menuMouseArea.containsMouse ? "white" : "#2c3e50"
                font.pixelSize: 14
            }

            MouseArea {
                id: menuMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: toggleSideBar()
            }
        }

        Text {
            text: "🎓 EduFlow - Управление базой данных"
            color: "#2c3e50"
            font.pixelSize: 14
            font.bold: true
            Layout.fillWidth: true
        }

        Row {
            spacing: 6

            Rectangle {
                id: minimizeButton
                width: 20
                height: 20
                radius: 10
                color: minimizeMouseArea.containsMouse ? "#FFD960" : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "-"
                    color: minimizeMouseArea.containsMouse ? "white" : "#2c3e50"
                    font.pixelSize: 14
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
                width: 20
                height: 20
                radius: 10
                color: maximizeMouseArea.containsMouse ? "#3498db" : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: isWindowMaximized ? "❐" : "⛶"
                    color: maximizeMouseArea.containsMouse ? "white" : "#2c3e50"
                    font.pixelSize: 12
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
                width: 20
                height: 20
                radius: 10
                color: closeMouseArea.containsMouse ? "#ff5c5c" : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "×"
                    color: closeMouseArea.containsMouse ? "white" : "#2c3e50"
                    font.pixelSize: 14
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
    }

    // Область перетаскивания
    MouseArea {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            leftMargin: 50
            rightMargin: 80
        }
        property point clickPos: Qt.point(0, 0)

        onPressed: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                clickPos = Qt.point(mouse.x, mouse.y);
            }
        }

        onPositionChanged: function(mouse) {
            if (mouse.buttons === Qt.LeftButton) {
                var delta = Qt.point(mouse.x - clickPos.x, mouse.y - clickPos.y);
                mainWindow.x += delta.x;
                mainWindow.y += delta.y;
            }
        }
    }
}
