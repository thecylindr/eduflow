import QtQuick 2.15
import QtQml 2.15

QtObject {
    id: authAPI
    property string authToken: ""
    property string baseUrl: ""
    property bool isAuthenticated: authToken !== "" && baseUrl !== ""
    property bool tokenValid: false
    property string tokenStatus: "не проверен"
    property string remoteApiBaseUrl: "https://deltablast.fun"
    property int remotePort: 5000

    // Кросс-платформенные настройки
    property string windowsLocalUrl: "http://127.0.0.1:5000"
    property string windowsNetworkUrl: "http://localhost:5000"
    property string unixLocalUrl: "http://localhost:5000"

    function initialize(token, url) {
        authToken = token && token.length > 0 ? token : settingsManager.authToken || "";

        // ОСОБАЯ ЛОГИКА ДЛЯ WINDOWS
        if (Qt.platform.os === "windows") {
            console.log("🖥️ Обнаружена Windows, применяем специальные настройки...");
            if (url && url.length > 0) {
                baseUrl = url;
            } else {
                if (settingsManager.useLocalServer) {
                    // НА WINDOWS ВСЕГДА ИСПОЛЬЗУЕМ 127.0.0.1 ВМЕСТО LOCALHOST
                    var serverAddress = settingsManager.serverAddress;
                    if (serverAddress.includes("localhost")) {
                        baseUrl = serverAddress.replace("localhost", "127.0.0.1");
                        console.log("🔄 Windows: автоматически заменяем localhost на 127.0.0.1");
                    } else {
                        baseUrl = serverAddress;
                    }
                } else {
                    baseUrl = remoteApiBaseUrl + ":" + remotePort;
                }
            }
        } else {
            // Обычная логика для других ОС
            if (url && url.length > 0) {
                baseUrl = url;
            } else {
                baseUrl = settingsManager.useLocalServer ?
                    settingsManager.serverAddress :
                    (remoteApiBaseUrl + ":" + remotePort);
            }
        }

        console.log("🔧 Инициализация AuthAPI:");
        console.log("   Платформа:", Qt.platform.os);
        console.log("   Base URL:", baseUrl);
        console.log("   Токен длина:", authToken.length);
        console.log("   Локальный сервер:", settingsManager.useLocalServer);
    }

    function testConnection(callback) {
            var testXhr = new XMLHttpRequest();
            testXhr.timeout = 5000;
            testXhr.onreadystatechange = function() {
                if (testXhr.readyState === XMLHttpRequest.DONE) {
                    var success = testXhr.status === 200 || testXhr.status === 404;
                    // 404 тоже считается успехом, так как сервер отвечает
                    console.log("🔗 Тест соединения с", baseUrl, ":", success ? "УСПЕХ" : "НЕУДАЧА");
                    if (callback) callback(success);
                }
            };
            testXhr.ontimeout = function() {
                console.log("⏰ Таймаут теста соединения с", baseUrl);
                if (callback) callback(false);
            };
            testXhr.onerror = function() {
                console.log("❌ Ошибка теста соединения с", baseUrl);
                if (callback) callback(false);
            };
            try {
                var testUrl = baseUrl + "/api/status";
                console.log("🔍 Тестируем соединение с:", testUrl);
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
                console.log("💥 Ошибка теста соединения:", error);
                if (callback) callback(false);
            }
        }

    function validateToken(callback) {
        if (!authToken || authToken.length === 0) {
            console.log("🔐 Токен пустой, пропускаем проверку");
            if (callback) callback({
                success: false,
                valid: false,
                error: "Токен отсутствует"
            });
            return;
        }

        console.log("🔐 Начинаем проверку токена, длина:", authToken.length);

        var requestData = {
            token: authToken
        };

        sendRequest("POST", "/verify-token", requestData, function(response) {
            console.log("🔐 Ответ verify-token:", JSON.stringify(response));

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

            console.log("🔐 Токен валиден:", isValid);

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
        console.log("👤 Регистрация пользователя:", JSON.stringify(userData));

        testConnection(function(success) {
            if (!success && Qt.platform.os === "windows" && baseUrl.includes("localhost")) {
                var altUrl = baseUrl.replace("localhost", "127.0.0.1");
                console.log("🔄 Localhost не работает, пробуем:", altUrl);
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
        // ОЧИСТКА ЛОГИНА И ПАРОЛЯ ОТ ЛИШНИХ КАВЫЧЕК
        var cleanLogin = login;
        var cleanPassword = password;

        if (cleanLogin.startsWith('"') && cleanLogin.endsWith('"')) {
            cleanLogin = cleanLogin.substring(1, cleanLogin.length - 1);
        }
        if (cleanPassword.startsWith('"') && cleanPassword.endsWith('"')) {
            cleanPassword = cleanPassword.substring(1, cleanPassword.length - 1);
        }

        console.log("🔐 Очищенный логин:", cleanLogin);
        console.log("🔐 Очищенный пароль:", cleanPassword.substring(0, 5) + "...");

        var loginData = {
            login: cleanLogin,
            password: cleanPassword,
            os: Qt.platform.os
        };

        console.log("🔐 Данные для входа:", JSON.stringify(loginData));

        testConnection(function(success) {
            if (!success && Qt.platform.os === "windows" && baseUrl.includes("localhost")) {
                var altUrl = baseUrl.replace("localhost", "127.0.0.1");
                console.log("🔄 Localhost не работает, пробуем:", altUrl);
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

        if (Qt.platform.os === "windows") {
            xhr.timeout = 15000;
        } else {
            xhr.timeout = 10000;
        }

        var normalizedBaseUrl = baseUrl.endsWith('/') ? baseUrl.slice(0, -1) : baseUrl;
        var normalizedEndpoint = endpoint.startsWith('/') ? endpoint : '/' + endpoint;
        var url = normalizedBaseUrl + normalizedEndpoint;

        console.log("🌐 Отправка запроса:", method, url);

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                console.log("📨 Получен ответ:", xhr.status, "для", url);

                if (xhr.status === 200 || xhr.status === 201) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        console.log("✅ Успешный ответ от", endpoint);

                        if (callback) callback({
                            success: true,
                            data: response,
                            message: response.message,
                            token: response.token,
                            valid: response.valid,
                            status: xhr.status
                        });
                    } catch (e) {
                        console.log("❌ Ошибка парсинга JSON:", e);
                        if (callback) callback({
                            success: false,
                            error: "Ошибка формата ответа: " + e.toString(),
                            status: xhr.status
                        });
                    }
                } else if (xhr.status === 0) {
                    console.log("❌ Сетевая ошибка - сервер недоступен");
                    console.log("   Таймаут:", xhr.timeout);
                    console.log("   Состояние:", xhr.readyState);
                    if (callback) callback({
                        success: false,
                        error: "Сервер недоступен",
                        status: xhr.status
                    });
                } else {
                    try {
                        var errorResponse = JSON.parse(xhr.responseText);
                        console.log("❌ Ошибка сервера:", errorResponse.error);
                        if (callback) callback({
                            success: false,
                            error: errorResponse.error || "Ошибка сервера (" + xhr.status + ")",
                            status: xhr.status
                        });
                    } catch (e) {
                        console.log("❌ Ошибка парсинга ошибки:", e);
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
            console.log("⏰ Таймаут запроса к", url);
            if (callback) callback({
                success: false,
                error: "Таймаут соединения",
                status: 408
            });
        };

        xhr.onerror = function() {
            console.log("❌ Ошибка сети для", url);
            console.log("   Таймаут:", xhr.timeout);
            console.log("   Состояние:", xhr.readyState);
            if (callback) callback({
                success: false,
                error: "Ошибка сети",
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

            // ВАЖНО: НЕ ДОБАВЛЯЕМ Authorization header для verify-token
            if (isAuthenticated && endpoint !== "/verify-token" && endpoint !== "/login" && endpoint !== "/register") {
                xhr.setRequestHeader("Authorization", "Bearer " + authToken);
            }

            var requestBody = data ? JSON.stringify(data) : "";
            console.log("📦 Тело запроса:", requestBody.substring(0, 200) + "...");

            xhr.send(requestBody);

        } catch (error) {
            console.log("💥 Критическая ошибка отправки:", error);
            if (callback) callback({
                success: false,
                error: "Ошибка отправки запроса: " + error.toString(),
                status: 0
            });
        }
    }
}
