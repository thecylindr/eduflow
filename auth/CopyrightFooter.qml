import QtQuick 2.15

Item {
    width: parent.width
    height: 30

    Rectangle {
        id: copyrightRect
        anchors.centerIn: parent
        width: copyrightText.width + 20
        height: copyrightText.height + 10
        color: "#40000000"
        radius: 6
        opacity: 0.9

        Text {
            id: copyrightText
            anchors.centerIn: parent
            text: "© 2025 Система безопасности"
            font.pixelSize: 10
            color: "white"
            opacity: 0.925
        }
    }
}
