import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15
import QtQuick.Controls.Universal
import "../../common" as Common

Window {
    id: portfolioFormWindow
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

    // Отступы для Android системных кнопок - как в Main.qml
    property int androidTopMargin: (Qt.platform.os === "android") ? 16 : 0
    property int androidBottomMargin: (Qt.platform.os === "android" && Screen.primaryOrientation === Qt.PortraitOrientation) ? 28 : 0
    property bool isMobile: Qt.platform.os === "android" || Qt.platform.os === "ios"

    property var currentPortfolio: null
    property bool isEditMode: false
    property bool isSaving: false
    property var students: []

    // Свойства для перетаскивания на Android
    property bool isDragging: false
    property point dragStartPoint: Qt.point(0, 0)
    property point dragCurrentPoint: Qt.point(0, 0)

    signal saved(var portfolioData)
    signal cancelled()
    signal saveCompleted(bool success, string message)

    // Компонент точки перетаскивания для Android
    Common.DragPoint {
        id: dragPoint
        visible: isMobile && isDragging
        currentPoint: dragCurrentPoint
    }

    ListModel {
        id: studentDisplayModel
    }

    function updateStudentModel() {
        studentDisplayModel.clear()
        for (var i = 0; i < students.length; i++) {
            var student = students[i]
            var displayName = formatStudentName(student)
            var studentCode = student.studentCode || student.student_code || ""
            studentDisplayModel.append({
                displayName: displayName,
                studentCode: studentCode,
                originalIndex: i
            })
        }
        if (isEditMode && currentPortfolio) {
            restoreSelectedStudent()
        }
    }

    function formatStudentName(student) {
        var lastName = student.lastName || student.last_name || ""
        var firstName = student.firstName || student.first_name || ""
        var middleName = student.middleName || student.middle_name || ""
        var studentCode = student.studentCode || student.student_code || ""
        return [lastName, firstName, middleName].filter(Boolean).join(" ") + " (" + studentCode + ")"
    }

    function restoreSelectedStudent() {
        var studentCode = currentPortfolio.studentCode || currentPortfolio.student_code
        if (studentCode) {
            var numericStudentCode = parseInt(studentCode)
            for (var i = 0; i < studentDisplayModel.count; i++) {
                var currentCode = parseInt(studentDisplayModel.get(i).studentCode || 0)
                if (currentCode === numericStudentCode) {
                    studentComboBox.currentIndex = i
                    break
                }
            }
        }
    }

    function openForAdd() {
        currentPortfolio = null
        isEditMode = false
        isSaving = false
        clearForm()
        updateStudentModel()

        // Центрируем содержимое при открытии
        windowContainer.x = (Screen.width - realwidth) / 2
        windowContainer.y = (Screen.height - realheight) / 2

        portfolioFormWindow.show()
    }

    function openForEdit(portfolioData) {
        currentPortfolio = portfolioData
        isEditMode = true
        isSaving = false
        updateStudentModel()
        fillForm(portfolioData)

        // Центрируем содержимое при открытии
        windowContainer.x = (Screen.width - realwidth) / 2
        windowContainer.y = (Screen.height - realheight) / 2

        portfolioFormWindow.show()
    }

    function closeWindow() {
        portfolioFormWindow.close()
    }

    function clearForm() {
        studentComboBox.currentIndex = -1
        dateField.text = ""
        decreeField.text = ""
    }

    function fillForm(portfolioData) {
        var studentCode = portfolioData.studentCode || portfolioData.student_code
        if (studentCode) {
            var numericStudentCode = parseInt(studentCode)
            for (var i = 0; i < studentDisplayModel.count; i++) {
                var currentCode = parseInt(studentDisplayModel.get(i).studentCode || 0)
                if (currentCode === numericStudentCode) {
                    studentComboBox.currentIndex = i
                    break
                }
            }
        } else {
            studentComboBox.currentIndex = -1
        }

        var serverDate = portfolioData.date || ""
        if (serverDate) {
            var parts = serverDate.split('-')
            if (parts.length === 3) {
                dateField.text = parts[2] + "." + parts[1] + "." + parts[0]
            } else {
                dateField.text = serverDate
            }
        } else {
            dateField.text = ""
        }

        decreeField.text = portfolioData.decree || ""
    }

    function getPortfolioData() {
        var portfolioId = 0
        if (isEditMode && currentPortfolio) {
            portfolioId = currentPortfolio.portfolioId || currentPortfolio.portfolio_id || 0
        }

        var studentCode = 0
        if (studentComboBox.currentIndex >= 0) {
            var selectedItem = studentDisplayModel.get(studentComboBox.currentIndex)
            studentCode = parseInt(selectedItem.studentCode || 0)
        }

        var dateText = dateField.text
        var formattedDate = dateText
        if (dateText) {
            var parts = dateText.split('.')
            if (parts.length === 3) {
                formattedDate = parts[2] + "-" + parts[1] + "-" + parts[0]
            }
        }

        return {
            portfolio_id: portfolioId,
            student_code: studentCode,
            date: formattedDate,
            decree: decreeField.text
        }
    }

    function validateDate(text) {
        if (!text) return true
        var parts = text.split('.')
        if (parts.length !== 3) return false
        var day = parseInt(parts[0])
        var month = parseInt(parts[1])
        var year = parseInt(parts[2])
        if (day < 1 || day > 31) return false
        if (month < 1 || month > 12) return false
        if (year < 1900 || year > 2100) return false
        return true
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

        // Ограничиваем позицию в пределах экрана
        newX = Math.max(0, Math.min(newX, Screen.width - windowContainer.width))
        newY = Math.max(0, Math.min(newY, Screen.height - windowContainer.height))

        // Анимация перемещения контейнера
        moveAnimation.xTo = newX
        moveAnimation.yTo = newY
        moveAnimation.start()
    }

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

    onStudentsChanged: {
        updateStudentModel()
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
            title: isEditMode ? "Редактирование портфолио" : "Добавление портфолио"
            window: portfolioFormWindow
            isMobile: portfolioFormWindow.isMobile
            onClose: {
                cancelled()
                closeWindow()
            }
            onAndroidDragStarted: function(startX, startY) {
                portfolioFormWindow.startAndroidDrag(startX, startY)
            }
            onAndroidDragUpdated: function(currentX, currentY) {
                portfolioFormWindow.updateAndroidDrag(currentX, currentY)
            }
            onAndroidDragEnded: function(endX, endY) {
                portfolioFormWindow.endAndroidDrag(endX, endY)
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
                                text: "Студент:"
                                font.bold: true
                                font.pixelSize: 14
                                color: "#2c3e50"
                            }

                            ComboBox {
                                id: studentComboBox
                                width: parent.width
                                height: 45
                                enabled: !isSaving && studentDisplayModel.count > 0
                                font.pixelSize: 14

                                background: Rectangle {
                                    radius: 8
                                    color: "#ffffff"
                                    border.color: studentComboBox.enabled ? "#e0e0e0" : "#f0f0f0"
                                    border.width: 1
                                }

                                model: studentDisplayModel
                                textRole: "displayName"
                            }

                            Label {
                                text: studentDisplayModel.count === 0 ? "Нет доступных студентов" : ""
                                color: "#e74c3c"
                                font.pixelSize: 12
                                visible: studentDisplayModel.count === 0
                            }

                            Label {
                                visible: studentDisplayModel.count > 0
                                text: "Доступно студентов: " + studentDisplayModel.count
                                color: "#27ae60"
                                font.pixelSize: 12
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: 8

                            Label {
                                text: "Дата:"
                                font.bold: true
                                font.pixelSize: 14
                                color: "#2c3e50"
                            }

                            TextField {
                                id: dateField
                                width: parent.width
                                height: 45
                                placeholderText: "ДД.ММ.ГГГГ"
                                font.pixelSize: 14
                                validator: RegularExpressionValidator {
                                    regularExpression: /^[\d\.]*$/
                                }

                                onTextChanged: {
                                    if (text.length > 10) {
                                        text = text.substring(0, 10)
                                    }
                                }
                            }

                            Label {
                                text: !validateDate(dateField.text) && dateField.text !== "" ?
                                      "Неверный формат даты" : "Формат: ДД.ММ.ГГГГ"
                                color: !validateDate(dateField.text) && dateField.text !== "" ? "#e74c3c" : "#7f8c8d"
                                font.pixelSize: 12
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: 8

                            Label {
                                text: "Приказ:"
                                font.bold: true
                                font.pixelSize: 14
                                color: "#2c3e50"
                            }

                            TextField {
                                id: decreeField
                                width: parent.width
                                height: 45
                                placeholderText: "Введите номер приказа*"
                                font.pixelSize: 14
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
                        enabled: !isSaving && studentComboBox.currentIndex >= 0 &&
                                dateField.text.trim() !== "" && validateDate(dateField.text) &&
                                decreeField.text.trim() !== "" && studentDisplayModel.count > 0
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
                            if (studentComboBox.currentIndex < 0) return
                            if (dateField.text.trim() === "") return
                            if (!validateDate(dateField.text)) return
                            if (decreeField.text.trim() === "") return
                            isSaving = true
                            saved(getPortfolioData())
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
