// enhanced/GridDelegate.qml
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

Rectangle {
    id: gridDelegateRoot
    property var itemData: modelData
    property string itemType: ""

    function getSubtitleText(data) { return ""; }

    signal editRequested(var itemData)
    signal deleteRequested(var itemData)

    width: GridView.view.cellWidth - 12
    height: GridView.view.cellHeight - 12
    radius: 12
    color: mouseArea.containsMouse ? "#f8f9fa" : "#ffffff"
    border.color: mouseArea.containsMouse ? "#3498db" : "#e9ecef"
    border.width: 2

    scale: mouseArea.pressed ? 0.98 : (mouseArea.containsMouse ? 1.05 : 1)
    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }

    Column {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        Rectangle {
            width: 48
            height: 48
            radius: 10
            color: mouseArea.containsMouse ? "#3498db" : "#e9ecef"
            border.color: mouseArea.containsMouse ? "#2980b9" : "#dee2e6"
            border.width: 2
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                anchors.centerIn: parent
                text: itemType === "student" ? "👨‍🎓" : "?"
                font.pixelSize: 20
            }
        }

        Text {
            text: (itemData.last_name || "") + " " + (itemData.first_name || "") + " " + (itemData.middle_name || "")
            font.bold: true
            font.pixelSize: 13
            color: "#2c3e50"
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            text: getSubtitleText(itemData)
            font.pixelSize: 11
            color: "#7f8c8d"
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

        Item { height: 4 }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 6

            Rectangle {
                id: editButtonGrid
                width: 32
                height: 32
                radius: 8
                color: editBtnMouseAreaGrid.pressed ? Qt.darker("#3498db", 1.2) : (editBtnMouseAreaGrid.containsMouse ? "#3498db" : "transparent")
                border.color: editBtnMouseAreaGrid.containsMouse || editBtnMouseAreaGrid.pressed ? "#3498db" : "#e0e0e0"
                border.width: 2
                z: 1

                Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }

                Rectangle {
                    width: 20
                    height: 20
                    radius: 5
                    color: parent.color
                    anchors.centerIn: parent

                    Text {
                        anchors.centerIn: parent
                        text: "✏️"
                        font.pixelSize: 9
                        color: editBtnMouseAreaGrid.containsMouse || editBtnMouseAreaGrid.pressed ? "white" : "#7f8c8d"
                    }
                }

                MouseArea {
                    id: editBtnMouseAreaGrid
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: editRequested(itemData)
                    onPressed: parent.color = Qt.darker("#3498db", 1.2)
                    onReleased: parent.color = "transparent"
                }
            }

            Rectangle {
                id: deleteButtonGrid
                width: 32
                height: 32
                radius: 8
                color: deleteBtnMouseAreaGrid.pressed ? Qt.darker("#e74c3c", 1.2) : (deleteBtnMouseAreaGrid.containsMouse ? "#e74c3c" : "transparent")
                border.color: deleteBtnMouseAreaGrid.containsMouse || deleteBtnMouseAreaGrid.pressed ? "#e74c3c" : "#e0e0e0"
                border.width: 2
                z: 1

                Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }

                Rectangle {
                    width: 20
                    height: 20
                    radius: 5
                    color: parent.color
                    anchors.centerIn: parent

                    Text {
                        anchors.centerIn: parent
                        text: "🗑️"
                        font.pixelSize: 9
                        color: deleteBtnMouseAreaGrid.containsMouse || deleteBtnMouseAreaGrid.pressed ? "white" : "#7f8c8d"
                    }
                }

                MouseArea {
                    id: deleteBtnMouseAreaGrid
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: deleteRequested(itemData)
                    onPressed: parent.color = Qt.darker("#e74c3c", 1.2)
                    onReleased: parent.color = "transparent"
                }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        preventStealing: false
        onPressed: mouse.accepted = false
        onReleased: mouse.accepted = false
        onClicked: mouse.accepted = false
    }
}
