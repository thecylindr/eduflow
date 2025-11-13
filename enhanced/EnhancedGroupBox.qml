import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: enhancedGroupBox
    property string title: ""
    property color titleColor: "#2c3e50"
    property color borderColor: "#bdc3c7"
    property color backgroundColor: "#ffffff"
    property alias contentItem: contentContainer.children

    radius: 8
    color: backgroundColor
    border.color: borderColor
    border.width: 1

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 10

        Text {
            text: enhancedGroupBox.title
            font.pixelSize: 16
            font.bold: true
            color: titleColor
            Layout.fillWidth: true
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: borderColor
        }

        Item {
            id: contentContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
