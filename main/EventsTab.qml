import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    property ListModel eventsModel
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
                id: eventsList
                model: eventsModel
                spacing: 2

                delegate: Rectangle {
                    width: eventsList.width
                    height: 80
                    color: index % 2 ? "#f8f9fa" : "#ffffff"
                    border.color: "#e9ecef"
                    border.width: 1
                    radius: 4

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10

                        Text {
                            text: model.event_category + " (" + model.event_type + ")"
                            font.bold: true
                            font.pixelSize: 14
                        }

                        Text {
                            text: "Период: " + model.start_date + " - " + model.end_date
                            font.pixelSize: 12
                        }

                        Text {
                            text: "Место: " + (model.location || "Не указано")
                            font.pixelSize: 12
                            color: "#6c757d"
                        }
                    }
                }
            }
        }
    }
}