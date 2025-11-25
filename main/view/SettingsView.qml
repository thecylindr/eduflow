import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15
import "settings/"

Rectangle {
    id: settingsView
    color: "#f8f9fa"
    radius: 8
    opacity: 0.925

    property bool isMobile: false
    property var userProfile: ({})
    property var sessions: []
    property bool isLoading: false

    // Server properties
    property string pingStatus: "not_checked"
    property string pingTime: "Не проверен"
    property string serverAddress: mainWindow.mainApi.baseUrl || ""
    property real pingValue: 0

    // User profile properties
    property string userLogin: userProfile.login || ""
    property string userFirstName: userProfile.firstName || ""
    property string userLastName: userProfile.lastName || ""
    property string userMiddleName: userProfile.middleName || ""
    property string userEmail: userProfile.email || ""
    property string userPhoneNumber: userProfile.phoneNumber || ""

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

    // About properties
    property string appVersion: Qt.application.version
    property string organizationName: Qt.application.organization
    property string appName: Qt.application.name
    property string gitflicUrl: "https://gitflic.ru/project/cylindr/eduflow"
    property string serverGitflicUrl: "https://gitflic.ru/project/cylindr/eduflowserver"

    // Navigation state
    property string currentPage: "main"

    function loadProfile() {
        isLoading = true

        mainWindow.mainApi.getProfile(function(response) {
            isLoading = false

            if (response.success && response.data) {

                var profileData = response.data.data || response.data
                userProfile = profileData

                userLogin = profileData.login || ""
                userFirstName = profileData.firstName || ""
                userLastName = profileData.lastName || ""
                userMiddleName = profileData.middleName || ""
                userEmail = profileData.email || ""
                userPhoneNumber = profileData.phoneNumber || ""

                editFirstName = userFirstName
                editLastName = userLastName
                editMiddleName = userMiddleName
                editEmail = userEmail
                editPhoneNumber = userPhoneNumber

                sessions = profileData.sessions || []

            } else {
                mainWindow.showMessage("Ошибка загрузки профиля: " + (response.error || "Неизвестная ошибка"), "error")
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

        isLoading = true
        mainWindow.mainApi.updateProfile(profileData, function(response) {
            isLoading = false
            if (response.success) {
                mainWindow.showMessage("Профиль успешно обновлен!", "success")
                loadProfile()
            } else {
                mainWindow.showMessage("Ошибка обновления профиля: " + (response.error || "Неизвестная ошибка"), "error")
            }
        })
    }

    function changePassword() {
        if (newPassword !== confirmPassword) {
            mainWindow.showMessage("Пароли не совпадают", "error")
            return
        }

        if (newPassword.length < 6) {
            mainWindow.showMessage("Пароль должен быть не менее 6 символов", "error")
            return
        }

        if (!currentPassword) {
            mainWindow.showMessage("Введите текущий пароль", "error")
            return
        }

        isLoading = true
        mainWindow.mainApi.changePassword(
            currentPassword,
            newPassword,
            function(response) {
                isLoading = false
                if (response.success) {
                    mainWindow.showMessage("Пароль успешно изменен", "success")
                    currentPassword = ""
                    newPassword = ""
                    confirmPassword = ""
                } else {
                    mainWindow.showMessage("Ошибка смены пароля: " + (response.error || "Неизвестная ошибка"), "error")
                }
            }
        )
    }

    function pingServer() {
        pingStatus = "checking"
        pingTime = "Проверка..."
        pingValue = 0

        var startTime = new Date().getTime()

        if (mainWindow && mainWindow.mainApi) {
            mainWindow.mainApi.sendRequest("GET", "/status", null, function(response) {
                var endTime = new Date().getTime()
                var pingTimeMs = endTime - startTime

                if (response.success) {
                    pingStatus = "success"
                    pingTime = pingTimeMs + " мс"
                    pingValue = pingTimeMs
                } else {
                    pingStatus = "error"
                    pingTime = "Ошибка соединения"
                    pingValue = 0
                }
            })
        } else {
            pingStatus = "error"
            pingTime = "API не доступен"
            pingValue = 0
        }
    }

    function revokeSession(token) {
        mainWindow.mainApi.revokeSession(token, function(response) {
            console.log("  Ответ отзыва сессии:", JSON.stringify(response))
            if (response.success) {
                mainWindow.showMessage("Сессия успешно отозвана", "success")
                loadProfile()
            } else {
                mainWindow.showMessage("Ошибка отзыва сессии: " + (response.error || "Неизвестная ошибка"), "error")
            }
        })
    }

    function logout() {
        mainWindow.mainApi.clearAuth()
        mainWindow.visible = false

        if (typeof mainWindow.showAuthWindow === "function") {
            mainWindow.showAuthWindow()
        }
    }

    Component.onCompleted: {
        loadProfile()
    }

    ColumnLayout {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: isMobile ? 4 : 8

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: isMobile ? 5 : 10
            Layout.rightMargin: isMobile ? 5 : 10
            Layout.topMargin: isMobile ? 5 : 10
            spacing: isMobile ? 8 : 15

            // Кнопка назад - видна только не на главной странице
            Rectangle {
                id: backButton
                width: isMobile ? 36 : 40
                height: isMobile ? 36 : 40
                radius: isMobile ? 6 : 8
                color: backMouseArea.containsMouse ? "#f1f3f4" : "transparent"
                visible: currentPage !== "main"

                Text {
                    anchors.centerIn: parent
                    text: "←"
                    font.pixelSize: isMobile ? 16 : 18
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
                spacing: isMobile ? 2 : 4

                Text {
                    text: getPageTitle()
                    font.pixelSize: isMobile ? 16 : 20
                    font.bold: true
                    color: "#2c3e50"
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }

                Text {
                    text: getPageSubtitle()
                    font.pixelSize: isMobile ? 10 : 12
                    color: "#6c757d"
                    visible: currentPage !== "main"
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
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
        anchors.topMargin: isMobile ? 60 : 80
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        SettingsMainPage {
            visible: currentPage === "main"
            anchors.fill: parent
            isMobile: settingsView.isMobile
            onSettingSelected: function(setting) {
                currentPage = setting
            }
            onLogoutRequested: logout()
        }

        ProfilePage {
            id: profilePage
            visible: currentPage === "profile"
            anchors.fill: parent
            isMobile: settingsView.isMobile

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
            isMobile: settingsView.isMobile

            // Используем прямые привязки вместо сигналов
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
            isMobile: settingsView.isMobile
            sessions: settingsView.sessions
            onRevokeSession: function(token) {
                settingsView.revokeSession(token)
            }
        }

        ServerPage {
            visible: currentPage === "server"
            anchors.fill: parent
            isMobile: settingsView.isMobile
            serverAddress: settingsView.serverAddress
            pingStatus: settingsView.pingStatus
            pingTime: settingsView.pingTime
            pingValue: settingsView.pingValue
            onPingRequested: settingsView.pingServer()
        }

        AboutPage {
            visible: currentPage === "about"
            anchors.fill: parent
            isMobile: settingsView.isMobile
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
        radius: isMobile ? 8 : 16

        Rectangle {
            width: isMobile ? 100 : 120
            height: isMobile ? 100 : 120
            radius: isMobile ? 8 : 16
            color: "#ffffff"
            anchors.centerIn: parent

            Column {
                anchors.centerIn: parent
                spacing: isMobile ? 8 : 12

                BusyIndicator {
                    id: busyIndicator
                    width: isMobile ? 32 : 40
                    height: isMobile ? 32 : 40
                    anchors.horizontalCenter: parent.horizontalCenter
                    running: isLoading
                }

                Text {
                    text: "Загрузка..."
                    font.pixelSize: isMobile ? 12 : 14
                    color: "#5f6368"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }

    function getPageTitle() {
        switch(currentPage) {
            case "main": return "Настройки @" + settingsView.userLogin
            case "profile": return "Профиль пользователя"
            case "security": return "Безопасность"
            case "sessions": return "Активные сессии"
            case "server": return "Настройки сервера"
            case "about": return "О программе"
            default: return "Настройки"
        }
    }

    function getPageSubtitle() {
        switch(currentPage) {
            case "profile": return "Управление персональными данными"
            case "security": return "Смена пароля и безопасность"
            case "sessions": return "Управление активными устройствами"
            case "server": return "Статус соединения и диагностика"
            case "about": return "Информация о версии и проекте"
            default: return "Панель управления системой"
        }
    }
}
