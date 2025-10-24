import QtQuick 2.15
import QtQuick.Layouts 1.15

Popup {
    id: confirmDialog
    width: 400
    height: 200
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape

    property string title: "Подтверждение"
    property string message: "Вы уверены?"
    property string confirmText: "Да"
    property string cancelText: "Отмена"

    signal confirmed
    signal cancelled

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: "#ffffff"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            // Заголовок
            Text {
                text: title
                font.pixelSize: 16
                font.bold: true
                color: "#2c3e50"
                Layout.alignment: Qt.AlignHCenter
            }

            // Сообщение
            Text {
                text: message
                font.pixelSize: 14
                color: "#7f8c8d"
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                Layout.fillHeight: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            // Кнопки
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    radius: 8
                    color: cancelMouseArea.containsMouse ? "#95a5a6" : "#bdc3c7"

                    Text {
                        anchors.centerIn: parent
                        text: cancelText
                        color: "white"
                        font.pixelSize: 14
                        font.bold: true
                    }

                    MouseArea {
                        id: cancelMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            confirmDialog.cancelled();
                            confirmDialog.close();
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    radius: 8
                    color: confirmMouseArea.containsMouse ? "#c0392b" : "#e74c3c"

                    Text {
                        anchors.centerIn: parent
                        text: confirmText
                        color: "white"
                        font.pixelSize: 14
                        font.bold: true
                    }

                    MouseArea {
                        id: confirmMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            confirmDialog.confirmed();
                            confirmDialog.close();
                        }
                    }
                }
            }
        }
    }
}
