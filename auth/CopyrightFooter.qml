import QtQuick

Item {
    width: parent.width
    height: 30

    property bool isMobile: Qt.platform.os === "android" || Qt.platform.os === "ios" ||
                           Qt.platform.os === "tvos" || Qt.platform.os === "wasm"

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
            font.pixelSize: isMobile ? 12 : 10
            color: "white"
            opacity: 0.925
        }
    }
}
