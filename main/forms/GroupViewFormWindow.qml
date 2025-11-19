import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material
import "../../common" as Common

Window {
    id: groupViewWindow
    width: 500
    height: 460
    flags: Qt.platform.os === "android" ? Qt.Dialog : Qt.Dialog | Qt.FramelessWindowHint
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
        groupStudents = []
        groupViewWindow.show()
        groupViewWindow.requestActivate()
        groupViewWindow.x = (Screen.width - groupViewWindow.width) / 2
        groupViewWindow.y = (Screen.height - groupViewWindow.height) / 2

        loadGroupStudents()
    }

    function closeWindow() {
        // Сначала скрываем окно, потом очищаем данные
        groupViewWindow.visible = false
        currentGroup = null
        groupStudents = []
        isLoading = false
        closed()
    }

    function loadGroupStudents() {
        if (!currentGroup) return

        console.log("Загрузка студентов группы:", currentGroup.groupId)
        isLoading = true

        mainApi.getStudentsByGroup(currentGroup.groupId, function(response) {
            isLoading = false
            if (response.success) {
                groupStudents = response.data || []
            } else {
                console.log("Ошибка загрузки студентов:", response.error)
                showMessage("Ошибка загрузки студентов: " + response.error, "error")
                groupStudents = []
            }
        })
    }

    Rectangle {
        id: windowContainer
        anchors.fill: parent
        radius: 12
        color: "transparent"
        clip: true

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#6a11cb" }
                GradientStop { position: 1.0; color: "#2575fc" }
            }
            radius: 12
        }

        Common.PolygonBackground {
            anchors.fill: parent
            polygonCount: 6
        }

        Common.DialogTitleBar {
            id: titleBar
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 6
            }
            height: 26
            title: currentGroup ? "Группа: " + (currentGroup.name || "Без названия") : "Просмотр группы"
            window: groupViewWindow
            onClose: {
                // Прямой вызов без рекурсии
                groupViewWindow.visible = false
                currentGroup = null
                groupStudents = []
                isLoading = false
                closed()
            }
        }

        Rectangle {
            id: whiteForm
            width: 460
            height: 380
            anchors {
                top: titleBar.bottom
                topMargin: 12
                horizontalCenter: parent.horizontalCenter
            }
            color: "#ffffff"
            opacity: 0.925
            radius: 10

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                Rectangle {
                    Layout.fillWidth: true
                    height: 50
                    radius: 6
                    color: "#e8f4fd"
                    border.color: "#3498db"
                    border.width: 1

                    Row {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 12

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

                Text {
                    text: "Студенты группы:"
                    font.pixelSize: 14
                    font.bold: true
                    color: "#2c3e50"
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "transparent"
                    border.color: "#e0e0e0"
                    border.width: 1
                    radius: 6

                    ScrollView {
                        id: scrollView
                        anchors.fill: parent
                        anchors.margins: 1
                        clip: true

                        ListView {
                            id: studentsList
                            width: scrollView.availableWidth
                            model: groupStudents
                            spacing: 1
                            boundsBehavior: Flickable.StopAtBounds

                            delegate: Rectangle {
                                width: studentsList.width
                                height: 40
                                color: index % 2 === 0 ? "#f8f9fa" : "#ffffff"

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    spacing: 12

                                    Text {
                                        text: (index + 1) + "."
                                        font.pixelSize: 12
                                        color: "#7f8c8d"
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        text: {
                                            var lastName = modelData.last_name || ""
                                            var firstName = modelData.first_name || ""
                                            var middleName = modelData.middle_name || ""
                                            return lastName + " " + firstName + " " + middleName
                                        }
                                        font.pixelSize: 12
                                        color: "#2c3e50"
                                        anchors.verticalCenter: parent.verticalCenter
                                        elide: Text.ElideRight
                                        width: parent.width * 0.6
                                    }

                                    Text {
                                        text: "Код: " + (modelData.student_code || "")
                                        font.pixelSize: 11
                                        color: "#7f8c8d"
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }

                            Label {
                                anchors.centerIn: parent
                                text: "В группе нет студентов"
                                font.pixelSize: 13
                                color: "#7f8c8d"
                                visible: groupStudents.length === 0 && !isLoading
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 36
                    color: "transparent"
                    visible: isLoading

                    Row {
                        anchors.centerIn: parent
                        spacing: 8

                        BusyIndicator {
                            width: 18
                            height: 18
                            running: true
                        }

                        Text {
                            text: "Загрузка студентов..."
                            font.pixelSize: 12
                            color: "#7f8c8d"
                        }
                    }
                }

                Button {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Закрыть"
                    implicitWidth: 120
                    implicitHeight: 36
                    font.pixelSize: 13
                    font.bold: true

                    background: Rectangle {
                        radius: 18
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

                    onClicked: {
                        // Прямой вызов без рекурсии
                        groupViewWindow.visible = false
                        currentGroup = null
                        groupStudents = []
                        isLoading = false
                        closed()
                    }
                }
            }
        }
    }
}
