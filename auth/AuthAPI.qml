import QtQml 2.15

QtObject {
    id: authApi

    property string remoteApiBaseUrl: "https://deltablast.fun"
    property int remotePort: 5000

    function attemptLogin(useLocalServer, serverAddress, login, password, callbacks) {
        if (!isFormValid(login, password)) {
            callbacks.onInvalidForm();
            return;
        }

        callbacks.onShowLoading();

        // Прямой запрос без проверки соединения (упрощаем)
        sendLoginData(useLocalServer, serverAddress, login, password, function(result) {
            callbacks.onHideLoading();
            if (result.success) {
                callbacks.onSuccess(result.token);
            } else {
                callbacks.onError(result.message);
            }
        });
    }

    function sendLoginData(useLocalServer, serverAddress, login, password, callback) {
        var xhr = new XMLHttpRequest();
        xhr.timeout = 10000;

        var baseUrl = useLocalServer ? serverAddress : (remoteApiBaseUrl + ":" + remotePort);
        var url = baseUrl + "/login"; // Прямой endpoint

        console.log("Sending login request to:", url);

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                console.log("Response status:", xhr.status);
                console.log("Response text:", xhr.responseText);

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
                            message: response.error || "Ошибка авторизации: " + xhr.status
                        });
                    }
                } catch (e) {
                    console.log("Response parsing error:", e);
                    callback({
                        success: false,
                        message: "Неверный формат ответа сервера"
                    });
                }
            }
        };

        xhr.ontimeout = function() {
            callback({ success: false, message: "Таймаут соединения с сервером." });
        };

        xhr.onerror = function() {
            callback({ success: false, message: "Ошибка соединения с сервером." });
        };

        try {
            xhr.open("POST", url, true);
            xhr.setRequestHeader("Content-Type", "application/json");
            xhr.send(JSON.stringify({
                email: login,
                password: password
            }));
        } catch (error) {
            console.log("Request sending error:", error);
            callback({ success: false, message: "Ошибка отправки данных." });
        }
    }

    function isFormValid(login, password) {
        return login.length > 0 && password.length > 0;
    }
}
