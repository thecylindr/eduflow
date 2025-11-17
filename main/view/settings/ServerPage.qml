import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15

Rectangle {
    id: serverPage
    color: "transparent"

    property string serverAddress: ""
    property string pingStatus: "not_checked"
    property string pingTime: "Не проверен"
    property real pingValue: 0

    signal pingRequested()

    function getStatusText() {
        switch(pingStatus) {
            case "success":
                if (pingValue <= 50) return "Отличное соединение";
                if (pingValue <= 100) return "Хорошее соединение";
                if (pingValue <= 200) return "Нормальное соединение";
                return "Медленное соединение";
            case "error": return "Ошибка соединения";
            case "checking": return "Измерение...";
            default: return "Не проверен";
        }
    }

    function getPingColor() {
        if (pingValue <= 50) return "#27ae60";
        if (pingValue <= 100) return "#f39c12";
        if (pingValue <= 200) return "#e74c3c";
        return "#902537";
    }

    ScrollView {
        anchors.fill: parent
        anchors.margins: 10
        clip: true

        ColumnLayout {
            width: parent.width
            spacing: 10

            Rectangle {
                Layout.fillWidth: true
                height: 360
                radius: 16
                color: "#ffffff"
                border.color: "#e0e0e0"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 16

                    Row {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 8

                        Image {
                            source: "qrc:/icons/server.png"
                            sourceSize: Qt.size(24, 24)
                            fillMode: Image.PreserveAspectFit
                            mipmap: true
                            antialiasing: true
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "Настройки сервера"
                            font.pixelSize: 18
                            font.bold: true
                            color: "#2c3e50"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    // Круговая диаграмма пинга
                    Item {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 220
                        Layout.preferredHeight: 160

                        // Фон дуги
                        Canvas {
                            id: pingArc
                            anchors.fill: parent
                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.clearRect(0, 0, width, height);

                                // Основная дуга (от левого края до правого)
                                ctx.beginPath();
                                ctx.arc(width/2, height/2 + 20, width/2 - 15, Math.PI, 2 * Math.PI, false);
                                ctx.strokeStyle = "#e0e0e0";
                                ctx.lineWidth = 8;
                                ctx.stroke();

                                // Активная часть дуги
                                if (pingStatus === "success" && pingValue >= 0) {
                                    ctx.beginPath();
                                    // Масштабируем значение: 0-200ms = 0-100%, больше 200ms = 100%
                                    var progress = Math.min(Math.max(pingValue, 0), 200) / 200;
                                    var endAngle = Math.PI + progress * Math.PI;
                                    ctx.arc(width/2, height/2 + 20, width/2 - 15, Math.PI, endAngle, false);
                                    ctx.strokeStyle = getPingColor();
                                    ctx.lineWidth = 8;
                                    ctx.stroke();
                                }

                                // Разметка с делениями
                                ctx.fillStyle = "#6c757d";
                                ctx.font = "10px Arial";
                                ctx.textAlign = "center";
                                ctx.textBaseline = "middle";

                                // Рисуем деления на дуге
                                ctx.strokeStyle = "#6c757d";
                                ctx.lineWidth = 1;

                                // Деления каждые 50 мс до 200
                                for (var i = 0; i <= 4; i++) {
                                    var angle = Math.PI + (i * Math.PI / 4);
                                    var value = i * 50;

                                    // Длина деления
                                    var innerRadius = width/2 - 25;
                                    var outerRadius = width/2 - 10;

                                    var x1 = width/2 + innerRadius * Math.cos(angle);
                                    var y1 = height/2 + 20 + innerRadius * Math.sin(angle);
                                    var x2 = width/2 + outerRadius * Math.cos(angle);
                                    var y2 = height/2 + 20 + outerRadius * Math.sin(angle);

                                    ctx.beginPath();
                                    ctx.moveTo(x1, y1);
                                    ctx.lineTo(x2, y2);
                                    ctx.stroke();

                                    // Текст меток
                                    var textRadius = width/2 - 35;
                                    var textX = width/2 + textRadius * Math.cos(angle);
                                    var textY = height/2 + 20 + textRadius * Math.sin(angle);

                                    ctx.fillText(value + (i === 4 ? "+" : "") + " мс", textX, textY);
                                }
                            }
                        }

                        // Текущее значение пинга
                        Row {
                            anchors.top: parent.top
                            anchors.topMargin: 50
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 2

                            Text {
                                text: {
                                    if (pingStatus === "checking") return "Измерение..."
                                    if (pingStatus === "success") return pingValue.toFixed(0) + " мс"
                                    return "—"
                                }
                                font.pixelSize: 28
                                font.bold: true
                                color: pingStatus === "success" ? getPingColor() :
                                       pingStatus === "checking" ? "#3498db" : "#bdc3c7"
                            }
                        }

                        // Статус под значением
                        Text {
                            anchors.top: parent.top
                            anchors.topMargin: 85
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: getStatusText()
                            font.pixelSize: 12
                            color: pingStatus === "success" ? getPingColor() :
                                   pingStatus === "checking" ? "#3498db" : "#6c757d"
                        }
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
                                color: pingStatus === "success" ? "#27ae60" :
                                       pingStatus === "checking" ? "#3498db" : "#e74c3c"
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
                        color: pingMouseArea.containsMouse && (pingStatus !== "checking") ? "#2980b9" :
                               (pingStatus === "checking") ? "#95a5a6" : "#3498db"

                        Row {
                            anchors.centerIn: parent
                            spacing: 8

                            Image {
                                source: pingStatus === "checking" ? "qrc:/icons/loading.png" : "qrc:/icons/ping.png"
                                sourceSize: Qt.size(24, 24)
                                fillMode: Image.PreserveAspectFit
                                mipmap: true
                                antialiasing: true
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: pingStatus === "checking" ? "Измерение..." : "Проверить ping"
                                color: "white"
                                font.pixelSize: 14
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            id: pingMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: (pingStatus === "checking") ? Qt.ArrowCursor : Qt.PointingHandCursor
                            onClicked: {
                                if (pingStatus !== "checking") {
                                    pingRequested();
                                }
                            }
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

                    Row {
                        spacing: 6
                        Image {
                            source: "qrc:/icons/info.png"
                            sourceSize: Qt.size(18, 18)
                            fillMode: Image.PreserveAspectFit
                            mipmap: true
                            antialiasing: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "Информация о подключении"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#0277bd"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Text {
                        text: "• Ping показывает время отклика сервера\n• Рекомендуемое время: менее 120 мс\n• При высоких значениях проверьте интернет-соединение\n• Убедитесь, что сервер доступен и работает"
                        font.pixelSize: 12
                        color: "#0288d1"
                        lineHeight: 1.4
                    }
                }
            }
        }
    }

    onPingStatusChanged: {
        pingArc.requestPaint();
    }

    onPingValueChanged: {
        pingArc.requestPaint();
    }
}
