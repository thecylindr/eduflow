// enhanced/EnhancedTableView.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: enhancedTableView
    color: "transparent"
    clip: true

    property var sourceModel: []
    property string itemType: ""
    property string searchPlaceholder: "Поиск..."
    property var sortOptions: []
    property var sortRoles: []
    property Component listDelegate: defaultListDelegate
    property Component gridDelegate: defaultGridDelegate

    signal itemEditRequested(var itemData)
    signal itemDeleteRequested(var itemData)

    property var displayedModel: []
    property string searchText: ""
    property int currentSortIndex: sortRoles.length > 0 ? 0 : -1
    property bool sortAscending: true
    property string viewMode: "list"
    property int gridCellWidth: 220
    property int gridCellHeight: 150

    onSourceModelChanged: updateDisplayedModel()
    onSearchTextChanged: updateDisplayedModel()
    onCurrentSortIndexChanged: updateDisplayedModel()
    onSortAscendingChanged: updateDisplayedModel()

    function updateDisplayedModel() {
        console.log("Updating displayed model. Source length:", sourceModel.length, "Search:", searchText, "Sort index:", currentSortIndex, "Ascending:", sortAscending)
        if (sourceModel.length === 0) {
            displayedModel = [];
            return;
        }

        var filtered = sourceModel.filter(function(item) {
            return matchesSearch(item);
        });

        if (currentSortIndex >= 0 && currentSortIndex < sortRoles.length) {
            var role = sortRoles[currentSortIndex];
            console.log("Sorting by role:", role)
            filtered.sort(function(a, b) {
                var valA = getSortValue(a[role]);
                var valB = getSortValue(b[role]);
                if (valA < valB) return sortAscending ? -1 : 1;
                if (valA > valB) return sortAscending ? 1 : -1;
                return 0;
            });
        }

        displayedModel = filtered;
        console.log("Displayed model length:", displayedModel.length)
    }

    function getSortValue(value) {
        if (value === undefined || value === null) return 0;
        if (typeof value === "string") return value.toLowerCase();
        return value;
    }

    function matchesSearch(item) {
        if (!searchText) return true;
        var lowerSearch = searchText.toLowerCase();
        for (var key in item) {
            var value = item[key];
            if (typeof value === "string" && value.toLowerCase().includes(lowerSearch)) {
                return true;
            } else if (typeof value === "number" && value.toString().includes(lowerSearch)) {
                return true;
            }
        }
        return false;
    }

    onWidthChanged: {
        if (viewMode === "grid") {
            var cols = Math.floor(width / gridCellWidth);
            if (cols < 1) cols = 1;
            gridView.columns = cols;
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        Rectangle {
            Layout.fillWidth: true
            height: 50
            radius: 12
            color: "#ffffff"
            border.color: "#e9ecef"
            border.width: 2

            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 12

                SearchBar {
                    Layout.fillWidth: true
                    placeholder: searchPlaceholder
                    onSearchRequested: function(text) {
                        searchText = text
                        updateDisplayedModel()
                    }
                }

                SortPanel {
                    sortOptions: enhancedTableView.sortOptions
                    sortRoles: enhancedTableView.sortRoles
                    currentSortRole: sortRoles.length > 0 ? sortRoles[currentSortIndex] : ""
                    sortAscending: enhancedTableView.sortAscending
                    onSortChanged: function(role, ascending) {
                        var index = sortRoles.indexOf(role);
                        if (index >= 0) {
                            currentSortIndex = index;
                        }
                        sortAscending = ascending;
                        updateDisplayedModel();
                    }
                    visible: sortOptions.length > 0
                }

                ViewModeSwitcher {
                    currentViewMode: enhancedTableView.viewMode
                    onViewModeChanged: function(mode) {
                        enhancedTableView.viewMode = mode
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ListView {
                id: listView
                anchors.fill: parent
                model: displayedModel
                delegate: listDelegate
                visible: viewMode === "list"
                spacing: 8
                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    contentItem: Rectangle {
                        opacity: 0
                    }
                }
                boundsBehavior: Flickable.StopAtBounds
            }

            GridView {
                id: gridView
                anchors.fill: parent
                model: displayedModel
                delegate: gridDelegate
                visible: viewMode === "grid"
                cellWidth: gridCellWidth
                cellHeight: gridCellHeight
                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    contentItem: Rectangle {
                        opacity: 0
                    }
                }
                boundsBehavior: Flickable.StopAtBounds

                property int columns: Math.max(1, Math.floor(width / cellWidth))
                onWidthChanged: columns = Math.max(1, Math.floor(width / cellWidth))
            }
        }
    }

    Component {
        id: defaultListDelegate

        Rectangle {
            width: listView.width
            height: 70
            radius: 12
            color: mouseArea.containsMouse ? "#f8f9fa" : "#ffffff"
            border.color: mouseArea.containsMouse ? "#3498db" : "#e9ecef"
            border.width: 2

            scale: mouseArea.pressed ? 0.98 : (mouseArea.containsMouse ? 1.02 : 1)
            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 12

                Rectangle {
                    width: 40
                    height: 40
                    radius: 8
                    color: mouseArea.containsMouse ? "#3498db" : "#e9ecef"
                    border.color: mouseArea.containsMouse ? "#2980b9" : "#dee2e6"
                    border.width: 2

                    Text {
                        anchors.centerIn: parent
                        text: itemType === "group" ? "👥" : (itemType === "teacher" ? "👨‍🏫" : "👨‍🎓")
                        font.pixelSize: 16
                    }
                }

                Column {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        text: getTitleText(modelData)
                        font.bold: true
                        font.pixelSize: 14
                        color: "#2c3e50"
                    }

                    Text {
                        text: getSubtitleText(modelData)
                        font.pixelSize: 12
                        color: "#7f8c8d"
                    }
                }

                Row {
                    spacing: 6

                    Rectangle {
                        id: defaultEditButton
                        width: 36
                        height: 36
                        radius: 8
                        color: defaultEditBtnMouseArea.pressed ? Qt.darker("#3498db", 1.2) : (defaultEditBtnMouseArea.containsMouse ? "#3498db" : "transparent")
                        border.color: defaultEditBtnMouseArea.containsMouse || defaultEditBtnMouseArea.pressed ? "#3498db" : "#e0e0e0"
                        border.width: 2
                        z: 1

                        Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }

                        Rectangle {
                            width: 24
                            height: 24
                            radius: 6
                            color: parent.color
                            anchors.centerIn: parent

                            Text {
                                anchors.centerIn: parent
                                text: "✏️"
                                font.pixelSize: 10
                                color: defaultEditBtnMouseArea.containsMouse || defaultEditBtnMouseArea.pressed ? "white" : "#7f8c8d"
                            }
                        }

                        MouseArea {
                            id: defaultEditBtnMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: enhancedTableView.itemEditRequested(modelData)
                            onPressed: parent.color = Qt.darker("#3498db", 1.2)
                            onReleased: parent.color = "transparent"
                        }
                    }

                    Rectangle {
                        id: defaultDeleteButton
                        width: 36
                        height: 36
                        radius: 8
                        color: defaultDeleteBtnMouseArea.pressed ? Qt.darker("#e74c3c", 1.2) : (defaultDeleteBtnMouseArea.containsMouse ? "#e74c3c" : "transparent")
                        border.color: defaultDeleteBtnMouseArea.containsMouse || defaultDeleteBtnMouseArea.pressed ? "#e74c3c" : "#e0e0e0"
                        border.width: 2
                        z: 1

                        Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }

                        Rectangle {
                            width: 24
                            height: 24
                            radius: 6
                            color: parent.color
                            anchors.centerIn: parent

                            Text {
                                anchors.centerIn: parent
                                text: "🗑️"
                                font.pixelSize: 10
                                color: defaultDeleteBtnMouseArea.containsMouse || defaultDeleteBtnMouseArea.pressed ? "white" : "#7f8c8d"
                            }
                        }

                        MouseArea {
                            id: defaultDeleteBtnMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: enhancedTableView.itemDeleteRequested(modelData)
                            onPressed: parent.color = Qt.darker("#e74c3c", 1.2)
                            onReleased: parent.color = "transparent"
                        }
                    }
                }
            }

            MouseArea {
                z: 2
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                propagateComposedEvents: true
                preventStealing: false
            }
        }
    }

    Component {
        id: defaultGridDelegate

        Rectangle {
            width: gridView.cellWidth - 12
            height: gridView.cellHeight - 12
            radius: 12
            color: mouseArea.containsMouse ? "#f8f9fa" : "#ffffff"
            border.color: mouseArea.containsMouse ? "#3498db" : "#e9ecef"
            border.width: 2

            scale: mouseArea.pressed ? 0.98 : (mouseArea.containsMouse ? 1.02 : 1)
            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }

            Column {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                Rectangle {
                    width: 48
                    height: 48
                    radius: 10
                    color: mouseArea.containsMouse ? "#3498db" : "#e9ecef"
                    border.color: mouseArea.containsMouse ? "#2980b9" : "#dee2e6"
                    border.width: 2
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        anchors.centerIn: parent
                        text: itemType === "group" ? "👥" : (itemType === "teacher" ? "👨‍🏫" : "👨‍🎓")
                        font.pixelSize: 20
                    }
                }

                Text {
                    text: getTitleText(modelData)
                    font.bold: true
                    font.pixelSize: 13
                    color: "#2c3e50"
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    text: getSubtitleText(modelData)
                    font.pixelSize: 11
                    color: "#7f8c8d"
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }

                Item { height: 4 }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 6

                    Rectangle {
                        id: defaultEditButtonGrid
                        width: 32
                        height: 32
                        radius: 8
                        color: defaultEditBtnMouseAreaGrid.pressed ? Qt.darker("#3498db", 1.2) : (defaultEditBtnMouseAreaGrid.containsMouse ? "#3498db" : "transparent")
                        border.color: defaultEditBtnMouseAreaGrid.containsMouse || defaultEditBtnMouseAreaGrid.pressed ? "#3498db" : "#e0e0e0"
                        border.width: 2
                        z: 1

                        Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }

                        Rectangle {
                            width: 20
                            height: 20
                            radius: 5
                            color: parent.color
                            anchors.centerIn: parent

                            Text {
                                anchors.centerIn: parent
                                text: "✏️"
                                font.pixelSize: 9
                                color: defaultEditBtnMouseAreaGrid.containsMouse || defaultEditBtnMouseAreaGrid.pressed ? "white" : "#7f8c8d"
                            }
                        }

                        MouseArea {
                            id: defaultEditBtnMouseAreaGrid
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: enhancedTableView.itemEditRequested(modelData)
                            onPressed: parent.color = Qt.darker("#3498db", 1.2)
                            onReleased: parent.color = "transparent"
                        }
                    }

                    Rectangle {
                        id: defaultDeleteButtonGrid
                        width: 32
                        height: 32
                        radius: 8
                        color: defaultDeleteBtnMouseAreaGrid.pressed ? Qt.darker("#e74c3c", 1.2) : (defaultDeleteBtnMouseAreaGrid.containsMouse ? "#e74c3c" : "transparent")
                        border.color: defaultDeleteBtnMouseAreaGrid.containsMouse || defaultDeleteBtnMouseAreaGrid.pressed ? "#e74c3c" : "#e0e0e0"
                        border.width: 2
                        z: 1

                        Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }

                        Rectangle {
                            width: 20
                            height: 20
                            radius: 5
                            color: parent.color
                            anchors.centerIn: parent

                            Text {
                                anchors.centerIn: parent
                                text: "🗑️"
                                font.pixelSize: 9
                                color: defaultDeleteBtnMouseAreaGrid.containsMouse || defaultDeleteBtnMouseAreaGrid.pressed ? "white" : "#7f8c8d"
                            }
                        }

                        MouseArea {
                            id: defaultDeleteBtnMouseAreaGrid
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: enhancedTableView.itemDeleteRequested(modelData)
                            onPressed: parent.color = Qt.darker("#e74c3c", 1.2)
                            onReleased: parent.color = "transparent"
                        }
                    }
                }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                propagateComposedEvents: true
                preventStealing: false
                onPressed: mouse.accepted = false
                onReleased: mouse.accepted = false
                onClicked: mouse.accepted = false
            }
        }
    }

    function getTitleText(data) {
        if (itemType === "group") {
            return data.name || "Без названия";
        } else if (itemType === "teacher") {
            return (data.lastName || "") + " " + (data.firstName || "") + " " + (data.middleName || "");
        } else if (itemType === "student") {
            return (data.last_name || "") + " " + (data.first_name || "") + " " + (data.middle_name || "");
        }
        return "Неизвестный";
    }

    function getSubtitleText(data) {
        if (itemType === "group") {
            return "Студентов: " + (data.studentCount || 0) + " · Куратор: " + (data.teacherName || "Не назначен");
        } else if (itemType === "teacher") {
            return "Специализация: " + (data.specialization || "") + " · Опыт: " + (data.experience || 0) + " лет";
        } else if (itemType === "student") {
            return "Группа: " + (getGroupName ? getGroupName(data.group_id) : data.group_id) + " · Email: " + (data.email || "Нет");
        }
        return "";
    }
}
