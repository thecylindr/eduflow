import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Dialog {
    id: profileDialog
    title: "Настройки профиля"
    modal: true
    standardButtons: Dialog.Save | Dialog.Cancel

    property string currentEmail: ""
    property string currentFirstName: ""
    property string currentLastName: ""
    property string currentPhone: ""

    signal saveProfile(var profileData)

    onOpened: {
        // Загружаем текущие данные профиля
        mainApi.getProfile(function(err, data) {
            if (!err && data) {
                emailField.text = data.email || "";
                firstNameField.text = data.first_name || "";
                lastNameField.text = data.last_name || "";
                phoneField.text = data.phone_number || "";
            }
        });
    }

    ColumnLayout {
        width: 400
        spacing: 15

        TextField {
            id: emailField
            placeholderText: "Email"
            Layout.fillWidth: true
        }

        TextField {
            id: firstNameField
            placeholderText: "Имя"
            Layout.fillWidth: true
        }

        TextField {
            id: lastNameField
            placeholderText: "Фамилия"
            Layout.fillWidth: true
        }

        TextField {
            id: phoneField
            placeholderText: "Телефон"
            Layout.fillWidth: true
        }

        TextField {
            id: currentPasswordField
            placeholderText: "Текущий пароль (для смены)"
            echoMode: TextField.Password
            Layout.fillWidth: true
        }

        TextField {
            id: newPasswordField
            placeholderText: "Новый пароль"
            echoMode: TextField.Password
            Layout.fillWidth: true
        }
    }

    onAccepted: {
        var profileData = {
            email: emailField.text,
            first_name: firstNameField.text,
            last_name: lastNameField.text,
            phone_number: phoneField.text
        };

        if (currentPasswordField.text && newPasswordField.text) {
            profileData.current_password = currentPasswordField.text;
            profileData.new_password = newPasswordField.text;
        }

        saveProfile(profileData);
    }
}
