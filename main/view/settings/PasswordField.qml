import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: passwordField
    color: "transparent"

    property string label: ""
    property string value: ""
    signal valueChanged(string value)

    Layout.fillWidth: true
    height: 60

    ColumnLayout {
        anchors.fill: parent
        spacing: 5

        Text {
            text: label
            font.pixelSize: 13
            color: "#2c3e50"
        }

        TextField {
            Layout.fillWidth: true
            height: 35
            echoMode: TextInput.Password
            text: value
            font.pixelSize: 13
            placeholderText: "Введите пароль"
            background: Rectangle {
                radius: 6
                border.color: parent.activeFocus ? "#2196f3" : "#ced4da"
                border.width: 1
                color: "#ffffff"
            }
            onTextChanged: valueChanged(text)
        }
    }
}
