// enhanced/EnhancedTableView.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: enhancedTableView

    property var sourceModel: []
    property string searchPlaceholder: "Поиск..."
    property string currentSortRole: "name"
    property bool sortAscending: true
    property string viewMode: "list"

    property var sortOptions: []
    property var sortRoles: []
    property string displayRole: "name"

    signal itemClicked(var itemData)
    signal itemEditRequested(var itemData)
    signal itemDeleteRequested(var itemData)
    signal itemDoubleClicked(var itemData)

    property Component listDelegate
    property Component gridDelegate
    property string itemType: "item"

    property string searchText: ""

    function triggerEdit(itemData) {
        console.log("✏️ Запрос редактирования:", itemData);
        itemEditRequested(itemData);
    }

    function triggerDelete(itemData) {
        console.log("🗑️ Запрос удаления:", itemData);
        itemDeleteRequested(itemData);
    }

    property var processedModel: {
        let filtered = sourceModel.filter(item => searchFilter(item));
        return sortModel(filtered);
    }

    function searchFilter(item) {
        if (!searchText || searchText.trim() === "") return true;

        var searchLower = searchText.toLowerCase();

        for (var key in item) {
            if (item.hasOwnProperty(key) && typeof item[key] === 'string') {
                if (item[key].toLowerCase().includes(searchLower)) {
                    return true;
                }
            }
        }

        for (var numKey in item) {
            if (item.hasOwnProperty(numKey) && typeof item[numKey] === 'number') {
                if (String(item[numKey]).includes(searchLower)) {
                    return true;
                }
            }
        }

        return false;
    }

    function sortModel(model) {
        if (!currentSortRole || currentSortRole === "") return model;

        return model.slice().sort((a, b) => {
            var aVal = getNestedValue(a, currentSortRole);
            var bVal = getNestedValue(b, currentSortRole);

            if (aVal === undefined || aVal === null) aVal = "";
            if (bVal === undefined || bVal === null) bVal = "";

            if (typeof aVal === 'number' && typeof bVal === 'number') {
                return sortAscending ? aVal - bVal : bVal - aVal;
            }

            aVal = String(aVal).toLowerCase();
            bVal = String(bVal).toLowerCase();

            if (aVal < bVal) return sortAscending ? -1 : 1;
            if (aVal > bVal) return sortAscending ? 1 : -1;
            return 0;
        });
    }

    function getNestedValue(obj, path) {
        return path.split('.').reduce((acc, part) => acc && acc[part], obj) || "";
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        // Панель управления
        Rectangle {
            Layout.fillWidth: true
            height: 50
            radius: 8
            color: "#ffffff"
            border.color: "#e0e0e0"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                // Поиск
                Rectangle {
                    Layout.fillWidth: true
                    height: 30
                    radius: 6
                    color: "#f8f9fa"
                    border.color: "#e0e0e0"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 5
                        spacing: 5

                        Text {
                            text: "🔍"
                            font.pixelSize: 12
                            Layout.alignment: Qt.AlignVCenter
                        }

                        TextField {
                            id: searchField
                            Layout.fillWidth: true
                            placeholderText: searchPlaceholder
                            background: null
                            font.pixelSize: 12
                            onTextChanged: searchText = text
                        }
                    }
                }

                // Сортировка
                ComboBox {
                    id: sortCombo
                    Layout.preferredWidth: 150
                    model: sortOptions
                    currentIndex: 0
                    visible: sortOptions.length > 0
                    onCurrentIndexChanged: {
                        if (currentIndex >= 0 && currentIndex < sortRoles.length) {
                            currentSortRole = sortRoles[currentIndex];
                        }
                    }
                }

                // Направление сортировки
                Rectangle {
                    width: 30
                    height: 30
                    radius: 6
                    color: sortDirectionMouseArea.containsMouse ? "#e3f2fd" : "#f8f9fa"
                    border.color: "#3498db"
                    border.width: 1
                    visible: sortOptions.length > 0

                    Text {
                        anchors.centerIn: parent
                        text: sortAscending ? "↑" : "↓"
                        color: "#3498db"
                        font.bold: true
                    }

                    MouseArea {
                        id: sortDirectionMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: sortAscending = !sortAscending
                    }
                }

                // Переключение режима просмотра
                Row {
                    spacing: 2

                    Rectangle {
                        width: 30
                        height: 30
                        radius: 6
                        color: viewMode === "list" ? "#3498db" : "#f8f9fa"
                        border.color: "#3498db"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "≡"
                            color: viewMode === "list" ? "white" : "#3498db"
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: viewMode = "list"
                        }
                    }

                    Rectangle {
                        width: 30
                        height: 30
                        radius: 6
                        color: viewMode === "grid" ? "#3498db" : "#f8f9fa"
                        border.color: "#3498db"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "☷"
                            color: viewMode === "grid" ? "white" : "#3498db"
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: viewMode = "grid"
                        }
                    }
                }
            }
        }

        // Статистика поиска
        Text {
            text: "Найдено: " + processedModel.length + " из " + sourceModel.length
            font.pixelSize: 12
            color: "#7f8c8d"
            Layout.alignment: Qt.AlignRight
            visible: sourceModel.length > 0
        }

        // Контент
        Loader {
            id: contentLoader
            Layout.fillWidth: true
            Layout.fillHeight: true
            sourceComponent: viewMode === "list" ? listViewComponent : gridViewComponent
        }
    }

    // Режим списка
    Component {
        id: listViewComponent

        ListView {
            id: listView
            model: processedModel
            spacing: 5
            clip: true

            delegate: Rectangle {
                id: listDelegate
                width: listView.width
                height: 70
                radius: 8
                color: mouseArea.containsMouse ? "#f0f8ff" : (index % 2 === 0 ? "#f8f9fa" : "#ffffff")
                border.color: mouseArea.containsMouse ? "#3498db" : "#e9ecef"
                border.width: mouseArea.containsMouse ? 2 : 1

                Loader {
                    id: listDelegateLoader
                    anchors.fill: parent
                    sourceComponent: enhancedTableView.listDelegate || defaultListDelegate

                    property var itemData: modelData
                    property int itemIndex: index

                    onLoaded: {
                        if (item && item.editRequested) {
                            item.editRequested.connect(triggerEdit);
                        }
                        if (item && item.deleteRequested) {
                            item.deleteRequested.connect(triggerDelete);
                        }
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: itemClicked(modelData)
                    onDoubleClicked: itemDoubleClicked(modelData)
                }
            }

            Text {
                anchors.centerIn: parent
                text: sourceModel.length === 0 ? "Нет данных для отображения" : "Ничего не найдено"
                color: "#7f8c8d"
                font.pixelSize: 14
                visible: processedModel.length === 0
            }
        }
    }

    // Режим плиток
    Component {
        id: gridViewComponent

        ScrollView {
            clip: true

            GridView {
                id: gridView
                width: parent.width
                model: processedModel
                cellWidth: Math.max(250, width / Math.floor(width / 280))
                cellHeight: 140 // Уменьшил высоту для лучшего отображения

                delegate: Rectangle {
                    id: gridDelegate
                    width: gridView.cellWidth - 5
                    height: gridView.cellHeight - 5
                    radius: 8
                    color: gridMouseArea.containsMouse ? "#f0f8ff" : "#ffffff"
                    border.color: gridMouseArea.containsMouse ? "#3498db" : "#e9ecef"
                    border.width: gridMouseArea.containsMouse ? 2 : 1

                    Loader {
                        id: gridDelegateLoader
                        anchors.fill: parent
                        sourceComponent: enhancedTableView.gridDelegate || defaultGridDelegate

                        property var itemData: modelData
                        property int itemIndex: index

                        onLoaded: {
                            if (item && item.editRequested) {
                                item.editRequested.connect(triggerEdit);
                            }
                            if (item && item.deleteRequested) {
                                item.deleteRequested.connect(triggerDelete);
                            }
                        }
                    }

                    MouseArea {
                        id: gridMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: itemClicked(modelData)
                        onDoubleClicked: itemDoubleClicked(modelData)
                    }
                }
            }
        }
    }

    // Стандартный делегат списка
    Component {
        id: defaultListDelegate

        Row {
            id: defaultListRow
            anchors.fill: parent
            anchors.margins: 10
            spacing: 15

            Rectangle {
                width: 50
                height: 50
                radius: 25
                color: getColorForType(itemType)
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    text: getIconForType(itemType)
                    font.pixelSize: 20
                    anchors.centerIn: parent
                }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2
                width: parent.width - 200

                Text {
                    text: getDisplayText(itemData)
                    font.pixelSize: 14
                    font.bold: true
                    color: "#2c3e50"
                    elide: Text.ElideRight
                    width: parent.width
                }

                Text {
                    text: getSubtitleText(itemData)
                    font.pixelSize: 11
                    color: "#7f8c8d"
                    width: parent.width
                    elide: Text.ElideRight
                }
            }

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 5

                Rectangle {
                    width: 30
                    height: 30
                    radius: 6
                    color: editMouseArea.containsMouse ? "#3498db" : "#2980b9"

                    Text {
                        anchors.centerIn: parent
                        text: "✏️"
                        font.pixelSize: 12
                    }

                    MouseArea {
                        id: editMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: defaultListRow.editRequested(itemData)
                    }
                }

                Rectangle {
                    width: 30
                    height: 30
                    radius: 6
                    color: deleteMouseArea.containsMouse ? "#e74c3c" : "#c0392b"

                    Text {
                        anchors.centerIn: parent
                        text: "🗑️"
                        font.pixelSize: 12
                    }

                    MouseArea {
                        id: deleteMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: defaultListRow.deleteRequested(itemData)
                    }
                }
            }

            signal editRequested(var itemData)
            signal deleteRequested(var itemData)
        }
    }

    // Стандартный делегат плиток - ИСПРАВЛЕННЫЙ
    Component {
        id: defaultGridDelegate

        Column {
            id: defaultGridColumn
            anchors.fill: parent
            anchors.margins: 8
            spacing: 4

            Rectangle {
                width: 35
                height: 35
                radius: 18
                color: getColorForType(itemType)
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    text: getIconForType(itemType)
                    font.pixelSize: 14
                    anchors.centerIn: parent
                }
            }

            Text {
                text: getDisplayText(itemData)
                font.pixelSize: 11
                font.bold: true
                color: "#2c3e50"
                anchors.horizontalCenter: parent.horizontalCenter
                elide: Text.ElideRight
                width: parent.width - 10
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                text: getSubtitleText(itemData)
                font.pixelSize: 9
                color: "#7f8c8d"
                anchors.horizontalCenter: parent.horizontalCenter
                elide: Text.ElideRight
                width: parent.width - 10
                horizontalAlignment: Text.AlignHCenter
                maximumLineCount: 2
                wrapMode: Text.WordWrap
            }

            // Кнопки теперь ближе к контенту
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 4
                anchors.verticalCenter: undefined // Убираем привязку к центру

                Rectangle {
                    width: 22
                    height: 22
                    radius: 4
                    color: tileEditMouseArea.containsMouse ? "#3498db" : "#2980b9"

                    Text {
                        anchors.centerIn: parent
                        text: "✏️"
                        font.pixelSize: 9
                    }

                    MouseArea {
                        id: tileEditMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: defaultGridColumn.editRequested(itemData)
                    }
                }

                Rectangle {
                    width: 22
                    height: 22
                    radius: 4
                    color: tileDeleteMouseArea.containsMouse ? "#e74c3c" : "#c0392b"

                    Text {
                        anchors.centerIn: parent
                        text: "🗑️"
                        font.pixelSize: 9
                    }

                    MouseArea {
                        id: tileDeleteMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: defaultGridColumn.deleteRequested(itemData)
                    }
                }
            }

            signal editRequested(var itemData)
            signal deleteRequested(var itemData)
        }
    }

    function getColorForType(type) {
        switch(type) {
            case "student": return "#2ecc71";
            case "teacher": return "#3498db";
            case "group": return "#e74c3c";
            default: return "#95a5a6";
        }
    }

    function getIconForType(type) {
        switch(type) {
            case "student": return "👨‍🎓";
            case "teacher": return "👨‍🏫";
            case "group": return "👥";
            default: return "📄";
        }
    }

    function getDisplayText(data) {
        // ПРИОРИТЕТ: ФИО для преподавателей и студентов
        if (data.last_name && data.first_name) {
            return data.last_name + " " + data.first_name + (data.middle_name ? " " + data.middle_name : "");
        }
        if (data.lastName && data.firstName) {
            return data.lastName + " " + data.firstName + (data.middleName ? " " + data.middleName : "");
        }
        if (data.name) return data.name;
        if (data.title) return data.title;
        if (data.email) return data.email;

        for (var key in data) {
            if (typeof data[key] === 'string' && data[key].length > 0) {
                return data[key];
            }
        }

        return "Элемент";
    }

    function getSubtitleText(data) {
        // Для преподавателей: специализация
        if (data.specialization) return data.specialization;
        if (data.specialization_id) return "Специализация: " + data.specialization_id;

        // Для групп: количество студентов и классный руководитель
        if (data.student_count !== undefined) {
            var teacherInfo = "";
            if (data.teacher_name) teacherInfo = " · " + data.teacher_name;
            else if (data.teacher_id) teacherInfo = " · Куратор: " + data.teacher_id;
            return "Студентов: " + data.student_count + teacherInfo;
        }

        // Для студентов: группа
        if (data.group_name) return "Группа: " + data.group_name;
        if (data.group_id) return "Группа ID: " + data.group_id;

        if (data.email) return data.email;
        if (data.phone_number) return data.phone_number;
        if (data.experience !== undefined) return "Опыт: " + data.experience + " лет";

        return "Дополнительная информация";
    }
}
