// enhanced/EnhancedSearchBox.qml
import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: searchBox
    width: 300
    height: 40
    radius: 20
    color: "#f5f5f5"
    border.color: "#ddd"
    border.width: 1

    property string placeholder: "Поиск..."
    property string searchText: ""

    signal searchRequested(string text)

    Row {
        anchors.fill: parent
        spacing: 0

        // Лупа с отступом
        Rectangle {
            width: 40
            height: parent.height
            color: "transparent"

            Text {
                id: searchIcon
                anchors.centerIn: parent
                text: "🔍"
                font.pixelSize: 16
                color: "#666"
            }
        }

        // Заменяем TextField на TextInput с кастомным оформлением
        Rectangle {
            width: parent.width - 40 - (clearButton.visible ? 35 : 0)
            height: parent.height
            color: "transparent"

            TextInput {
                id: searchField
                anchors.fill: parent
                anchors.leftMargin: 5
                anchors.rightMargin: 5
                verticalAlignment: TextInput.AlignVCenter
                font.pixelSize: 14
                color: "#2c3e50"

                Text {
                    id: placeholder
                    anchors.fill: parent
                    verticalAlignment: TextInput.AlignVCenter
                    text: searchBox.placeholder
                    font: searchField.font
                    color: "#999"
                    visible: !searchField.text && !searchField.activeFocus
                }

                onTextChanged: {
                    searchBox.searchText = text
                    searchTimer.restart()
                }
            }
        }

        // Кнопка очистки
        Rectangle {
            id: clearButton
            width: 30
            height: 30
            radius: 15
            anchors.verticalCenter: parent.verticalCenter
            color: clearMouseArea.containsMouse ? "#e0e0e0" : "transparent"
            visible: searchField.text.length > 0

            Text {
                anchors.centerIn: parent
                text: "×"
                font.pixelSize: 18
                font.bold: true
                color: "#666"
            }

            MouseArea {
                id: clearMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    searchField.text = ""
                    searchBox.searchText = ""
                    searchBox.searchRequested("")
                }
            }
        }
    }

    Timer {
        id: searchTimer
        interval: 300
        onTriggered: searchBox.searchRequested(searchBox.searchText)
    }
}
