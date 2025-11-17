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
        anchors.margins: 8
        spacing: 8

        // Кнопка меню с анимацией поворота - отцентрирована
        Rectangle {
            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
            radius: 8
            color: menuMouseArea.containsMouse ? "#f1f3f4" : "transparent"
            border.color: menuMouseArea.containsMouse ? "#3498db" : "transparent"
            border.width: 1

            Image {
                id: menuIcon
                anchors.centerIn: parent
                source: "qrc:/icons/sidebar.png"
                sourceSize: Qt.size(16, 16)
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
            text: currentView
            font.pixelSize: 16
            font.bold: true
            color: "#2c3e50"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        // Кнопка Gitflic - отцентрирована
        Rectangle {
            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
            radius: 8
            color: gitflicMouseArea.containsMouse ? "#4CAF50" : "transparent"
            border.color: gitflicMouseArea.containsMouse ? "#4CAF50" : "transparent"
            border.width: 1

            Image {
                anchors.centerIn: parent
                source: "qrc:/icons/git.png"
                sourceSize: Qt.size(18, 18)
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
