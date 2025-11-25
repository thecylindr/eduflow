import QtQuick
import QtQuick.Layouts 1.15

Rectangle {
    id: registrationForm
    width: parent.width * 0.85
    height: contentLayout.height + 25
    radius: 8
    color: "#f8f8f8"
    opacity: 0.925
    border.color: "#e0e0e0"
    border.width: 1

    signal attemptRegistration()
    signal showLoginForm()

    property bool hasValidFullName: false
    property string fullNameError: ""

    property bool isMobile: Qt.platform.os === "android" || Qt.platform.os === "ios" ||
                           Qt.platform.os === "tvos" || Qt.platform.os === "wasm"

    // Функции форматирования телефона как в других формах
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

    function focusUsername() {
        usernameField.focus = true
        usernameField.cursorPosition = usernameField.text.length
    }

    function focusFullName() {
        fullNameField.focus = true
        fullNameField.cursorPosition = fullNameField.text.length
    }

    function focusEmail() {
        emailField.focus = true
        emailField.cursorPosition = emailField.text.length
    }

    function focusPhone() {
        phoneField.focus = true
        phoneField.cursorPosition = phoneField.text.length
    }

    function focusPassword() {
        passwordField.focus = true
        passwordField.cursorPosition = passwordField.text.length
    }

    function focusConfirmPassword() {
        confirmPasswordField.focus = true
        confirmPasswordField.cursorPosition = confirmPasswordField.text.length
    }

    function submitForm() {
        if (registerButton.enabled) {
            attemptRegistration()
        }
    }

    function navigateToNextField(currentField) {
        if (currentField === usernameField) {
            focusFullName()
        } else if (currentField === fullNameField) {
            focusEmail()
        } else if (currentField === emailField) {
            focusPhone()
        } else if (currentField === phoneField) {
            focusPassword()
        } else if (currentField === passwordField) {
            focusConfirmPassword()
        } else if (currentField === confirmPasswordField) {
            submitForm()
        }
    }

    function navigateToPreviousField(currentField) {
        if (currentField === fullNameField) {
            focusUsername()
        } else if (currentField === emailField) {
            focusFullName()
        } else if (currentField === phoneField) {
            focusEmail()
        } else if (currentField === passwordField) {
            focusPhone()
        } else if (currentField === confirmPasswordField) {
            focusPassword()
        }
    }

    // Обработка Escape для возврата к форме входа
    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Escape) {
            showLoginForm()
            event.accepted = true
        }
    }

    function validateFullName() {
        var text = fullNameField.text.trim()
        var parts = text.split(/\s+/).filter(function(part) { return part.length > 0 })

        if (parts.length === 0) {
            hasValidFullName = false
            fullNameError = ""
            return false
        }

        if (parts.length < 2 || parts.length > 3) {
            hasValidFullName = false
            fullNameError = "Введите Фамилию Имя Отчество (2 или 3 слова)"
            return false
        }

        hasValidFullName = true
        fullNameError = ""
        return true
    }

    function parseFullName() {
        var text = fullNameField.text.trim()
        var parts = text.split(/\s+/).filter(function(part) { return part.length > 0 })

        if (parts.length === 2) {
            return {
                lastName: parts[0],
                firstName: parts[1],
                middleName: ""
            }
        } else if (parts.length === 3) {
            return {
                lastName: parts[0],
                firstName: parts[1],
                middleName: parts[2]
            }
        }

        return {
            lastName: "",
            firstName: "",
            middleName: ""
        }
    }

    function clearForm() {
        usernameField.text = ""
        fullNameField.text = ""
        emailField.text = ""
        phoneField.text = ""
        passwordField.text = ""
        confirmPasswordField.text = ""
        hasValidFullName = false
        fullNameError = ""
    }

    // Добавляем функцию clearAllFields для совместимости
    function clearAllFields() {
        clearForm()
    }

    ColumnLayout {
        id: contentLayout
        width: parent.width - 20
        anchors.centerIn: parent
        spacing: 10

        Row {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 4
            spacing: 8

            AnimatedImage {
                source: "qrc:/icons/edit.png"
                sourceSize: Qt.size(20, 20)
                anchors.verticalCenter: parent.verticalCenter
                playing: true
            }

            Text {
                text: "РЕГИСТРАЦИЯ"
                font.pixelSize: 16
                font.bold: true
                color: "#2c3e50"
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // Поле логина
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3

            Row {
                spacing: 4
                AnimatedImage {
                    source: usernameField.activeFocus ? "qrc:/icons/profile.gif" : "qrc:/icons/user.png"
                    sourceSize: Qt.size(16, 16)
                    anchors.verticalCenter: parent.verticalCenter
                    playing: usernameField.activeFocus
                    speed: 0.7
                }
                Text {
                    text: "Логин"
                    font.pixelSize: isMobile ? 13 : 11
                    color: "#2c3e50"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 32
                radius: 5
                border.color: usernameField.activeFocus ? "#3498db" : "#d0d0d0"
                border.width: usernameField.activeFocus ? 1.5 : 1
                color: "#ffffff"

                TextInput {
                    id: usernameField
                    anchors.fill: parent
                    anchors.margins: 8
                    verticalAlignment: TextInput.AlignVCenter
                    font.pixelSize: isMobile ? 14 : 12
                    color: "#000000"
                    selectByMouse: true

                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            registrationForm.navigateToNextField(usernameField)
                            event.accepted = true
                        } else if (event.key === Qt.Key_Down) {
                            registrationForm.focusFullName()
                            event.accepted = true
                        } else if (event.key === Qt.Key_Up) {
                            registrationForm.focusUsername()
                            event.accepted = true
                        } else if (event.key === Qt.Key_Escape) {
                            // Передача события родителю
                            event.accepted = false
                        }
                    }
                }

                Text {
                    anchors.fill: parent
                    anchors.margins: 8
                    verticalAlignment: Text.AlignVCenter
                    text: "Введите логин"
                    color: "#a0a0a0"
                    visible: !usernameField.text && !usernameField.activeFocus
                    font.pixelSize: isMobile ? 14 : 12
                }
            }
        }

        // Объединенное поле ФИО
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3

            Row {
                spacing: 4
                AnimatedImage {
                    source: fullNameField.activeFocus ? "qrc:/icons/profile.gif" : "qrc:/icons/profile.png"
                    sourceSize: Qt.size(16, 16)
                    anchors.verticalCenter: parent.verticalCenter
                    playing: fullNameField.activeFocus
                    speed: 0.7
                }
                Text {
                    text: "Фамилия Имя Отчество"
                    font.pixelSize: isMobile ? 13 : 11
                    color: "#2c3e50"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 32
                radius: 5
                border.color: fullNameField.activeFocus ?
                    (hasValidFullName ? "#3498db" : "#e74c3c") : "#d0d0d0"
                border.width: fullNameField.activeFocus ? 1.5 : 1
                color: "#ffffff"

                TextInput {
                    id: fullNameField
                    anchors.fill: parent
                    anchors.margins: 8
                    verticalAlignment: TextInput.AlignVCenter
                    font.pixelSize: isMobile ? 14 : 12
                    color: "#000000"
                    selectByMouse: true

                    onTextChanged: validateFullName()
                    onEditingFinished: validateFullName()

                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            registrationForm.navigateToNextField(fullNameField)
                            event.accepted = true
                        } else if (event.key === Qt.Key_Down) {
                            registrationForm.focusEmail()
                            event.accepted = true
                        } else if (event.key === Qt.Key_Up) {
                            registrationForm.focusUsername()
                            event.accepted = true
                        } else if (event.key === Qt.Key_Escape) {
                            // Передача события родителю
                            event.accepted = false
                        }
                    }
                }

                Text {
                    anchors.fill: parent
                    anchors.margins: 8
                    verticalAlignment: Text.AlignVCenter
                    text: "Фамилия Имя Отчество"
                    color: "#a0a0a0"
                    visible: !fullNameField.text && !fullNameField.activeFocus
                    font.pixelSize: isMobile ? 14 : 12
                }
            }

            // Сообщение об ошибке ФИО
            Text {
                id: fullNameErrorText
                text: fullNameError
                font.pixelSize: 10
                color: "#e74c3c"
                visible: fullNameError !== "" && fullNameField.text
                Layout.fillWidth: true
                wrapMode: Text.Wrap
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3

            Row {
                spacing: 4
                AnimatedImage {
                    source: emailField.activeFocus ? "qrc:/icons/email.gif" : "qrc:/icons/email.png"
                    sourceSize: Qt.size(16, 16)
                    anchors.verticalCenter: parent.verticalCenter
                    playing: emailField.activeFocus
                    speed: 0.7
                }
                Text {
                    text: "E-mail"
                    font.pixelSize: isMobile ? 13 : 11
                    color: "#2c3e50"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 32
                radius: 5
                border.color: emailField.activeFocus ? "#3498db" : "#d0d0d0"
                border.width: emailField.activeFocus ? 1.5 : 1
                color: "#ffffff"

                TextInput {
                    id: emailField
                    anchors.fill: parent
                    anchors.margins: 8
                    verticalAlignment: TextInput.AlignVCenter
                    font.pixelSize: isMobile ? 14 : 12
                    color: "#000000"
                    selectByMouse: true

                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            registrationForm.navigateToNextField(emailField)
                            event.accepted = true
                        } else if (event.key === Qt.Key_Down) {
                            registrationForm.focusPhone()
                            event.accepted = true
                        } else if (event.key === Qt.Key_Up) {
                            registrationForm.focusFullName()
                            event.accepted = true
                        } else if (event.key === Qt.Key_Escape) {
                            // Передача события родителю
                            event.accepted = false
                        }
                    }
                }

                Text {
                    anchors.fill: parent
                    anchors.margins: 8
                    verticalAlignment: Text.AlignVCenter
                    text: "Введите e-mail"
                    color: "#a0a0a0"
                    visible: !emailField.text && !emailField.activeFocus
                    font.pixelSize: isMobile ? 14 : 12
                }
            }
        }

        // Поле телефона с форматированием
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3

            Row {
                spacing: 4
                AnimatedImage {
                    source: phoneField.activeFocus ? "qrc:/icons/phone.gif" : "qrc:/icons/phone.png"
                    sourceSize: Qt.size(16, 16)
                    anchors.verticalCenter: parent.verticalCenter
                    playing: phoneField.activeFocus
                    speed: 0.7
                }
                Text {
                    text: "Телефон (необязательно)"
                    font.pixelSize: isMobile ? 13 : 11
                    color: "#2c3e50"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 32
                radius: 5
                border.color: phoneField.activeFocus ? "#3498db" : "#d0d0d0"
                border.width: phoneField.activeFocus ? 1.5 : 1
                color: "#ffffff"

                TextInput {
                    id: phoneField
                    anchors.fill: parent
                    anchors.margins: 8
                    verticalAlignment: TextInput.AlignVCenter
                    text: ""
                    font.pixelSize: isMobile ? 14 : 12
                    color: "#000000"
                    selectByMouse: true

                    // Валидатор для ввода только цифр
                    validator: RegularExpressionValidator {
                        regularExpression: /^[0-9+\(\)\-\s]*$/
                    }

                    // Обработчик изменения текста для форматирования
                    onTextChanged: {
                        if (activeFocus) {
                            var cursorPosition = phoneField.cursorPosition
                            var formatted = formatPhoneNumber(text)
                            if (formatted !== text) {
                                phoneField.text = formatted
                                phoneField.cursorPosition = Math.min(cursorPosition, formatted.length)
                                phoneField.cursorPosition = formatted.length
                            }
                        }
                    }

                    // Обработчик ввода текста для фильтрации нецифровых символов
                    onActiveFocusChanged: {
                        if (activeFocus && text === "") {
                            phoneField.text = "+7 "
                        }
                    }

                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            registrationForm.navigateToNextField(phoneField)
                            event.accepted = true
                        } else if (event.key === Qt.Key_Down) {
                            registrationForm.focusPassword()
                            event.accepted = true
                        } else if (event.key === Qt.Key_Up) {
                            registrationForm.focusEmail()
                            event.accepted = true
                        } else if (event.key === Qt.Key_Escape) {
                            // Передача события родителю
                            event.accepted = false
                        }
                    }
                }

                Text {
                    anchors.fill: parent
                    anchors.margins: 8
                    verticalAlignment: Text.AlignVCenter
                    text: "Введите номер телефона"
                    color: "#a0a0a0"
                    visible: !phoneField.text && !phoneField.activeFocus
                    font.pixelSize: isMobile ? 14 : 12
                }
            }
        }

        // Поле пароля с кнопкой показа пароля
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3

            Row {
                spacing: 4
                AnimatedImage {
                    source: passwordField.activeFocus ? "qrc:/icons/security.gif" : "qrc:/icons/security.png"
                    sourceSize: Qt.size(16, 16)
                    anchors.verticalCenter: parent.verticalCenter
                    playing: passwordField.activeFocus
                    speed: 0.7
                }
                Text {
                    text: "Пароль"
                    font.pixelSize: isMobile ? 13 : 11
                    color: "#2c3e50"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Rectangle {
                    Layout.fillWidth: true
                    height: 32
                    radius: 5
                    border.color: passwordField.activeFocus ? "#3498db" : "#d0d0d0"
                    border.width: passwordField.activeFocus ? 1.5 : 1
                    color: "#ffffff"

                    TextInput {
                        id: passwordField
                        anchors.fill: parent
                        anchors.margins: 8
                        verticalAlignment: TextInput.AlignVCenter
                        font.pixelSize: isMobile ? 14 : 12
                        echoMode: showPasswordButton.checked ? TextInput.Normal : TextInput.Password
                        color: "#000000"
                        selectByMouse: true

                        Keys.onPressed: (event) => {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                registrationForm.navigateToNextField(passwordField)
                                event.accepted = true
                            } else if (event.key === Qt.Key_Down) {
                                registrationForm.focusConfirmPassword()
                                event.accepted = true
                            } else if (event.key === Qt.Key_Up) {
                                registrationForm.focusPhone()
                                event.accepted = true
                            } else if (event.key === Qt.Key_Escape) {
                                // Передача события родителю
                                event.accepted = false
                            }
                        }
                    }

                    Text {
                        anchors.fill: parent
                        anchors.margins: 8
                        verticalAlignment: Text.AlignVCenter
                        text: "Введите пароль"
                        color: "#a0a0a0"
                        visible: !passwordField.text && !passwordField.activeFocus
                        font.pixelSize: isMobile ? 14 : 12
                    }
                }

                // Кнопка показа пароля (только для первого поля)
                Rectangle {
                    id: showPasswordButton
                    width: 26
                    height: 26
                    radius: 5
                    border.color: showPasswordMouseArea.containsPress ? "#3498db" : "#d0d0d0"
                    border.width: 1
                    color: showPasswordButton.checked ? "#3498db" : "transparent"

                    property bool checked: false

                    Image {
                        anchors.centerIn: parent
                        source: showPasswordButton.checked ? "qrc:/icons/eye.png" : "qrc:/icons/eye-off.png"
                        sourceSize: Qt.size(16, 16)
                    }

                    MouseArea {
                        id: showPasswordMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: showPasswordButton.checked = !showPasswordButton.checked
                    }
                }
            }
        }

        // Поле подтверждения пароля (без кнопки показа)
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3

            Row {
                spacing: 4
                AnimatedImage {
                    source: confirmPasswordField.activeFocus ? "qrc:/icons/security.gif" : "qrc:/icons/security.png"
                    sourceSize: Qt.size(16, 16)
                    anchors.verticalCenter: parent.verticalCenter
                    playing: confirmPasswordField.activeFocus
                    speed: 0.7
                }
                Text {
                    text: "Подтвердите пароль"
                    font.pixelSize: isMobile ? 13 : 11
                    color: "#2c3e50"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 32
                radius: 5
                border.color: confirmPasswordField.activeFocus ? "#3498db" : "#d0d0d0"
                border.width: confirmPasswordField.activeFocus ? 1.5 : 1
                color: "#ffffff"

                TextInput {
                    id: confirmPasswordField
                    anchors.fill: parent
                    anchors.margins: 8
                    verticalAlignment: TextInput.AlignVCenter
                    font.pixelSize: isMobile ? 14 : 12
                    echoMode: showPasswordButton.checked ? TextInput.Normal : TextInput.Password
                    color: "#000000"
                    selectByMouse: true

                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            registrationForm.submitForm()
                            event.accepted = true
                        } else if (event.key === Qt.Key_Down) {
                            registrationForm.focusConfirmPassword()
                            event.accepted = true
                        } else if (event.key === Qt.Key_Up) {
                            registrationForm.focusPassword()
                            event.accepted = true
                        } else if (event.key === Qt.Key_Escape) {
                            // Передача события родителю
                            event.accepted = false
                        }
                    }
                }

                Text {
                    anchors.fill: parent
                    anchors.margins: 8
                    verticalAlignment: Text.AlignVCenter
                    text: "Повторите пароль"
                    color: "#a0a0a0"
                    visible: !confirmPasswordField.text && !confirmPasswordField.activeFocus
                    font.pixelSize: isMobile ? 14 : 12
                }
            }
        }

        Rectangle {
            id: registerButton
            Layout.fillWidth: true
            height: 40
            radius: 5
            color: registerButtonMouseArea.pressed ? "#2980b9" : (registerButton.enabled ? "#3498db" : "#d0d0d0")

            property bool enabled: authWindow.isRegistrationFormValid() && !authWindow._isLoading

            Row {
                anchors.centerIn: parent
                spacing: 6
                AnimatedImage {
                    source: authWindow._isLoading ? "qrc:/icons/loading.png" : "qrc:/icons/check.png"
                    sourceSize: Qt.size(16, 16)
                    anchors.verticalCenter: parent.verticalCenter
                    playing: authWindow._isLoading
                }
                Text {
                    text: authWindow._isLoading ? "ЗАГРУЗКА..." : "ЗАРЕГИСТРИРОВАТЬСЯ"
                    font.pixelSize: isMobile ? 14 : 12
                    font.bold: true
                    color: "white"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                id: registerButtonMouseArea
                anchors.fill: parent
                hoverEnabled: true
                enabled: registerButton.enabled
                onClicked: attemptRegistration()
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 10

            Text {
                text: "Уже есть аккаунт? Войти"
                font.pixelSize: isMobile ? 14 : 12
                color: "#3498db"
                opacity: 0.9

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: showLoginForm()
                }
            }
        }
    }

    property alias usernameField: usernameField
    property alias fullNameField: fullNameField
    property alias emailField: emailField
    property alias phoneField: phoneField
    property alias passwordField: passwordField
    property alias confirmPasswordField: confirmPasswordField
    property alias registerButton: registerButton

    Component.onCompleted: {
        focusUsername()
    }
}
