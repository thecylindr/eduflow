// main/PortfolioView.qml
import QtQuick 2.15
import QtQuick.Layouts 1.15

Item {
    ColumnLayout {
        anchors.fill: parent
        spacing: 15

        // Заголовок с полоской
        Column {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: "📁 Портфолио студентов"
                font.pixelSize: 20
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
            text: "Раздел в разработке"
            font.pixelSize: 16
            color: "#7f8c8d"
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 50
        }
    }
}
