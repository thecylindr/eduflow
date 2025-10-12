import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: sideBar
    color: "#ffffff"
    opacity: 0.9

    property bool isExpanded: true
    property int currentTab: 0

    signal tabSelected(int tabIndex)
    signal showProfileSettings()

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Заголовок боковой панели
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: "transparent"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10

                Text {
                    text: "☰"
                    font.pixelSize: 20
                    color: "#2c3e50"
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                }

                Text {
                    text: "EduFlow"
                    font.bold: true
                    font.pixelSize: 18
                    color: "#2c3e50"
                    visible: isExpanded
                    Layout.fillWidth: true
                }
            }
        }

        // Навигационные кнопки
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 2

            SideBarButton {
                icon: "👨‍🏫"
                text: "Преподаватели"
                expanded: isExpanded
                selected: currentTab === 0
                onClicked: {
                    currentTab = 0;
                    tabSelected(0);
                }
            }

            SideBarButton {
                icon: "👥"
                text: "Группы"
                expanded: isExpanded
                selected: currentTab === 1
                onClicked: {
                    currentTab = 1;
                    tabSelected(1);
                }
            }

            SideBarButton {
                icon: "🎓"
                text: "Студенты"
                expanded: isExpanded
                selected: currentTab === 2
                onClicked: {
                    currentTab = 2;
                    tabSelected(2);
                }
            }

            SideBarButton {
                icon: "📁"
                text: "Портфолио"
                expanded: isExpanded
                selected: currentTab === 3
                onClicked: {
                    currentTab = 3;
                    tabSelected(3);
                }
            }

            SideBarButton {
                icon: "📅"
                text: "Мероприятия"
                expanded: isExpanded
                selected: currentTab === 4
                onClicked: {
                    currentTab = 4;
                    tabSelected(4);
                }
            }

            Item { Layout.fillHeight: true }
        }

        // Нижняя секция с настройками профиля
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: "transparent"

            SideBarButton {
                anchors.fill: parent
                anchors.margins: 5
                icon: "⚙️"
                text: "Настройки"
                expanded: isExpanded
                selected: false
                onClicked: showProfileSettings()
            }
        }
    }
}
