// enhanced/ViewModeSwitcher.qml
import QtQuick 2.15
import QtQuick.Layouts 1.15

Row {
    id: viewModeSwitcher
    spacing: 4
    z: 1000

    property string currentViewMode: "list"
    property color accentColor: "#3498db"

    signal viewModeChanged(string mode)

    Rectangle {
        width: 36
        height: 36
        radius: 8
        color: currentViewMode === "list" ? accentColor : "transparent"
        border.color: listMouseArea.containsMouse ? accentColor : (currentViewMode === "list" ? accentColor : "#bdc3c7")
        border.width: 2

        Text {
            anchors.centerIn: parent
            text: "≡"
            color: currentViewMode === "list" ? "white" : "#7f8c8d"
            font.bold: true
            font.pixelSize: 14
        }

        MouseArea {
            id: listMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                currentViewMode = "list"
                viewModeChanged("list")
            }
        }
    }

    Rectangle {
        width: 36
        height: 36
        radius: 8
        color: currentViewMode === "grid" ? accentColor : "transparent"
        border.color: gridMouseArea.containsMouse ? accentColor : (currentViewMode === "grid" ? accentColor : "#bdc3c7")
        border.width: 2

        Text {
            anchors.centerIn: parent
            text: "☷"
            color: currentViewMode === "grid" ? "white" : "#7f8c8d"
            font.bold: true
            font.pixelSize: 14
        }

        MouseArea {
            id: gridMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                currentViewMode = "grid"
                viewModeChanged("grid")
            }
        }
    }
}
