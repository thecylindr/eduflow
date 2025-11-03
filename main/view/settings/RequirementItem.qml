import QtQuick 2.15
import QtQuick.Layouts 2.15

Rectangle {
    id: requirementItem
    color: "transparent"

    property string text: ""
    property bool met: false

    Layout.fillWidth: true
    height: 20

    Row {
        spacing: 8

        Text {
            text: requirementItem.met ? "✅" : "❌"
            font.pixelSize: 10
        }

        Text {
            text: requirementItem.text
            font.pixelSize: 11
            color: requirementItem.met ? "#27ae60" : "#e74c3c"
        }
    }
}
