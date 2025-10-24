// enhanced/ActionButtons.qml
import QtQuick 2.15
import QtQuick.Layouts 1.15

Row {
    id: actionButtons
    spacing: 6
    z: 1000

    property var itemData: null
    property string itemType: "item"
    property color accentColor: "#3498db"

    signal editRequested(var data)
    signal deleteRequested(var data)

    Rectangle {
        id: editBtn
        width: 32
        height: 32
        radius: 8
        color: editMouseArea.pressed ? Qt.darker(accentColor, 1.2) : (editMouseArea.containsMouse ? accentColor : "transparent")
        border.color: editMouseArea.containsMouse || editMouseArea.pressed ? accentColor : "#e0e0e0"
        border.width: 2

        Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }

        Rectangle {
            width: 24
            height: 24
            radius: 6
            color: parent.color
            anchors.centerIn: parent

            Text {
                anchors.centerIn: parent
                text: "✏️"
                font.pixelSize: 12
                color: editMouseArea.containsMouse || editMouseArea.pressed ? "white" : "#7f8c8d"
            }
        }

        MouseArea {
            id: editMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                console.log("✏️ ActionButtons: редактирование запрошено для", itemData);
                editRequested(itemData);
            }
            onPressed: parent.color = Qt.darker(accentColor, 1.2)
            onReleased: parent.color = "transparent"
        }
    }

    Rectangle {
        id: deleteBtn
        width: 32
        height: 32
        radius: 8
        color: deleteMouseArea.pressed ? Qt.darker("#e74c3c", 1.2) : (deleteMouseArea.containsMouse ? "#e74c3c" : "transparent")
        border.color: deleteMouseArea.containsMouse || deleteMouseArea.pressed ? "#e74c3c" : "#e0e0e0"
        border.width: 2

        Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }

        Rectangle {
            width: 24
            height: 24
            radius: 6
            color: parent.color
            anchors.centerIn: parent

            Text {
                anchors.centerIn: parent
                text: "🗑️"
                font.pixelSize: 12
                color: deleteMouseArea.containsMouse || deleteMouseArea.pressed ? "white" : "#7f8c8d"
            }
        }

        MouseArea {
            id: deleteMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                console.log("🗑️ ActionButtons: удаление запрошено для", itemData);
                deleteRequested(itemData);
            }
            onPressed: parent.color = Qt.darker("#e74c3c", 1.2)
            onReleased: parent.color = "transparent"
        }
    }
}
