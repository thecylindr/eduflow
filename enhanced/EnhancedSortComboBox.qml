import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

Rectangle {
    id: sortComboBox
    width: isMobile ? 150 : 200
    height: isMobile ? 32 : 35
    radius: isMobile ? 6 : 8
    color: "#f5f5f5"
    border.color: "#ddd"
    border.width: 1

    property var sortOptions: []
    property var sortRoles: []
    property int currentSortIndex: 0
    property bool sortAscending: true
    property bool isMobile: false

    signal sortChanged(int index, bool ascending)

    Row {
        anchors.fill: parent
        spacing: isMobile ? 3 : 5

        // Кастомный комбобокс без использования стилизованного ComboBox
        Rectangle {
            id: comboBoxRect
            width: parent.width - sortDirectionButton.width - (isMobile ? 6 : 10)
            height: parent.height
            radius: isMobile ? 4 : 6
            color: "transparent"

            Text {
                id: selectedText
                anchors.left: parent.left
                anchors.leftMargin: isMobile ? 6 : 10
                anchors.verticalCenter: parent.verticalCenter
                text: sortComboBox.sortOptions[sortComboBox.currentSortIndex] || ""
                font.pixelSize: isMobile ? 10 : 12
                color: "#666"
                elide: Text.ElideRight
                width: parent.width - (isMobile ? 16 : 20)
            }

            // Стрелка вниз
            Text {
                anchors.right: parent.right
                anchors.rightMargin: isMobile ? 6 : 8
                anchors.verticalCenter: parent.verticalCenter
                text: "▼"
                font.pixelSize: isMobile ? 8 : 10
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
                        font.pixelSize: isMobile ? 10 : 12
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
            width: isMobile ? 26 : 30
            height: parent.height
            radius: isMobile ? 4 : 6
            color: directionMouseArea.containsMouse ? "#e0e0e0" : "#f5f5f5"

            Text {
                anchors.centerIn: parent
                text: sortComboBox.sortAscending ? "↑" : "↓"
                font.pixelSize: isMobile ? 12 : 14
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
