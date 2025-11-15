import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: serverConfigBox
    width: parent.width
    height: settingsManager.useLocalServer ? 150 : 60
    radius: 8
    color: "#f8f8f8"
    opacity: 0.95
    border.color: "#e0e0e0"
    border.width: 1
    clip: true

    signal serverTypeToggled(bool useLocal)
    signal saveServerConfig(string serverAddress)
    signal resetSettings

    // Функция синхронизации UI с настройками
    function updateFromSettings() {
        serverAddressField.text = settingsManager.serverAddress;
    }

    Component.onCompleted: {
        updateFromSettings();
    }

    // Обработка изменений настроек
    Connections {
        target: settingsManager
        function onUseLocalServerChanged() {
            updateFromSettings();
        }
        function onServerAddressChanged() {
            serverAddressField.text = settingsManager.serverAddress;
        }
    }

    Behavior on height {
        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 15

            Rectangle {
                Layout.fillWidth: true
                height: 40
                radius: 8
                color: !settingsManager.useLocalServer ? "#e3f2fd" : "#f5f5f5"
                border.color: !settingsManager.useLocalServer ? "#2196f3" : "#e0e0e0"
                border.width: 2

                Row {
                    anchors.centerIn: parent
                    spacing: 6

                    Image {
                        source: "qrc:/icons/earth.png"
                        sourceSize: Qt.size(20, 20)
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "Официальный\nEduFlow"
                        font.pixelSize: 11
                        color: !settingsManager.useLocalServer ? "#1976d2" : "#9e9e9e"
                        horizontalAlignment: Text.AlignHCenter
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        console.log("Выбран официальный сервер");
                        serverTypeToggled(false);
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 40
                radius: 8
                color: settingsManager.useLocalServer ? "#e8f5e8" : "#f5f5f5"
                border.color: settingsManager.useLocalServer ? "#4caf50" : "#e0e0e0"
                border.width: 2

                Row {
                    anchors.centerIn: parent
                    spacing: 6

                    AnimatedImage {
                        source: settingsManager.useLocalServer ? "qrc:/icons/server.gif" : "qrc:/icons/server.png"
                        sourceSize: Qt.size(20, 20)
                        anchors.verticalCenter: parent.verticalCenter
                        playing: settingsManager.useLocalServer
                        speed: 0.7
                    }

                    Text {
                        text: "Локальный\nНастраиваемый"
                        font.pixelSize: 11
                        color: settingsManager.useLocalServer ? "#2e7d32" : "#9e9e9e"
                        horizontalAlignment: Text.AlignHCenter
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        console.log("Выбран локальный сервер");
                        serverTypeToggled(true);
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            visible: settingsManager.useLocalServer
            opacity: visible ? 1 : 0

            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Row {
                    spacing: 4
                    Image {
                        source: "qrc:/icons/ip.png"
                        sourceSize: Qt.size(16, 16)
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "Адрес сервера:"
                        font.pixelSize: 11
                        color: "#2c3e50"
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 30
                    radius: 4
                    border.color: serverAddressField.activeFocus ? "#3498db" : "#d0d0d0"
                    border.width: serverAddressField.activeFocus ? 1.5 : 1
                    color: "#ffffff"

                    TextInput {
                        id: serverAddressField
                        anchors.fill: parent
                        anchors.margins: 8
                        verticalAlignment: TextInput.AlignVCenter
                        font.pixelSize: 11
                        text: settingsManager.serverAddress
                        selectByMouse: true
                        onTextChanged: {
                            // Обновляем текст в реальном времени
                        }
                    }

                    Text {
                        anchors.fill: parent
                        anchors.margins: 8
                        verticalAlignment: Text.AlignVCenter
                        text: "http://localhost:5000"
                        color: "#a0a0a0"
                        visible: !serverAddressField.text && !serverAddressField.activeFocus
                        font.pixelSize: 11
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Rectangle {
                    id: saveButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    radius: 8
                    color: saveMouseArea.pressed ? "#27ae60" : "#2ecc71"

                    Row {
                        anchors.centerIn: parent
                        spacing: 6
                        Image {
                            source: "qrc:/icons/save.png"
                            sourceSize: Qt.size(16, 16)
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "Сохранить"
                            color: "white"
                            font.pixelSize: 11
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: saveMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            console.log("Сохранение конфигурации сервера:", serverAddressField.text);
                            saveServerConfig(serverAddressField.text);
                        }
                    }
                }

                Rectangle {
                    id: resetButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    radius: 8
                    color: resetMouseArea.pressed ? "#c0392b" : "#e74c3c"

                    Row {
                        anchors.centerIn: parent
                        spacing: 6
                        AnimatedImage {
                            source: resetMouseArea.containsMouse ? "qrc:/icons/refresh.png" : "qrc:/icons/refresh.png"
                            sourceSize: Qt.size(16, 16)
                            anchors.verticalCenter: parent.verticalCenter
                            playing: resetMouseArea.containsMouse
                        }
                        Text {
                            text: "Сбросить"
                            color: "white"
                            font.pixelSize: 11
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: resetMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            console.log("Сброс настроек сервера");
                            resetSettings();
                        }
                    }
                }
            }
        }
    }
}
