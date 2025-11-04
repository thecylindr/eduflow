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

        if (isAuthenticated) {
            validateToken(function(response) {
                tokenValid = response.success;
                tokenStatus = response.success ? "валиден" : "невалиден";
                console.log("🔐 Статус токена:", tokenStatus);
            });
        }
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
            console.log("🔐 Ответ verify-token:", JSON.stringify(response));

            var isValid = false;
            if (response.success) {
                // Проверяем различные форматы успешного ответа
                if (response.data && response.data.success === true) {
                    isValid = true;
                } else if (response.data && response.data.userId) {
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
        console.log("👤 Регистрация пользователя:", JSON.stringify(userData));

        // Сначала тестируем соединение
        testConnection(function(success) {
            if (!success && Qt.platform.os === "windows" && baseUrl.includes("localhost")) {
                // Пробуем альтернативный адрес на Windows
                var altUrl = baseUrl.replace("localhost", "127.0.0.1");
                console.log("🔄 Localhost не работает, пробуем:", altUrl);
                var originalBaseUrl = baseUrl;
                baseUrl = altUrl;

                sendRequest("POST", "/register", userData, function(response) {
                    if (!response.success && response.error && response.error.includes("Сервер недоступен")) {
                        // Возвращаем оригинальный URL для сообщения об ошибке
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
        var loginData = {
            email: login,
            password: password
        };
        console.log("🔐 Логин пользователя:", login);

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

        // КРОССПЛАТФОРМЕННЫЕ ТАЙМАУТЫ
        if (Qt.platform.os === "windows") {
            xhr.timeout = 30000; // 30 секунд для Windows
        } else {
            xhr.timeout = 15000; // 15 секунд для других ОС
        }

        var normalizedBaseUrl = baseUrl.endsWith('/') ? baseUrl.slice(0, -1) : baseUrl;
        var normalizedEndpoint = endpoint.startsWith('/') ? endpoint : '/' + endpoint;
        var url = normalizedBaseUrl + normalizedEndpoint;

        console.log("🌐 Отправка запроса:", method, url);
        console.log("   Платформа:", Qt.platform.os);

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
                    var errorMsg = "Сервер недоступен. ";

                    if (Qt.platform.os === "windows") {
                        errorMsg += "На Windows попробуйте:\n";
                        errorMsg += "• Проверить что сервер запущен\n";
                        errorMsg += "• Попробовать адрес 127.0.0.1 вместо localhost\n";
                        errorMsg += "• Проверить настройки firewall";
                    } else {
                        errorMsg += "Проверьте:\n- Запущен ли сервер\n- Настройки firewall";
                    }

                    if (callback) callback({
                        success: false,
                        error: errorMsg,
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
            var timeoutMsg = "Таймаут соединения. ";

            if (Qt.platform.os === "windows") {
                timeoutMsg += "На Windows это может быть связано с:\n";
                timeoutMsg += "• Медленным соединением\n";
                timeoutMsg += "• Проблемами с localhost\n";
                timeoutMsg += "• Блокировкой firewall";
            } else {
                timeoutMsg += "Сервер не отвечает.";
            }

            if (callback) callback({
                success: false,
                error: timeoutMsg,
                status: 408
            });
        };

        xhr.onerror = function() {
            console.log("❌ Ошибка сети для", url);
            var networkErrorMsg = "Ошибка сети. ";

            if (Qt.platform.os === "windows") {
                networkErrorMsg += "На Windows проверьте:\n";
                networkErrorMsg += "• Запущен ли сервер\n";
                networkErrorMsg += "• Настройки сети\n";
                networkErrorMsg += "• Попробуйте 127.0.0.1 вместо localhost";
            } else {
                networkErrorMsg += "Проверьте подключение к интернету.";
            }

            if (callback) callback({
                success: false,
                error: networkErrorMsg,
                status: 0
            });
        };

        try {
            xhr.open(method, url, true);
            xhr.setRequestHeader("Content-Type", "application/json");
            xhr.setRequestHeader("Accept", "application/json");

            // КРОССПЛАТФОРМЕННЫЕ ЗАГОЛОВКИ
            if (Qt.platform.os === "windows") {
                xhr.setRequestHeader("User-Agent", "Mozilla/5.0");
                xhr.setRequestHeader("Connection", "keep-alive");
                xhr.setRequestHeader("Cache-Control", "no-cache");
            }

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
