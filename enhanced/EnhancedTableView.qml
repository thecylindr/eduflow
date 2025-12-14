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
    property bool isGridView: settingsManager ? settingsManager.isGridView : false
    property bool isMobile: Qt.platform.os === "android" || Qt.platform.os === "ios"

    signal itemEditRequested(var itemData)
    signal itemDeleteRequested(var itemData)
    signal itemDoubleClicked(var itemData)

    property var filteredModel: []
    property string searchText: ""
    property int sortIndex: 0
    property bool sortAscending: true

    // Функция для форматирования даты в дд.мм.гггг
    function formatDate(dateString) {
        if (!dateString) return "";

        try {
            var date = new Date(dateString);
            if (isNaN(date.getTime())) return "";

            var day = date.getDate().toString().padStart(2, '0');
            var month = (date.getMonth() + 1).toString().padStart(2, '0');
            var year = date.getFullYear();

            return day + "." + month + "." + year;
        } catch(e) {
            return "";
        }
    }

    // Проверка активности события по дате
    function isEventActive(event) {
        var status = event.status || "active";

        // Если статус не "active", возвращаем false
        if (status !== "active") return false;

        var startDate = event.startDate;
        if (!startDate) return true; // Если даты нет, считаем активным

        try {
            var eventDate = new Date(startDate);
            var today = new Date();

            // Сбрасываем время для сравнения только дат
            eventDate.setHours(0, 0, 0, 0);
            today.setHours(0, 0, 0, 0);

            // Событие активно, если его дата сегодня или в будущем
            return eventDate >= today;
        } catch(e) {
            return true;
        }
    }

    // Вспомогательная функция для форматирования даты в поиске
    function formatDateForSearch(dateString) {
        if (!dateString) return "";

        try {
            var date = new Date(dateString);
            if (isNaN(date.getTime())) return "";

            var day = date.getDate().toString().padStart(2, '0');
            var month = (date.getMonth() + 1).toString().padStart(2, '0');
            var year = date.getFullYear();

            return day + "." + month + "." + year;
        } catch(e) {
            return "";
        }
    }

    // Вспомогательная функция для определения статуса события для сортировки
    function getEventStatusForSort(event) {
        var status = event.status || "active";

        // Если статус активный, проверяем актуальность по дате
        if (status === "active") {
            return isEventActive(event) ? "active" : "inactive";
        }

        return status;
    }

    function updateDisplayedModel() {
        if (!sourceModel || sourceModel.length === 0) {
            filteredModel = [];
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
                var eventCategory = (item.eventCategory || item.category || "").toLowerCase();
                var eventType = (item.eventType || "").toLowerCase();
                var eventLocation = (item.location || "").toLowerCase();
                var eventStatus = (item.status || "").toLowerCase();
                var eventDescription = (item.lore || "").toLowerCase();
                // Добавляем форматированную дату в поиск
                var eventDate = formatDateForSearch(item.startDate || "");

                return eventCategory.includes(searchLower) ||
                       eventType.includes(searchLower) ||
                       eventLocation.includes(searchLower) ||
                       eventStatus.includes(searchLower) ||
                       eventDescription.includes(searchLower) ||
                       eventDate.includes(searchLower);
            } else if (itemType === "portfolio") {
                var studentName = (item.studentName || "").toLowerCase();
                var decree = (item.decree || "").toString().toLowerCase();
                // Добавляем форматированную дату в поиск
                var portfolioDate = formatDateForSearch(item.date || "");
                return studentName.includes(searchLower) || decree.includes(searchLower) || portfolioDate.includes(searchLower);
            }
            return true;
        });

        // Сортировка
        if (sortRoles.length > sortIndex) {
            var sortRole = sortRoles[sortIndex];

            filtered.sort(function(a, b) {
                var aVal = "";
                var bVal = "";
                var isNumeric = false;

                // Обработка разных типов данных
                if (itemType === "student") {
                    if (sortRole === "full_name") {
                        aVal = ((a.last_name || a.lastName || "") + " " + (a.first_name || a.firstName || "") + " " + (a.middle_name || a.middleName || "")).toString();
                        bVal = ((b.last_name || b.lastName || "") + " " + (b.first_name || b.firstName || "") + " " + (b.middle_name || b.middleName || "")).toString();
                    } else if (sortRole === "group_name") {
                        aVal = (a.group_name || "").toString();
                        bVal = (b.group_name || "").toString();
                    } else if (sortRole === "phone_number") {
                        aVal = (a.phone_number || a.phoneNumber || "").toString();
                        bVal = (b.phone_number || b.phoneNumber || "").toString();
                    } else if (sortRole === "email") {
                        aVal = (a.email || "").toString();
                        bVal = (b.email || "").toString();
                    } else {
                        aVal = (a[sortRole] || "").toString();
                        bVal = (b[sortRole] || "").toString();
                    }
                }
                else if (itemType === "teacher") {
                    if (sortRole === "full_name") {
                        aVal = ((a.lastName || "") + " " + (a.firstName || "") + " " + (a.middleName || "")).toString();
                        bVal = ((b.lastName || "") + " " + (b.firstName || "") + " " + (b.middleName || "")).toString();
                    } else if (sortRole === "experience") {
                        // ОСОБАЯ ОБРАБОТКА ДЛЯ ОПЫТА - ЧИСЛОВАЯ СОРТИРОВКА
                        aVal = parseFloat(a.experience) || 0;
                        bVal = parseFloat(b.experience) || 0;
                        isNumeric = true;
                    } else {
                        aVal = (a[sortRole] || "").toString();
                        bVal = (b[sortRole] || "").toString();
                    }
                }
                else if (itemType === "group") {
                    if (sortRole === "studentCount") {
                        // ОСОБАЯ ОБРАБОТКА ДЛЯ КОЛИЧЕСТВА СТУДЕНТОВ - ЧИСЛОВАЯ СОРТИРОВКА
                        aVal = parseFloat(a.studentCount) || 0;
                        bVal = parseFloat(b.studentCount) || 0;
                        isNumeric = true;
                    } else {
                        aVal = (a[sortRole] || "").toString();
                        bVal = (b[sortRole] || "").toString();
                    }
                }
                else if (itemType === "event") {
                    if (sortRole === "eventCategory") {
                        aVal = (a.eventCategory || a.category || "Без наименования").toString();
                        bVal = (b.eventCategory || b.category || "Без наименования").toString();
                    } else if (sortRole === "eventType") {
                        aVal = (a.eventType || "Без типа").toString();
                        bVal = (b.eventType || "Без типа").toString();
                    } else if (sortRole === "startDate") {
                        // Для сортировки используем оригинальную дату
                        aVal = (a.startDate || "").toString();
                        bVal = (b.startDate || "").toString();
                    } else if (sortRole === "status") {
                        // Для сортировки по статусу учитываем фактический статус
                        aVal = getEventStatusForSort(a).toString();
                        bVal = getEventStatusForSort(b).toString();
                    } else if (sortRole === "location") {
                        aVal = (a.location || "").toString();
                        bVal = (b.location || "").toString();
                    } else if (sortRole === "lore") {
                        aVal = (a.lore || "").toString();
                        bVal = (b.lore || "").toString();
                    } else if (sortRole === "maxParticipants" || sortRole === "currentParticipants") {
                        // ОСОБАЯ ОБРАБОТКА ДЛЯ ЧИСЛОВЫХ ПОЛЕЙ СОБЫТИЙ
                        aVal = parseFloat(a[sortRole]) || 0;
                        bVal = parseFloat(b[sortRole]) || 0;
                        isNumeric = true;
                    } else {
                        aVal = (a[sortRole] || "").toString();
                        bVal = (b[sortRole] || "").toString();
                    }
                }
                else if (itemType === "portfolio") {
                    if (sortRole === "studentName") {
                        aVal = (a.studentName || "").toString();
                        bVal = (b.studentName || "").toString();
                    } else if (sortRole === "date") {
                        aVal = (a.date || "").toString();
                        bVal = (b.date || "").toString();
                    } else if (sortRole === "decree") {
                        aVal = (a.decree || "").toString();
                        bVal = (b.decree || "").toString();
                    } else {
                        aVal = (a[sortRole] || "").toString();
                        bVal = (b[sortRole] || "").toString();
                    }
                }
                else {
                    aVal = (a[sortRole] || "").toString();
                    bVal = (b[sortRole] || "").toString();
                }

                var result = 0;

                if (isNumeric) {
                    // ЧИСЛОВАЯ СОРТИРОВКА
                    if (aVal < bVal) result = -1;
                    else if (aVal > bVal) result = 1;
                } else {
                    // СТРОКОВАЯ СОРТИРОВКА (с приведением к нижнему регистру)
                    var aStr = aVal.toString().toLowerCase();
                    var bStr = bVal.toString().toLowerCase();
                    if (aStr < bStr) result = -1;
                    else if (aStr > bStr) result = 1;
                }

                return sortAscending ? result : -result;
            });
        }

        filteredModel = filtered;
    }

    onSourceModelChanged: updateDisplayedModel()
    onSearchTextChanged: updateDisplayedModel()
    onSortIndexChanged: updateDisplayedModel()
    onSortAscendingChanged: updateDisplayedModel()

    // Синхронизация с SettingsManager
    Connections {
        target: settingsManager
        function onIsGridViewChanged() {
            enhancedTable.isGridView = settingsManager.isGridView
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: isMobile ? 4 : 10

        // Панель управления - полностью адаптивная для мобильных
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: isMobile ? 90 : 45

            // Мобильная версия - вертикальное расположение (поиск отдельно, кнопки под ним)
            ColumnLayout {
                anchors.fill: parent
                spacing: 6
                visible: isMobile

                // Поисковая строка на всю ширину
                EnhancedSearchBox {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    placeholder: enhancedTable.searchPlaceholder
                    isMobile: enhancedTable.isMobile
                    onSearchRequested: function(text) {
                        enhancedTable.searchText = text
                    }
                }

                // Кнопки сортировки и переключения вида под поиском
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    EnhancedSortComboBox {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        sortOptions: enhancedTable.sortOptions
                        sortRoles: enhancedTable.sortRoles
                        isMobile: enhancedTable.isMobile
                        onSortChanged: function(index, ascending) {
                            enhancedTable.sortIndex = index
                            enhancedTable.sortAscending = ascending
                        }
                    }

                    EnhancedViewToggle {
                        Layout.preferredHeight: 36
                        Layout.preferredWidth: 80
                        isGridView: enhancedTable.isGridView
                        isMobile: enhancedTable.isMobile
                        onViewToggled: function(gridView) {
                            if (settingsManager) {
                                // ПРАВИЛЬНОЕ ПРИСВАИВАНИЕ - без вызова функции
                                settingsManager.isGridView = gridView
                            }
                        }
                    }
                }
            }

            // Компьютерная версия - горизонтальное расположение
            RowLayout {
                anchors.fill: parent
                spacing: 10
                visible: !isMobile

                EnhancedSearchBox {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    placeholder: enhancedTable.searchPlaceholder
                    isMobile: enhancedTable.isMobile
                    onSearchRequested: function(text) {
                        enhancedTable.searchText = text
                    }
                }

                EnhancedSortComboBox {
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 35
                    sortOptions: enhancedTable.sortOptions
                    sortRoles: enhancedTable.sortRoles
                    isMobile: enhancedTable.isMobile
                    onSortChanged: function(index, ascending) {
                        enhancedTable.sortIndex = index
                        enhancedTable.sortAscending = ascending
                    }
                }

                EnhancedViewToggle {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 35
                    isGridView: enhancedTable.isGridView
                    isMobile: enhancedTable.isMobile
                    onViewToggled: function(gridView) {
                        if (settingsManager) {
                            // ПРАВИЛЬНОЕ ПРИСВАИВАНИЕ - без вызова функции
                            settingsManager.isGridView = gridView
                        }
                    }
                }
            }
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
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    contentWidth: availableWidth
                    contentHeight: listViewColumn.height

                    Column {
                        id: listViewColumn
                        width: listScrollView.availableWidth
                        spacing: isMobile ? 4 : 8

                        Repeater {
                            model: enhancedTable.filteredModel

                            delegate: EnhancedListItem {
                                width: listViewColumn.width - (isMobile ? 8 : 20)
                                anchors.horizontalCenter: parent.horizontalCenter
                                itemData: modelData
                                itemType: enhancedTable.itemType
                                isMobile: enhancedTable.isMobile
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
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    contentWidth: availableWidth
                    contentHeight: gridViewLayout.height

                    Flow {
                        id: gridViewLayout
                        width: gridScrollView.availableWidth
                        spacing: isMobile ? 8 : 12
                        padding: isMobile ? 8 : 12

                        Repeater {
                            model: enhancedTable.filteredModel

                            delegate: EnhancedGridItem {
                                width: {
                                    if (isMobile) {
                                        var availableWidth = gridViewLayout.width - gridViewLayout.padding * 2;
                                        var columns = 2;
                                        return (availableWidth - (columns - 1) * gridViewLayout.spacing) / columns;
                                    } else {
                                        return 180;
                                    }
                                }
                                height: isMobile ? 130 : 160
                                itemData: modelData
                                itemType: enhancedTable.itemType
                                isMobile: enhancedTable.isMobile
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
