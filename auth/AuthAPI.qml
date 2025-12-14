import QtQuick
import QtQml 2.15

QtObject {
    id: authAPI
    property string authToken: ""
    property string baseUrl: ""
    property bool isAuthenticated: authToken !== "" && baseUrl !== ""
    property bool tokenValid: false
    property string tokenStatus: "не проверен"
    property string remoteApiBaseUrl: "http://deltablast.fun"
    property int remotePort: 5000

    // Кросс-платформенные настройки (Linux & Windows)
    property string windowsLocalUrl: "http://127.0.0.1:5000"
    property string windowsNetworkUrl: "http://localhost:5000"
    property string unixLocalUrl: "http://localhost:5000"

    function initialize(token, url) {
        authToken = token && token.length > 0 ? token : settingsManager.authToken || "";

        // Если URL не передан, определяем его на основе текущих настроек
        if (!url || url.length === 0) {
            if (settingsManager.useLocalServer) {
                baseUrl = settingsManager.serverAddress;
            } else {
                baseUrl = remoteApiBaseUrl + ":" + remotePort;
            }
        } else {
            baseUrl = url;
        }

        // Корректировка для Windows
        if (Qt.platform.os === "windows" && baseUrl.includes("localhost")) {
            baseUrl = baseUrl.replace("localhost", "127.0.0.1");
        }
    }

    function testConnection(callback) {
            var testXhr = new XMLHttpRequest();
            testXhr.timeout = 5000;
            testXhr.onreadystatechange = function() {
                if (testXhr.readyState === XMLHttpRequest.DONE) {
                    var success = testXhr.status === 200 || testXhr.status === 404;
                    if (callback) callback(success);
                }
            };
            testXhr.ontimeout = function() {
                if (callback) callback(false);
            };
            testXhr.onerror = function() {
                if (callback) callback(false);
            };
            try {
                var testUrl = baseUrl + "/status";
                testXhr.open("GET", testUrl, true);

                // Кросс-платформенные заголовки
                testXhr.setRequestHeader("Content-Type", "application/json");
                testXhr.setRequestHeader("Accept", "application/json");
                if (Qt.platform.os === "windows") {
                    testXhr.setRequestHeader("User-Agent", "Mozilla/5.0");
                    testXhr.setRequestHeader("Connection", "keep-alive");
                }
                testXhr.send();
            } catch (error) {
                if (callback) callback(false);
            }
        }

    function validateToken(callback) {
        if (!authToken || authToken.length === 0) {
            if (callback) callback({
                success: false,
                valid: false,
                error: "Токен отсутствует"
            });
            return;
        }

        var requestData = {
            token: authToken
        };

        sendRequest("POST", "/verify-token", requestData, function(response) {

            var isValid = false;
            if (response.success) {
                // Проверяем различные форматы успешного ответа
                if (response.data && response.data.valid === true) {
                    isValid = true;
                } else if (response.data && response.data.userId) {
                    isValid = true;
                } else if (response.valid === true) {
                    isValid = true;
                } else if (response.message && response.message.includes("valid")) {
                    isValid = true;
                }
            }

            if (callback) callback({
                success: response.success,
                valid: isValid,
                message: response.message,
                error: response.error,
                data: response.data
            });
        });
    }

    function sendRegistrationRequest(userData, callback) {

        testConnection(function(success) {
            if (!success && Qt.platform.os === "windows" && baseUrl.includes("localhost")) {
                var altUrl = baseUrl.replace("localhost", "127.0.0.1");
                var originalBaseUrl = baseUrl;
                baseUrl = altUrl;

                sendRequest("POST", "/register", userData, function(response) {
                    if (!response.success && response.error && response.error.includes("Сервер недоступен")) {
                        baseUrl = originalBaseUrl;
                    }
                    if (callback) callback(response);
                });
            } else {
                sendRequest("POST", "/register", userData, callback);
            }
        });
    }

    function sendLoginRequest(login, password, callback) {
        var cleanLogin = login;
        var cleanPassword = password;

        if (cleanLogin.startsWith('"') && cleanLogin.endsWith('"')) {
            cleanLogin = cleanLogin.substring(1, cleanLogin.length - 1);
        }
        if (cleanPassword.startsWith('"') && cleanPassword.endsWith('"')) {
            cleanPassword = cleanPassword.substring(1, cleanPassword.length - 1);
        }
        var loginData = {
            login: cleanLogin,
            password: cleanPassword,
            os: Qt.platform.os
        };

        testConnection(function(success) {
            if (!success && Qt.platform.os === "windows" && baseUrl.includes("localhost")) {
                var altUrl = baseUrl.replace("localhost", "127.0.0.1");
                var originalBaseUrl = baseUrl;
                baseUrl = altUrl;

                sendRequest("POST", "/login", loginData, function(response) {
                    if (!response.success && response.error && response.error.includes("Сервер недоступен")) {
                        baseUrl = originalBaseUrl;
                    }
                    if (callback) callback(response);
                });
            } else {
                sendRequest("POST", "/login", loginData, callback);
            }
        });
    }

    function sendRequest(method, endpoint, data, callback) {
        var xhr = new XMLHttpRequest();

        // КРОССПЛАТФОРМЕННЫЕ ТАЙМАУТЫ
        if (Qt.platform.os === "windows") {
            xhr.timeout = 7500 // 7.5 секунд для windows
        } else if (Qt.platform.os === "android") {
            xhr.timeout = 7500 // 7.5 секунд для android
        } else {
            xhr.timeout = 4500; // 4.5 секунд для других ОС
        }

        var normalizedBaseUrl = baseUrl.endsWith('/') ? baseUrl.slice(0, -1) : baseUrl;
        var normalizedEndpoint = endpoint.startsWith('/') ? endpoint : '/' + endpoint;
        var url = normalizedBaseUrl + normalizedEndpoint;

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {

                if (xhr.status === 200 || xhr.status === 201) {
                    try {
                        var response = JSON.parse(xhr.responseText);

                        if (callback) callback({
                            success: true,
                            data: response,
                            message: response.message,
                            token: response.token,
                            valid: response.valid,
                            status: xhr.status
                        });
                    } catch (e) {
                        console.log("Ошибка парсинга JSON:", error);
                        if (callback) callback({
                            success: false,
                            error: "Ошибка формата ответа: " + error.toString(),
                            status: xhr.status
                        });
                    }
                } else if (xhr.status === 0) {
                    if (callback) callback({
                        success: false,
                        error: "Сервер недоступен",
                        status: xhr.status
                    });
                } else {
                    try {
                        var errorResponse = JSON.parse(xhr.responseText);
                        console.log("Ошибка сервера:", errorResponse.error);
                        if (callback) callback({
                            success: false,
                            error: errorResponse.error || "Ошибка сервера (" + xhr.status + ")",
                            status: xhr.status
                        });
                    } catch (e) {
                        console.log("Ошибка парсинга ошибки:", e);
                        if (callback) callback({
                            success: false,
                            error: "Сетевая ошибка (" + xhr.status + ")",
                            status: xhr.status
                        });
                    }
                }
            }
        };

        xhr.ontimeout = function() {
            if (callback) callback({
                success: false,
                error: "Таймаут соединения",
                status: 408
            });
        };

        xhr.onerror = function() {
            if (callback) callback({
                success: false,
                error: "Ошибка сети, возможно у вас включён VPN, неправильно введенные параметры подключения к серверу, или плохая связь.",
                status: 0
            });
        };

        try {
            xhr.open(method, url, true);
            xhr.setRequestHeader("Content-Type", "application/json");
            xhr.setRequestHeader("Accept", "application/json");
            xhr.setRequestHeader("User-OS", Qt.platform.os);

            if (Qt.platform.os === "windows") {
                xhr.setRequestHeader("User-Agent", "Mozilla/5.0");
                xhr.setRequestHeader("Connection", "keep-alive");
            }

            if (isAuthenticated && endpoint !== "/verify-token" && endpoint !== "/login" && endpoint !== "/register") {
                xhr.setRequestHeader("Authorization", "Bearer " + authToken);
            }

            var requestBody = data ? JSON.stringify(data) : "";

            xhr.send(requestBody);

        } catch (error) {
            if (callback) callback({
                success: false,
                error: "Ошибка отправки запроса: " + error.toString(),
                status: 0
            });
        }
    }
}
