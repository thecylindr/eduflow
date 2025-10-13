// main/UserSettingsPanel.qml
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects

Rectangle {
    id: userSettingsPanel
    width: 300
    height: 400
    radius: 12
    color: "#ffffff"
    opacity: 0.98
    border.color: "#e0e0e0"
    border.width: 1
    visible: false

    property string userName: "Пользователь"
    property string userEmail: "user@example.com"
    property string userRole: "Преподаватель"

    signal logoutRequested
    signal closePanel

    // Эффект тени
    DropShadow {
        anchors.fill: userSettingsPanel
        horizontalOffset: 0
        verticalOffset: 4
        radius: 16
        samples: 17
        color: "#60000000"
        source: userSettingsPanel
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 10

        // Заголовок панели
        Text {
            text: "👤 Настройки профиля"
            font.pixelSize: 16
            font.bold: true
            color: "#2c3e50"
            Layout.alignment: Qt.AlignHCenter
        }

        // Разделитель
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#e0e0e0"
        }

        // Информация о пользователе
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 5

            Text {
                text: "Информация о пользователе"
                font.pixelSize: 12
                font.bold: true
                color: "#7f8c8d"
            }

            Rectangle {
                Layout.fillWidth: true
                height: 80
                radius: 8
                color: "#f8f9fa"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10

                    Text {
                        text: userSettingsPanel.userName
                        font.pixelSize: 14
                        font.bold: true
                        color: "#2c3e50"
                    }

                    Text {
                        text: userSettingsPanel.userEmail
                        font.pixelSize: 11
                        color: "#7f8c8d"
                    }

                    Text {
                        text: "Роль: " + userSettingsPanel.userRole
                        font.pixelSize: 10
                        color: "#3498db"
                    }
                }
            }
        }

        // Настройки уведомлений
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 5

            Text {
                text: "Уведомления"
                font.pixelSize: 12
                font.bold: true
                color: "#7f8c8d"
            }

            Rectangle {
                Layout.fillWidth: true
                height: 100
                radius: 8
                color: "#f8f9fa"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 5

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "📧 Email уведомления"
                            font.pixelSize: 11
                            color: "#2c3e50"
                            Layout.fillWidth: true
                        }

                        Switch {
                            checked: true
                            onCheckedChanged: console.log("Email уведомления:", checked)
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "🔔 Push уведомления"
                            font.pixelSize: 11
                            color: "#2c3e50"
                            Layout.fillWidth: true
                        }

                        Switch {
                            checked: true
                            onCheckedChanged: console.log("Push уведомления:", checked)
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "📱 SMS уведомления"
                            font.pixelSize: 11
                            color: "#2c3e50"
                            Layout.fillWidth: true
                        }

                        Switch {
                            checked: false
                            onCheckedChanged: console.log("SMS уведомления:", checked)
                        }
                    }
                }
            }
        }

        // Настройки темы
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 5

            Text {
                text: "Внешний вид"
                font.pixelSize: 12
                font.bold: true
                color: "#7f8c8d"
            }

            Rectangle {
                Layout.fillWidth: true
                height: 50
                radius: 8
                color: "#f8f9fa"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10

                    Text {
                        text: "🎨 Тема оформления"
                        font.pixelSize: 11
                        color: "#2c3e50"
                        Layout.fillWidth: true
                    }

                    ComboBox {
                        Layout.preferredWidth: 120
                        model: ["Светлая", "Темная", "Системная"]
                        currentIndex: 0
                        onActivated: console.log("Выбрана тема:", currentText)
                    }
                }
            }
        }

        // Кнопки действий
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            Rectangle {
                Layout.fillWidth: true
                height: 40
                radius: 8
                color: editProfileMouseArea.pressed ? "#3498db" : "#2980b9"

                Row {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        text: "✏️"
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "Редактировать профиль"
                        font.pixelSize: 12
                        color: "white"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: editProfileMouseArea
                    anchors.fill: parent
                    onClicked: console.log("Редактирование профиля")
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 40
                radius: 8
                color: changePasswordMouseArea.pressed ? "#27ae60" : "#2ecc71"

                Row {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        text: "🔒"
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "Сменить пароль"
                        font.pixelSize: 12
                        color: "white"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: changePasswordMouseArea
                    anchors.fill: parent
                    onClicked: console.log("Смена пароля")
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 40
                radius: 8
                color: logoutMouseArea.pressed ? "#c0392b" : "#e74c3c"

                Row {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        text: "🚪"
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "Выйти из системы"
                        font.pixelSize: 12
                        color: "white"
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: logoutMouseArea
                    anchors.fill: parent
                    onClicked: userSettingsPanel.logoutRequested()
                }
            }
        }

        // Кнопка закрытия
        Rectangle {
            Layout.fillWidth: true
            height: 30
            radius: 6
            color: closeMouseArea.pressed ? "#bdc3c7" : "#ecf0f1"

            Text {
                anchors.centerIn: parent
                text: "Закрыть"
                font.pixelSize: 11
                color: "#7f8c8d"
            }

            MouseArea {
                id: closeMouseArea
                anchors.fill: parent
                onClicked: userSettingsPanel.closePanel()
            }
        }
    }

    // Анимация появления
    Behavior on opacity {
        NumberAnimation { duration: 200 }
    }

    function show() {
        visible = true
        opacity = 1
    }

    function hide() {
        opacity = 0
        visible = false
    }
}
