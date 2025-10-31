// settings/ProfileEditPanel.qml
import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: profileEditPanel
    width: parent.width
    height: 260
    radius: 8
    color: "#eaf2f8"
    border.color: "#3498db"
    border.width: 2

    property var userProfile: ({})
    signal profileSaved()

    property string firstName: userProfile.firstName || ""
    property string lastName: userProfile.lastName || ""
    property string middleName: userProfile.middleName || ""
    property string email: userProfile.email || ""
    property string phoneNumber: userProfile.phoneNumber || ""

    Text {
        id: editProfileTitle
        anchors.top: parent.top
        anchors.topMargin: 12
        anchors.left: parent.left
        anchors.leftMargin: 12
        text: "✏️ Редактирование профиля"
        font.pixelSize: 14
        font.bold: true
        color: "#2c3e50"
    }

    Rectangle {
        id: editProfileLine
        anchors.top: editProfileTitle.bottom
        anchors.topMargin: 8
        width: parent.width
        height: 1
        color: "#3498db"
    }

    Column {
        anchors.top: editProfileLine.bottom
        anchors.topMargin: 12
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.right: parent.right
        anchors.rightMargin: 12
        spacing: 8

        Row {
            width: parent.width
            spacing: 10

            Column {
                width: (parent.width - 20) / 3
                spacing: 5

                Text {
                    text: "Фамилия:"
                    color: "#7f8c8d"
                    font.pixelSize: 11
                }
                TextField {
                    id: lastNameField
                    width: parent.width
                    placeholderText: "Фамилия"
                    font.pixelSize: 11
                    text: profileEditPanel.lastName
                }
            }

            Column {
                width: (parent.width - 20) / 3
                spacing: 5

                Text {
                    text: "Имя:"
                    color: "#7f8c8d"
                    font.pixelSize: 11
                }
                TextField {
                    id: firstNameField
                    width: parent.width
                    placeholderText: "Имя"
                    font.pixelSize: 11
                    text: profileEditPanel.firstName
                }
            }

            Column {
                width: (parent.width - 20) / 3
                spacing: 5

                Text {
                    text: "Отчество:"
                    color: "#7f8c8d"
                    font.pixelSize: 11
                }
                TextField {
                    id: middleNameField
                    width: parent.width
                    placeholderText: "Отчество"
                    font.pixelSize: 11
                    text: profileEditPanel.middleName
                }
            }
        }

        Column {
            width: parent.width
            spacing: 5

            Text {
                text: "Email:"
                color: "#7f8c8d"
                font.pixelSize: 11
            }
            TextField {
                id: emailField
                width: parent.width
                placeholderText: "Email"
                font.pixelSize: 11
                text: profileEditPanel.email
            }
        }

        Column {
            width: parent.width
            spacing: 5

            Text {
                text: "Телефон:"
                color: "#7f8c8d"
                font.pixelSize: 11
            }
            TextField {
                id: phoneField
                width: parent.width
                placeholderText: "Телефон"
                font.pixelSize: 11
                text: profileEditPanel.phoneNumber
            }
        }

        Rectangle {
            width: parent.width
            height: 30
            radius: 5
            color: saveProfileMouseArea.containsMouse ? "#27ae60" : "#2ecc71"

            Text {
                anchors.centerIn: parent
                text: "💾 Сохранить изменения"
                color: "white"
                font.pixelSize: 11
                font.bold: true
            }

            MouseArea {
                id: saveProfileMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: profileSaved()
            }
        }
    }
}
