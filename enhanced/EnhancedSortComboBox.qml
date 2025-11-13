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

        // Кастомный комбобокс без использования стилизованного ComboBox
        Rectangle {
            id: comboBoxRect
            width: parent.width - sortDirectionButton.width - 10
            height: parent.height
            radius: 6
            color: "transparent"

            Text {
                id: selectedText
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                text: sortComboBox.sortOptions[sortComboBox.currentSortIndex] || ""
                font.pixelSize: 12
                color: "#666"
                elide: Text.ElideRight
                width: parent.width - 20
            }

            // Стрелка вниз
            Text {
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                text: "▼"
                font.pixelSize: 10
                color: "#666"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    // Показываем контекстное меню с опциями
                    optionMenu.popup()
                }
            }

            Menu {
                id: optionMenu
                y: comboBoxRect.height

                Repeater {
                    model: sortComboBox.sortOptions
                    MenuItem {
                        text: modelData
                        onTriggered: {
                            sortComboBox.currentSortIndex = index
                            sortComboBox.sortChanged(index, sortComboBox.sortAscending)
                        }
                    }
                }
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
