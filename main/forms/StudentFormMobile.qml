import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15
import QtQuick.Controls.Universal
import "../../common" as Common

Window {
    id: studentFormWindow
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

    property var currentStudent: null
    property bool isEditMode: false
    property bool isSaving: false
    property var groups: []

    // Свойства для перетаскивания на Android
    property bool isDragging: false
    property point dragStartPoint: Qt.point(0, 0)
    property point dragCurrentPoint: Qt.point(0, 0)

    signal saved(var studentData)
    signal cancelled()
    signal saveCompleted(bool success, string message)

    // Компонент точки перетаскивания для Android
    Common.DragPoint {
        id: dragPoint
        visible: isMobile && isDragging
        currentPoint: dragCurrentPoint
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

    function formatPhoneNumber(text) {
        var digits = text.replace(/\D/g, '')
        if (digits.startsWith('7') || digits.startsWith('8')) {
            digits = digits.substring(1)
        }
        digits = digits.substring(0, 10)

        if (digits.length === 0) {
            return "+7 "
        } else if (digits.length <= 3) {
            return "+7 (" + digits
        } else if (digits.length <= 6) {
            return "+7 (" + digits.substring(0, 3) + ") " + digits.substring(3)
        } else if (digits.length <= 8) {
            return "+7 (" + digits.substring(0, 3) + ") " + digits.substring(3, 6) + "-" + digits.substring(6)
        } else {
            return "+7 (" + digits.substring(0, 3) + ") " + digits.substring(3, 6) + "-" + digits.substring(6, 8) + "-" + digits.substring(8)
        }
    }

    function normalizePhoneNumber(phone) {
        var digits = phone.replace(/\D/g, '')
        if (digits.length === 0) return ""
        if (digits.startsWith('8')) digits = '7' + digits.substring(1)
        else if (!digits.startsWith('7')) digits = '7' + digits
        digits = digits.substring(0, 11)
        if (digits === '7') return ""
        return digits
    }

    function openForAdd() {
        currentStudent = null
        isEditMode = false
        isSaving = false
        clearForm()

        // Центрируем содержимое при открытии
        windowContainer.x = (Screen.width - realwidth) / 2
        windowContainer.y = (Screen.height - realheight) / 2

        studentFormWindow.show()
    }

    function openForEdit(studentData) {
        currentStudent = studentData
        isEditMode = true
        isSaving = false
        fillForm(studentData)

        // Центрируем содержимое при открытии
        windowContainer.x = (Screen.width - realwidth) / 2
        windowContainer.y = (Screen.height - realheight) / 2

        studentFormWindow.show()
    }

    function closeWindow() {
        studentFormWindow.close()
    }

    function clearForm() {
        lastNameField.text = ""
        firstNameField.text = ""
        middleNameField.text = ""
        emailField.text = ""
        phoneField.text = ""
        passportSeriesField.text = ""
        passportNumberField.text = ""
        groupComboBox.currentIndex = -1
    }

    function fillForm(studentData) {
        lastNameField.text = studentData.lastName || studentData.last_name || ""
        firstNameField.text = studentData.firstName || studentData.first_name || ""
        middleNameField.text = studentData.middleName || studentData.middle_name || ""
        emailField.text = studentData.email || ""
        var phoneData = studentData.phoneNumber || studentData.phone_number || ""
        if (phoneData && !phoneData.startsWith("+7")) {
            phoneField.text = formatPhoneNumber(phoneData)
        } else {
            phoneField.text = phoneData
        }
        passportSeriesField.text = studentData.passportSeries || studentData.passport_series || ""
        passportNumberField.text = studentData.passportNumber || studentData.passport_number || ""

        var groupId = studentData.groupId || studentData.group_id
        if (groupId) {
            for (var i = 0; i < groups.length; i++) {
                var group = groups[i]
                var currentGroupId = group.groupId || group.group_id
                if (currentGroupId === groupId) {
                    groupComboBox.currentIndex = i
                    break
                }
            }
        } else {
            groupComboBox.currentIndex = -1
        }
    }

    function getStudentData() {
        var studentCode = ""
        if (isEditMode && currentStudent) {
            studentCode = currentStudent.studentCode || currentStudent.student_code || ""
        }

        var selectedGroup = groupComboBox.currentIndex >= 0 ? groups[groupComboBox.currentIndex] : null
        var groupId = selectedGroup ? (selectedGroup.groupId || selectedGroup.group_id) : 0
        var normalizedPhone = normalizePhoneNumber(phoneField.text)

        return {
            student_code: studentCode,
            last_name: lastNameField.text,
            first_name: firstNameField.text,
            middle_name: middleNameField.text,
            email: emailField.text,
            phone_number: normalizedPhone,
            passport_series: passportSeriesField.text,
            passport_number: passportNumberField.text,
            group_id: groupId
        }
    }

    // Функции для перетаскивания на Android
    function startAndroidDrag(startX, startY) {
        if (!isMobile) return

        isDragging = true
        dragStartPoint = Qt.point(startX, startY)
        dragCurrentPoint = Qt.point(startX, startY)
    }

    function updateAndroidDrag(currentX, currentY) {
        if (!isDragging || !isMobile) return

        dragCurrentPoint = Qt.point(currentX, currentY)
    }

    function endAndroidDrag(endX, endY) {
        if (!isDragging || !isMobile) return

        isDragging = false

        // Вычисляем смещение относительно начальной точки
        var deltaX = endX - dragStartPoint.x
        var deltaY = endY - dragStartPoint.y

        // Вычисляем новую позицию контейнера
        var newX = windowContainer.x + deltaX
        var newY = windowContainer.y + deltaY

        // Проверяем, выходит ли форма за границы экрана
        var needsCorrection = false

        // Проверка левой границы
        if (newX < 0) {
            newX = 0
            needsCorrection = true
        }

        // Проверка правой границы
        if (newX + windowContainer.width > Screen.width) {
            newX = Screen.width - windowContainer.width
            needsCorrection = true
        }

        // Проверка верхней границы
        if (newY < 0) {
            newY = 0
            needsCorrection = true
        }

        // Проверка нижней границы
        if (newY + windowContainer.height > Screen.height) {
            newY = Screen.height - windowContainer.height
            needsCorrection = true
        }

        // Анимация перемещения контейнера с поведением возврата
        if (needsCorrection) {
            // Используем Behavior анимацию для плавного возврата
            returnToBoundsAnimation.xTo = newX
            returnToBoundsAnimation.yTo = newY
            returnToBoundsAnimation.start()
        } else {
            // Обычная анимация перемещения
            moveAnimation.xTo = newX
            moveAnimation.yTo = newY
            moveAnimation.start()
        }
    }

    // Обычная анимация перемещения
    ParallelAnimation {
        id: moveAnimation
        property real xTo: 0
        property real yTo: 0

        NumberAnimation {
            target: windowContainer
            property: "x"
            to: moveAnimation.xTo
            duration: 300
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: windowContainer
            property: "y"
            to: moveAnimation.yTo
            duration: 300
            easing.type: Easing.OutCubic
        }
    }

    // Анимация возврата к границам с поведением
    ParallelAnimation {
        id: returnToBoundsAnimation
        property real xTo: 0
        property real yTo: 0

        NumberAnimation {
            target: windowContainer
            property: "x"
            to: returnToBoundsAnimation.xTo
            duration: 500
            easing.type: Easing.OutBack
        }

        NumberAnimation {
            target: windowContainer
            property: "y"
            to: returnToBoundsAnimation.yTo
            duration: 500
            easing.type: Easing.OutBack
        }
    }

    // Анимация корректировки позиции при смене ориентации
    ParallelAnimation {
        id: orientationAdjustAnimation
        property real xTo: 0
        property real yTo: 0

        NumberAnimation {
            target: windowContainer
            property: "x"
            to: orientationAdjustAnimation.xTo
            duration: 400
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: windowContainer
            property: "y"
            to: orientationAdjustAnimation.yTo
            duration: 400
            easing.type: Easing.OutCubic
        }
    }

    Rectangle {
        id: windowContainer
        width: realwidth
        height: realheight
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
            title: isEditMode ? "Редактирование студента" : "Добавление студента"
            window: studentFormWindow
            isMobile: studentFormWindow.isMobile
            onClose: {
                cancelled()
                closeWindow()
            }
            onAndroidDragStarted: function(startX, startY) {
                studentFormWindow.startAndroidDrag(startX, startY)
            }
            onAndroidDragUpdated: function(currentX, currentY) {
                studentFormWindow.updateAndroidDrag(currentX, currentY)
            }
            onAndroidDragEnded: function(endX, endY) {
                studentFormWindow.endAndroidDrag(endX, endY)
            }
        }

        Rectangle {
            id: whiteForm
            anchors {
                top: titleBar.bottom
                bottom: parent.bottom
                left: parent.left
                right: parent.right
                topMargin: 20
                leftMargin: 10
                rightMargin: 10
                bottomMargin: 10
            }
            color: "#ffffff"
            opacity: 0.925
            radius: 12

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 12

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    ScrollBar.horizontal: null

                    Column {
                        width: parent.width
                        spacing: 15

                        Column {
                            width: parent.width
                            spacing: 8

                            Label {
                                text: "ФИО:"
                                font.bold: true
                                font.pixelSize: 14
                                color: "#2c3e50"
                            }

                            TextField {
                                id: lastNameField
                                width: parent.width
                                height: 45
                                placeholderText: "Фамилия*"
                                font.pixelSize: 14
                            }

                            TextField {
                                id: firstNameField
                                width: parent.width
                                height: 45
                                placeholderText: "Имя*"
                                font.pixelSize: 14
                            }

                            TextField {
                                id: middleNameField
                                width: parent.width
                                height: 45
                                placeholderText: "Отчество"
                                font.pixelSize: 14
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: 8

                            Label {
                                text: "Контакты:"
                                font.bold: true
                                font.pixelSize: 14
                                color: "#2c3e50"
                            }

                            TextField {
                                id: emailField
                                width: parent.width
                                height: 45
                                placeholderText: "Email"
                                font.pixelSize: 14
                            }

                            TextField {
                                id: phoneField
                                width: parent.width
                                height: 45
                                placeholderText: "Номер телефона"
                                font.pixelSize: 14
                                validator: RegularExpressionValidator {
                                    regularExpression: /^[0-9+\(\)\-\s]*$/
                                }

                                onTextChanged: {
                                    if (activeFocus) {
                                        var formatted = formatPhoneNumber(text)
                                        if (formatted !== text) {
                                            text = formatted
                                        }
                                    }
                                }

                                onActiveFocusChanged: {
                                    if (activeFocus && text === "") {
                                        text = "+7 "
                                    }
                                }
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: 8

                            Label {
                                text: "Паспортные данные:"
                                font.bold: true
                                font.pixelSize: 14
                                color: "#2c3e50"
                            }

                            Grid {
                                width: parent.width
                                columns: 2
                                spacing: 10

                                TextField {
                                    id: passportSeriesField
                                    width: parent.width / 2 - 5
                                    height: 45
                                    placeholderText: "Серия паспорта*"
                                    font.pixelSize: 14
                                    validator: IntValidator { bottom: 1000; top: 9999 }
                                }

                                TextField {
                                    id: passportNumberField
                                    width: parent.width / 2 - 5
                                    height: 45
                                    placeholderText: "Номер паспорта*"
                                    font.pixelSize: 14
                                    validator: IntValidator { bottom: 100000; top: 999999 }
                                }
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: 8

                            Label {
                                text: "Группа:"
                                font.bold: true
                                font.pixelSize: 14
                                color: "#2c3e50"
                            }

                            ComboBox {
                                id: groupComboBox
                                width: parent.width
                                height: 45
                                enabled: !isSaving
                                font.pixelSize: 14

                                background: Rectangle {
                                    radius: 8
                                    color: "#ffffff"
                                    border.color: groupComboBox.enabled ? "#e0e0e0" : "#f0f0f0"
                                    border.width: 1
                                }

                                model: studentFormWindow.groups
                                textRole: "name"
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 20

                    Button {
                        id: saveButton
                        text: isSaving ? "Сохранение..." : "Сохранить"
                        implicitWidth: 120
                        implicitHeight: 45
                        enabled: !isSaving && lastNameField.text.trim() !== "" &&
                                firstNameField.text.trim() !== "" &&
                                passportSeriesField.text.trim() !== "" &&
                                passportNumberField.text.trim() !== "" &&
                                groupComboBox.currentIndex >= 0
                        font.pixelSize: 14
                        font.bold: true

                        background: Rectangle {
                            radius: 22
                            color: saveButton.enabled ? "#27ae60" : "#95a5a6"
                            border.color: saveButton.enabled ? "#219a52" : "transparent"
                            border.width: 2
                        }

                        contentItem: Item {
                            anchors.fill: parent

                            Row {
                                anchors.centerIn: parent
                                spacing: 8

                                Image {
                                    source: isSaving ? "qrc:/icons/loading.png" : "qrc:/icons/save.png"
                                    width: 16
                                    height: 16
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: saveButton.text
                                    color: "white"
                                    font: saveButton.font
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }

                        onClicked: {
                            if (lastNameField.text.trim() === "" || firstNameField.text.trim() === "") return
                            if (passportSeriesField.text.trim() === "" || passportNumberField.text.trim() === "") return
                            if (groupComboBox.currentIndex < 0) return
                            isSaving = true
                            saved(getStudentData())
                        }
                    }

                    Button {
                        id: cancelButton
                        text: "Отмена"
                        implicitWidth: 120
                        implicitHeight: 45
                        enabled: !isSaving
                        font.pixelSize: 14
                        font.bold: true

                        background: Rectangle {
                            radius: 22
                            color: "#e74c3c"
                            border.color: "#c0392b"
                            border.width: 2
                        }

                        contentItem: Item {
                            anchors.fill: parent

                            Row {
                                anchors.centerIn: parent
                                spacing: 8

                                Image {
                                    source: "qrc:/icons/cross.png"
                                    width: 16
                                    height: 16
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: cancelButton.text
                                    color: "white"
                                    font: cancelButton.font
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }

                        onClicked: {
                            cancelled()
                            closeWindow()
                        }
                    }
                }
            }
        }

        Common.BottomBlur {
            id: bottomBlur
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            blurHeight: androidBottomMargin
            blurOpacity: 0.8
            z: 2
            isMobile: isMobile
        }
    }
}
