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
                font.pixelSize: 18
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
                    height: 140
                    radius: 12
                    color: modelData.isCurrent ? "#e8f5e8" : "#ffffff"
                    border.color: modelData.isCurrent ? "#4caf50" : "#e0e0e0"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 8

                        // Заголовок с статусом сессии
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Rectangle {
                                width: 8
                                height: 8
                                radius: 4
                                color: modelData.isCurrent ? "#4caf50" : "#ff9800"
                            }

                            Text {
                                text: modelData.isCurrent ? "✅ Текущая сессия" : "📱 Другое устройство"
                                font.pixelSize: 14
                                color: modelData.isCurrent ? "#4caf50" : "#ff9800"
                                font.bold: true
                                Layout.fillWidth: true
                            }

                            Rectangle {
                                visible: !modelData.isCurrent
                                Layout.preferredWidth: 100
                                Layout.preferredHeight: 32
                                radius: 6
                                color: revokeMouseArea.containsMouse ? "#c0392b" : "#e74c3c"

                                Row {
                                    anchors.centerIn: parent
                                    spacing: 4

                                    Text {
                                        text: "🗑️"
                                        font.pixelSize: 12
                                        color: "white"
                                    }

                                    Text {
                                        text: "Отозвать"
                                        color: "white"
                                        font.pixelSize: 11
                                        font.bold: true
                                    }
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

                        // Информация о сессии в две колонки
                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            columnSpacing: 20
                            rowSpacing: 6

                            // Левая колонка
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                // ОС
                                RowLayout {
                                    spacing: 6
                                    Layout.fillWidth: true

                                    Text {
                                        text: "💻"
                                        font.pixelSize: 12
                                        color: "#6c757d"
                                        Layout.preferredWidth: 20
                                    }

                                    Text {
                                        text: "ОС:"
                                        font.pixelSize: 11
                                        color: "#6c757d"
                                        font.bold: true
                                        Layout.preferredWidth: 70
                                    }

                                    Text {
                                        text: getOSFromUserAgent(modelData.userAgent) || "Неизвестно"
                                        font.pixelSize: 11
                                        color: "#2c3e50"
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }
                                }

                                // IP
                                RowLayout {
                                    spacing: 6
                                    Layout.fillWidth: true

                                    Text {
                                        text: "🌐"
                                        font.pixelSize: 12
                                        color: "#6c757d"
                                        Layout.preferredWidth: 20
                                    }

                                    Text {
                                        text: "IP:"
                                        font.pixelSize: 11
                                        color: "#6c757d"
                                        font.bold: true
                                        Layout.preferredWidth: 70
                                    }

                                    Text {
                                        text: modelData.ipAddress || "Неизвестно"
                                        font.pixelSize: 11
                                        color: "#2c3e50"
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }
                                }

                                // Возраст
                                RowLayout {
                                    spacing: 6
                                    Layout.fillWidth: true

                                    Text {
                                        text: "🕒"
                                        font.pixelSize: 12
                                        color: "#6c757d"
                                        Layout.preferredWidth: 20
                                    }

                                    Text {
                                        text: "Возраст:"
                                        font.pixelSize: 11
                                        color: "#6c757d"
                                        font.bold: true
                                        Layout.preferredWidth: 70
                                    }

                                    Text {
                                        text: (modelData.ageHours || "0") + " часов"
                                        font.pixelSize: 11
                                        color: "#2c3e50"
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }
                                }
                            }

                            // Правая колонка
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                // Создана
                                RowLayout {
                                    spacing: 6
                                    Layout.fillWidth: true

                                    Text {
                                        text: "⏰"
                                        font.pixelSize: 12
                                        color: "#6c757d"
                                        Layout.preferredWidth: 20
                                    }

                                    Text {
                                        text: "Создана:"
                                        font.pixelSize: 11
                                        color: "#6c757d"
                                        font.bold: true
                                        Layout.preferredWidth: 70
                                    }

                                    Text {
                                        text: formatDate(modelData.createdAt)
                                        font.pixelSize: 11
                                        color: "#2c3e50"
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }
                                }

                                // Активность
                                RowLayout {
                                    spacing: 6
                                    Layout.fillWidth: true

                                    Text {
                                        text: "📊"
                                        font.pixelSize: 12
                                        color: "#6c757d"
                                        Layout.preferredWidth: 20
                                    }

                                    Text {
                                        text: "Активность:"
                                        font.pixelSize: 11
                                        color: "#6c757d"
                                        font.bold: true
                                        Layout.preferredWidth: 70
                                    }

                                    Text {
                                        text: formatDate(modelData.lastActivity)
                                        font.pixelSize: 11
                                        color: "#2c3e50"
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }
                                }

                                // Неактивна
                                RowLayout {
                                    spacing: 6
                                    Layout.fillWidth: true

                                    Text {
                                        text: "⏱️"
                                        font.pixelSize: 12
                                        color: "#6c757d"
                                        Layout.preferredWidth: 20
                                    }

                                    Text {
                                        text: "Неактивна:"
                                        font.pixelSize: 11
                                        color: "#6c757d"
                                        font.bold: true
                                        Layout.preferredWidth: 70
                                    }

                                    Text {
                                        text: (modelData.inactiveMinutes || "0") + " мин."
                                        font.pixelSize: 11
                                        color: "#2c3e50"
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Text {
                text: sessions.length === 0 ?
                    "❌ Активные сессии не найдены" :
                    "💡 Совет: Регулярно проверяйте активные сессии и отзывайте подозрительные"
                font.pixelSize: 11
                color: "#6c757d"
                font.italic: true
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 10
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }
        }
    }

    function formatDate(timestamp) {
        if (!timestamp) return "Неизвестно"
        var date = new Date(timestamp * 1000);
        if (isNaN(date.getTime())) {
            return "Неизвестно";
        }
        return date.toLocaleDateString(Qt.locale(), "dd.MM.yyyy") + " " +
               date.toLocaleTimeString(Qt.locale(), "hh:mm:ss");
    }

    function getOSFromUserAgent(userAgent) {
        if (!userAgent) return "Неизвестно";

        var ua = userAgent.toLowerCase();
        if (ua.includes("windows")) return "Windows";
        if (ua.includes("mac os")) return "macOS";
        if (ua.includes("linux")) return "Linux";
        if (ua.includes("android")) return "Android";
        if (ua.includes("ios") || ua.includes("iphone")) return "iOS";

        return "Другая ОС";
    }
}
