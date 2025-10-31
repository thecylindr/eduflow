// settings/PasswordChangePanel.qml
import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: passwordChangePanel
    width: parent.width
    height: 190 // Немного уменьшена высота
    radius: 8
    color: "#fdedec"
    border.color: "#e74c3c"
    border.width: 2

    signal passwordChangeRequested()

    property string currentPassword: ""
    property string newPassword: ""
    property string confirmPassword: ""

    Text {
        id: passwordTitle
        anchors.top: parent.top
        anchors.topMargin: 12
        anchors.left: parent.left
        anchors.leftMargin: 12
        text: "🔒 Смена пароля"
        font.pixelSize: 14
        font.bold: true
        color: "#2c3e50"
    }

    Rectangle {
        id: passwordLine
        anchors.top: passwordTitle.bottom
        anchors.topMargin: 8
        width: parent.width
        height: 1
        color: "#e74c3c"
    }

    Column {
        anchors.top: passwordLine.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.right: parent.right
        anchors.rightMargin: 12
        spacing: 6 // Уменьшен spacing

        TextField {
            id: currentPasswordField
            width: parent.width
            placeholderText: "Текущий пароль"
            echoMode: TextInput.Password
            font.pixelSize: 11
            onTextChanged: passwordChangePanel.currentPassword = text
        }

        TextField {
            id: newPasswordField
            width: parent.width
            placeholderText: "Новый пароль"
            echoMode: TextInput.Password
            font.pixelSize: 11
            onTextChanged: passwordChangePanel.newPassword = text
        }

        TextField {
            id: confirmPasswordField
            width: parent.width
            placeholderText: "Подтвердите пароль"
            echoMode: TextInput.Password
            font.pixelSize: 11
            onTextChanged: passwordChangePanel.confirmPassword = text
        }

        Text {
            width: parent.width
            text: "⚠️ После смены пароля все сессии будут отозваны"
            font.pixelSize: 9
            color: "#e67e22"
            wrapMode: Text.WordWrap
        }

        Rectangle {
            width: parent.width
            height: 28
            radius: 5
            color: changePasswordMouseArea.containsMouse ? "#e74c3c" : "#ff6b6b"

            Text {
                anchors.centerIn: parent
                text: "🔄 Сменить пароль"
                color: "white"
                font.pixelSize: 11
                font.bold: true
            }

            MouseArea {
                id: changePasswordMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: passwordChangeRequested()
            }
        }
    }
}
