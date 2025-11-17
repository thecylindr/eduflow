import QtQuick

Rectangle {
    id: messageContainer
    width: parent.width
    height: showingMessage ? Math.max(messageTextItem.contentHeight + 20, 40) : 0
    radius: 8
    border.width: 2
    opacity: showingMessage ? 1 : 0
    clip: true

    property string messageText: ""
    property bool showingMessage: false
    property string messageType: "info"

    color: {
        if (messageType === "error") return "#ffebee";
        if (messageType === "success") return "#e8f5e8";
        return "#e3f2fd";
    }

    border.color: {
        if (messageType === "error") return "#f44336";
        if (messageType === "success") return "#4caf50";
        return "#2196f3";
    }

    Behavior on height {
        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
    }

    Behavior on opacity {
        NumberAnimation { duration: 300 }
    }

    Text {
        id: messageTextItem
        anchors {
            fill: parent
            margins: 10
        }
        text: messageContainer.messageText
        font.pixelSize: 12
        color: {
            if (messageType === "error") return "#d32f2f";
            if (messageType === "success") return "#2e7d32";
            return "#1976d2";
        }
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    Rectangle {
        id: closeMessageButton
        width: 16
        height: 16
        radius: 8
        color: closeMessageMouseArea.containsMouse ? messageContainer.border.color : "transparent"
        anchors {
            top: parent.top
            right: parent.right
            margins: 1
        }

        Text {
            anchors.centerIn: parent
            text: "×"
            color: closeMessageMouseArea.containsMouse ? "white" : messageContainer.border.color
            font.pixelSize: 12
            font.bold: true
        }

        MouseArea {
            id: closeMessageMouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: closeMessage()
        }
    }

    signal closeMessage

    Timer {
        id: autoCloseTimer
        interval: 5000
        onTriggered: closeMessage()
    }

    onShowingMessageChanged: {
        if (showingMessage) {
            autoCloseTimer.restart();
        }
    }
}
