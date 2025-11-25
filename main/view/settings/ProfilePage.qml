import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15

Rectangle {
    id: profilePage
    color: "transparent"
    property bool isMobile: false

    property alias userLogin: profilePage.userLoginInternal
    property alias userFirstName: profilePage.userFirstNameInternal
    property alias userLastName: profilePage.userLastNameInternal
    property alias userMiddleName: profilePage.userMiddleNameInternal
    property alias userEmail: profilePage.userEmailInternal
    property alias userPhoneNumber: profilePage.userPhoneNumberInternal

    property alias editFirstName: profilePage.editFirstNameInternal
    property alias editLastName: profilePage.editLastNameInternal
    property alias editMiddleName: profilePage.editMiddleNameInternal
    property alias editEmail: profilePage.editEmailInternal
    property alias editPhoneNumber: profilePage.editPhoneNumberInternal

    property string userLoginInternal: ""
    property string userFirstNameInternal: ""
    property string userLastNameInternal: ""
    property string userMiddleNameInternal: ""
    property string userEmailInternal: ""
    property string userPhoneNumberInternal: ""

    property string editFirstNameInternal: ""
    property string editLastNameInternal: ""
    property string editMiddleNameInternal: ""
    property string editEmailInternal: ""
    property string editPhoneNumberInternal: ""

    // Функция для инициализации форматированного номера
    function initializeFormattedPhone() {
        if (editPhoneNumberInternal && !editPhoneNumberInternal.startsWith("+7")) {
            editPhoneNumberInternal = formatPhoneNumber(editPhoneNumberInternal)
        }
    }

    // Функция форматирования номера телефона
    function formatPhoneNumber(text) {
        // Удаляем все нецифровые символы
        var digits = text.replace(/\D/g, '')

        // Если номер начинается с 7 или 8, заменяем на +7
        if (digits.startsWith('7') || digits.startsWith('8')) {
            digits = digits.substring(1)
        }

        // Ограничиваем длину до 10 цифр
        digits = digits.substring(0, 10)

        // Форматируем номер в российский формат
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
        // Удаляем все нецифровые символы
        var digits = phone.replace(/\D/g, '')

        // Если номер пустой, возвращаем пустую строку
        if (digits.length === 0) {
            return ""
        }

        // Если номер начинается с 8, заменяем на 7
        if (digits.startsWith('8')) {
            digits = '7' + digits.substring(1)
        }
        // Если номер начинается не с 7 и не с 8, добавляем 7 в начало
        else if (!digits.startsWith('7')) {
            digits = '7' + digits
        }

        // Ограничиваем длину до 11 цифр
        digits = digits.substring(0, 11)

        // Если осталась только одна цифра 7, возвращаем пустую строку
        if (digits === '7') {
            return ""
        }

        return digits
    }

    // Инициализируем форматированный номер при загрузке компонента
    Component.onCompleted: {
        initializeFormattedPhone()
    }

    // Также обновляем при изменении номера извне
    onEditPhoneNumberInternalChanged: {
        if (editPhoneNumberInternal && !editPhoneNumberInternal.startsWith("+7")) {
            editPhoneNumberInternal = formatPhoneNumber(editPhoneNumberInternal)
        }
    }

    signal fieldChanged(string field, string value)
    signal saveRequested()

    ScrollView {
        anchors.fill: parent
        anchors.margins: isMobile ? 5 : 10
        clip: true

        ColumnLayout {
            width: parent.width
            spacing: isMobile ? 8 : 10

            Rectangle {
                Layout.fillWidth: true
                height: isMobile ? 180 : 220
                radius: isMobile ? 12 : 16
                color: "#ffffff"
                border.color: "#e0e0e0"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: isMobile ? 16 : 24
                    spacing: isMobile ? 12 : 16

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: isMobile ? 12 : 16

                        Rectangle {
                            Layout.preferredWidth: isMobile ? 60 : 80
                            Layout.preferredHeight: isMobile ? 60 : 80
                            radius: isMobile ? 30 : 40
                            color: "transparent"
                            border.color: "#3498db"
                            border.width: 2

                            Rectangle {
                                width: isMobile ? 50 : 70
                                height: isMobile ? 50 : 70
                                radius: isMobile ? 25 : 35
                                anchors.centerIn: parent
                                color: "#e3f2fd"

                                AnimatedImage {
                                    anchors.centerIn: parent
                                    width: isMobile ? 40 : 52
                                    height: isMobile ? 40 : 52
                                    clip: true
                                    source: profileMouseArea.containsMouse ? "qrc:/icons/profile.gif" : "qrc:/icons/profile.png"
                                    fillMode: Image.PreserveAspectFit
                                    speed: 0.7
                                    mipmap: true
                                    antialiasing: true
                                    playing: profileMouseArea.containsMouse
                                }

                                MouseArea {
                                    id: profileMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                }
                            }
                        }

                        ColumnLayout {
                            spacing: isMobile ? 4 : 6

                            Text {
                                text: "@" + userLoginInternal || "???"
                                font.pixelSize: isMobile ? 16 : 20
                                font.bold: true
                                color: "#2c3e50"
                            }

                            Text {
                                text: [userLastNameInternal, userFirstNameInternal, userMiddleNameInternal]
                                      .filter(Boolean).join(" ") || "Имя не указано"
                                font.pixelSize: isMobile ? 14 : 16
                                color: "#6c757d"
                            }

                            Rectangle {
                                width: isMobile ? 120 : 140
                                height: isMobile ? 20 : 24
                                radius: isMobile ? 10 : 12
                                color: "#e3f2fd"

                                Row {
                                    anchors.centerIn: parent
                                    spacing: isMobile ? 3 : 4
                                    Image {
                                        source: "qrc:/icons/user.png"
                                        sourceSize: Qt.size(isMobile ? 14 : 18, isMobile ? 14 : 18)
                                        fillMode: Image.PreserveAspectFit
                                        mipmap: true
                                        antialiasing: true
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: "Аккаунт пользователя"
                                        font.pixelSize: isMobile ? 8 : 10
                                        color: "#3498db"
                                        font.bold: true
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        columns: isMobile ? 1 : 2
                        columnSpacing: isMobile ? 0 : 20
                        rowSpacing: isMobile ? 8 : 12

                        RowLayout {
                            spacing: isMobile ? 6 : 8
                            Layout.fillWidth: true

                            Rectangle {
                                width: isMobile ? 32 : 40
                                height: isMobile ? 32 : 40
                                radius: isMobile ? 5 : 6
                                color: emailMouseArea.containsMouse ? "#e3f2fd" : "#f8f9fa"

                                AnimatedImage {
                                    anchors.centerIn: parent
                                    width: isMobile ? 20 : 28
                                    height: isMobile ? 20 : 28
                                    source: emailMouseArea.containsMouse ? "qrc:/icons/email.gif" : "qrc:/icons/email.png"
                                    fillMode: Image.PreserveAspectFit
                                    speed: 0.7
                                    mipmap: true
                                    antialiasing: true
                                    playing: emailMouseArea.containsMouse
                                }

                                MouseArea {
                                    id: emailMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                }
                            }

                            ColumnLayout {
                                spacing: isMobile ? 1 : 2
                                Layout.fillWidth: true

                                Text {
                                    text: "Email"
                                    font.pixelSize: isMobile ? 11 : 12
                                    color: "#6c757d"
                                }

                                Text {
                                    text: userEmailInternal || "Не указан"
                                    font.pixelSize: isMobile ? 12 : 14
                                    color: userEmailInternal ? "#2c3e50" : "#95a5a6"
                                    font.bold: !!userEmailInternal
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                            }
                        }

                        RowLayout {
                            spacing: isMobile ? 6 : 8
                            Layout.fillWidth: true

                            Rectangle {
                                width: isMobile ? 32 : 40
                                height: isMobile ? 32 : 40
                                radius: isMobile ? 5 : 6
                                color: phoneMouseArea.containsMouse ? "#e8f5e8" : "#f8f9fa"

                                AnimatedImage {
                                    anchors.centerIn: parent
                                    width: isMobile ? 20 : 28
                                    height: isMobile ? 20 : 28
                                    source: phoneMouseArea.containsMouse ? "qrc:/icons/phone.gif" : "qrc:/icons/phone.png"
                                    fillMode: Image.PreserveAspectFit
                                    speed: 0.7
                                    mipmap: true
                                    antialiasing: true
                                    playing: phoneMouseArea.containsMouse
                                }

                                MouseArea {
                                    id: phoneMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                }
                            }

                            ColumnLayout {
                                spacing: isMobile ? 1 : 2
                                Layout.fillWidth: true

                                Text {
                                    text: "Телефон"
                                    font.pixelSize: isMobile ? 11 : 12
                                    color: "#6c757d"
                                }

                                Text {
                                    text: formatPhoneNumber(userPhoneNumberInternal) || "Не указан"
                                    font.pixelSize: isMobile ? 12 : 14
                                    color: userPhoneNumberInternal ? "#2c3e50" : "#95a5a6"
                                    font.bold: !!userPhoneNumberInternal
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: isMobile ? 500 : 600
                radius: isMobile ? 12 : 16
                color: "#ffffff"
                border.color: "#e0e0e0"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: isMobile ? 16 : 24
                    spacing: isMobile ? 16 : 20

                    Row {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: isMobile ? 6 : 8

                        Image {
                            source: "qrc:/icons/edit.png"
                            sourceSize: Qt.size(isMobile ? 24 : 32, isMobile ? 24 : 32)
                            fillMode: Image.PreserveAspectFit
                            mipmap: true
                            antialiasing: true
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "Редактирование профиля"
                            font.pixelSize: isMobile ? 16 : 18
                            font.bold: true
                            color: "#2c3e50"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: isMobile ? 12 : 16

                        ColumnLayout {
                            spacing: isMobile ? 4 : 6
                            Layout.fillWidth: true

                            Text {
                                text: "Фамилия"
                                font.pixelSize: isMobile ? 13 : 14
                                color: "#2c3e50"
                                font.bold: true
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: isMobile ? 40 : 44
                                radius: isMobile ? 6 : 8
                                border.color: lastNameField.activeFocus ? "#3498db" : "#e0e0e0"
                                border.width: lastNameField.activeFocus ? 2 : 1
                                color: "#ffffff"

                                TextInput {
                                    id: lastNameField
                                    anchors.fill: parent
                                    anchors.margins: isMobile ? 6 : 8
                                    verticalAlignment: TextInput.AlignVCenter
                                    text: profilePage.editLastNameInternal
                                    font.pixelSize: isMobile ? 13 : 14
                                    selectByMouse: true

                                    onTextChanged: {
                                        profilePage.editLastNameInternal = text
                                        fieldChanged("lastName", text)
                                    }
                                }

                                Text {
                                    anchors.fill: parent
                                    anchors.margins: isMobile ? 6 : 8
                                    verticalAlignment: Text.AlignVCenter
                                    text: "Введите фамилию"
                                    color: "#a0a0a0"
                                    visible: !lastNameField.text && !lastNameField.activeFocus
                                    font.pixelSize: isMobile ? 13 : 14
                                }
                            }
                        }

                        ColumnLayout {
                            spacing: isMobile ? 4 : 6
                            Layout.fillWidth: true

                            Text {
                                text: "Имя"
                                font.pixelSize: isMobile ? 13 : 14
                                color: "#2c3e50"
                                font.bold: true
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: isMobile ? 40 : 44
                                radius: isMobile ? 6 : 8
                                border.color: firstNameField.activeFocus ? "#3498db" : "#e0e0e0"
                                border.width: firstNameField.activeFocus ? 2 : 1
                                color: "#ffffff"

                                TextInput {
                                    id: firstNameField
                                    anchors.fill: parent
                                    anchors.margins: isMobile ? 6 : 8
                                    verticalAlignment: TextInput.AlignVCenter
                                    text: profilePage.editFirstNameInternal
                                    font.pixelSize: isMobile ? 13 : 14
                                    selectByMouse: true

                                    onTextChanged: {
                                        profilePage.editFirstNameInternal = text
                                        fieldChanged("firstName", text)
                                    }
                                }

                                Text {
                                    anchors.fill: parent
                                    anchors.margins: isMobile ? 6 : 8
                                    verticalAlignment: Text.AlignVCenter
                                    text: "Введите имя"
                                    color: "#a0a0a0"
                                    visible: !firstNameField.text && !firstNameField.activeFocus
                                    font.pixelSize: isMobile ? 13 : 14
                                }
                            }
                        }

                        ColumnLayout {
                            spacing: isMobile ? 4 : 6
                            Layout.fillWidth: true

                            Text {
                                text: "Отчество"
                                font.pixelSize: isMobile ? 13 : 14
                                color: "#2c3e50"
                                font.bold: true
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: isMobile ? 40 : 44
                                radius: isMobile ? 6 : 8
                                border.color: middleNameField.activeFocus ? "#3498db" : "#e0e0e0"
                                border.width: middleNameField.activeFocus ? 2 : 1
                                color: "#ffffff"

                                TextInput {
                                    id: middleNameField
                                    anchors.fill: parent
                                    anchors.margins: isMobile ? 6 : 8
                                    verticalAlignment: TextInput.AlignVCenter
                                    text: profilePage.editMiddleNameInternal
                                    font.pixelSize: isMobile ? 13 : 14
                                    selectByMouse: true

                                    onTextChanged: {
                                        profilePage.editMiddleNameInternal = text
                                        fieldChanged("middleName", text)
                                    }
                                }

                                Text {
                                    anchors.fill: parent
                                    anchors.margins: isMobile ? 6 : 8
                                    verticalAlignment: Text.AlignVCenter
                                    text: "Введите отчество"
                                    color: "#a0a0a0"
                                    visible: !middleNameField.text && !middleNameField.activeFocus
                                    font.pixelSize: isMobile ? 13 : 14
                                }
                            }
                        }

                        ColumnLayout {
                            spacing: isMobile ? 4 : 6
                            Layout.fillWidth: true

                            Text {
                                text: "Email"
                                font.pixelSize: isMobile ? 13 : 14
                                color: "#2c3e50"
                                font.bold: true
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: isMobile ? 40 : 44
                                radius: isMobile ? 6 : 8
                                border.color: emailField.activeFocus ? "#3498db" : "#e0e0e0"
                                border.width: emailField.activeFocus ? 2 : 1
                                color: "#ffffff"

                                TextInput {
                                    id: emailField
                                    anchors.fill: parent
                                    anchors.margins: isMobile ? 6 : 8
                                    verticalAlignment: TextInput.AlignVCenter
                                    text: profilePage.editEmailInternal
                                    font.pixelSize: isMobile ? 13 : 14
                                    selectByMouse: true

                                    onTextChanged: {
                                        profilePage.editEmailInternal = text
                                        fieldChanged("email", text)
                                    }
                                }

                                Text {
                                    anchors.fill: parent
                                    anchors.margins: isMobile ? 6 : 8
                                    verticalAlignment: Text.AlignVCenter
                                    text: "Введите email"
                                    color: "#a0a0a0"
                                    visible: !emailField.text && !emailField.activeFocus
                                    font.pixelSize: isMobile ? 13 : 14
                                }
                            }
                        }

                        ColumnLayout {
                            spacing: isMobile ? 4 : 6
                            Layout.fillWidth: true

                            Text {
                                text: "Телефон"
                                font.pixelSize: isMobile ? 13 : 14
                                color: "#2c3e50"
                                font.bold: true
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: isMobile ? 40 : 44
                                radius: isMobile ? 6 : 8
                                border.color: phoneField.activeFocus ? "#3498db" : "#e0e0e0"
                                border.width: phoneField.activeFocus ? 2 : 1
                                color: "#ffffff"

                                TextInput {
                                    id: phoneField
                                    anchors.fill: parent
                                    anchors.margins: isMobile ? 6 : 8
                                    verticalAlignment: TextInput.AlignVCenter
                                    text: profilePage.editPhoneNumberInternal
                                    font.pixelSize: isMobile ? 13 : 14
                                    selectByMouse: true

                                    // Валидатор для ввода только цифр
                                    validator: RegularExpressionValidator {
                                        regularExpression: /^[0-9+\(\)\-\s]*$/
                                    }

                                    // Обработчик изменения текста для форматирования
                                    onTextChanged: {
                                        if (activeFocus) {
                                            var cursorPosition = cursorPosition
                                            var formatted = formatPhoneNumber(text)
                                            if (formatted !== text) {
                                                text = formatted
                                                cursorPosition = Math.min(cursorPosition, formatted.length)
                                                cursorPosition = formatted.length
                                            }
                                        }
                                        profilePage.editPhoneNumberInternal = text
                                        fieldChanged("phoneNumber", text)
                                    }

                                    // Обработчик ввода текста для фильтрации нецифровых символов
                                    onActiveFocusChanged: {
                                        if (activeFocus && text === "") {
                                            text = "+7 "
                                        }
                                    }
                                }

                                Text {
                                    anchors.fill: parent
                                    anchors.margins: isMobile ? 6 : 8
                                    verticalAlignment: Text.AlignVCenter
                                    text: "Номер телефона"
                                    color: "#a0a0a0"
                                    visible: !phoneField.text && !phoneField.activeFocus
                                    font.pixelSize: isMobile ? 13 : 14
                                }
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: isMobile ? 40 : 48

                        Rectangle {
                            width: isMobile ? 180 : 200
                            height: isMobile ? 40 : 48
                            radius: isMobile ? 8 : 10
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: saveMouseArea.containsMouse ? "#2980b9" : "#3498db"

                            Row {
                                anchors.centerIn: parent
                                spacing: isMobile ? 6 : 8

                                Image {
                                    source: "qrc:/icons/save.png"
                                    sourceSize: Qt.size(isMobile ? 24 : 32, isMobile ? 24 : 32)
                                    fillMode: Image.PreserveAspectFit
                                    mipmap: true
                                    antialiasing: true
                                }

                                Text {
                                    text: "Сохранить изменения"
                                    color: "white"
                                    font.pixelSize: isMobile ? 12 : 14
                                    font.bold: true
                                }
                            }

                            MouseArea {
                                id: saveMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    var normalizedPhone = normalizePhoneNumber(phoneField.text)
                                    if (normalizedPhone !== profilePage.editPhoneNumberInternal) {
                                        profilePage.editPhoneNumberInternal = normalizedPhone
                                        fieldChanged("phoneNumber", normalizedPhone)
                                    }
                                    saveRequested()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
