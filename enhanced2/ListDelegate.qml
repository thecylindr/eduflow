import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

Rectangle {
    id: listDelegateRoot
    property var itemData: modelData
    property string itemType: ""

    function getSubtitleText(data) { return ""; }

    signal editRequested(var itemData)
    signal deleteRequested(var itemData)

    width: ListView.view.width
    height: 70
    color: mouseArea.containsMouse ? "#f8f9fa" : "#ffffff"
    border.color: mouseArea.containsMouse ? "#3498db" : "#e9ecef"
    border.width: 2

    scale: mouseArea.pressed ? 0.98 : (mouseArea.containsMouse ? 1.02 : 1)
    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        Rectangle {
            width: 40
            height: 40
            radius: 8
            color: mouseArea.containsMouse ? "#3498db" : "#e9ecef"
            border.color: mouseArea.containsMouse ? "#2980b9" : "#dee2e6"
            border.width: 2

            Text {
                anchors.centerIn: parent
                text: itemType === "student" ? "👨‍🎓" : "?"
                font.pixelSize: 16
            }
        }

        Column {
            Layout.filflWidth: true
            spacing: 4

            Text {
                text: (itemData.last_name || "") + " " + (itemData.first_name || "") + " " + (itemData.middle_name || "")
                font.bold: true
                font.pixelSize: 14
                color: "#2c3e50"
            }

            Text {
                text: getSubtitleText(itemData)
                font.pixelSize: 12
                color: "#7f8c8d"
            }
        }

        Row {
            spacing: 6

            Rectangle {
                id: editButton
                width: 36
                height: 36
                radius: 8
                color: editBtnMouseArea.pressed ? Qt.darker("#3498db", 1.2) : (editBtnMouseArea.containsMouse ? "#3498db" : "transparent")
                border.color: editBtnMouseArea.containsMouse || editBtnMouseArea.pressed ? "#3498db" : "#e0e0e0"
                border.width: 2
                z: 1

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
                        font.pixelSize: 10
                        color: editBtnMouseArea.containsMouse || editBtnMouseArea.pressed ? "white" : "#7f8c8d"
                    }
                }

                MouseArea {
                    id: editBtnMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: editRequested(itemData)
                    onPressed: parent.color = Qt.darker("#3498db", 1.2)
                    onReleased: parent.color = "transparent"
                }
            }

            Rectangle {
                id: deleteButton
                width: 36
                height: 36
                radius: 8
                color: deleteBtnMouseArea.pressed ? Qt.darker("#e74c3c", 1.2) : (deleteBtnMouseArea.containsMouse ? "#e74c3c" : "transparent")
                border.color: deleteBtnMouseArea.containsMouse || deleteBtnMouseArea.pressed ? "#e74c3c" : "#e0e0e0"
                border.width: 2
                z: 1

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
                        font.pixelSize: 10
                        color: deleteBtnMouseArea.containsMouse || deleteBtnMouseArea.pressed ? "white" : "#7f8c8d"
                    }
                }

                MouseArea {
                    id: deleteBtnMouseArea
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
