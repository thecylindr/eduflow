import QtQuick
import QtQuick.Layouts 1.15

Rectangle {
    id: adaptiveSideBar
    width: Math.min(parent.width * 0.8, 300)
    height: parent.height
    color: "#ffffff"
    radius: 16
    opacity: 0.925
    border.color: "#e0e0e0"
    border.width: 1
    z: 1000

    property string currentView: "dashboard"
    property bool isOpen: false
    property int topMargin: 0
    property bool swipeEnabled: true

    property var menuItems: [
        {icon: "qrc:/icons/home.png", name: "Главная панель", view: "dashboard"},
        {icon: "qrc:/icons/faq.png", name: "Справочник", view: "faq"},
        {icon: "qrc:/icons/teachers.png", name: "Преподаватели", view: "teachers"},
        {icon: "qrc:/icons/students.png", name: "Студенты", view: "students"},
        {icon: "qrc:/icons/groups.png", name: "Группы", view: "groups"},
        {icon: "qrc:/icons/portfolio.png", name: "Портфолио", view: "portfolio"},
        {icon: "qrc:/icons/events.png", name: "События", view: "events"},
        {icon: "qrc:/icons/news.png", name: "Новости", view: "news"}
    ]

    x: isOpen ? 0 : -width - 10
    visible: isOpen
    y: topMargin

    Behavior on x {
        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
    }

    signal closeRequested()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 4

        // Заголовок мобильного меню
        Rectangle {
            Layout.fillWidth: true
            height: 60
            color: "transparent"

            Row {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 12

                Rectangle {
                    width: 40
                    height: 40
                    radius: 8
                    color: "#3498db"
                    anchors.verticalCenter: parent.verticalCenter

                    Image {
                        anchors.centerIn: parent
                        source: "qrc:/icons/earth.png"
                        sourceSize: Qt.size(24, 24)
                        fillMode: Image.PreserveAspectFit
                        mipmap: true
                        antialiasing: true
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 0

                    Text {
                        text: appName
                        font.pixelSize: 16
                        font.bold: true
                        color: "#2c3e50"
                    }

                    Text {
                        text: "Меню"
                        font.pixelSize: 14
                        color: "#7f8c8d"
                    }
                }
            }
        }

        // Разделитель
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#3498db"
            opacity: 0.3
        }

        // Основное меню
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 1

            Repeater {
                model: menuItems

                delegate: Rectangle {
                    id: menuItem
                    Layout.fillWidth: true
                    height: 44
                    radius: 6
                    color: adaptiveSideBar.currentView === modelData.view ? "#e3f2fd" :
                          (navMouseArea.containsMouse ? "#f8f9fa" : "transparent")
                    border.color: adaptiveSideBar.currentView === modelData.view ? "#3498db" : "transparent"
                    border.width: 1

                    Row {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 12

                        Image {
                            source: modelData.icon
                            sourceSize: Qt.size(20, 20)
                            anchors.verticalCenter: parent.verticalCenter
                            fillMode: Image.PreserveAspectFit
                            mipmap: true
                            antialiasing: true
                        }

                        Text {
                            text: modelData.name
                            color: adaptiveSideBar.currentView === modelData.view ? "#1976d2" : "#5f6368"
                            font.pixelSize: 14
                            font.bold: adaptiveSideBar.currentView === modelData.view
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    // Индикатор активного элемента
                    Rectangle {
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            rightMargin: 6
                        }
                        width: 3
                        height: 16
                        radius: 2
                        color: "#1976d2"
                        visible: adaptiveSideBar.currentView === modelData.view
                    }

                    MouseArea {
                        id: navMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (mainWindow) {
                                mainWindow.navigateTo(modelData.view)
                                adaptiveSideBar.closeRequested()
                            }
                        }
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }

        // Кнопка настроек
        Rectangle {
            Layout.fillWidth: true
            height: 44
            radius: 6
            color: adaptiveSideBar.currentView === "settings" ? "#e3f2fd" :
                  (settingsMouseArea.containsMouse ? "#f8f9fa" : "transparent")
            border.color: adaptiveSideBar.currentView === "settings" ? "#3498db" : "transparent"
            border.width: 1

            Row {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 12

                AnimatedImage {
                    sourceSize: Qt.size(20,20)
                    source: settingsMouseArea.containsMouse ? "qrc:/icons/settings.gif" : "qrc:/icons/settings.png"
                    fillMode: Image.PreserveAspectFit
                    speed: 0.7
                    mipmap: true
                    antialiasing: true
                    playing: settingsMouseArea.containsMouse
                }

                Text {
                    text: "Настройки"
                    color: adaptiveSideBar.currentView === "settings" ? "#1976d2" : "#5f6368"
                    font.pixelSize: 14
                    font.bold: adaptiveSideBar.currentView === "settings"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                id: settingsMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (mainWindow) {
                        mainWindow.navigateTo("settings")
                        adaptiveSideBar.closeRequested()
                    }
                }
            }
        }
    }
}
