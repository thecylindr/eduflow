import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: root
    width: Math.min(parent.width * 0.85, 400)
    height: contentColumn.implicitHeight + 50
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    modal: true
    dim: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    property string title: "Выход из приложения"
    property string message: "Вы уверены, что хотите выйти?"
    property string confirmText: "Выйти"
    property string cancelText: "Отмена"

    signal confirmed()
    signal cancelled()

    background: Rectangle {
        radius: 16
        color: "#ffffff"
        border.color: "#e0e0e0"
        border.width: 1
    }

    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        Label {
            text: root.title
            font.bold: true
            font.pixelSize: 18
            color: "#2c3e50"
            Layout.alignment: Qt.AlignHCenter
        }

        Label {
            text: root.message
            font.pixelSize: 14
            color: "#5a6c7d"
            wrapMode: Text.Wrap
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 12

            Button {
                text: root.cancelText
                font.pixelSize: 14
                implicitWidth: 120
                implicitHeight: 44

                background: Rectangle {
                    radius: 8
                    color: parent.down ? "#e0e0e0" : "#f5f5f5"
                    border.color: "#d0d0d0"
                    border.width: 1
                }

                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: "#5a6c7d"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    root.cancelled()
                    root.close()
                }
            }

            Button {
                text: root.confirmText
                font.pixelSize: 14
                font.bold: true
                implicitWidth: 120
                implicitHeight: 44

                background: Rectangle {
                    radius: 8
                    color: parent.down ? "#c62828" : "#f44336"
                    border.color: parent.down ? "#b71c1c" : "#d32f2f"
                    border.width: 1
                }

                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    root.confirmed()
                    root.close()
                }
            }
        }
    }

    function openDialog() {
        open()
    }
}
