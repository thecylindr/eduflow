// enhanced/SortPanel.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

RowLayout {
    id: sortPanel
    spacing: 12
    z: 1000

    property var sortOptions: []
    property var sortRoles: []
    property string currentSortRole: sortRoles.length > 0 ? sortRoles[0] : ""
    property bool sortAscending: true
    property color accentColor: "#3498db"

    signal sortChanged(string role, bool ascending)

    Rectangle {
        width: 160
        height: 36
        radius: 8
        color: "transparent"
        border.color: "#e0e0e0"
        border.width: 2

        ComboBox {
            id: sortCombo
            anchors.fill: parent
            anchors.margins: 2
            model: sortOptions
            currentIndex: {
                var index = sortRoles.indexOf(currentSortRole);
                return index >= 0 ? index : 0;
            }
            visible: sortOptions.length > 0

            background: Rectangle {
                color: "transparent"
                radius: 6
            }

            onActivated: (index) => {
                if (index >= 0 && index < sortRoles.length) {
                    var newRole = sortRoles[index];
                    console.log("🔀 ComboBox: выбрана роль сортировки:", newRole);
                    currentSortRole = newRole;
                    sortChanged(newRole, sortAscending);
                }
            }
        }
    }

    Rectangle {
        id: directionButton
        width: 36
        height: 36
        radius: 8
        color: sortDirectionMouseArea.pressed ? Qt.darker(accentColor, 1.2) : (sortDirectionMouseArea.containsMouse ? accentColor : "transparent")
        border.color: sortDirectionMouseArea.containsMouse || sortDirectionMouseArea.pressed ? accentColor : "#e0e0e0"
        border.width: 2
        visible: sortOptions.length > 0

        Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }

        Text {
            anchors.centerIn: parent
            text: sortAscending ? "↑" : "↓"
            color: sortDirectionMouseArea.containsMouse || sortDirectionMouseArea.pressed ? "white" : "#7f8c8d"
            font.bold: true
            font.pixelSize: 16
        }

        MouseArea {
            id: sortDirectionMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                console.log("🔼 Направление сортировки изменено");
                sortAscending = !sortAscending;
                sortChanged(currentSortRole, sortAscending);
            }
            onPressed: parent.color = Qt.darker(accentColor, 1.2)
            onReleased: parent.color = "transparent"
        }
    }

    onCurrentSortRoleChanged: {
        var index = sortRoles.indexOf(currentSortRole);
        if (index >= 0 && index !== sortCombo.currentIndex) {
            sortCombo.currentIndex = index;
        }
    }
}
