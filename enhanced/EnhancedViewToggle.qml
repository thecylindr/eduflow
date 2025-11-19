import QtQuick
import QtQuick.Controls

Rectangle {
    id: viewToggle
    width: isMobile ? 70 : 80
    height: isMobile ? 32 : 35
    radius: isMobile ? 6 : 8
    color: "#f5f5f5"
    border.color: "#ddd"
    border.width: 1

    property bool isGridView: false
    property bool isMobile: false
    signal viewToggled(bool gridView)

    Row {
        anchors.centerIn: parent
        spacing: isMobile ? 6 : 10

        Rectangle {
            id: listViewButton
            width: isMobile ? 26 : 30
            height: isMobile ? 22 : 25
            radius: isMobile ? 4 : 5
            color: !viewToggle.isGridView ? "#3498db" : "transparent"
            border.color: !viewToggle.isGridView ? "#2980b9" : "#ddd"
            border.width: 2

            Text {
                anchors.centerIn: parent
                text: "≡"
                font.pixelSize: isMobile ? 10 : 12
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
            width: isMobile ? 26 : 30
            height: isMobile ? 22 : 25
            radius: isMobile ? 4 : 5
            color: viewToggle.isGridView ? "#3498db" : "transparent"
            border.color: viewToggle.isGridView ? "#2980b9" : "#ddd"
            border.width: 2

            Text {
                anchors.centerIn: parent
                text: "⧉"
                font.pixelSize: isMobile ? 10 : 12
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
