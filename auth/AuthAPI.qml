import QtQuick 2.15
import QtQml 2.15

QtObject {
    id: authAPI

    property string remoteApiBaseUrl: "https://deltablast.fun"
    property int remotePort: 5000

    function sendRegistrationRequest(userData, callback) {
        try {
            var xhr = new XMLHttpRequest();
            xhr.timeout = 10000;

            var baseUrl = settingsManager.useLocalServer ?
                settingsManager.serverAddress :
                (remoteApiBaseUrl + ":" + remotePort);
            var url = baseUrl + "/register";

            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    try {
                        var response = JSON.parse(xhr.responseText);

                        if (xhr.status === 201) {
                            callback({
                                success: true,
                                message: response.message || "Регистрация успешна! Теперь вы можете войти в систему."
                            });
                        } else {
                            callback({
                                success: false,
                                message: response.error || "Ошибка регистрации: " + xhr.status
                            });
                        }
                    } catch (e) {
                        callback({
                            success: false,
                            message: "Неверный формат ответа сервера."
                        });
                    }
                }
            };

            xhr.ontimeout = function() {
                callback({ success: false, message: "Таймаут соединения." });
            };

            xhr.onerror = function() {
                callback({ success: false, message: "Ошибка сети или неверные параметры." });
            };

            xhr.open("POST", url, true);
            xhr.setRequestHeader("Content-Type", "application/json");
            xhr.send(JSON.stringify(userData));

        } catch (error) {
            callback({ success: false, message: "Ошибка отправки: " + error });
        }
    }

    function sendLoginRequest(login, password, callback) {
        try {
            var xhr = new XMLHttpRequest();
            xhr.timeout = 10000;

            var baseUrl = settingsManager.useLocalServer ?
                settingsManager.serverAddress :
                (remoteApiBaseUrl + ":" + remotePort);
            var url = baseUrl + "/login";

            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    try {
                        var response = JSON.parse(xhr.responseText);

                        if (xhr.status === 200) {
                            callback({
                                success: true,
                                message: response.message || "Успешный вход!",
                                token: response.token
                            });
                        } else {
                            callback({
                                success: false,
                                message: response.error || "Ошибка: " + xhr.status
                            });
                        }
                    } catch (e) {
                        callback({
                            success: false,
                            message: "Неверный формат ответа сервера"
                        });
                    }
                }
            };

            xhr.ontimeout = function() {
                callback({ success: false, message: "Таймаут соединения" });
            };

            xhr.onerror = function() {
                callback({ success: false, message: "Ошибка сети" });
            };

            xhr.open("POST", url, true);
            xhr.setRequestHeader("Content-Type", "application/json");
            xhr.send(JSON.stringify({
                email: login,
                password: password
            }));

        } catch (error) {
            callback({ success: false, message: "Ошибка отправки: " + error });
        }
    }
}
