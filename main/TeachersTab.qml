import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    color: "transparent"

    property ListModel teachersModel
    signal refresh()

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        Button {
            text: "🔄 Обновить"
            onClicked: refresh()
            Layout.alignment: Qt.AlignLeft
        }

        Text {
            text: "Преподаватели: " + teachersModel.count
            font.pixelSize: 16
            font.bold: true
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: teachersList
                model: teachersModel
                spacing: 5
                delegate: Rectangle {
                    width: teachersList.width
                    height: 70
                    radius: 8
                    color: index % 2 ? "#f8f9fa" : "#ffffff"
                    border.color: "#e9ecef"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        ColumnLayout {
                            Layout.fillWidth: true
                            Text {
                                text: model.last_name + " " + model.first_name + (model.middle_name ? " " + model.middle_name : "")
                                font.bold: true
                                font.pixelSize: 14
                            }
                            Text {
                                text: "Специализация: " + model.specialization + " | Опыт: " + model.experience + " лет"
                                font.pixelSize: 12
                                color: "#6c757d"
                            }
                        }

                        ColumnLayout {
                            Text {
                                text: model.email
                                font.pixelSize: 12
                            }
                            Text {
                                text: model.phone_number
                                font.pixelSize: 12
                                color: "#6c757d"
                            }
                        }
                    }
                }
            }
        }
    }
}
