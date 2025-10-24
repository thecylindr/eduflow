// enhanced/SearchBar.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: searchBar
    height: 36
    radius: 10
    color: "#ffffff"
    border.color: searchField.activeFocus ? "#3498db" : "#e0e0e0"
    border.width: 2

    property string placeholder: "Поиск..."
    property string searchText: ""

    signal searchRequested(string text)

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        Text {
            text: "🔍"
            font.pixelSize: 14
            Layout.alignment: Qt.AlignVCenter
            color: "#7f8c8d"
        }

        TextField {
            id: searchField
            Layout.fillWidth: true
            placeholderText: placeholder
            background: Rectangle {
                color: "transparent"
            }
            font.pixelSize: 14
            onTextChanged: {
                searchText = text
                searchRequested(text)
            }
        }

        Rectangle {
            width: 24
            height: 24
            radius: 12
            color: clearMouseArea.containsMouse ? "#e74c3c" : "transparent"
            border.color: clearMouseArea.containsMouse ? "#e74c3c" : "#bdc3c7"
            border.width: 2
            visible: searchField.text !== ""

            Text {
                anchors.centerIn: parent
                text: "×"
                color: clearMouseArea.containsMouse ? "white" : "#7f8c8d"
                font.pixelSize: 16
                font.bold: true
            }

            MouseArea {
                id: clearMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    searchField.text = ""
                    searchField.forceActiveFocus()
                    searchText = ""
                    searchRequested("")
                }
            }
        }
    }
}
