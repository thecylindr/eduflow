import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: confirmDialog
    width: 300
    height: 160
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape

    property string message: "Вы уверены?"
    signal accepted()
    signal rejected()

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: "#ffffff"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20

            Text {
                text: message
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                font.pixelSize: 14
                color: "#333333"
            }

            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: 10

                Button {
                    text: "Отмена"
                    Layout.preferredWidth: 80
                    onClicked: {
                        confirmDialog.rejected();
                        confirmDialog.close();
                    }
                }

                Button {
                    text: "Выйти"
                    onClicked: {
                        confirmDialog.accepted();
                        confirmDialog.close();
                    }
                }
            }
        }
    }
}
