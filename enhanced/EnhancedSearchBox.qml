import QtQuick
import QtQuick.Controls

Rectangle {
    id: searchBox
    width: 300
    height: isMobile ? 36 : 40
    radius: isMobile ? 18 : 20
    color: "#f5f5f5"
    border.color: "#ddd"
    border.width: 1

    property string placeholder: "Поиск..."
    property string searchText: ""
    property bool isMobile: false

    signal searchRequested(string text)

    Row {
        anchors.fill: parent
        spacing: 0

        // Лупа с отступом
        Rectangle {
            width: isMobile ? 35 : 45
            height: parent.height
            color: "transparent"

            Item {
                id: searchIconContainer
                anchors.centerIn: parent
                width: isMobile ? 20 : 24
                height: isMobile ? 20 : 24

                AnimatedImage {
                    id: animatedSearchIcon
                    anchors.fill: parent
                    source: "qrc:icons/search.gif"
                    playing: searchField.activeFocus || searchField.text
                    visible: playing
                    fillMode: Image.PreserveAspectFit
                }

                Image {
                    id: staticSearchIcon
                    anchors.fill: parent
                    source: "qrc:icons/search.png"
                    visible: !animatedSearchIcon.playing
                    fillMode: Image.PreserveAspectFit
                }
            }
        }

        // Заменяем TextField на TextInput с кастомным оформлением
        Rectangle {
            width: parent.width - (isMobile ? 35 : 45) - (clearButton.visible ? (isMobile ? 25 : 35) : 0)
            height: parent.height
            color: "transparent"

            TextInput {
                id: searchField
                anchors.fill: parent
                anchors.leftMargin: isMobile ? 3 : 5
                anchors.rightMargin: isMobile ? 3 : 5
                verticalAlignment: TextInput.AlignVCenter
                font.pixelSize: isMobile ? 12 : 14
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
            width: isMobile ? 22 : 30
            height: isMobile ? 22 : 30
            radius: isMobile ? 11 : 15
            anchors.verticalCenter: parent.verticalCenter
            color: clearMouseArea.containsMouse ? "#e0e0e0" : "transparent"
            visible: searchField.text.length > 0

            Image {
                anchors.centerIn: parent
                source: "qrc:icons/cross.png"
                width: isMobile ? 10 : 12
                height: isMobile ? 10 : 12
                fillMode: Image.PreserveAspectFit
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
