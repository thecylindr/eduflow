import QtQuick
import QtQuick.Layouts 1.15

Rectangle {
    id: titleBarMobile
    height: 40
    color: "#ffffff"
    opacity: 0.925
    radius: 12
    z: 10

    property string currentView: ""
    property bool menuOpen: false

    signal toggleMenu()

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // Кнопка меню с анимацией поворота - отцентрирована
        Rectangle {
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            Layout.alignment: Qt.AlignVCenter
            radius: 10
            color: menuMouseArea.containsMouse ? "#f1f3f4" : "transparent"
            border.color: menuMouseArea.containsMouse ? "#3498db" : "transparent"
            border.width: 1

            Image {
                id: menuIcon
                anchors.centerIn: parent
                source: "qrc:/icons/sidebar.png"
                sourceSize: Qt.size(20, 20)
                fillMode: Image.PreserveAspectFit
                mipmap: true
                antialiasing: true
                rotation: menuOpen ? -90 : 0

                Behavior on rotation {
                    NumberAnimation {
                        duration: 300;
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            MouseArea {
                id: menuMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    titleBarMobile.toggleMenu()
                }
            }
        }

        // Заголовок
        Text {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            text: currentView
            font.pixelSize: 17
            font.bold: true
            color: "#2c3e50"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        // Кнопка Gitflic - отцентрирована
        Rectangle {
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            Layout.alignment: Qt.AlignVCenter
            radius: 10
            color: gitflicMouseArea.containsMouse ? "#4CAF50" : "transparent"
            border.color: gitflicMouseArea.containsMouse ? "#4CAF50" : "transparent"
            border.width: 1

            Image {
                anchors.centerIn: parent
                source: "qrc:/icons/git.png"
                sourceSize: Qt.size(24, 24)
                fillMode: Image.PreserveAspectFit
                mipmap: true
                antialiasing: true
            }

            MouseArea {
                id: gitflicMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    Qt.openUrlExternally("https://gitflic.ru/project/cylindr/eduflow");
                }
            }
        }
    }
}
