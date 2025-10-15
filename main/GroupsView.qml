// main/GroupsView.qml
import QtQuick 2.15
import QtQuick.Layouts 1.15

Item {
    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        Text {
            text: "👥 Управление группами"
            font.pixelSize: 20
            font.bold: true
            color: "#2c3e50"
            Layout.alignment: Qt.AlignHCenter
        }

        Rectangle {
            Layout.fillWidth: true
            height: 40
            radius: 8
            color: "#e74c3c"

            Row {
                anchors.centerIn: parent
                spacing: 10

                Text {
                    text: "Всего групп: " + mainWindow.groups.length
                    color: "white"
                    font.pixelSize: 14
                    font.bold: true
                }
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: mainWindow.groups
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
                        color: "#e74c3c"
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: "👥"
                            font.pixelSize: 16
                            anchors.centerIn: parent
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2

                        Text {
                            text: modelData.name || "Без названия"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#2c3e50"
                        }

                        Text {
                            text: "Студентов: " + (modelData.studentCount || "0") + " | Куратор: " + (modelData.teacherId || "Не назначен")
                            font.pixelSize: 11
                            color: "#7f8c8d"
                        }
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                text: "Нет данных о группах"
                color: "#7f8c8d"
                font.pixelSize: 14
                visible: mainWindow.groups.length === 0
            }
        }
    }
}
