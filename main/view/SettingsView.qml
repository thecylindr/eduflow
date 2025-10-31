// SettingsView.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import "./settings" as SettingsComponents

Item {
    id: settingsView

    property var userProfile: ({})
    property var sessions: []
    property bool isLoading: false

    // Свойства для проверки сервера
    property string pingStatus: "not_checked"
    property string pingTime: "Не проверен"
    property string serverAddress: mainWindow.mainApi.baseUrl || "Не указан"

    function loadProfile() {
        isLoading = true;
        mainWindow.mainApi.getProfile(function(response) {
            isLoading = false;
            if (response.success) {
                userProfile = response.data || {};
            } else {
                mainWindow.showMessage("❌ Ошибка загрузки профиля: " + response.error, "error");
            }
        });
    }

    function loadSessions() {
        mainWindow.mainApi.sendRequest("GET", "/sessions", null, function(response) {
            if (response.success) {
                sessions = response.data || [];
            }
        });
    }

    function updateProfile() {
        var profileData = {
            firstName: firstNameField.text,
            lastName: lastNameField.text,
            middleName: middleNameField.text,
            email: emailField.text,
            phoneNumber: phoneField.text
        };

        isLoading = true;
        mainWindow.mainApi.updateProfile(profileData, function(response) {
            isLoading = false;
            if (response.success) {
                mainWindow.showMessage("✅ Профиль успешно обновлен", "success");
                loadProfile();
            } else {
                mainWindow.showMessage("❌ Ошибка обновления профиля: " + response.error, "error");
            }
        });
    }

    function changePassword() {
        if (newPasswordField.text !== confirmPasswordField.text) {
            mainWindow.showMessage("❌ Пароли не совпадают", "error");
            return;
        }

        if (newPasswordField.text.length < 6) {
            mainWindow.showMessage("❌ Пароль должен быть не менее 6 символов", "error");
            return;
        }

        isLoading = true;
        mainWindow.mainApi.changePassword(
            currentPasswordField.text,
            newPasswordField.text,
            function(response) {
                isLoading = false;
                if (response.success) {
                    mainWindow.showMessage("✅ Пароль успешно изменен", "success");
                    currentPasswordField.text = "";
                    newPasswordField.text = "";
                    confirmPasswordField.text = "";
                    loadSessions();
                } else {
                    mainWindow.showMessage("❌ Ошибка смены пароля: " + response.error, "error");
                }
            }
        );
    }

    function pingServer() {
        pingStatus = "checking"
        pingTime = "Проверка..."

        var startTime = new Date().getTime()

        if (mainWindow && mainWindow.mainApi) {
            mainWindow.mainApi.getProfile(function(response) {
                var endTime = new Date().getTime()
                var pingTimeMs = endTime - startTime

                if (response.success) {
                    pingStatus = "success"
                    pingTime = pingTimeMs + " мс"
                } else {
                    pingStatus = "error"
                    pingTime = "Ошибка соединения"
                }
            })
        } else {
            pingStatus = "error"
            pingTime = "API не доступен"
        }
    }

    function revokeSession(sessionId) {
        mainWindow.mainApi.sendRequest("DELETE", "/sessions/" + sessionId, null, function(response) {
            if (response.success) {
                mainWindow.showMessage("✅ Сессия отозвана", "success");
                loadSessions();
            } else {
                mainWindow.showMessage("❌ Ошибка отзыва сессии: " + response.error, "error");
            }
        });
    }

    function logout() {
        mainWindow.mainApi.clearAuth();
        mainWindow.showMessage("✅ Выход выполнен", "success");
        mainWindow.visible = false;
    }

    Component.onCompleted: {
        loadProfile();
        loadSessions();
    }

    // Основной контейнер
    Rectangle {
        anchors.fill: parent
        anchors.margins: 10
        color: "transparent"

        // Заголовок
        Text {
            id: title
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            text: "⚙️ Настройки"
            font.pixelSize: 18
            font.bold: true
            color: "#2c3e50"
        }

        Rectangle {
            id: titleLine
            anchors.top: title.bottom
            anchors.topMargin: 8
            width: parent.width
            height: 1
            color: "#e0e0e0"
        }

        // Панель информации о сервере (уменьшенная высота)
        SettingsComponents.ServerInfoPanel {
            id: serverInfoPanel
            anchors.top: titleLine.bottom
            anchors.topMargin: 15
            serverAddress: settingsView.serverAddress
            pingStatus: settingsView.pingStatus
            pingTime: settingsView.pingTime
            onPingRequested: pingServer()
        }

        // Основной контент - две колонки
        Item {
            id: contentArea
            anchors.top: serverInfoPanel.bottom
            anchors.topMargin: 15
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 50 // Место для кнопки выхода
            width: parent.width

            // Левая колонка - профиль и сессии
            Column {
                id: leftColumn
                width: parent.width / 2 - 10
                height: parent.height
                spacing: 10

                // Панель профиля пользователя
                SettingsComponents.UserProfilePanel {
                    width: parent.width
                    height: 150
                    userProfile: settingsView.userProfile
                }

                // Панель активных сессий
                SettingsComponents.SessionsPanel {
                    width: parent.width
                    height: parent.height - 170
                    sessions: settingsView.sessions
                    onRevokeSession: settingsView.revokeSession(sessionId)
                }
            }

            // Правая колонка - формы редактирования
            Column {
                id: rightColumn
                anchors.left: leftColumn.right
                anchors.leftMargin: 20
                width: parent.width / 2 - 10
                height: parent.height
                spacing: 10

                // Панель редактирования профиля
                SettingsComponents.ProfileEditPanel {
                    width: parent.width
                    height: 260
                    userProfile: settingsView.userProfile
                    onProfileSaved: settingsView.updateProfile()
                }

                // Панель смены пароля
                SettingsComponents.PasswordChangePanel {
                    width: parent.width
                    height: 190 // Немного уменьшена высота
                    onPasswordChangeRequested: settingsView.changePassword()
                }
            }
        }

        // Кнопка выхода - справа после всех панелей
        Rectangle {
            id: logoutButton
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.bottomMargin: 10
            anchors.rightMargin: 10
            width: 140
            height: 40
            radius: 8
            color: logoutMouseArea.containsMouse ? "#e74c3c" : "#c0392b"

            Row {
                anchors.centerIn: parent
                spacing: 8

                Text {
                    text: "🚪"
                    font.pixelSize: 14
                    color: "white"
                }

                Text {
                    text: "Выйти из системы"
                    color: "white"
                    font.pixelSize: 12
                    font.bold: true
                }
            }

            MouseArea {
                id: logoutMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: logout()
            }
        }

        // Индикатор загрузки
        Rectangle {
            anchors.centerIn: parent
            width: 150
            height: 40
            radius: 8
            color: "#fff3cd"
            border.color: "#ffeaa7"
            border.width: 2
            visible: isLoading

            Row {
                anchors.centerIn: parent
                spacing: 10

                Text {
                    text: "⏳"
                    font.pixelSize: 14
                }

                Text {
                    text: "Загрузка..."
                    color: "#856404"
                    font.pixelSize: 12
                    font.bold: true
                }
            }
        }
    }
}
