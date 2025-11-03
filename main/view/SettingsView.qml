import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "settings/"

Rectangle {
    id: settingsView
    color: "#f8f9fa"

    property var userProfile: ({})
    property var sessions: []
    property bool isLoading: false

    // Server properties
    property string pingStatus: "not_checked"
    property string pingTime: "Не проверен"
    property string serverAddress: mainWindow.mainApi.baseUrl || ""

    // User profile properties
    property string userLogin: userProfile.login || "Не указан"
    property string userFirstName: userProfile.firstName || "Не указано"
    property string userLastName: userProfile.lastName || "Не указано"
    property string userMiddleName: userProfile.middleName || "Не указано"
    property string userEmail: userProfile.email || "Не указан"
    property string userPhoneNumber: userProfile.phoneNumber || "Не указан"

    // Edit properties
    property string editFirstName: userFirstName
    property string editLastName: userLastName
    property string editMiddleName: userMiddleName
    property string editEmail: userEmail
    property string editPhoneNumber: userPhoneNumber

    // Password properties
    property string currentPassword: ""
    property string newPassword: ""
    property string confirmPassword: ""

    // About properties - получаем из главного окна
    property string appVersion: Qt.application.version
    property string organizationName: Qt.application.organization
    property string appName: Qt.application.name
    property string gitflicUrl: "https://gitflic.ru/project/cylindr/eduflow"
    property string serverGitflicUrl: "https://gitflic.ru/project/cylindr/eduflowserver"

    // Navigation state
    property string currentPage: "main"

    function loadProfile() {
        console.log("🔄 Загрузка профиля...")
        isLoading = true

        mainWindow.mainApi.getProfile(function(response) {
            isLoading = false
            console.log("📨 Ответ профиля:", JSON.stringify(response))

            if (response.success && response.data) {
                console.log("✅ Данные профиля загружены")

                userProfile = response.data

                editFirstName = userProfile.firstName || ""
                editLastName = userProfile.lastName || ""
                editMiddleName = userProfile.middleName || ""
                editEmail = userProfile.email || ""
                editPhoneNumber = userProfile.phoneNumber || ""

                sessions = userProfile.sessions || []

            } else {
                console.log("❌ Ошибка загрузки профиля:", response.error)
                mainWindow.showMessage("❌ Ошибка загрузки профиля: " + (response.error || "Неизвестная ошибка"), "error")
            }
        })
    }

    function updateProfile() {
        var profileData = {
            firstName: editFirstName,
            lastName: editLastName,
            middleName: editMiddleName,
            email: editEmail,
            phoneNumber: editPhoneNumber
        }

        console.log("📤 Отправка данных профиля:", JSON.stringify(profileData))

        isLoading = true
        mainWindow.mainApi.updateProfile(profileData, function(response) {
            isLoading = false
            if (response.success) {
                mainWindow.showMessage("✅ Профиль успешно обновлен", "success")
                loadProfile()
            } else {
                mainWindow.showMessage("❌ Ошибка обновления профиля: " + (response.error || "Неизвестная ошибка"), "error")
            }
        })
    }

    function changePassword() {
        if (newPassword !== confirmPassword) {
            mainWindow.showMessage("❌ Пароли не совпадают", "error")
            return
        }

        if (newPassword.length < 6) {
            mainWindow.showMessage("❌ Пароль должен быть не менее 6 символов", "error")
            return
        }

        if (!currentPassword) {
            mainWindow.showMessage("❌ Введите текущий пароль", "error")
            return
        }

        isLoading = true
        mainWindow.mainApi.changePassword(
            currentPassword,
            newPassword,
            function(response) {
                isLoading = false
                if (response.success) {
                    mainWindow.showMessage("✅ Пароль успешно изменен", "success")
                    currentPassword = ""
                    newPassword = ""
                    confirmPassword = ""
                } else {
                    mainWindow.showMessage("❌ Ошибка смены пароля: " + (response.error || "Неизвестная ошибка"), "error")
                }
            }
        )
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

    function revokeSession(token) {
        mainWindow.mainApi.revokeSession(token, function(response) {
            if (response.success) {
                mainWindow.showMessage("✅ Сессия отозвана", "success")
                loadProfile()
            } else {
                mainWindow.showMessage("❌ Ошибка отзыва сессии: " + (response.error || "Неизвестная ошибка"), "error")
            }
        })
    }

    function logout() {
        mainWindow.mainApi.clearAuth()
        mainWindow.visible = false
    }

    Component.onCompleted: {
        loadProfile()
    }

    // Заголовок как в TeachersView
    ColumnLayout {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 8

        // Кнопка назад и заголовок
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            Layout.topMargin: 10
            spacing: 15

            // Кнопка назад - видна только не на главной странице
            Rectangle {
                id: backButton
                width: 40
                height: 40
                radius: 8
                color: backMouseArea.containsMouse ? "#f1f3f4" : "transparent"
                visible: currentPage !== "main"

                Text {
                    anchors.centerIn: parent
                    text: "←"
                    font.pixelSize: 18
                    color: "#5f6368"
                    font.bold: true
                }

                MouseArea {
                    id: backMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: currentPage = "main"
                }
            }

            Column {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: getPageTitle()
                    font.pixelSize: 20
                    font.bold: true
                    color: "#2c3e50"
                }

                Text {
                    text: getPageSubtitle()
                    font.pixelSize: 12
                    color: "#6c757d"
                    visible: currentPage !== "main"
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            radius: 16
            opacity: 0.4
            color: "transparent"
        }
    }

    Item {
        anchors.top: parent.top
        anchors.topMargin: 80
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        SettingsMainPage {
            visible: currentPage === "main"
            anchors.fill: parent
            onSettingSelected: function(setting) {
                currentPage = setting
            }
            onLogoutRequested: logout()
        }

        ProfilePage {
            id: profilePage
            visible: currentPage === "profile"
            anchors.fill: parent

            // Используем прямые привязки вместо alias
            userLogin: settingsView.userLogin
            userFirstName: settingsView.userFirstName
            userLastName: settingsView.userLastName
            userMiddleName: settingsView.userMiddleName
            userEmail: settingsView.userEmail
            userPhoneNumber: settingsView.userPhoneNumber

            editFirstName: settingsView.editFirstName
            editLastName: settingsView.editLastName
            editMiddleName: settingsView.editMiddleName
            editEmail: settingsView.editEmail
            editPhoneNumber: settingsView.editPhoneNumber

            onFieldChanged: function(field, value) {
                console.log("Field changed:", field, value)
                if (field === "firstName") settingsView.editFirstName = value
                else if (field === "lastName") settingsView.editLastName = value
                else if (field === "middleName") settingsView.editMiddleName = value
                else if (field === "email") settingsView.editEmail = value
                else if (field === "phoneNumber") settingsView.editPhoneNumber = value
            }

            onSaveRequested: settingsView.updateProfile()
        }

        SecurityPage {
            id: securityPage
            visible: currentPage === "security"
            anchors.fill: parent
            currentPassword: settingsView.currentPassword
            newPassword: settingsView.newPassword
            confirmPassword: settingsView.confirmPassword

            onCurrentPasswordChanged: settingsView.currentPassword = securityPage.currentPassword
            onNewPasswordChanged: settingsView.newPassword = securityPage.newPassword
            onConfirmPasswordChanged: settingsView.confirmPassword = securityPage.confirmPassword
            onChangePasswordRequested: settingsView.changePassword()
        }

        SessionsPage {
            visible: currentPage === "sessions"
            anchors.fill: parent
            sessions: settingsView.sessions
            onRevokeSession: function(token) {
                settingsView.revokeSession(token)
            }
        }

        ServerPage {
            visible: currentPage === "server"
            anchors.fill: parent
            serverAddress: settingsView.serverAddress
            pingStatus: settingsView.pingStatus
            pingTime: settingsView.pingTime
            onPingRequested: settingsView.pingServer()
        }

        AboutPage {
            visible: currentPage === "about"
            anchors.fill: parent
            appVersion: settingsView.appVersion
            appName: settingsView.appName
            organizationName: settingsView.organizationName
            gitflicUrl: settingsView.gitflicUrl
            serverGitflicUrl: settingsView.serverGitflicUrl
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#ccffffff"
        visible: isLoading
        z: 3
        radius: 16  // Добавлено скругление

        Rectangle {
            width: 120
            height: 120
            radius: 16
            color: "#ffffff"
            anchors.centerIn: parent

            Column {
                anchors.centerIn: parent
                spacing: 12

                BusyIndicator {
                    id: busyIndicator
                    width: 40
                    height: 40
                    anchors.horizontalCenter: parent.horizontalCenter
                    running: isLoading
                }

                Text {
                    text: "Загрузка..."
                    font.pixelSize: 14
                    color: "#5f6368"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }

    function getPageTitle() {
        switch(currentPage) {
            case "main": return "⚙️ Настройки системы"
            case "profile": return "👤 Профиль пользователя"
            case "security": return "🔐 Безопасность и пароли"
            case "sessions": return "📱 Активные сессии"
            case "server": return "🌐 Настройки сервера"
            case "about": return "ℹ️ О программе"
            default: return "⚙️ Настройки"
        }
    }

    function getPageSubtitle() {
        switch(currentPage) {
            case "profile": return "Управление персональными данными"
            case "security": return "Смена пароля и настройки безопасности"
            case "sessions": return "Управление активными устройствами"
            case "server": return "Статус соединения и диагностика"
            case "about": return "Информация о версии и проекте"
            default: return "Панель управления системой"
        }
    }
}
