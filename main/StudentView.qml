// main/StudentsView.qml
import QtQuick 2.15
import QtQuick.Layouts 1.15

Item {
    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        Text {
            text: "👨‍🎓 Управление студентами"
            font.pixelSize: 20
            font.bold: true
            color: "#2c3e50"
            Layout.alignment: Qt.AlignHCenter
        }

        Rectangle {
            Layout.fillWidth: true
            height: 40
            radius: 8
            color: "#2ecc71"

            Row {
                anchors.centerIn: parent
                spacing: 10

                Text {
                    text: "Всего студентов: " + mainWindow.students.length
                    color: "white"
                    font.pixelSize: 14
                    font.bold: true
                }
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: mainWindow.students
            spacing: 5
            clip: true

            delegate: Rectangle {
                width: ListView.view.width
                height: 60
                radius: 8
                color: index % 2 === 0 ? "#f8f9fa" : "#ffffff"
                border.color: "#e9ecef"
                border.width: 1

                Row {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 15

                    Rectangle {
                        width: 40
                        height: 40
                        radius: 20
                        color: "#2ecc71"
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: "👨‍🎓"
                            font.pixelSize: 16
                            anchors.centerIn: parent
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2

                        Text {
                            text: (modelData.lastName || "") + " " + (modelData.firstName || "") + " " + (modelData.middleName || "")
                            font.pixelSize: 14
                            font.bold: true
                            color: "#2c3e50"
                        }

                        Text {
                            text: "Группа: " + (modelData.groupId || "")
                            font.pixelSize: 11
                            color: "#7f8c8d"
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: modelData.email || "Нет email"
                        font.pixelSize: 11
                        color: "#7f8c8d"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                text: "Нет данных о студентах"
                color: "#7f8c8d"
                font.pixelSize: 14
                visible: mainWindow.students.length === 0
            }
        }
    }
}
