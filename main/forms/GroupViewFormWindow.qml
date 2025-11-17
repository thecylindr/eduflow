import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts 1.15
import "../../common" as Common

ApplicationWindow {
    id: groupViewWindow
    width: 600
    height: 540
    flags: Qt.Dialog | Qt.FramelessWindowHint
    modality: Qt.ApplicationModal
    color: "transparent"
    visible: false

    property var currentGroup: null
    property var groupStudents: []
    property bool isLoading: false

    signal closed()

    function openForGroup(groupData) {
        currentGroup = groupData
        isLoading = true
        groupViewWindow.show()
        groupViewWindow.requestActivate()
        groupViewWindow.x = (Screen.width - groupViewWindow.width) / 2
        groupViewWindow.y = (Screen.height - groupViewWindow.height) / 2

        loadGroupStudents()
    }

    function closeWindow() {
        groupViewWindow.close()
        closed()
    }

    function loadGroupStudents() {
        console.log("👥 Загрузка студентов группы:", currentGroup.groupId)
        isLoading = true

        // Вместо заглушки используем реальный API вызов
        mainApi.getStudentsByGroup(currentGroup.groupId, function(response) {
            isLoading = false
            if (response.success) {
                groupStudents = response.data
                console.log("✅ Загружены студенты группы:", groupStudents.length)
            } else {
                console.log("❌ Ошибка загрузки студентов:", response.error)
                showMessage("❌ Ошибка загрузки студентов: " + response.error, "error")
                groupStudents = []
            }
        })
    }

    // Основной контейнер
    Rectangle {
        id: windowContainer
        anchors.fill: parent
        radius: 16
        color: "transparent"
        clip: true

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#6a11cb" }
                GradientStop { position: 1.0; color: "#2575fc" }
            }
            radius: 15
        }

        Common.PolygonBackground {
            anchors.fill: parent
        }

        Common.DialogTitleBar {
            id: titleBar
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 8
            }
            height: 28
            title: currentGroup ? "Группа: " + (currentGroup.name || "Без названия") : "Просмотр группы"
            window: groupViewWindow
            onClose: closeWindow()
        }

        Rectangle {
            id: whiteForm
            width: 560
            height: 440
            anchors {
                top: titleBar.bottom
                topMargin: 20
                horizontalCenter: parent.horizontalCenter
            }
            color: "#ffffff"
            opacity: 0.925
            radius: 12

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 12

                // Информация о группе
                Rectangle {
                    Layout.fillWidth: true
                    height: 60
                    radius: 8
                    color: "#e8f4fd"
                    border.color: "#3498db"
                    border.width: 1

                    Row {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 15

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                text: "Куратор: " + (currentGroup ? currentGroup.teacherName : "Не указан")
                                font.pixelSize: 12
                                color: "#2c3e50"
                            }

                            Text {
                                text: "Количество студентов: " + (groupStudents.length)
                                font.pixelSize: 12
                                color: "#2c3e50"
                            }
                        }
                    }
                }

                // Заголовок списка студентов
                Text {
                    text: "Студенты группы:"
                    font.pixelSize: 16
                    font.bold: true
                    color: "#2c3e50"
                }

                // Список студентов с ПРАВИЛЬНОЙ ПРОКРУТКОЙ
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "transparent"
                    border.color: "#e0e0e0"
                    border.width: 1
                    radius: 8

                    ScrollView {
                        id: scrollView
                        anchors.fill: parent
                        anchors.margins: 1
                        clip: true

                        ScrollBar.vertical: ScrollBar {
                            id: verticalScrollBar
                            policy: ScrollBar.AsNeeded
                            width: 8
                            contentItem: Rectangle {
                                implicitWidth: 8
                                implicitHeight: 100
                                radius: 4
                                color: verticalScrollBar.pressed ? "#3498db" : "#95a5a6"
                                opacity: verticalScrollBar.active ? 0.75 : 0.0

                                Behavior on opacity {
                                    NumberAnimation { duration: 200 }
                                }
                            }
                        }

                        ListView {
                            id: studentsList
                            width: scrollView.width - (verticalScrollBar.visible ? verticalScrollBar.width : 0)
                            height: contentHeight
                            model: groupStudents
                            spacing: 1
                            boundsBehavior: Flickable.StopAtBounds
                            interactive: true

                            delegate: Rectangle {
                                width: studentsList.width
                                height: 50
                                color: index % 2 === 0 ? "#f8f9fa" : "#ffffff"

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 15

                                    // Номер
                                    Text {
                                        text: (index + 1) + "."
                                        font.pixelSize: 14
                                        color: "#7f8c8d"
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    // ФИО студента
                                    Text {
                                        text: {
                                            var lastName = modelData.last_name || ""
                                            var firstName = modelData.first_name || ""
                                            var middleName = modelData.middle_name || ""
                                            return lastName + " " + firstName + " " + middleName
                                        }
                                        font.pixelSize: 14
                                        color: "#2c3e50"
                                        anchors.verticalCenter: parent.verticalCenter
                                        elide: Text.ElideRight
                                        width: parent.width * 0.6
                                    }

                                    // Код студента
                                    Text {
                                        text: "Код: " + (modelData.student_code || "")
                                        font.pixelSize: 12
                                        color: "#7f8c8d"
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }

                            // Сообщение если студентов нет
                            Rectangle {
                                width: studentsList.width
                                height: 100
                                color: "transparent"
                                visible: groupStudents.length === 0 && !isLoading

                                Text {
                                    anchors.centerIn: parent
                                    text: "В группе нет студентов"
                                    font.pixelSize: 14
                                    color: "#7f8c8d"
                                }
                            }
                        }
                    }
                }

                // Индикатор загрузки
                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    color: "transparent"
                    visible: isLoading

                    Row {
                        anchors.centerIn: parent
                        spacing: 10

                        BusyIndicator {
                            width: 20
                            height: 20
                            running: true
                        }

                        Text {
                            text: "Загрузка студентов..."
                            font.pixelSize: 14
                            color: "#7f8c8d"
                        }
                    }
                }

                // Кнопка закрытия
                Button {
                    Layout.alignment: Qt.AlignHCenter
                    text: "❌ Закрыть"
                    implicitWidth: 140
                    implicitHeight: 40
                    font.pixelSize: 14
                    font.bold: true

                    background: Rectangle {
                        radius: 20
                        color: "#3498db"
                        border.color: "#2980b9"
                        border.width: 2
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font: parent.font
                    }

                    onClicked: closeWindow()
                    Keys.onReturnPressed: if (enabled) closeWindow()
                    Keys.onUpPressed: studentsList.forceActiveFocus()
                }
            }
        }
    }
}
