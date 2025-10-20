// main/DashboardView.qml
import QtQuick 2.15
import QtQuick.Layouts 1.15

Item {
    Column {
        anchors.centerIn: parent
        spacing: 20

        // Заголовок с полоской
        Column {
            width: parent.width
            spacing: 8

            Text {
                text: "🏠 Главная панель"
                font.pixelSize: 24
                font.bold: true
                color: "#2c3e50"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // Серая полоска под заголовком
            Rectangle {
                width: parent.width
                height: 1
                color: "#e0e0e0"
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        Text {
            text: "Добро пожаловать в EduFlow!\n\nСистема управления образовательным процессом."
            font.pixelSize: 14
            color: "#7f8c8d"
            horizontalAlignment: Text.AlignHCenter
        }

        Grid {
            columns: 2
            spacing: 15
            anchors.horizontalCenter: parent.horizontalCenter

            Rectangle {
                width: 140
                height: 80
                radius: 8
                color: "#e8f4f8"
                border.color: "#3498db"
                border.width: 2

                Column {
                    anchors.centerIn: parent
                    spacing: 2

                    Text {
                        text: "👨‍🏫 Преподаватели"
                        font.pixelSize: 12
                        font.bold: true
                        color: "#2c3e50"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: mainWindow.teachers.length + " чел."
                        font.pixelSize: 16
                        font.bold: true
                        color: "#3498db"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }

            Rectangle {
                width: 140
                height: 80
                radius: 8
                color: "#e8f4f8"
                border.color: "#2ecc71"
                border.width: 2

                Column {
                    anchors.centerIn: parent
                    spacing: 2

                    Text {
                        text: "👨‍🎓 Студенты"
                        font.pixelSize: 12
                        font.bold: true
                        color: "#2c3e50"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: mainWindow.students.length + " чел."
                        font.pixelSize: 16
                        font.bold: true
                        color: "#2ecc71"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }

            Rectangle {
                width: 140
                height: 80
                radius: 8
                color: "#e8f4f8"
                border.color: "#e74c3c"
                border.width: 2

                Column {
                    anchors.centerIn: parent
                    spacing: 2

                    Text {
                        text: "👥 Группы"
                        font.pixelSize: 12
                        font.bold: true
                        color: "#2c3e50"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: mainWindow.groups.length + " шт."
                        font.pixelSize: 16
                        font.bold: true
                        color: "#e74c3c"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }

            Rectangle {
                width: 140
                height: 80
                radius: 8
                color: "#e8f4f8"
                border.color: "#9b59b6"
                border.width: 2

                Column {
                    anchors.centerIn: parent
                    spacing: 2

                    Text {
                        text: "📊 Активность"
                        font.pixelSize: 12
                        font.bold: true
                        color: "#2c3e50"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: "Онлайн"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#9b59b6"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }
    }
}
