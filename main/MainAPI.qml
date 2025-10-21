import QtQuick 2.15

QtObject {
    id: mainApi

    property string authToken: ""
    property string baseUrl: ""
    property bool isAuthenticated: authToken !== "" && baseUrl !== ""
    property bool tokenValid: false
    property string tokenStatus: "не проверен"

    property string remoteApiBaseUrl: "http://deltablast.fun"
    property int remotePort: 5000

    function initialize(token, url) {
        if (token && token.length > 0) {
            authToken = token;
            settingsManager.authToken = token;
            console.log("✅ Токен установлен, длина:", authToken.length);
        } else {
            authToken = settingsManager.authToken || "";
            console.log("🔄 Токен взят из настроек, длина:", authToken.length);
        }

        if (url && url.length > 0) {
            baseUrl = url;
        } else {
            baseUrl = settingsManager.useLocalServer ?
                settingsManager.serverAddress :
                (remoteApiBaseUrl + ":" + remotePort);
        }

        console.log("✅ API инициализирован. Токен:", authToken ? "есть" : "нет");
        console.log("   Base URL:", baseUrl);
        console.log("   Токен длина:", authToken.length);

        if (isAuthenticated) {
            validateToken(function(response) {
                tokenValid = response.success;
                tokenStatus = response.success ? "валиден" : "невалиден";
                console.log("🔐 Статус токена:", tokenStatus);

                if (!response.success) {
                    console.log("❌ Токен невалиден, очищаем...");
                    clearAuth();
                }
            });
        }
    }

    function clearAuth() {
        console.log("🧹 Очистка аутентификации...");
        authToken = "";
        baseUrl = "";
        tokenValid = false;
        tokenStatus = "очищен";
        settingsManager.authToken = "";
        console.log("✅ Аутентификация очищена");
    }

    function getTeachers(callback) {
        sendRequest("GET", "/teachers", null, callback);
    }

    function getStudents(callback) {
        sendRequest("GET", "/students", null, callback);
    }

    function getGroups(callback) {
        sendRequest("GET", "/groups", null, callback);
    }

    function getPortfolios(callback) {
        sendRequest("GET", "/portfolio", null, callback);
    }

    function getEvents(callback) {
        sendRequest("GET", "/events", null, callback);
    }

    function getProfile(callback) {
        sendRequest("GET", "/profile", null, callback);
    }

    function validateToken(callback) {
        // Отправляем токен в теле запроса, а не в заголовке
        var requestData = {
            token: authToken
        };

        sendRequest("POST", "/verify-token", requestData, function(response) {
            console.log("🔐 Ответ проверки токена:", response);
            if (callback) callback(response);
        });
    }

    function sendRequest(method, endpoint, data, callback) {
        console.log("🔐 ========== НАЧАЛО ОТПРАВКИ ЗАПРОСА ==========");
        console.log("🔐 ДЕТАЛИ АУТЕНТИФИКАЦИИ:");
        console.log("   isAuthenticated:", isAuthenticated);
        console.log("   authToken:", authToken ? authToken.substring(0, 32) + "..." : "пустой");
        console.log("   authToken длина:", authToken ? authToken.length : 0);
        console.log("   baseUrl:", baseUrl);

        if (!isAuthenticated) {
            console.log("❌ API не аутентифицирован для запроса:", endpoint);
            if (callback) callback({
                success: false,
                error: "API не аутентифицирован",
                status: 401
            });
            return;
        }

        var xhr = new XMLHttpRequest();
        xhr.timeout = 10000;

        // Нормализация URL
        var normalizedBaseUrl = baseUrl.endsWith('/') ? baseUrl.slice(0, -1) : baseUrl;
        var normalizedEndpoint = endpoint.startsWith('/') ? endpoint : '/' + endpoint;
        var url = normalizedBaseUrl + normalizedEndpoint;

        console.log("🌐 Параметры запроса:");
        console.log("   Method:", method);
        console.log("   Endpoint:", endpoint);
        console.log("   Normalized URL:", url);
        console.log("   Токен длина:", authToken.length);
        console.log("   Токен (первые 32 символа):", authToken.substring(0, 32));
        console.log("   Токен (последние 32 символа):", authToken.substring(authToken.length - 32));

        xhr.onreadystatechange = function() {
            console.log("📨 Изменение состояния XHR:", xhr.readyState, "для", endpoint);

            if (xhr.readyState === XMLHttpRequest.DONE) {
                console.log("✅ Запрос завершен:", endpoint, "Статус:", xhr.status);
                console.log("   Полный ответ:", xhr.responseText);

                if (xhr.status === 200 || xhr.status === 201) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        console.log("✅ Успешный ответ от", endpoint);
                        if (callback) callback({
                            success: true,
                            data: response,
                            status: xhr.status
                        });
                    } catch (e) {
                        console.log("❌ Ошибка парсинга JSON:", e);
                        console.log("   Сырой ответ:", xhr.responseText);
                        if (callback) callback({
                            success: false,
                            error: "Ошибка формата ответа",
                            status: xhr.status
                        });
                    }
                } else if (xhr.status === 401) {
                    console.log("❌ Ошибка аутентификации 401 для", endpoint);
                    console.log("   Заголовки ответа:", xhr.getAllResponseHeaders());
                    if (callback) callback({
                        success: false,
                        error: "Ошибка доступа (401)",
                        status: xhr.status
                    });
                } else {
                    try {
                        var errorResponse = JSON.parse(xhr.responseText);
                        console.log("❌ Ошибка сервера для", endpoint + ":", errorResponse.error);
                        if (callback) callback({
                            success: false,
                            error: errorResponse.error || "Ошибка сервера",
                            status: xhr.status
                        });
                    } catch (e) {
                        console.log("❌ Ошибка парсинга ошибки для", endpoint + ":", e);
                        console.log("   Сырой ответ ошибки:", xhr.responseText);
                        if (callback) callback({
                            success: false,
                            error: "Сетевая ошибка",
                            status: xhr.status
                        });
                    }
                }
            }
        };

        xhr.ontimeout = function() {
            console.log("⏰ Таймаут запроса:", endpoint);
            if (callback) callback({
                success: false,
                error: "Таймаут",
                status: 408
            });
        };

        xhr.onerror = function() {
            console.log("❌ Ошибка сети:", endpoint);
            if (callback) callback({
                success: false,
                error: "Ошибка сети",
                status: 0
            });
        };

        try {
            xhr.open(method, url, true);
            xhr.setRequestHeader("Authorization", "Bearer " + authToken);
            xhr.setRequestHeader("Content-Type", "application/json");
            xhr.setRequestHeader("Accept", "application/json");

            if (data) {
                console.log("📦 Отправка данных:", JSON.stringify(data).substring(0, 100) + "...");
                xhr.send(JSON.stringify(data));
            } else {
                xhr.send();
            }
        } catch (error) {
            console.log("❌ Ошибка отправки запроса:", error);
            if (callback) callback({
                success: false,
                error: "Ошибка отправки",
                status: 0
            });
        }
    }
}
