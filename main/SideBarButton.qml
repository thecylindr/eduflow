import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15

Rectangle {
    id: button
    height: 50
    radius: 8

    property string icon: ""
    property string text: ""
    property bool expanded: true
    property bool selected: false

    signal clicked()

    color: selected ? "#3498db" : (mouseArea.containsMouse ? "#ecf0f1" : "transparent")

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 12

        Text {
            text: icon
            font.pixelSize: 16
            Layout.preferredWidth: 24
        }

        Text {
            text: button.text
            font.pixelSize: 14
            color: selected ? "white" : "#2c3e50"
            visible: expanded
            Layout.fillWidth: true
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: button.clicked()
    }
}
