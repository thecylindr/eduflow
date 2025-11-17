import QtQuick
import QtQuick.Controls
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
    signal itemDoubleClicked(var itemData)

    property var filteredModel: []
    property string searchText: ""
    property int sortIndex: 0
    property bool sortAscending: true

    function updateDisplayedModel() {
        if (!sourceModel || sourceModel.length === 0) {
            filteredModel = [];
            console.log("Source model is empty");
            return;
        }

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
                var studentName = ((item.last_name || item.lastName || "") + " " + (item.first_name || item.firstName || "") + " " + (item.middle_name || item.middleName || "")).toLowerCase();
                var studentEmail = (item.email || "").toLowerCase();
                var studentPhone = (item.phone_number || item.phoneNumber || "").toLowerCase();
                var studentGroup = (item.group_name || "").toLowerCase();
                return studentName.includes(searchLower) || studentEmail.includes(searchLower) || studentPhone.includes(searchLower) || studentGroup.includes(searchLower);
            } else if (itemType === "group") {
                var groupName = (item.name || "").toLowerCase();
                var teacherName = (item.teacherName || "").toLowerCase();
                return groupName.includes(searchLower) || teacherName.includes(searchLower);
            } else if (itemType === "event") {
                // 🔥 ИСПРАВЛЕНИЕ: используем правильные поля для событий
                var eventCategory = (item.eventCategory || item.category || "").toLowerCase();
                var eventType = (item.eventType || "").toLowerCase();
                var eventLocation = (item.location || "").toLowerCase();
                var eventStatus = (item.status || "").toLowerCase();
                var eventDescription = (item.lore || "").toLowerCase();

                return eventCategory.includes(searchLower) ||
                       eventType.includes(searchLower) ||
                       eventLocation.includes(searchLower) ||
                       eventStatus.includes(searchLower) ||
                       eventDescription.includes(searchLower);
            } else if (itemType === "portfolio") {
                var studentName = (item.studentName || "").toLowerCase();
                var decree = (item.decree || "").toString().toLowerCase();
                return studentName.includes(searchLower) || decree.includes(searchLower);
            }
            return true;
        });

        // Сортировка
        if (sortRoles.length > sortIndex) {
            var sortRole = sortRoles[sortIndex];
            console.log("Sorting by role:", sortRole, "for itemType:", itemType);

            filtered.sort(function(a, b) {
                var aVal = "";
                var bVal = "";

                // Обработка разных типов данных
                if (itemType === "student") {
                    if (sortRole === "full_name") {
                        aVal = ((a.last_name || a.lastName || "") + " " + (a.first_name || a.firstName || "") + " " + (a.middle_name || a.middleName || "")).toString().toLowerCase();
                        bVal = ((b.last_name || b.lastName || "") + " " + (b.first_name || b.firstName || "") + " " + (b.middle_name || b.middleName || "")).toString().toLowerCase();
                    } else if (sortRole === "group_name") {
                        aVal = (a.group_name || "").toString().toLowerCase();
                        bVal = (b.group_name || "").toString().toLowerCase();
                    } else if (sortRole === "phone_number") {
                        aVal = (a.phone_number || a.phoneNumber || "").toString().toLowerCase();
                        bVal = (b.phone_number || b.phoneNumber || "").toString().toLowerCase();
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
                        aVal = ((a.lastName || "") + " " + (a.firstName || "") + " " + (a.middleName || "")).toString().toLowerCase();
                        bVal = ((b.lastName || "") + " " + (b.firstName || "") + " " + (b.middleName || "")).toString().toLowerCase();
                    } else {
                        aVal = (a[sortRole] || "").toString().toLowerCase();
                        bVal = (b[sortRole] || "").toString().toLowerCase();
                    }
                }
                else if (itemType === "group") {
                    aVal = (a[sortRole] || "").toString().toLowerCase();
                    bVal = (b[sortRole] || "").toString().toLowerCase();
                }
                else if (itemType === "event") {
                    // 🔥 ИСПРАВЛЕНИЕ: правильная обработка полей событий
                    if (sortRole === "Category") {
                        aVal = (a.eventCategory || a.category || "Без наименования").toString().toLowerCase();
                        bVal = (b.eventCategory || b.category || "Без наименования").toString().toLowerCase();
                    } else if (sortRole === "eventType") {
                        aVal = (a.eventType || "Без типа").toString().toLowerCase();
                        bVal = (b.eventType || "Без типа").toString().toLowerCase();
                    } else if (sortRole === "startDate") {
                        aVal = (a.startDate || "").toString().toLowerCase();
                        bVal = (b.startDate || "").toString().toLowerCase();
                    } else if (sortRole === "status") {
                        aVal = (a.status || "active").toString().toLowerCase();
                        bVal = (b.status || "active").toString().toLowerCase();
                    } else if (sortRole === "location") {
                        aVal = (a.location || "").toString().toLowerCase();
                        bVal = (b.location || "").toString().toLowerCase();
                    } else if (sortRole === "lore") {
                        aVal = (a.lore || "").toString().toLowerCase();
                        bVal = (b.lore || "").toString().toLowerCase();
                    } else {
                        aVal = (a[sortRole] || "").toString().toLowerCase();
                        bVal = (b[sortRole] || "").toString().toLowerCase();
                    }
                }
                else if (itemType === "portfolio") {
                    if (sortRole === "studentName") {
                        aVal = (a.studentName || "").toString().toLowerCase();
                        bVal = (b.studentName || "").toString().toLowerCase();
                    } else if (sortRole === "date") {
                        aVal = (a.date || "").toString().toLowerCase();
                        bVal = (b.date || "").toString().toLowerCase();
                    } else if (sortRole === "decree") {
                        aVal = (a.decree || "").toString().toLowerCase();
                        bVal = (b.decree || "").toString().toLowerCase();
                    } else {
                        aVal = (a[sortRole] || "").toString().toLowerCase();
                        bVal = (b[sortRole] || "").toString().toLowerCase();
                    }
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
        if (sourceModel.length > 0) {
            console.log("First item:", JSON.stringify(sourceModel[0]));
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
                        width: listScrollView.availableWidth
                        spacing: 6

                        Repeater {
                            model: enhancedTable.filteredModel

                            delegate: EnhancedListItem {
                                width: listViewColumn.width - 20
                                itemData: modelData
                                itemType: enhancedTable.itemType
                                onEditRequested: function(data) {
                                    enhancedTable.itemEditRequested(data)
                                }
                                onDeleteRequested: function(data) {
                                    enhancedTable.itemDeleteRequested(data)
                                }
                                onDoubleClicked: function(data) {
                                    enhancedTable.itemDoubleClicked(data)
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
                        width: gridScrollView.availableWidth
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
                                onDoubleClicked: function(data) {
                                    enhancedTable.itemDoubleClicked(data)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
