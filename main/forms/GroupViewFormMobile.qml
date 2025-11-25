import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15
import QtQuick.Controls.Universal
import "../../common" as Common

Window {
    id: groupViewWindow
    width: Math.min(Screen.width * 0.95, 400)
    height: Math.min(Screen.height * 0.8, 600)
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
        loadGroupStudents()
    }

    function closeWindow() {
        groupViewWindow.visible = false
        currentGroup = null
        groupStudents = []
        isLoading = false
        closed()
    }

    function loadGroupStudents() {
        if (!currentGroup) return
        isLoading = true
        mainApi.getStudentsByGroup(currentGroup.groupId, function(response) {
            isLoading = false
            if (response.success) {
                groupStudents = response.data || []
            } else {
                groupStudents = []
            }
        })
    }

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
            onClose: {
                groupViewWindow.visible = false
                currentGroup = null
                groupStudents = []
                isLoading = false
                closed()
            }
        }

        Rectangle {
            id: whiteForm
            width: parent.width - 20
            height: parent.height - titleBar.height - 40
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

                Rectangle {
                    Layout.fillWidth: true
                    height: 70
                    radius: 10
                    color: "#e8f4fd"
                    border.color: "#3498db"
                    border.width: 1

                    Row {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 12

                        Image {
                            source: "qrc:/icons/info.png"
                            width: 24
                            height: 24
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 4

                            Label {
                                text: "Куратор: " + (currentGroup ? currentGroup.teacherName : "Не указан")
                                font.pixelSize: 12
                                color: "#2c3e50"
                            }

                            Label {
                                text: "Количество студентов: " + groupStudents.length
                                font.pixelSize: 12
                                color: "#2c3e50"
                            }
                        }
                    }
                }

                Label {
                    text: "Студенты группы:"
                    font.pixelSize: 14
                    font.bold: true
                    color: "#2c3e50"
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    border.color: "#e0e0e0"
                    border.width: 1
                    radius: 8

                    ScrollView {
                        anchors.fill: parent
                        anchors.margins: 1
                        clip: true

                        ListView {
                            id: studentsList
                            width: parent.width
                            model: groupStudents
                            spacing: 1

                            delegate: Rectangle {
                                width: studentsList.width
                                height: 60
                                color: index % 2 === 0 ? "#f8f9fa" : "#ffffff"

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 12

                                    Text {
                                        text: (index + 1) + "."
                                        font.pixelSize: 12
                                        color: "#7f8c8d"
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 2

                                        Text {
                                            text: (modelData.last_name || "") + " " +
                                                  (modelData.first_name || "") + " " + (modelData.middle_name || "")
                                            font.pixelSize: 14
                                            color: "#2c3e50"
                                            elide: Text.ElideRight
                                            width: studentsList.width - 100
                                        }

                                        Text {
                                            text: "Код: " + (modelData.student_code || "")
                                            font.pixelSize: 12
                                            color: "#7f8c8d"
                                        }
                                    }
                                }
                            }

                            Label {
                                anchors.centerIn: parent
                                text: "В группе нет студентов"
                                font.pixelSize: 14
                                color: "#7f8c8d"
                                visible: groupStudents.length === 0 && !isLoading
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    color: "transparent"
                    visible: isLoading

                    Row {
                        anchors.centerIn: parent
                        spacing: 8

                        BusyIndicator {
                            width: 20
                            height: 20
                            running: true
                        }

                        Label {
                            text: "Загрузка студентов..."
                            font.pixelSize: 12
                            color: "#7f8c8d"
                        }
                    }
                }

                Button {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Закрыть"
                    implicitWidth: 150
                    implicitHeight: 45
                    font.pixelSize: 14
                    font.bold: true

                    background: Rectangle {
                        radius: 22
                        color: "#3498db"
                        border.color: "#2980b9"
                        border.width: 2
                    }

                    contentItem: Row {
                        spacing: 8
                        anchors.centerIn: parent

                        Image {
                            source: "qrc:/icons/cross.png"
                            width: 16
                            height: 16
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "Закрыть"
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font: parent.parent.font
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    onClicked: closeWindow()
                }
            }
        }
    }
}
