import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: serverPage
    color: "transparent"

    property string serverAddress: ""
    property string pingStatus: "not_checked"
    property string pingTime: "Не проверен"

    signal pingRequested()

    ScrollView {
        anchors.fill: parent
        anchors.margins: 20
        clip: true

        ColumnLayout {
            width: parent.width
            spacing: 20

            Rectangle {
                Layout.fillWidth: true
                height: 220
                radius: 16
                color: "#ffffff"
                border.color: "#e0e0e0"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 16

                    Text {
                        text: "🌐 Настройки сервера"
                        font.pixelSize: 18
                        font.bold: true
                        color: "#2c3e50"
                        Layout.alignment: Qt.AlignHCenter
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            Text {
                                text: "Адрес сервера:"
                                font.pixelSize: 14
                                color: "#6c757d"
                                Layout.preferredWidth: 120
                            }

                            Text {
                                text: serverAddress
                                font.pixelSize: 14
                                color: "#2c3e50"
                                font.bold: true
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            Text {
                                text: "Статус:"
                                font.pixelSize: 14
                                color: "#6c757d"
                                Layout.preferredWidth: 120
                            }

                            Text {
                                text: getStatusText()
                                font.pixelSize: 14
                                color: getStatusColor()
                                font.bold: true
                                Layout.fillWidth: true
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            Text {
                                text: "Время отклика:"
                                font.pixelSize: 14
                                color: "#6c757d"
                                Layout.preferredWidth: 120
                            }

                            Text {
                                text: pingTime
                                font.pixelSize: 14
                                color: "#2c3e50"
                                font.bold: true
                                Layout.fillWidth: true
                            }
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 160
                        Layout.preferredHeight: 44
                        Layout.alignment: Qt.AlignHCenter
                        radius: 10
                        color: pingMouseArea.containsMouse ? "#2980b9" : "#3498db"

                        Row {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                text: pingStatus === "checking" ? "⏳" : "📡"
                                font.pixelSize: 14
                                color: "white"
                            }

                            Text {
                                text: pingStatus === "checking" ? "Проверка..." : "Проверить связь"
                                color: "white"
                                font.pixelSize: 14
                                font.bold: true
                            }
                        }

                        MouseArea {
                            id: pingMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: pingRequested()
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 140
                radius: 16
                color: "#e8f4f8"
                border.color: "#b3e5fc"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 8

                    Text {
                        text: "💡 Информация о подключении"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#0277bd"
                    }

                    Text {
                        text: "• Ping показывает время отклика сервера\n• Рекомендуемое время: менее 100 мс\n• При высоких значениях проверьте интернет-соединение\n• Убедитесь, что сервер доступен и работает"
                        font.pixelSize: 12
                        color: "#0288d1"
                        lineHeight: 1.4
                    }
                }
            }
        }
    }

    function getStatusText() {
        switch(pingStatus) {
            case "success": return "✅ Соединение установлено"
            case "error": return "❌ Ошибка соединения"
            case "checking": return "⏳ Проверка..."
            default: return "⚪ Не проверен"
        }
    }

    function getStatusColor() {
        switch(pingStatus) {
            case "success": return "#27ae60"
            case "error": return "#e74c3c"
            case "checking": return "#f39c12"
            default: return "#6c757d"
        }
    }
}
