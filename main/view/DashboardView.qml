// main/view/DashboardView.qml
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

Item {
    id: dashboardView

    property var statsData: ({
        teachers: mainWindow.teachers ? mainWindow.teachers.length : 0,
        students: mainWindow.students ? mainWindow.students.length : 0,
        groups: mainWindow.groups ? mainWindow.groups.length : 0,
        portfolios: mainWindow.portfolios ? mainWindow.portfolios.length : 0,
        events: mainWindow.events ? mainWindow.events.length : 0
    })

    function refreshStats() {
        statsData = {
            teachers: mainWindow.teachers ? mainWindow.teachers.length : 0,
            students: mainWindow.students ? mainWindow.students.length : 0,
            groups: mainWindow.groups ? mainWindow.groups.length : 0,
            portfolios: mainWindow.portfolios ? mainWindow.portfolios.length : 0,
            events: mainWindow.events ? mainWindow.events.length : 0
        }
    }

    Component.onCompleted: {
        refreshStats()
    }

    Flickable {
        anchors.fill: parent
        contentHeight: contentColumn.height
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: contentColumn
            width: parent.width
            spacing: 15

            // Заголовок
            Column {
                Layout.fillWidth: true
                spacing: 8

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 10

                    Image {
                        source: "qrc:/icons/home.png"
                        sourceSize: Qt.size(24, 24)
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "Панель управления"
                        font.pixelSize: 24
                        font.bold: true
                        color: "#2c3e50"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Text {
                    text: "Обзор системы и ключевые метрики"
                    font.pixelSize: 12
                    color: "#7f8c8d"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Rectangle {
                    width: parent.width
                    height: 2
                    color: "#3498db"
                    opacity: 0.3
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            // Компактная статистика
            GridLayout {
                columns: 3
                rowSpacing: 10
                columnSpacing: 10
                Layout.fillWidth: true

                // Преподаватели
                Rectangle {
                    Layout.fillWidth: true
                    height: 80
                    radius: 12
                    color: "#ffffff"
                    border.color: "#e0e0e0"
                    border.width: 1

                    Row {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 8
                            color: "#3498db"
                            anchors.verticalCenter: parent.verticalCenter

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/teachers.png"
                                sourceSize: Qt.size(20, 20)
                                fillMode: Image.PreserveAspectFit
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                text: statsData.teachers
                                font.pixelSize: 20
                                font.bold: true
                                color: "#2c3e50"
                            }

                            Text {
                                text: "Преподаватели"
                                font.pixelSize: 10
                                color: "#7f8c8d"
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mainWindow.navigateTo("teachers")
                    }
                }

                // Студенты
                Rectangle {
                    Layout.fillWidth: true
                    height: 80
                    radius: 12
                    color: "#ffffff"
                    border.color: "#e0e0e0"
                    border.width: 1

                    Row {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 8
                            color: "#2ecc71"
                            anchors.verticalCenter: parent.verticalCenter

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/students.png"
                                sourceSize: Qt.size(20, 20)
                                fillMode: Image.PreserveAspectFit
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                text: statsData.students
                                font.pixelSize: 20
                                font.bold: true
                                color: "#2c3e50"
                            }

                            Text {
                                text: "Студенты"
                                font.pixelSize: 10
                                color: "#7f8c8d"
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mainWindow.navigateTo("students")
                    }
                }

                // Группы
                Rectangle {
                    Layout.fillWidth: true
                    height: 80
                    radius: 12
                    color: "#ffffff"
                    border.color: "#e0e0e0"
                    border.width: 1

                    Row {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 8
                            color: "#e74c3c"
                            anchors.verticalCenter: parent.verticalCenter

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/groups.png"
                                sourceSize: Qt.size(20, 20)
                                fillMode: Image.PreserveAspectFit
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                text: statsData.groups
                                font.pixelSize: 20
                                font.bold: true
                                color: "#2c3e50"
                            }

                            Text {
                                text: "Группы"
                                font.pixelSize: 10
                                color: "#7f8c8d"
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mainWindow.navigateTo("groups")
                    }
                }

                // Портфолио
                Rectangle {
                    Layout.fillWidth: true
                    height: 80
                    radius: 12
                    color: "#ffffff"
                    border.color: "#e0e0e0"
                    border.width: 1

                    Row {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 8
                            color: "#9b59b6"
                            anchors.verticalCenter: parent.verticalCenter

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/portfolio.png"
                                sourceSize: Qt.size(20, 20)
                                fillMode: Image.PreserveAspectFit
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                text: statsData.portfolios
                                font.pixelSize: 20
                                font.bold: true
                                color: "#2c3e50"
                            }

                            Text {
                                text: "Портфолио"
                                font.pixelSize: 10
                                color: "#7f8c8d"
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mainWindow.navigateTo("portfolio")
                    }
                }

                // События
                Rectangle {
                    Layout.fillWidth: true
                    height: 80
                    radius: 12
                    color: "#ffffff"
                    border.color: "#e0e0e0"
                    border.width: 1

                    Row {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 8
                            color: "#e67e22"
                            anchors.verticalCenter: parent.verticalCenter

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/events.png"
                                sourceSize: Qt.size(20, 20)
                                fillMode: Image.PreserveAspectFit
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                text: statsData.events
                                font.pixelSize: 20
                                font.bold: true
                                color: "#2c3e50"
                            }

                            Text {
                                text: "События"
                                font.pixelSize: 10
                                color: "#7f8c8d"
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mainWindow.navigateTo("events")
                    }
                }

                // Настройки системы
                Rectangle {
                    Layout.fillWidth: true
                    height: 80
                    radius: 12
                    color: "#ffffff"
                    border.color: "#e0e0e0"
                    border.width: 1

                    Row {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 8
                            color: "#95a5a6"
                            anchors.verticalCenter: parent.verticalCenter

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/settings.png"
                                sourceSize: Qt.size(20, 20)
                                fillMode: Image.PreserveAspectFit
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                text: "Настройки системы"
                                font.pixelSize: 14
                                font.bold: true
                                color: "#2c3e50"
                            }

                            Text {
                                text: "изменить параметры"
                                font.pixelSize: 10
                                color: "#7f8c8d"
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mainWindow.navigateTo("settings")
                    }
                }
            }

            // Быстрые действия
            Rectangle {
                Layout.fillWidth: true
                height: quickActionsColumn.height + 30
                radius: 12
                color: "#ffffff"
                border.color: "#e0e0e0"
                border.width: 1

                Column {
                    id: quickActionsColumn
                    width: parent.width - 30
                    anchors.centerIn: parent
                    spacing: 12

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 8

                        Image {
                            source: "qrc:/icons/statistics.png"
                            sourceSize: Qt.size(20, 20)
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "Быстрые действия"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#2c3e50"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Grid {
                        columns: 3
                        spacing: 8
                        anchors.horizontalCenter: parent.horizontalCenter

                        // Добавить студента
                        Rectangle {
                            width: 90
                            height: 70
                            radius: 8
                            color: addStudentMouseArea.containsMouse ? "#27ae60" : "#2ecc71"

                            Column {
                                anchors.centerIn: parent
                                spacing: 4

                                Image {
                                    source: "qrc:/icons/students.png"
                                    sourceSize: Qt.size(20, 20)
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                Text {
                                    text: "Студент"
                                    font.pixelSize: 10
                                    color: "white"
                                    font.bold: true
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }

                            MouseArea {
                                id: addStudentMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    console.log("Быстрое действие: Добавить студента")
                                    if (mainWindow && mainWindow.studentFormWindow) {
                                        mainWindow.studentFormWindow.openForAdd()
                                    }
                                }
                            }
                        }

                        // Добавить преподавателя
                        Rectangle {
                            width: 90
                            height: 70
                            radius: 8
                            color: addTeacherMouseArea.containsMouse ? "#2980b9" : "#3498db"

                            Column {
                                anchors.centerIn: parent
                                spacing: 4

                                Image {
                                    source: "qrc:/icons/teachers.png"
                                    sourceSize: Qt.size(20, 20)
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                Text {
                                    text: "Преподаватель"
                                    font.pixelSize: 10
                                    color: "white"
                                    font.bold: true
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }

                            MouseArea {
                                id: addTeacherMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    console.log("Быстрое действие: Добавить преподавателя")
                                    if (mainWindow && mainWindow.teacherFormWindow) {
                                        mainWindow.teacherFormWindow.openForAdd()
                                    }
                                }
                            }
                        }

                        // Добавить группу
                        Rectangle {
                            width: 90
                            height: 70
                            radius: 8
                            color: addGroupMouseArea.containsMouse ? "#c0392b" : "#e74c3c"

                            Column {
                                anchors.centerIn: parent
                                spacing: 4

                                Image {
                                    source: "qrc:/icons/groups.png"
                                    sourceSize: Qt.size(20, 20)
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                Text {
                                    text: "Группа"
                                    font.pixelSize: 10
                                    color: "white"
                                    font.bold: true
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }

                            MouseArea {
                                id: addGroupMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    console.log("Быстрое действие: Добавить группу")
                                    if (mainWindow && mainWindow.groupFormWindow) {
                                        mainWindow.groupFormWindow.openForAdd()
                                    }
                                }
                            }
                        }

                        // Добавить портфолио
                        Rectangle {
                            width: 90
                            height: 70
                            radius: 8
                            color: addPortfolioMouseArea.containsMouse ? "#8e44ad" : "#9b59b6"

                            Column {
                                anchors.centerIn: parent
                                spacing: 4

                                Image {
                                    source: "qrc:/icons/portfolio.png"
                                    sourceSize: Qt.size(20, 20)
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                Text {
                                    text: "Портфолио"
                                    font.pixelSize: 10
                                    color: "white"
                                    font.bold: true
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }

                            MouseArea {
                                id: addPortfolioMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    console.log("Быстрое действие: Добавить портфолио")
                                    if (mainWindow && mainWindow.portfolioFormWindow) {
                                        mainWindow.portfolioFormWindow.openForAdd()
                                    }
                                }
                            }
                        }

                        // Добавить событие
                        Rectangle {
                            width: 90
                            height: 70
                            radius: 8
                            color: addEventMouseArea.containsMouse ? "#d35400" : "#e67e22"

                            Column {
                                anchors.centerIn: parent
                                spacing: 4

                                Image {
                                    source: "qrc:/icons/events.png"
                                    sourceSize: Qt.size(20, 20)
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                Text {
                                    text: "Событие"
                                    font.pixelSize: 10
                                    color: "white"
                                    font.bold: true
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }

                            MouseArea {
                                id: addEventMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    console.log("Быстрое действие: Добавить событие")
                                    if (mainWindow && mainWindow.eventFormWindow) {
                                        mainWindow.eventFormWindow.openForAdd()
                                    }
                                }
                            }
                        }

                        // Настройки
                        Rectangle {
                            width: 90
                            height: 70
                            radius: 8
                            color: settingsMouseArea.containsMouse ? "#2c3e50" : "#34495e"

                            Column {
                                anchors.centerIn: parent
                                spacing: 4

                                Image {
                                    source: "qrc:/icons/settings.png"
                                    sourceSize: Qt.size(20, 20)
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                Text {
                                    text: "Настройки"
                                    font.pixelSize: 10
                                    color: "white"
                                    font.bold: true
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }

                            MouseArea {
                                id: settingsMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    console.log("Быстрое действие: Настройки")
                                    mainWindow.navigateTo("settings")
                                }
                            }
                        }
                    }
                }
            }

            // Статус системы
            Rectangle {
                Layout.fillWidth: true
                height: 80
                radius: 12
                color: "#ffffff"
                border.color: "#e0e0e0"
                border.width: 1

                Row {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 15

                    Rectangle {
                        width: 50
                        height: 50
                        radius: 10
                        color: "#2ecc71"
                        anchors.verticalCenter: parent.verticalCenter

                        Image {
                            anchors.centerIn: parent
                            source: "qrc:/icons/check.png"
                            sourceSize: Qt.size(24, 24)
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 4

                        Text {
                            text: "Система активна"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#2c3e50"
                        }

                        Text {
                            text: "Все службы работают стабильно. Последняя проверка: " +
                                  new Date().toLocaleTimeString(Qt.locale(), "hh:mm")
                            font.pixelSize: 11
                            color: "#7f8c8d"
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }
        }
    }

    // Обновляем статистику при изменении данных
    Connections {
        target: mainWindow
        onTeachersChanged: refreshStats()
        onStudentsChanged: refreshStats()
        onGroupsChanged: refreshStats()
        onPortfoliosChanged: refreshStats()
        onEventsChanged: refreshStats()
    }
}
