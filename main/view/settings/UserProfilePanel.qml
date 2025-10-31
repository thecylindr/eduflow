// settings/UserProfilePanel.qml
import QtQuick 2.15

Rectangle {
    id: userProfilePanel
    width: parent.width
    height: 150
    radius: 8
    color: "#e8f6f3"
    border.color: "#1abc9c"
    border.width: 2

    property var userProfile: ({})

    Text {
        id: profileTitle
        anchors.top: parent.top
        anchors.topMargin: 12
        anchors.left: parent.left
        anchors.leftMargin: 12
        text: "👤 Профиль пользователя"
        font.pixelSize: 14
        font.bold: true
        color: "#2c3e50"
    }

    Rectangle {
        id: profileLine
        anchors.top: profileTitle.bottom
        anchors.topMargin: 8
        width: parent.width
        height: 1
        color: "#1abc9c"
    }

    Grid {
        anchors.top: profileLine.bottom
        anchors.topMargin: 8
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.right: parent.right
        anchors.rightMargin: 12
        columns: 2
        columnSpacing: 8
        rowSpacing: 5

        Text { text: "Логин:"; color: "#7f8c8d"; font.pixelSize: 11 }
        Text {
            text: userProfile.login || "не указан";
            color: "#2c3e50";
            font.pixelSize: 11;
            font.bold: true;
        }

        Text { text: "ФИО:"; color: "#7f8c8d"; font.pixelSize: 11 }
        Text {
            text: (userProfile.lastName || "") + " " + (userProfile.firstName || "") + " " + (userProfile.middleName || "");
            color: "#2c3e50";
            font.pixelSize: 11;
            font.bold: true;
        }

        Text { text: "Email:"; color: "#7f8c8d"; font.pixelSize: 11 }
        Text {
            text: userProfile.email || "не указан";
            color: "#2c3e50";
            font.pixelSize: 11;
            font.bold: true;
        }

        Text { text: "Телефон:"; color: "#7f8c8d"; font.pixelSize: 11 }
        Text {
            text: userProfile.phoneNumber || "не указан";
            color: "#2c3e50";
            font.pixelSize: 11;
            font.bold: true;
        }
    }
}
