// settings/ServerInfoPanel.qml
import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: serverInfoPanel
    width: parent.width
    height: 90
    radius: 12
    color: "#e8f4f8"
    border.color: "#9b59b6"
    border.width: 2

    property string serverAddress: ""
    property string pingStatus: "not_checked"
    property string pingTime: "Не проверен"

    signal pingRequested()

    Row {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 15

        // Левая часть - информация о сервере
        Column {
            width: parent.width - 120
            spacing: 8

            Text {
                text: "🌐 Соединение с сервером"
                font.pixelSize: 14
                font.bold: true
                color: "#2c3e50"
            }

            Grid {
                width: parent.width
                columns: 2
                columnSpacing: 8
                rowSpacing: 5

                Text { text: "Адрес:"; font.bold: true; color: "#34495e"; font.pixelSize: 11 }
                Text {
                    text: serverAddress
                    color: "#2c3e50"
                    width: parent.width / 2 - 20
                    elide: Text.ElideRight
                    font.pixelSize: 11
                }

                Text { text: "Статус:"; font.bold: true; color: "#34495e"; font.pixelSize: 11 }
                Row {
                    spacing: 5
                    Rectangle {
                        width: 10
                        height: 10
                        radius: 5
                        anchors.verticalCenter: parent.verticalCenter
                        color: pingStatus === "success" ? "#27ae60" :
                               pingStatus === "checking" ? "#f39c12" :
                               pingStatus === "error" ? "#e74c3c" : "#bdc3c7"
                    }
                    Text {
                        text: pingTime
                        color: pingStatus === "success" ? "#27ae60" :
                               pingStatus === "checking" ? "#f39c12" :
                               pingStatus === "error" ? "#e74c3c" : "#7f8c8d"
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: 11
                    }
                }
            }
        }

        // Правая часть - кнопка проверки
        Rectangle {
            width: 100
            height: 30
            radius: 8
            anchors.verticalCenter: parent.verticalCenter
            gradient: Gradient {
                GradientStop { position: 0.0; color: pingStatus === "checking" ? "#f39c12" : "#9b59b6" }
                GradientStop { position: 1.0; color: pingStatus === "checking" ? "#e67e22" : "#8e44ad" }
            }

            Column {
                anchors.centerIn: parent
                spacing: 2

                Text {
                    text: pingStatus === "checking" ? "⏳ Проверка..." : "🔍 Проверить"
                    color: "white"
                    font.pixelSize: 12
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                enabled: pingStatus !== "checking"
                onClicked: pingRequested()
            }
        }
    }
}
