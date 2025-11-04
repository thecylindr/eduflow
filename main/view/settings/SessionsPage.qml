import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: sessionsPage
    color: "transparent"

    property var sessions: []
    signal revokeSession(string token)

    ScrollView {
        anchors.fill: parent
        anchors.margins: 15
        clip: true

        ColumnLayout {
            width: parent.width
            spacing: 15

            Text {
                text: "Активные сессии"
                font.pixelSize: 16
                font.bold: true
                color: "#2c3e50"
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "Всего активных сессий: " + sessions.length
                font.pixelSize: 12
                color: "#6c757d"
                Layout.alignment: Qt.AlignHCenter
            }

            Repeater {
                model: sessions

                delegate: Rectangle {
                    Layout.fillWidth: true
                    height: 120  // Увеличили высоту для дополнительной информации
                    radius: 8
                    color: modelData.isCurrent ? "#e8f5e8" : "#ffffff"
                    border.color: modelData.isCurrent ? "#4caf50" : "#e9ecef"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                text: "📍 " + (modelData.email || "Неизвестно")
                                font.pixelSize: 12
                                color: "#2c3e50"
                                font.bold: true
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "🌐 IP: " + (modelData.ipAddress || "Неизвестно")
                                font.pixelSize: 10
                                color: "#6c757d"
                            }

                            Text {
                                text: "📱 Устройство: " + (modelData.deviceName || "Неизвестно")
                                font.pixelSize: 10
                                color: "#6c757d"
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "⏰ Создана: " + formatDate(modelData.createdAt)
                                font.pixelSize: 10
                                color: "#6c757d"
                            }

                            Text {
                                text: "🕒 Активность: " + formatDate(modelData.lastActivity)
                                font.pixelSize: 10
                                color: "#6c757d"
                            }

                            Text {
                                text: modelData.isCurrent ? "✅ Текущая сессия" : "📱 Другое устройство"
                                font.pixelSize: 10
                                color: modelData.isCurrent ? "#4caf50" : "#ff9800"
                                font.bold: true
                            }
                        }

                        Rectangle {
                            visible: !modelData.isCurrent
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 30
                            radius: 6
                            color: revokeMouseArea.containsMouse ? "#c0392b" : "#e74c3c"

                            Text {
                                anchors.centerIn: parent
                                text: "🗑️ Отозвать"
                                color: "white"
                                font.pixelSize: 10
                                font.bold: true
                            }

                            MouseArea {
                                id: revokeMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: revokeSession(modelData.token)
                            }
                        }
                    }
                }
            }

            Text {
                text: "💡 Совет: Регулярно проверяйте активные сессии и отзывайте подозрительные"
                font.pixelSize: 11
                color: "#6c757d"
                font.italic: true
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 10
            }
        }
    }

    function formatDate(timestamp) {
        if (!timestamp) return "Неизвестно"
        // Преобразуем строку timestamp в Date объект
        var date = new Date(timestamp);
        if (isNaN(date.getTime())) {
            return "Неизвестно";
        }
        return date.toLocaleDateString(Qt.locale(), "dd.MM.yyyy") + " " + date.toLocaleTimeString(Qt.locale(), "hh:mm:ss");
    }
}
