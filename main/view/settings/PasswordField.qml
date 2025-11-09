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

        Rectangle {
            Layout.fillWidth: true
            height: 35
            radius: 6
            border.color: textField.activeFocus ? "#2196f3" : "#ced4da"
            border.width: 1
            color: "#ffffff"

            TextField {
                id: textField
                anchors.fill: parent
                anchors.margins: 2
                echoMode: TextInput.Password
                text: value
                font.pixelSize: 13
                placeholderText: "Введите пароль"
                background: null

                onTextChanged: valueChanged(text)
            }
        }
    }
}
