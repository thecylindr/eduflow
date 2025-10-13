// main/EventsView.qml
import QtQuick 2.15
import QtQuick.Layouts 1.15

Item {
    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        Text {
            text: "📅 Управление событиями"
            font.pixelSize: 20
            font.bold: true
            color: "#2c3e50"
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: "Раздел в разработке"
            font.pixelSize: 16
            color: "#7f8c8d"
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 50
        }
    }
}
