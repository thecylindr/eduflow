import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    property ListModel portfolioModel
    property ListModel studentsModel
    signal refresh()

    color: "transparent"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10

        RowLayout {
            Button {
                text: "🔄 Обновить"
                onClicked: refresh()
            }
            Item { Layout.fillWidth: true }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: portfolioList
                model: portfolioModel
                spacing: 2

                delegate: Rectangle {
                    width: portfolioList.width
                    height: 70
                    color: index % 2 ? "#f8f9fa" : "#ffffff"
                    border.color: "#e9ecef"
                    border.width: 1
                    radius: 4

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10

                        Text {
                            text: "Студент ID: " + model.student_code + " | Мероприятие: " + model.measure_code
                            font.bold: true
                            font.pixelSize: 14
                        }

                        Text {
                            text: "Дата: " + model.date + " | Паспорт: " + model.passport_series + " " + model.passport_number
                            font.pixelSize: 12
                            color: "#6c757d"
                        }
                    }
                }
            }
        }
    }
}