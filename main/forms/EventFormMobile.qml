import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15
import QtQuick.Controls.Universal
import "../../common" as Common

Window {
    id: eventFormWindow
    modality: Qt.ApplicationModal
    color: "transparent"
    flags: Qt.Dialog
    visible: false

    // Устанавливаем размер окна на весь экран
    width: Screen.width
    height: Screen.height

    // Настоящие размеры формы (содержимого)
    property int realwidth: {
        if (isMobile) {
            var baseWidth = Math.min(Screen.width * 0.9, 360)
            return Screen.width > Screen.height ? Math.min(Screen.width * 0.95, baseWidth + 100) : baseWidth
        }
        return Math.min(Screen.width * 0.9, 360)
    }
    property int realheight: Math.min(Screen.height * 0.85, 650)

    // Отступы для Android системных кнопок
    property int androidTopMargin: (Qt.platform.os === "android") ? 16 : 0
    property int androidBottomMargin: (Qt.platform.os === "android" && Screen.primaryOrientation === Qt.PortraitOrientation) ? 28 : 0
    property bool isMobile: Qt.platform.os === "android" || Qt.platform.os === "ios"

    property var currentEvent: null
    property bool isEditMode: false
    property bool isSaving: false
    property var eventCategories: []
    property var portfolioList: []
    property bool portfoliosLoaded: false
    property bool portfoliosLoading: false
    property string portfolioStatus: "Загрузка портфолио..."

    // Свойства для перетаскивания на Android
    property bool isDragging: false
    property point dragStartPoint: Qt.point(0, 0)
    property point dragCurrentPoint: Qt.point(0, 0)

    signal saved(var eventData)
    signal cancelled()
    signal saveCompleted(bool success, string message)

    // Компонент точки перетаскивания для Android
    Common.DragPoint {
        id: dragPoint
        visible: isMobile && isDragging
        currentPoint: dragCurrentPoint
    }

    // Модель для отображения портфолио в ComboBox
    ListModel {
        id: portfolioDisplayModel
    }

    // Обработчик изменения ориентации экрана
    onWidthChanged: {
        if (visible && isMobile) {
            Qt.callLater(adjustPositionToScreen);
        }
    }

    onHeightChanged: {
        if (visible && isMobile) {
            Qt.callLater(adjustPositionToScreen);
        }
    }

    function adjustPositionToScreen() {
        if (!isMobile) return;

        var newX = windowContainer.x;
        var newY = windowContainer.y;
        var needsAdjustment = false;

        // Проверяем и корректируем позицию по X
        if (windowContainer.x < 0) {
            newX = 0;
            needsAdjustment = true;
        } else if (windowContainer.x + windowContainer.width > Screen.width) {
            newX = Screen.width - windowContainer.width;
            needsAdjustment = true;
        }

        // Проверяем и корректируем позицию по Y
        if (windowContainer.y < 0) {
            newY = 0;
            needsAdjustment = true;
        } else if (windowContainer.y + windowContainer.height > Screen.height) {
            newY = Screen.height - windowContainer.height;
            needsAdjustment = true;
        }

        // Если нужна корректировка, анимируем перемещение
        if (needsAdjustment) {
            orientationAdjustAnimation.xTo = newX;
            orientationAdjustAnimation.yTo = newY;
            orientationAdjustAnimation.start();
        }
    }

    function updatePortfolioModel() {
        portfolioDisplayModel.clear();
        for (var i = 0; i < portfolioList.length; i++) {
            var portfolio = portfolioList[i];
            var displayText = "Приказ №" + (portfolio.decree || "") + " - " + (portfolio.student_name || "Без имени");
            var measureCode = portfolio.measure_code || portfolio.measureCode || 0;
            portfolioDisplayModel.append({
                displayText: displayText,
                measureCode: measureCode,
                originalIndex: i
            });
        }

        if (isEditMode && currentEvent) {
            restoreSelectedPortfolio();
        }
    }

    function restoreSelectedPortfolio() {
        var measureCode = currentEvent.measureCode || currentEvent.portfolio_id || currentEvent.event_id || 0;
        if (measureCode) {
            for (var i = 0; i < portfolioDisplayModel.count; i++) {
                if (portfolioDisplayModel.get(i).measureCode === measureCode) {
                    portfolioComboBox.currentIndex = i;
                    break;
                }
            }
        }
    }

    function openForAdd() {
        currentEvent = null;
        isEditMode = false;
        isSaving = false;
        portfoliosLoaded = false;
        portfoliosLoading = false;
        portfolioStatus = "Загрузка портфолио...";
        clearForm();
        loadPortfolios();

        // Центрируем содержимое при открытии
        windowContainer.x = (Screen.width - realwidth) / 2;
        windowContainer.y = (Screen.height - realheight) / 2;

        eventFormWindow.show();
    }

    function openForEdit(eventData) {
        currentEvent = eventData;
        isEditMode = true;
        isSaving = false;
        portfoliosLoaded = false;
        portfoliosLoading = false;
        portfolioStatus = "Загрузка портфолио...";
        loadPortfolios();

        // Центрируем содержимое при открытии
        windowContainer.x = (Screen.width - realwidth) / 2;
        windowContainer.y = (Screen.height - realheight) / 2;

        eventFormWindow.show();
        Qt.callLater(function() {
            if (portfolioDisplayModel.count > 0) {
                portfolioComboBox.forceActiveFocus();
            } else {
                eventTypeField.forceActiveFocus();
            }
        });
    }

    function closeWindow() {
        eventFormWindow.close();
    }

    function clearForm() {
        portfolioComboBox.currentIndex = -1;
        eventTypeField.text = "";
        categoryField.text = "";
        startDateField.text = "";
        endDateField.text = "";
        locationField.text = "";
        loreField.text = "";
    }

    function fillForm(eventData) {
        if (!portfoliosLoaded) return;

        eventTypeField.text = eventData.eventType || eventData.event_type || "";
        categoryField.text = eventData.category || "";

        var serverStartDate = eventData.startDate || eventData.start_date || "";
        if (serverStartDate) {
            var startParts = serverStartDate.split('-');
            if (startParts.length === 3) {
                startDateField.text = startParts[2] + "." + startParts[1] + "." + startParts[0];
            } else {
                startDateField.text = serverStartDate;
            }
        }

        var serverEndDate = eventData.endDate || eventData.end_date || "";
        if (serverEndDate) {
            var endParts = serverEndDate.split('-');
            if (endParts.length === 3) {
                endDateField.text = endParts[2] + "." + endParts[1] + "." + endParts[0];
            } else {
                endDateField.text = serverEndDate;
            }
        }

        locationField.text = eventData.location || "";
        loreField.text = eventData.lore || "";
    }

    function getEventData() {
        if (portfolioComboBox.currentIndex < 0) return null;

        var selectedItem = portfolioDisplayModel.get(portfolioComboBox.currentIndex);
        if (!selectedItem || !selectedItem.measureCode) return null;

        var startDateText = startDateField.text.trim();
        var formattedStartDate = startDateText;
        if (startDateText) {
            var startParts = startDateText.split('.');
            if (startParts.length === 3) {
                formattedStartDate = startParts[2] + "-" + startParts[1] + "-" + startParts[0];
            }
        }

        var endDateText = endDateField.text.trim();
        var formattedEndDate = endDateText;
        if (endDateText) {
            var endParts = endDateText.split('.');
            if (endParts.length === 3) {
                formattedEndDate = endParts[2] + "-" + endParts[1] + "-" + endParts[0];
            }
        }

        var eventData = {
            eventType: eventTypeField.text.trim(),
            category: categoryField.text.trim(),
            measureCode: selectedItem.measureCode,
            startDate: formattedStartDate,
            endDate: formattedEndDate,
            location: locationField.text.trim(),
            lore: loreField.text.trim()
        };

        if (isEditMode && currentEvent) {
            eventData.id = currentEvent.id;
        }

        return eventData;
    }

    function validateDate(text) {
        if (!text) return true;
        var parts = text.split('.');
        if (parts.length !== 3) return false;
        var day = parseInt(parts[0]);
        var month = parseInt(parts[1]);
        var year = parseInt(parts[2]);
        if (day < 1 || day > 31) return false;
        if (month < 1 || month > 12) return false;
        if (year < 1900 || year > 2100) return false;
        return true;
    }

    function loadPortfolios() {
        if (portfoliosLoading) return;
        portfoliosLoading = true;
        portfolioStatus = "Загрузка портфолио...";
        mainApi.getPortfolioForEvents(function(response) {
            portfoliosLoading = false;
            if (response.success) {
                eventFormWindow.portfolioList = response.data;
                eventFormWindow.portfoliosLoaded = true;
                updatePortfolioModel();
                portfolioStatus = "Загружено: " + response.data.length + " портфолио";
                if (response.data.length > 0) {
                    if (isEditMode && currentEvent) {
                        fillForm(currentEvent);
                    }
                } else {
                    portfolioStatus = "Нет доступных портфолио";
                }
            } else {
                portfolioStatus = "Ошибка загрузки";
            }
        });
    }

    // Функции для перетаскивания на Android
    function startAndroidDrag(startX, startY) {
        if (!isMobile) return;

        isDragging = true;
        dragStartPoint = Qt.point(startX, startY);
        dragCurrentPoint = Qt.point(startX, startY);
    }

    function updateAndroidDrag(currentX, currentY) {
        if (!isDragging || !isMobile) return;

        dragCurrentPoint = Qt.point(currentX, currentY);
    }

    function endAndroidDrag(endX, endY) {
        if (!isDragging || !isMobile) return;

        isDragging = false;

        // Вычисляем смещение относительно начальной точки
        var deltaX = endX - dragStartPoint.x;
        var deltaY = endY - dragStartPoint.y;

        // Вычисляем новую позицию контейнера
        var newX = windowContainer.x + deltaX;
        var newY = windowContainer.y + deltaY;

        // Проверяем, выходит ли форма за границы экрана
        var needsCorrection = false;

        // Проверка левой границы
        if (newX < 0) {
            newX = 0;
            needsCorrection = true;
        }

        // Проверка правой границы
        if (newX + windowContainer.width > Screen.width) {
            newX = Screen.width - windowContainer.width;
            needsCorrection = true;
        }

        // Проверка верхней границы
        if (newY < 0) {
            newY = 0;
            needsCorrection = true;
        }

        // Проверка нижней границы
        if (newY + windowContainer.height > Screen.height) {
            newY = Screen.height - windowContainer.height;
            needsCorrection = true;
        }

        // Анимация перемещения контейнера с поведением возврата
        if (needsCorrection) {
            // Используем Behavior анимацию для плавного возврата
            returnToBoundsAnimation.xTo = newX;
            returnToBoundsAnimation.yTo = newY;
            returnToBoundsAnimation.start();
        } else {
            // Обычная анимация перемещения
            moveAnimation.xTo = newX;
            moveAnimation.yTo = newY;
            moveAnimation.start();
        }
    }

    // Обычная анимация перемещения
    ParallelAnimation {
        id: moveAnimation
        property real xTo: 0;
        property real yTo: 0;

        NumberAnimation {
            target: windowContainer;
            property: "x";
            to: moveAnimation.xTo;
            duration: 300;
            easing.type: Easing.OutCubic;
        }

        NumberAnimation {
            target: windowContainer;
            property: "y";
            to: moveAnimation.yTo;
            duration: 300;
            easing.type: Easing.OutCubic;
        }
    }

    // Анимация возврата к границам с поведением
    ParallelAnimation {
        id: returnToBoundsAnimation
        property real xTo: 0;
        property real yTo: 0;

        NumberAnimation {
            target: windowContainer;
            property: "x";
            to: returnToBoundsAnimation.xTo;
            duration: 500;
            easing.type: Easing.OutBack;
        }

        NumberAnimation {
            target: windowContainer;
            property: "y";
            to: returnToBoundsAnimation.yTo;
            duration: 500;
            easing.type: Easing.OutBack;
        }
    }

    // Анимация корректировки позиции при смене ориентации
    ParallelAnimation {
        id: orientationAdjustAnimation
        property real xTo: 0;
        property real yTo: 0;

        NumberAnimation {
            target: windowContainer;
            property: "x";
            to: orientationAdjustAnimation.xTo;
            duration: 400;
            easing.type: Easing.OutCubic;
        }

        NumberAnimation {
            target: windowContainer;
            property: "y";
            to: orientationAdjustAnimation.yTo;
            duration: 400;
            easing.type: Easing.OutCubic;
        }
    }

    onPortfolioListChanged: {
        updatePortfolioModel();
    }

    Rectangle {
        id: windowContainer;
        width: realwidth;
        height: realheight;
        radius: 16;
        color: "transparent";
        clip: true;

        Rectangle {
            anchors.fill: parent;
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#6a11cb"; }
                GradientStop { position: 1.0; color: "#2575fc"; }
            }
            radius: 15;
        }

        Common.PolygonBackground {
            anchors.fill: parent;
        }

        Common.DialogTitleBar {
            id: titleBar;
            anchors {
                top: parent.top;
                left: parent.left;
                right: parent.right;
                margins: 8;
            }
            height: 28;
            title: isEditMode ? "Редактирование события" : "Добавление события";
            window: eventFormWindow;
            isMobile: eventFormWindow.isMobile;
            onClose: {
                cancelled();
                closeWindow();
            }
            onAndroidDragStarted: function(startX, startY) {
                eventFormWindow.startAndroidDrag(startX, startY);
            }
            onAndroidDragUpdated: function(currentX, currentY) {
                eventFormWindow.updateAndroidDrag(currentX, currentY);
            }
            onAndroidDragEnded: function(endX, endY) {
                eventFormWindow.endAndroidDrag(endX, endY);
            }
        }

        Rectangle {
            id: whiteForm;
            anchors {
                top: titleBar.bottom;
                bottom: parent.bottom;
                left: parent.left;
                right: parent.right;
                topMargin: 20;
                leftMargin: 10;
                rightMargin: 10;
                bottomMargin: 10;
            }
            color: "#ffffff";
            opacity: 0.925;
            radius: 12;

            ColumnLayout {
                anchors.fill: parent;
                anchors.margins: 15;
                spacing: 12;

                ScrollView {
                    Layout.fillWidth: true;
                    Layout.fillHeight: true;
                    clip: true;
                    ScrollBar.horizontal: null;

                    Column {
                        width: parent.width;
                        spacing: 15;

                        Column {
                            width: parent.width;
                            spacing: 8;

                            Label {
                                text: "Портфолио студента:";
                                font.bold: true;
                                font.pixelSize: 14;
                                color: "#2c3e50";
                            }

                            ComboBox {
                                id: portfolioComboBox;
                                width: parent.width;
                                height: 45;
                                enabled: !isSaving && portfolioDisplayModel.count > 0;
                                font.pixelSize: 14;

                                background: Rectangle {
                                    radius: 8;
                                    color: "#ffffff";
                                    border.color: portfolioComboBox.enabled ? "#e0e0e0" : "#f0f0f0";
                                    border.width: 1;
                                }

                                model: portfolioDisplayModel;
                                textRole: "displayText";
                            }

                            Label {
                                visible: portfolioDisplayModel.count === 0;
                                text: portfoliosLoading ? "Загрузка портфолио..." : "Нет доступных портфолио";
                                color: portfoliosLoading ? "#ff9800" : "#e74c3c";
                                font.pixelSize: 12;
                            }

                            Label {
                                visible: portfolioDisplayModel.count > 0;
                                text: "Доступно портфолио: " + portfolioDisplayModel.count;
                                color: "#27ae60";
                                font.pixelSize: 12;
                            }
                        }

                        Column {
                            width: parent.width;
                            spacing: 8;

                            Label {
                                text: "Тип мероприятия:";
                                font.bold: true;
                                font.pixelSize: 14;
                                color: "#2c3e50";
                            }

                            TextField {
                                id: eventTypeField;
                                width: parent.width;
                                height: 45;
                                placeholderText: "Введите тип мероприятия";
                                font.pixelSize: 14;
                            }
                        }

                        Column {
                            width: parent.width;
                            spacing: 8;

                            Label {
                                text: "Название мероприятия:";
                                font.bold: true;
                                font.pixelSize: 14;
                                color: "#2c3e50";
                            }

                            TextField {
                                id: categoryField;
                                width: parent.width;
                                height: 45;
                                placeholderText: "Введите полное название мероприятия";
                                font.pixelSize: 14;
                            }
                        }

                        Column {
                            width: parent.width;
                            spacing: 8;

                            Label {
                                text: "Даты проведения:";
                                font.bold: true;
                                font.pixelSize: 14;
                                color: "#2c3e50";
                            }

                            Grid {
                                width: parent.width;
                                columns: 2;
                                spacing: 10;

                                Column {
                                    width: parent.width / 2 - 5;
                                    spacing: 4;

                                    Label {
                                        text: "Начало:";
                                        font.pixelSize: 12;
                                        color: "#2c3e50";
                                    }

                                    TextField {
                                        id: startDateField;
                                        width: parent.width;
                                        height: 40;
                                        placeholderText: "ДД.ММ.ГГГГ";
                                        font.pixelSize: 14;
                                        validator: RegularExpressionValidator {
                                            regularExpression: /^[\d\.]*$/;
                                        }
                                    }
                                }

                                Column {
                                    width: parent.width / 2 - 5;
                                    spacing: 4;

                                    Label {
                                        text: "Окончание:";
                                        font.pixelSize: 12;
                                        color: "#2c3e50";
                                    }

                                    TextField {
                                        id: endDateField;
                                        width: parent.width;
                                        height: 40;
                                        placeholderText: "ДД.ММ.ГГГГ";
                                        font.pixelSize: 14;
                                        validator: RegularExpressionValidator {
                                            regularExpression: /^[\d\.]*$/;
                                        }
                                    }
                                }
                            }
                        }

                        Column {
                            width: parent.width;
                            spacing: 8;

                            Label {
                                text: "Местоположение:";
                                font.bold: true;
                                font.pixelSize: 14;
                                color: "#2c3e50";
                            }

                            TextField {
                                id: locationField;
                                width: parent.width;
                                height: 45;
                                placeholderText: "Введите местоположение";
                                font.pixelSize: 14;
                            }
                        }

                        Column {
                            width: parent.width;
                            spacing: 8;

                            Label {
                                text: "Описание события:";
                                font.bold: true;
                                font.pixelSize: 14;
                                color: "#2c3e50";
                            }

                            TextArea {
                                id: loreField;
                                width: parent.width;
                                height: 100;
                                placeholderText: "Введите описание события...";
                                wrapMode: TextArea.Wrap;
                                font.pixelSize: 14;
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter;
                    spacing: 20;

                    Button {
                        id: saveButton;
                        text: isSaving ? "Сохранение..." : "Сохранить";
                        implicitWidth: 120;
                        implicitHeight: 45;
                        enabled: !isSaving && portfolioComboBox.currentIndex >= 0 && portfolioDisplayModel.count > 0 &&
                                eventTypeField.text.trim() !== "" && categoryField.text.trim() !== "" &&
                                startDateField.text.trim() !== "" && validateDate(startDateField.text) &&
                                endDateField.text.trim() !== "" && validateDate(endDateField.text);
                        font.pixelSize: 14;
                        font.bold: true;

                        background: Rectangle {
                            radius: 22;
                            color: saveButton.enabled ? "#27ae60" : "#95a5a6";
                            border.color: saveButton.enabled ? "#219a52" : "transparent";
                            border.width: 2;
                        }

                        contentItem: Item {
                            anchors.fill: parent;

                            Row {
                                anchors.centerIn: parent;
                                spacing: 8;

                                Image {
                                    source: isSaving ? "qrc:/icons/loading.png" : "qrc:/icons/save.png";
                                    width: 16;
                                    height: 16;
                                    anchors.verticalCenter: parent.verticalCenter;
                                }

                                Text {
                                    text: saveButton.text;
                                    color: "white";
                                    font: saveButton.font;
                                    anchors.verticalCenter: parent.verticalCenter;
                                }
                            }
                        }

                        onClicked: {
                            if (portfolioComboBox.currentIndex < 0) return;
                            if (eventTypeField.text.trim() === "") return;
                            if (categoryField.text.trim() === "") return;
                            if (startDateField.text.trim() === "" || endDateField.text.trim() === "") return;
                            if (!validateDate(startDateField.text) || !validateDate(endDateField.text)) return;

                            isSaving = true;
                            var eventData = getEventData();
                            if (eventData) {
                                saved(eventData);
                            } else {
                                isSaving = false;
                            }
                        }
                    }

                    Button {
                        id: cancelButton;
                        text: "Отмена";
                        implicitWidth: 120;
                        implicitHeight: 45;
                        enabled: !isSaving;
                        font.pixelSize: 14;
                        font.bold: true;

                        background: Rectangle {
                            radius: 22;
                            color: "#e74c3c";
                            border.color: "#c0392b";
                            border.width: 2;
                        }

                        contentItem: Item {
                            anchors.fill: parent;

                            Row {
                                anchors.centerIn: parent;
                                spacing: 8;

                                Image {
                                    source: "qrc:/icons/cross.png";
                                    width: 16;
                                    height: 16;
                                    anchors.verticalCenter: parent.verticalCenter;
                                }

                                Text {
                                    text: cancelButton.text;
                                    color: "white";
                                    font: cancelButton.font;
                                    anchors.verticalCenter: parent.verticalCenter;
                                }
                            }
                        }

                        onClicked: {
                            cancelled();
                            closeWindow();
                        }
                    }
                }
            }
        }

        Common.BottomBlur {
            id: bottomBlur;
            anchors {
                left: parent.left;
                right: parent.right;
                bottom: parent.bottom;
            }
            blurHeight: androidBottomMargin;
            blurOpacity: 0.8;
            z: 2;
            isMobile: isMobile;
        }
    }
}
