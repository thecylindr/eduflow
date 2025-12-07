import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15
import QtQuick.Controls.Universal
import "../../common" as Common

Window {
    id: groupFormWindow
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
    property int realheight: Math.min(Screen.height * 0.75, 550)

    // Отступы для Android системных кнопок
    property int androidTopMargin: (Qt.platform.os === "android") ? 16 : 0
    property int androidBottomMargin: (Qt.platform.os === "android" && Screen.primaryOrientation === Qt.PortraitOrientation) ? 28 : 0
    property bool isMobile: Qt.platform.os === "android" || Qt.platform.os === "ios"

    property var currentGroup: null
    property bool isEditMode: false
    property bool isSaving: false
    property var teachers: []

    // Свойства для перетаскивания на Android
    property bool isDragging: false
    property point dragStartPoint: Qt.point(0, 0)
    property point dragCurrentPoint: Qt.point(0, 0)

    signal saved(var groupData)
    signal cancelled()
    signal saveCompleted(bool success, string message)

    // Компонент точки перетаскивания для Android
    Common.DragPoint {
        id: dragPoint
        visible: isMobile && isDragging
        currentPoint: dragCurrentPoint
    }

    ListModel {
        id: teacherDisplayModel
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

    function updateTeacherModel() {
        teacherDisplayModel.clear()
        for (var i = 0; i < teachers.length; i++) {
            var teacher = teachers[i]
            var displayName = formatTeacherName(teacher)
            var teacherId = teacher.teacher_id || teacher.teacherId || teacher.id || 0
            teacherDisplayModel.append({
                displayName: displayName,
                teacherId: teacherId,
                originalIndex: i
            })
        }
        if (isEditMode && currentGroup) {
            restoreSelectedTeacher()
        }
    }

    function formatTeacherName(teacher) {
        var lastName = teacher.last_name || teacher.lastName || ""
        var firstName = teacher.first_name || teacher.firstName || ""
        var middleName = teacher.middle_name || teacher.middleName || ""
        return [lastName, firstName, middleName].filter(Boolean).join(" ").trim()
    }

    function restoreSelectedTeacher() {
        var teacherId = currentGroup.teacher_id || currentGroup.teacherId
        if (teacherId) {
            for (var i = 0; i < teacherDisplayModel.count; i++) {
                if (teacherDisplayModel.get(i).teacherId === teacherId) {
                    teacherComboBox.currentIndex = i
                    break
                }
            }
        }
    }

    function openForAdd() {
        currentGroup = null
        isEditMode = false
        isSaving = false
        clearForm()
        updateTeacherModel()

        // Центрируем содержимое при открытии
        windowContainer.x = (Screen.width - realwidth) / 2
        windowContainer.y = (Screen.height - realheight) / 2

        groupFormWindow.show()
    }

    function openForEdit(groupData) {
        currentGroup = groupData
        isEditMode = true
        isSaving = false
        updateTeacherModel()
        fillForm(groupData)

        // Центрируем содержимое при открытии
        windowContainer.x = (Screen.width - realwidth) / 2
        windowContainer.y = (Screen.height - realheight) / 2

        groupFormWindow.show()
    }

    function closeWindow() {
        groupFormWindow.close()
    }

    function clearForm() {
        nameField.text = ""
        teacherComboBox.currentIndex = -1
    }

    function fillForm(groupData) {
        nameField.text = groupData.name || ""
    }

    function getGroupData() {
        var groupId = 0
        if (isEditMode && currentGroup) {
            groupId = currentGroup.groupId || currentGroup.group_id || 0
        }

        var teacherId = 0
        if (teacherComboBox.currentIndex >= 0) {
            var selectedItem = teacherDisplayModel.get(teacherComboBox.currentIndex)
            teacherId = selectedItem.teacherId
        }

        return {
            group_id: groupId,
            name: nameField.text,
            teacher_id: teacherId,
            student_count: 0
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

    onTeachersChanged: {
        updateTeacherModel()
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
            title: isEditMode ? "Редактирование группы" : "Добавление группы"
            window: groupFormWindow
            isMobile: groupFormWindow.isMobile
            onClose: {
                cancelled()
                closeWindow()
            }
            onAndroidDragStarted: function(startX, startY) {
                groupFormWindow.startAndroidDrag(startX, startY)
            }
            onAndroidDragUpdated: function(currentX, currentY) {
                groupFormWindow.updateAndroidDrag(currentX, currentY)
            }
            onAndroidDragEnded: function(endX, endY) {
                groupFormWindow.endAndroidDrag(endX, endY)
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
                                text: "Название группы:"
                                font.bold: true
                                font.pixelSize: 14
                                color: "#2c3e50"
                            }

                            TextField {
                                id: nameField
                                width: parent.width
                                height: 45
                                placeholderText: "Введите название группы*"
                                font.pixelSize: 14
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: 8

                            Label {
                                text: "Преподаватель (куратор):"
                                font.bold: true
                                font.pixelSize: 14
                                color: "#2c3e50"
                            }

                            ComboBox {
                                id: teacherComboBox
                                width: parent.width
                                height: 45
                                enabled: !isSaving && teacherDisplayModel.count > 0
                                font.pixelSize: 14

                                background: Rectangle {
                                    radius: 8
                                    color: "#ffffff"
                                    border.color: teacherComboBox.enabled ? "#e0e0e0" : "#f0f0f0"
                                    border.width: 1
                                }

                                model: teacherDisplayModel
                                textRole: "displayName"
                            }

                            Label {
                                visible: teacherDisplayModel.count === 0
                                text: teachers.length === 0 ? "Нет доступных преподавателей" : "Загрузка преподавателей..."
                                color: "#e74c3c"
                                font.pixelSize: 12
                            }

                            Label {
                                visible: teacherDisplayModel.count > 0
                                text: "Доступно преподавателей: " + teacherDisplayModel.count
                                color: "#27ae60"
                                font.pixelSize: 12
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 80
                            color: "#e8f4fd"
                            radius: 10
                            border.color: "#3498db"
                            border.width: 1

                            Row {
                                anchors.centerIn: parent
                                spacing: 12
                                width: parent.width - 20

                                Image {
                                    source: "qrc:/icons/info.png"
                                    width: 24
                                    height: 24
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Column {
                                    width: parent.width - 36
                                    spacing: 4
                                    anchors.verticalCenter: parent.verticalCenter

                                    Label {
                                        text: "Информация о группе"
                                        font.bold: true
                                        font.pixelSize: 12
                                        color: "#2c3e50"
                                    }

                                    Label {
                                        width: parent.width
                                        text: "Количество студентов автоматически рассчитывается при добавлении студентов в группу"
                                        font.pixelSize: 11
                                        color: "#34495e"
                                        wrapMode: Text.WordWrap
                                    }
                                }
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
                        enabled: !isSaving && nameField.text.trim() !== "" && teacherComboBox.currentIndex >= 0
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
                            if (nameField.text.trim() === "") return
                            if (teacherComboBox.currentIndex < 0) return
                            isSaving = true
                            saved(getGroupData())
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
