import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15
import QtQuick.Controls.Universal
import "../../common" as Common

Window {
    id: groupViewWindow
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
    property var groupStudents: []
    property bool isLoading: false

    // Свойства для перетаскивания на Android
    property bool isDragging: false
    property point dragStartPoint: Qt.point(0, 0)
    property point dragCurrentPoint: Qt.point(0, 0)

    signal closed()

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

    function openForGroup(groupData) {
        currentGroup = groupData
        isLoading = true
        groupStudents = []

        // Центрируем содержимое при открытии
        windowContainer.x = (Screen.width - realwidth) / 2
        windowContainer.y = (Screen.height - realheight) / 2

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
                        ScrollBar.horizontal: null

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
                    implicitWidth: 120
                    implicitHeight: 45
                    font.pixelSize: 14
                    font.bold: true

                    background: Rectangle {
                        radius: 22
                        color: "#3498db"
                        border.color: "#2980b9"
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
                                text: "Закрыть"
                                color: "white"
                                font: parent.parent.font
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    onClicked: closeWindow()
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
