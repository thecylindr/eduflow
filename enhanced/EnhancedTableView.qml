// enhanced/EnhancedTableView.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: enhancedTable
    property var sourceModel: []
    property string itemType: ""
    property string searchPlaceholder: "Поиск..."
    property var sortOptions: []
    property var sortRoles: []
    property bool isGridView: false

    signal itemEditRequested(var itemData)
    signal itemDeleteRequested(var itemData)

    property var filteredModel: []
    property string searchText: ""
    property int sortIndex: 0
    property bool sortAscending: true

    function updateDisplayedModel() {
        console.log("Updating displayed model. Source length:", sourceModel.length, "Search:", searchText, "Sort index:", sortIndex, "Ascending:", sortAscending);

        // Фильтрация
        var filtered = sourceModel.filter(function(item) {
            if (!searchText) return true;

            var searchLower = searchText.toLowerCase();
            if (itemType === "teacher") {
                var teacherName = ((item.lastName || "") + " " + (item.firstName || "") + " " + (item.middleName || "")).toLowerCase();
                var teacherSpecialization = (item.specialization || "").toLowerCase();
                var teacherEmail = (item.email || "").toLowerCase();
                return teacherName.includes(searchLower) || teacherSpecialization.includes(searchLower) || teacherEmail.includes(searchLower);
            } else if (itemType === "student") {
                var studentName = ((item.last_name || "") + " " + (item.first_name || "") + " " + (item.middle_name || "")).toLowerCase();
                var studentEmail = (item.email || "").toLowerCase();
                var studentPhone = (item.phone_number || "").toLowerCase();
                var studentGroup = (item.group_id || "").toLowerCase();
                return studentName.includes(searchLower) || studentEmail.includes(searchLower) || studentPhone.includes(searchLower) || studentGroup.includes(searchLower);
            } else if (itemType === "group") {
                var groupName = (item.name || "").toLowerCase();
                var teacherName = (item.teacherName || "").toLowerCase();
                return groupName.includes(searchLower) || teacherName.includes(searchLower);
            }
            return true;
        });

        // Сортировка
        if (sortRoles.length > sortIndex) {
            var sortRole = sortRoles[sortIndex];
            console.log("Sorting by role:", sortRole, "for itemType:", itemType);

            filtered.sort(function(a, b) {
                var aVal, bVal;

                // Обработка разных типов данных
                if (itemType === "student") {
                    if (sortRole === "full_name") {
                        aVal = ((a.last_name || "") + " " + (a.first_name || "") + " " + (a.middle_name || "")).toLowerCase();
                        bVal = ((b.last_name || "") + " " + (b.first_name || "") + " " + (b.middle_name || "")).toLowerCase();
                    } else if (sortRole === "group_id") {
                        aVal = (a.group_id || "").toString().toLowerCase();
                        bVal = (b.group_id || "").toString().toLowerCase();
                    } else if (sortRole === "phone_number") {
                        aVal = (a.phone_number || "").toString().toLowerCase();
                        bVal = (b.phone_number || "").toString().toLowerCase();
                    } else if (sortRole === "email") {
                        aVal = (a.email || "").toString().toLowerCase();
                        bVal = (b.email || "").toString().toLowerCase();
                    } else {
                        aVal = (a[sortRole] || "").toString().toLowerCase();
                        bVal = (b[sortRole] || "").toString().toLowerCase();
                    }
                }
                else if (itemType === "teacher") {
                    if (sortRole === "full_name") {
                        aVal = ((a.lastName || "") + " " + (a.firstName || "") + " " + (a.middleName || "")).toLowerCase();
                        bVal = ((b.lastName || "") + " " + (b.firstName || "") + " " + (b.middleName || "")).toLowerCase();
                    } else {
                        aVal = (a[sortRole] || "").toString().toLowerCase();
                        bVal = (b[sortRole] || "").toString().toLowerCase();
                    }
                }
                else if (itemType === "group") {
                    aVal = (a[sortRole] || "").toString().toLowerCase();
                    bVal = (b[sortRole] || "").toString().toLowerCase();
                }
                else {
                    aVal = (a[sortRole] || "").toString().toLowerCase();
                    bVal = (b[sortRole] || "").toString().toLowerCase();
                }

                var result = 0;
                if (aVal < bVal) result = -1;
                else if (aVal > bVal) result = 1;

                return sortAscending ? result : -result;
            });
        }

        filteredModel = filtered;
        console.log("Displayed model length:", filteredModel.length);
    }

    onSourceModelChanged: {
        console.log("Source model changed, length:", sourceModel.length);
        if (sourceModel.length > 0 && itemType === "student") {
            console.log("First student item:", JSON.stringify(sourceModel[0]));
        }
        updateDisplayedModel();
    }
    onSearchTextChanged: updateDisplayedModel()
    onSortIndexChanged: updateDisplayedModel()
    onSortAscendingChanged: updateDisplayedModel()

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        // Панель управления
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            EnhancedSearchBox {
                Layout.preferredWidth: 300
                placeholder: enhancedTable.searchPlaceholder
                onSearchRequested: function(text) {
                    enhancedTable.searchText = text
                }
            }

            EnhancedSortComboBox {
                sortOptions: enhancedTable.sortOptions
                sortRoles: enhancedTable.sortRoles
                onSortChanged: function(index, ascending) {
                    enhancedTable.sortIndex = index
                    enhancedTable.sortAscending = ascending
                }
            }

            EnhancedViewToggle {
                onViewToggled: function(gridView) {
                    enhancedTable.isGridView = gridView
                }
            }

            Item { Layout.fillWidth: true }
        }

        // Область контента
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"

            Loader {
                id: viewLoader
                anchors.fill: parent
                sourceComponent: enhancedTable.isGridView ? gridViewComponent : listViewComponent
            }

            Component {
                id: listViewComponent

                ScrollView {
                    id: listScrollView
                    anchors.fill: parent
                    clip: true
                    ScrollBar.vertical.policy: ScrollBar.AsNeeded

                    Column {
                        id: listViewColumn
                        width: listScrollView.availableWidth // Используем доступную ширину
                        spacing: 6

                        Repeater {
                            model: enhancedTable.filteredModel

                            delegate: EnhancedListItem {
                                // Упрощенная установка ширины без конфликтующих якорей
                                width: listViewColumn.width - 20
                                itemData: modelData
                                itemType: enhancedTable.itemType
                                onEditRequested: function(data) {
                                    enhancedTable.itemEditRequested(data)
                                }
                                onDeleteRequested: function(data) {
                                    enhancedTable.itemDeleteRequested(data)
                                }
                            }
                        }
                    }
                }
            }

            Component {
                id: gridViewComponent

                ScrollView {
                    id: gridScrollView
                    anchors.fill: parent
                    clip: true
                    ScrollBar.vertical.policy: ScrollBar.AsNeeded

                    Flow {
                        id: gridViewLayout
                        width: gridScrollView.availableWidth // Используем доступную ширину
                        spacing: 10
                        padding: 10

                        Repeater {
                            model: enhancedTable.filteredModel

                            delegate: EnhancedGridItem {
                                width: 180
                                height: 150
                                itemData: modelData
                                itemType: enhancedTable.itemType
                                onEditRequested: function(data) {
                                    enhancedTable.itemEditRequested(data)
                                }
                                onDeleteRequested: function(data) {
                                    enhancedTable.itemDeleteRequested(data)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
