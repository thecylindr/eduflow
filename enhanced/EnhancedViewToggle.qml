// EnhancedViewToggle.qml
import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: viewToggle
    width: 80
    height: 35
    radius: 8
    color: "#f5f5f5"
    border.color: "#ddd"
    border.width: 1

    property bool isGridView: false
    signal viewToggled(bool gridView)

    Row {
        anchors.centerIn: parent
        spacing: 10

        Rectangle {
            id: listViewButton
            width: 30
            height: 25
            radius: 5
            color: !viewToggle.isGridView ? "#3498db" : "transparent"
            border.color: !viewToggle.isGridView ? "#2980b9" : "#ddd"
            border.width: 2

            Text {
                anchors.centerIn: parent
                text: "≡"
                font.pixelSize: 12
                color: !viewToggle.isGridView ? "white" : "#666"
                font.bold: true
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    viewToggle.isGridView = false
                    viewToggle.viewToggled(false)
                }
            }
        }

        Rectangle {
            id: gridViewButton
            width: 30
            height: 25
            radius: 5
            color: viewToggle.isGridView ? "#3498db" : "transparent"
            border.color: viewToggle.isGridView ? "#2980b9" : "#ddd"
            border.width: 2

            Text {
                anchors.centerIn: parent
                text: "⧉"
                font.pixelSize: 12
                color: viewToggle.isGridView ? "white" : "#666"
                font.bold: true
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    viewToggle.isGridView = true
                    viewToggle.viewToggled(true)
                }
            }
        }
    }
}
