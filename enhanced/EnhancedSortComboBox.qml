// enhanced/EnhancedSortComboBox.qml
import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: sortComboBox
    width: 200
    height: 35
    radius: 8
    color: "#f5f5f5"
    border.color: "#ddd"
    border.width: 1

    property var sortOptions: []
    property var sortRoles: []
    property int currentSortIndex: 0
    property bool sortAscending: true

    signal sortChanged(int index, bool ascending)

    Row {
        anchors.fill: parent
        spacing: 5

        ComboBox {
            id: sortSelector
            width: parent.width - sortDirectionButton.width - 10
            height: parent.height
            model: sortComboBox.sortOptions
            currentIndex: sortComboBox.currentSortIndex
            background: Rectangle {
                color: "transparent"
                border.width: 0
            }
            onCurrentIndexChanged: {
                sortComboBox.currentSortIndex = currentIndex
                sortComboBox.sortChanged(currentIndex, sortComboBox.sortAscending)
            }
        }

        Rectangle {
            id: sortDirectionButton
            width: 30
            height: parent.height
            radius: 6
            color: directionMouseArea.containsMouse ? "#e0e0e0" : "#f5f5f5"

            Text {
                anchors.centerIn: parent
                text: sortComboBox.sortAscending ? "↑" : "↓"
                font.pixelSize: 14
                font.bold: true
                color: "#666"
            }

            MouseArea {
                id: directionMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    sortComboBox.sortAscending = !sortComboBox.sortAscending
                    sortComboBox.sortChanged(sortComboBox.currentSortIndex, sortComboBox.sortAscending)
                }
            }
        }
    }
}
