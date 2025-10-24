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

    TextField {
        id: searchField
        anchors {
            left: parent.left
            right: clearButton.left
            verticalCenter: parent.verticalCenter
            margins: 15
        }
        placeholderText: searchBox.placeholder
        background: Rectangle {
            color: "transparent"
            border.width: 0
        }
        onTextChanged: {
            searchBox.searchText = text
            searchTimer.restart()
        }
    }

    Text {
        id: searchIcon
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
            leftMargin: 12
        }
        text: "🔍"
        font.pixelSize: 14
        color: "#666"
    }

    Rectangle {
        id: clearButton
        width: 20
        height: 20
        radius: 10
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            rightMargin: 10
        }
        color: clearMouseArea.containsMouse ? "#e0e0e0" : "transparent"
        visible: searchField.text.length > 0

        Text {
            anchors.centerIn: parent
            text: "×"
            font.pixelSize: 14
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

    Timer {
        id: searchTimer
        interval: 300
        onTriggered: searchBox.searchRequested(searchBox.searchText)
    }
}
