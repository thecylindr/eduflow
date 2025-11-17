import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15

Page {
    id: sessionsPage
    background: Rectangle {
        color: "#f8f9fa"
    }

    property var sessions: []
    signal revokeSession(string token)

    // Сортируем сессии: текущая первая
    property var sortedSessions: {
        if (!sessions) return [];
        var current = [];
        var others = [];

        for (var i = 0; i < sessions.length; i++) {
            if (sessions[i].isCurrent) {
                current.push(sessions[i]);
            } else {
                others.push(sessions[i]);
            }
        }
        return current.concat(others);
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 10

        // Заголовок
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 5

            Row {
                Layout.alignment: Qt.AlignHCenter
                spacing: 8

                Image {
                    source: "qrc:/icons/sessions.png"
                    sourceSize: Qt.size(24, 24)
                    fillMode: Image.PreserveAspectFit
                    mipmap: true
                    antialiasing: true
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "Активные сессии"
                    font.pixelSize: 24
                    font.bold: true
                    color: "#2c3e50"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Text {
                text: "Всего активных сессий: " + sessions.length
                font.pixelSize: 14
                color: "#7f8c8d"
                Layout.alignment: Qt.AlignHCenter
            }
        }

        // Список сессий
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            Column {
                id: sessionsColumn
                width: parent.width
                spacing: 12
                anchors.horizontalCenter: parent.horizontalCenter

                Repeater {
                    model: sessionsPage.sortedSessions

                    Rectangle {
                        id: sessionCard
                        width: sessionsColumn.width
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: 100
                        radius: 12
                        color: modelData.isCurrent ? "#e3f2fd" : "#ffffff"
                        border.color: modelData.isCurrent ? "#2196f3" : "#e0e0e0"
                        border.width: 2

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            // Левая часть - статус и дата
                            Column {
                                Layout.preferredWidth: 100
                                Layout.alignment: Qt.AlignTop
                                spacing: 4

                                Row {
                                    spacing: 6
                                    Image {
                                        source: {
                                            if (modelData.isCurrent) return "qrc:/icons/status-connection.png";
                                            var minutes = parseInt(modelData.inactiveMinutes || "0");
                                            if (minutes <= 5) return "qrc:/icons/status-active.png";
                                            var hours = parseInt(modelData.ageHours || "0");
                                            if (hours >= 72) return "qrc:/icons/status-inactive.png";
                                            return "qrc:/icons/status-warning.png";
                                        }
                                        sourceSize: Qt.size(24, 24)
                                        fillMode: Image.PreserveAspectFit
                                        mipmap: true
                                        antialiasing: true
                                    }
                                    Text {
                                        text: {
                                            if (modelData.isCurrent) return "Текущая";
                                            var minutes = parseInt(modelData.inactiveMinutes || "0");
                                            if (minutes <= 5) return "Активная";
                                            var hours = parseInt(modelData.ageHours || "0");
                                            if (hours >= 72) return "Давно";
                                            return "Неактивная";
                                        }
                                        font.pixelSize: 11
                                        font.bold: true
                                        color: {
                                            if (modelData.isCurrent) return "#2196f3";
                                            var minutes = parseInt(modelData.inactiveMinutes || "0");
                                            if (minutes <= 5) return "#2ecc71";
                                            var hours = parseInt(modelData.ageHours || "0");
                                            if (hours >= 72) return "#e74c3c";
                                            return "#f39c12";
                                        }
                                    }
                                }

                                Text {
                                    text: formatDate(modelData.createdAt)
                                    font.pixelSize: 9
                                    color: "#95a5a6"
                                    width: parent.width
                                    elide: Text.ElideRight
                                }
                            }

                            // Центральная часть - информация о сессии
                            GridLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                columns: 2
                                columnSpacing: 8
                                rowSpacing: 4

                                // ОС
                                Row {
                                    spacing: 4
                                    Image {
                                        source: "qrc:/icons/os.png"
                                        sourceSize: Qt.size(16, 16)
                                        fillMode: Image.PreserveAspectFit
                                        mipmap: true
                                        antialiasing: true
                                    }
                                    Text {
                                        text: "ОС:"
                                        font.pixelSize: 11
                                        color: "#7f8c8d"
                                        font.bold: true
                                    }
                                }
                                Text {
                                    text: modelData.userOS && modelData.userOS !== "unknown" ? modelData.userOS : "Неизвестно"
                                    font.pixelSize: 11
                                    color: "#2c3e50"
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }

                                // IP
                                Row {
                                    spacing: 4
                                    Image {
                                        source: "qrc:/icons/ip.png"
                                        sourceSize: Qt.size(16, 16)
                                        fillMode: Image.PreserveAspectFit
                                        mipmap: true
                                        antialiasing: true
                                    }
                                    Text {
                                        text: "IP:"
                                        font.pixelSize: 11
                                        color: "#7f8c8d"
                                        font.bold: true
                                    }
                                }
                                Text {
                                    text: modelData.ipAddress && modelData.ipAddress !== "unknown" ? modelData.ipAddress : "Неизвестно"
                                    font.pixelSize: 11
                                    color: "#2c3e50"
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }

                                // Время существования
                                Row {
                                    spacing: 4
                                    Image {
                                        source: "qrc:/icons/time.png"
                                        sourceSize: Qt.size(16, 16)
                                        fillMode: Image.PreserveAspectFit
                                        mipmap: true
                                        antialiasing: true
                                    }
                                    Text {
                                        text: "Возраст:"
                                        font.pixelSize: 11
                                        color: "#7f8c8d"
                                        font.bold: true
                                    }
                                }
                                Text {
                                    text: (modelData.ageHours || "0") + " ч."
                                    font.pixelSize: 11
                                    color: "#2c3e50"
                                }

                                // Время неактивности
                                Row {
                                    spacing: 4
                                    Image {
                                        source: "qrc:/icons/activity.png"
                                        sourceSize: Qt.size(16, 16)
                                        fillMode: Image.PreserveAspectFit
                                        mipmap: true
                                        antialiasing: true
                                    }
                                    Text {
                                        text: "Активность:"
                                        font.pixelSize: 11
                                        color: "#7f8c8d"
                                        font.bold: true
                                    }
                                }
                                Text {
                                    text: {
                                        var minutes = parseInt(modelData.inactiveMinutes || "0");
                                        var hours = parseInt(modelData.ageHours || "0");

                                        if (minutes <= 5) {
                                            return "сейчас";
                                        } else if (minutes < 60) {
                                            return minutes + " мин. назад";
                                        } else if (hours > 1) {
                                            return hours + " ч. назад";
                                        } else if (hours > 72) {
                                            return Math.floor(hours / 24) + " д. назад";
                                        } else {
                                            return "Давно";
                                        }
                                    }
                                    font.pixelSize: 11
                                    color: {
                                        var minutes = parseInt(modelData.inactiveMinutes || "0");
                                        var hours = parseInt(modelData.ageHours || "0");

                                        if (minutes <= 5) return "#2ecc71";
                                        if (hours < 12) return "#2c3e50";
                                        if (hours < 72) return "#f39c12";
                                        return "#e74c3c";
                                    }
                                    font.bold: {
                                        var hours = parseInt(modelData.ageHours || "0");
                                        return hours >= 72;
                                    }
                                }
                            }

                            // Правая часть - кнопка отзыва
                            Item {
                                Layout.preferredWidth: 80
                                Layout.preferredHeight: 28
                                Layout.alignment: Qt.AlignCenter

                                // Кнопка "Отозвать" для не текущих сессий
                                Rectangle {
                                    visible: !modelData.isCurrent
                                    anchors.fill: parent
                                    radius: 6
                                    color: revokeMouseArea.containsMouse ? "#c0392b" : "#e74c3c"
                                    border.color: revokeMouseArea.containsMouse ? "#a93226" : "#c0392b"
                                    border.width: 1

                                    Row {
                                        anchors.centerIn: parent
                                        spacing: 4
                                        Image {
                                            source: "qrc:/icons/revoke.png"
                                            sourceSize: Qt.size(24, 24)
                                            fillMode: Image.PreserveAspectFit
                                            mipmap: true
                                            antialiasing: true
                                        }
                                        Text {
                                            text: "Отозвать"
                                            font.pixelSize: 10
                                            color: "white"
                                            font.bold: true
                                        }
                                    }

                                    MouseArea {
                                        id: revokeMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            console.log("Отзыв сессии:", modelData.token);
                                            sessionsPage.revokeSession(modelData.token);
                                        }
                                    }
                                }

                                // Заглушка "Текущая" для текущей сессии
                                Rectangle {
                                    visible: modelData.isCurrent
                                    anchors.fill: parent
                                    radius: 5
                                    color: "transparent"
                                    border.color: "#2196f3"
                                    border.width: 1

                                    Text {
                                        text: "Текущая"
                                        color: "#2196f3"
                                        font.pixelSize: 10
                                        font.bold: true
                                        anchors.centerIn: parent
                                    }
                                }
                            }
                        }
                    }
                }

                // Сообщение когда нет сессий
                Rectangle {
                    width: sessionsColumn.width
                    height: 100
                    radius: 12
                    color: "#ecf0f1"
                    border.color: "#bdc3c7"
                    visible: sessions.length === 0

                    Column {
                        anchors.centerIn: parent
                        spacing: 8

                        Image {
                            source: "qrc:/icons/sessions.png"
                            sourceSize: Qt.size(28, 28)
                            fillMode: Image.PreserveAspectFit
                            mipmap: true
                            antialiasing: true
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            text: "Активные сессии не найдены"
                            font.pixelSize: 14
                            color: "#7f8c8d"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }
        }

        // Подсказка
        Row {
            Layout.alignment: Qt.AlignHCenter
            spacing: 4
            visible: sessions.length > 0

            Image {
                source: "qrc:/icons/info.png"
                sourceSize: Qt.size(18, 18)
                fillMode: Image.PreserveAspectFit
                mipmap: true
                antialiasing: true
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: "Здесь отображаются все сессии вашего аккаунта."
                font.pixelSize: 11
                color: "#7f8c8d"
                font.italic: true
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    function formatDate(timestamp) {
        if (!timestamp) return "Неизвестно"
        var date = new Date(timestamp * 1000);
        if (isNaN(date.getTime())) {
            return "Неизвестно";
        }
        return date.toLocaleDateString(Qt.locale(), "dd.MM.yy") + " " +
               date.toLocaleTimeString(Qt.locale(), "HH:mm");
    }
}
