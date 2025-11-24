import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15

Rectangle {
    id: serverPage
    color: "transparent"
    property bool isMobile: false

    property string serverAddress: ""
    property string pingStatus: "not_checked"
    property string pingTime: "Не проверен"
    property real pingValue: 0

    // Новые свойства для анимации
    property real animatedPingValue: 0
    property bool animationRunning: false

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

    function getPingColor(value) {
        // Принимаем значение для вычисления цвета, по умолчанию используем pingValue
        var val = value !== undefined ? value : pingValue;
        if (val <= 50) return "#27ae60";
        if (val <= 100) return "#f39c12";
        if (val <= 200) return "#e74c3c";
        return "#902537";
    }

    // Функция для запуска анимации пинга
    function startPingAnimation() {
        if (pingStatus === "success" && pingValue > 0) {
            animationRunning = true;
            animatedPingValue = 0; // Сбрасываем анимированное значение перед началом
            pingAnimation.from = 0;
            pingAnimation.to = Math.min(pingValue, 200); // Ограничиваем максимум 200 для отображения
            pingAnimation.start();
        } else {
            animatedPingValue = 0;
            animationRunning = false;
        }
    }

    ScrollView {
        anchors.fill: parent
        anchors.margins: isMobile ? 5 : 10
        clip: true

        ColumnLayout {
            width: parent.width
            spacing: isMobile ? 8 : 10

            Rectangle {
                Layout.fillWidth: true
                height: isMobile ? 300 : 360
                radius: isMobile ? 12 : 16
                color: "#ffffff"
                border.color: "#e0e0e0"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: isMobile ? 16 : 24
                    spacing: isMobile ? 12 : 16

                    Row {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: isMobile ? 6 : 8

                        Image {
                            source: "qrc:/icons/server.png"
                            sourceSize: Qt.size(isMobile ? 20 : 24, isMobile ? 20 : 24)
                            fillMode: Image.PreserveAspectFit
                            mipmap: true
                            antialiasing: true
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "Настройки сервера"
                            font.pixelSize: isMobile ? 16 : 18
                            font.bold: true
                            color: "#2c3e50"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    // Круговая диаграмма пинга
                    Item {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: isMobile ? 180 : 220
                        Layout.preferredHeight: isMobile ? 130 : 160
                        Layout.topMargin: isMobile ? 10 : 0

                        // Фон дуги
                        Canvas {
                            id: pingArc
                            anchors.fill: parent
                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.clearRect(0, 0, width, height);

                                // Основная дуга (от левого края до правого)
                                ctx.beginPath();
                                ctx.arc(width/2, height/2 + (isMobile ? 20 : 20), width/2 - (isMobile ? 12 : 15), Math.PI, 2 * Math.PI, false);
                                ctx.strokeStyle = "#e0e0e0";
                                ctx.lineWidth = isMobile ? 6 : 8;
                                ctx.stroke();

                                // Активная часть дуги - используем анимированное значение
                                if ((pingStatus === "success" || animationRunning) && animatedPingValue >= 0) {
                                    ctx.beginPath();
                                    // Масштабируем значение: 0-200ms = 0-100%, больше 200ms = 100%
                                    var progress = Math.min(Math.max(animatedPingValue, 0), 200) / 200;
                                    var endAngle = Math.PI + progress * Math.PI;
                                    ctx.arc(width/2, height/2 + (isMobile ? 20 : 20), width/2 - (isMobile ? 12 : 15), Math.PI, endAngle, false);
                                    ctx.strokeStyle = getPingColor(animatedPingValue);
                                    ctx.lineWidth = isMobile ? 6 : 8;
                                    ctx.stroke();
                                }

                                // Разметка с делениями
                                ctx.fillStyle = "#6c757d";
                                ctx.font = (isMobile ? 8 : 10) + "px Arial";
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
                                    var innerRadius = width/2 - (isMobile ? 20 : 25);
                                    var outerRadius = width/2 - (isMobile ? 8 : 10);

                                    var x1 = width/2 + innerRadius * Math.cos(angle);
                                    var y1 = height/2 + (isMobile ? 20 : 20) + innerRadius * Math.sin(angle);
                                    var x2 = width/2 + outerRadius * Math.cos(angle);
                                    var y2 = height/2 + (isMobile ? 20 : 20) + outerRadius * Math.sin(angle);

                                    ctx.beginPath();
                                    ctx.moveTo(x1, y1);
                                    ctx.lineTo(x2, y2);
                                    ctx.stroke();

                                    // Текст меток
                                    var textRadius = width/2 - (isMobile ? 28 : 35);
                                    var textX = width/2 + textRadius * Math.cos(angle);
                                    var textY = height/2 + (isMobile ? 20 : 20) + textRadius * Math.sin(angle);

                                    ctx.fillText(value + (i === 4 ? "+" : "") + " мс", textX, textY);
                                }
                            }
                        }

                        // Текущее значение пинга
                        Row {
                            anchors.top: parent.top
                            anchors.topMargin: isMobile ? 45 : 50
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 2

                            Text {
                                text: {
                                    if (pingStatus === "checking") return "Измерение..."
                                    if (animationRunning) return Math.round(animatedPingValue) + " мс"
                                    if (pingStatus === "success") return pingValue.toFixed(0) + " мс"
                                    return "—"
                                }
                                font.pixelSize: isMobile ? 22 : 28
                                font.bold: true
                                color: {
                                    if (pingStatus === "checking") return "#3498db"
                                    if (animationRunning) return getPingColor(animatedPingValue)
                                    if (pingStatus === "success") return getPingColor(pingValue)
                                    return "#bdc3c7"
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: isMobile ? 8 : 12

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: isMobile ? 8 : 12

                            Text {
                                text: "Адрес сервера:"
                                font.pixelSize: isMobile ? 12 : 14
                                color: "#6c757d"
                                Layout.preferredWidth: isMobile ? 100 : 120
                            }

                            Text {
                                text: serverAddress
                                font.pixelSize: isMobile ? 12 : 14
                                color: "#2c3e50"
                                font.bold: true
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: isMobile ? 8 : 12

                            Text {
                                text: "Статус:"
                                font.pixelSize: isMobile ? 12 : 14
                                color: "#6c757d"
                                Layout.preferredWidth: isMobile ? 100 : 120
                            }

                            Text {
                                text: getStatusText()
                                font.pixelSize: isMobile ? 12 : 14
                                color: pingStatus === "success" ? "#27ae60" :
                                       pingStatus === "checking" ? "#3498db" : "#e74c3c"
                                font.bold: true
                                Layout.fillWidth: true
                            }
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: isMobile ? 140 : 180
                        Layout.preferredHeight: isMobile ? 40 : 44
                        Layout.alignment: Qt.AlignHCenter
                        radius: isMobile ? 8 : 10
                        color: {
                            if (pingStatus === "checking" || animationRunning) return "#95a5a6";
                            return pingMouseArea.containsMouse ? "#2980b9" : "#3498db";
                        }

                        Row {
                            anchors.centerIn: parent
                            spacing: isMobile ? 6 : 8

                            Image {
                                source: (pingStatus === "checking" || animationRunning) ? "qrc:/icons/loading.png" : "qrc:/icons/ping.png"
                                sourceSize: Qt.size(isMobile ? 20 : 24, isMobile ? 20 : 24)
                                fillMode: Image.PreserveAspectFit
                                mipmap: true
                                antialiasing: true
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: (pingStatus === "checking" || animationRunning) ? "Измерение..." : "Проверить отклик"
                                color: "white"
                                font.pixelSize: isMobile ? 12 : 14
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            id: pingMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: (pingStatus === "checking" || animationRunning) ? Qt.ArrowCursor : Qt.PointingHandCursor
                            onClicked: {
                                if (pingStatus !== "checking" && !animationRunning) {
                                    pingRequested();
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: isMobile ? 120 : 140
                radius: isMobile ? 12 : 16
                color: "#e8f4f8"
                border.color: "#b3e5fc"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: isMobile ? 12 : 20
                    spacing: isMobile ? 6 : 8

                    Row {
                        spacing: isMobile ? 4 : 6
                        Image {
                            source: "qrc:/icons/info.png"
                            sourceSize: Qt.size(isMobile ? 16 : 18, isMobile ? 16 : 18)
                            fillMode: Image.PreserveAspectFit
                            mipmap: true
                            antialiasing: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "Информация о подключении"
                            font.pixelSize: isMobile ? 12 : 14
                            font.bold: true
                            color: "#0277bd"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Text {
                        text: "• Ping показывает время отклика сервера\n• Рекомендуемое время: менее 120 мс\n• При высоких значениях проверьте интернет-соединение\n• Убедитесь, что сервер доступен и работает"
                        font.pixelSize: isMobile ? 11 : 12
                        color: "#0288d1"
                        lineHeight: 1.4
                    }
                }
            }
        }
    }

    // Анимация для плавного заполнения полоски пинга
    NumberAnimation {
        id: pingAnimation
        target: serverPage
        property: "animatedPingValue"
        duration: 750 // Уменьшена длительность анимации до 0.75 секунд
        easing.type: Easing.OutCubic // Плавное замедление в конце
        onStarted: {
            animationRunning = true;
        }
        onStopped: {
            animationRunning = false;
        }
    }

    onPingStatusChanged: {
        if (pingStatus === "success") {
            // Запускаем анимацию после успешного измерения
            startPingAnimation();
        } else {
            // Сбрасываем анимированное значение для других статусов
            animatedPingValue = 0;
            animationRunning = false;
        }
        pingArc.requestPaint();
    }

    onPingValueChanged: {
        if (pingStatus === "success") {
            // Если значение изменилось и статус успешный, перезапускаем анимацию
            startPingAnimation();
        }
        pingArc.requestPaint();
    }

    onAnimatedPingValueChanged: {
        pingArc.requestPaint();
    }
}
