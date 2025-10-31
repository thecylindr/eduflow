// enhanced/EnhancedTextField.qml
import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: textField
    height: 40
    radius: 8
    color: "#f8f9fa"
    border.color: textField.activeFocus ? "#3498db" : "#ddd"
    border.width: 2

    property string placeholderText: ""
    property string text: ""
    property bool passwordMode: false

    // Изменил имя сигнала чтобы избежать конфликта с TextInput
    signal userTextChanged(string text)

    TextInput {
        id: inputField
        anchors.fill: parent
        anchors.margins: 10
        verticalAlignment: TextInput.AlignVCenter
        font.pixelSize: 14
        color: "#2c3e50"
        echoMode: passwordMode ? TextInput.Password : TextInput.Normal

        onTextChanged: {
            textField.text = text
            textField.userTextChanged(text) // Используем новый сигнал
        }

        Text {
            id: placeholder
            anchors.fill: parent
            verticalAlignment: TextInput.AlignVCenter
            text: textField.placeholderText
            font: inputField.font
            color: "#95a5a6"
            visible: !inputField.text && !inputField.activeFocus
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: inputField.forceActiveFocus()
    }
}
