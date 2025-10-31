// settings/SessionsPanel.qml
import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: sessionsPanel
    width: parent.width
    height: parent.height
    radius: 8
    color: "#fef9e7"
    border.color: "#f1c40f"
    border.width: 2

    property var sessions: []
    signal revokeSession(string sessionId)

    Text {
        id: sessionsTitle
        anchors.top: parent.top
        anchors.topMargin: 12
        anchors.left: parent.left
        anchors.leftMargin: 12
        text: "🔐 Активные сессии"
        font.pixelSize: 14
        font.bold: true
        color: "#2c3e50"
    }

    Rectangle {
        id: sessionsLine
        anchors.top: sessionsTitle.bottom
        anchors.topMargin: 8
        width: parent.width
        height: 1
        color: "#f1c40f"
    }

    ScrollView {
        anchors.top: sessionsLine.bottom
        anchors.topMargin: 8
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.right: parent.right
        anchors.rightMargin: 8
        clip: true

        Column {
            width: parent.width
            spacing: 6

            Repeater {
                model: sessions

                delegate: Rectangle {
                    width: parent.width - 5
                    height: 55
                    radius: 6
                    color: modelData.is_current ? "#e8f4f8" : "#ffffff"
                    border.color: modelData.is_current ? "#3498db" : "#e0e0e0"
                    border.width: 1

                    Column {
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 2

                        Text {
                            text: modelData.user_agent || "Неизвестное устройство"
                            font.pixelSize: 11
                            font.bold: true
                            color: "#2c3e50"
                            elide: Text.ElideRight
                            width: parent.width
                        }

                        Text {
                            text: "IP: " + (modelData.ip_address || "неизвестен")
                            font.pixelSize: 9
                            color: "#7f8c8d"
                        }

                        Text {
                            text: "Создана: " + (modelData.created_at || "неизвестно")
                            font.pixelSize: 9
                            color: "#7f8c8d"
                        }
                    }

                    Rectangle {
                        visible: !modelData.is_current
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        width: 50
                        height: 22
                        radius: 4
                        color: revokeMouseArea.containsMouse ? "#e74c3c" : "#ff6b6b"

                        Text {
                            anchors.centerIn: parent
                            text: "Отозвать"
                            color: "white"
                            font.pixelSize: 9
                            font.bold: true
                        }

                        MouseArea {
                            id: revokeMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: revokeSession(modelData.session_id)
                        }
                    }

                    Text {
                        visible: modelData.is_current
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Текущая"
                        color: "#3498db"
                        font.pixelSize: 10
                        font.bold: true
                    }
                }
            }
        }
    }
}
