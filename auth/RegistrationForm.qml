import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: registrationForm
    width: parent.width * 0.85
    height: contentLayout.height + 25
    radius: 8
    color: "#f8f8f8"
    opacity: 0.95
    border.color: "#e0e0e0"
    border.width: 1

    signal attemptRegistration()
    signal showLoginForm()

    property bool hasValidFullName: false
    property string fullNameError: ""

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
        fullNameField.text = ""
        emailField.text = ""
        phoneField.text = ""
        passwordField.text = ""
        confirmPasswordField.text = ""
        hasValidFullName = false
        fullNameError = ""
    }

    ColumnLayout {
        id: contentLayout
        width: parent.width - 20
        anchors.centerIn: parent
        spacing: 10

        Text {
            text: "📝 РЕГИСТРАЦИЯ"
            font.pixelSize: 16
            font.bold: true
            color: "#2c3e50"
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 4
        }

        // Объединенное поле ФИО
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3

            Text {
                text: "👤 Фамилия Имя Отчество"
                font.pixelSize: 11
                color: "#2c3e50"
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
                    font.pixelSize: 12
                    color: "#000000"
                    selectByMouse: true

                    onTextChanged: validateFullName()
                    onEditingFinished: validateFullName()
                }

                Text {
                    anchors.fill: parent
                    anchors.margins: 8
                    verticalAlignment: Text.AlignVCenter
                    text: "Фамилия Имя Отчество"
                    color: "#a0a0a0"
                    visible: !fullNameField.text && !fullNameField.activeFocus
                    font.pixelSize: 12
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

            Text {
                text: "📧 E-mail"
                font.pixelSize: 11
                color: "#2c3e50"
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
                    font.pixelSize: 12
                    color: "#000000"
                    selectByMouse: true
                }

                Text {
                    anchors.fill: parent
                    anchors.margins: 8
                    verticalAlignment: Text.AlignVCenter
                    text: "Введите e-mail"
                    color: "#a0a0a0"
                    visible: !emailField.text && !emailField.activeFocus
                    font.pixelSize: 12
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3

            Text {
                text: "📞 Телефон (необязательно)"
                font.pixelSize: 11
                color: "#2c3e50"
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
                    font.pixelSize: 12
                    color: "#000000"
                    selectByMouse: true
                }

                Text {
                    anchors.fill: parent
                    anchors.margins: 8
                    verticalAlignment: Text.AlignVCenter
                    text: "Введите номер телефона"
                    color: "#a0a0a0"
                    visible: !phoneField.text && !phoneField.activeFocus
                    font.pixelSize: 12
                }
            }
        }

        // Поле пароля с кнопкой показа пароля
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3

            Text {
                text: "🔒 Пароль"
                font.pixelSize: 11
                color: "#2c3e50"
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
                        font.pixelSize: 12
                        echoMode: showPasswordButton.checked ? TextInput.Normal : TextInput.Password
                        color: "#000000"
                        selectByMouse: true
                    }

                    Text {
                        anchors.fill: parent
                        anchors.margins: 8
                        verticalAlignment: Text.AlignVCenter
                        text: "Введите пароль"
                        color: "#a0a0a0"
                        visible: !passwordField.text && !passwordField.activeFocus
                        font.pixelSize: 12
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

                    Text {
                        anchors.centerIn: parent
                        text: "👁"
                        font.pixelSize: 14
                        color: showPasswordButton.checked ? "white" : "#7f8c8d"
                    }

                    Rectangle {
                        visible: !showPasswordButton.checked
                        anchors.centerIn: parent
                        width: 16
                        height: 2
                        rotation: 45
                        color: "#7f8c8d"
                    }

                    MouseArea {
                        id: showPasswordMouseArea
                        anchors.fill: parent
                        onClicked: showPasswordButton.checked = !showPasswordButton.checked
                    }
                }
            }
        }

        // Поле подтверждения пароля (без кнопки показа)
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3

            Text {
                text: "🔒 Подтвердите пароль"
                font.pixelSize: 11
                color: "#2c3e50"
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
                    font.pixelSize: 12
                    echoMode: showPasswordButton.checked ? TextInput.Normal : TextInput.Password
                    color: "#000000"
                    selectByMouse: true
                }

                Text {
                    anchors.fill: parent
                    anchors.margins: 8
                    verticalAlignment: Text.AlignVCenter
                    text: "Повторите пароль"
                    color: "#a0a0a0"
                    visible: !confirmPasswordField.text && !confirmPasswordField.activeFocus
                    font.pixelSize: 12
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

            Text {
                anchors.centerIn: parent
                text: authWindow._isLoading ? "⏳ ЗАГРУЗКА..." : "🚀 ЗАРЕГИСТРИРОВАТЬСЯ"
                font.pixelSize: 12
                font.bold: true
                color: "white"
            }

            MouseArea {
                id: registerButtonMouseArea
                anchors.fill: parent
                enabled: registerButton.enabled
                onClicked: attemptRegistration()
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 10

            Text {
                text: "Уже есть аккаунт? Войти"
                font.pixelSize: 12
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


    property alias fullNameField: fullNameField
    property alias emailField: emailField
    property alias phoneField: phoneField
    property alias passwordField: passwordField
    property alias confirmPasswordField: confirmPasswordField
    property alias registerButton: registerButton
}
