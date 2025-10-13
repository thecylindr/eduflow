// main/main.qml (корневой файл для использования)
import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    width: 900
    height: 600
    visible: true
    title: "EduFlow"

    property string authToken: "your_auth_token_here" // Токен должен передаваться из окна авторизации

    Main {
        id: mainApp
        anchors.fill: parent
        authToken: authToken

        onLogoutRequested: {
            console.log("Выход из системы...")
            // Здесь логика выхода - очистка токена и возврат к окну авторизации
            Qt.quit() // Временное решение - закрытие приложения
        }
    }

    Component.onCompleted: {
        console.log("Запуск главного окна с токеном:", authToken)
        // Проверка валидности токена при запуске
        if (!authToken) {
            console.error("Токен авторизации не предоставлен!")
        }
    }
}
