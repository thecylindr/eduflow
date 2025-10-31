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
    function initialize(token, url) {
        if (token && token.length > 0) {
            authToken = token;
        } else {
            authToken = settingsManager.authToken || "";
        }
        if (url && url.length > 0) {
            baseUrl = url;
        } else {
            baseUrl = settingsManager.useLocalServer ?
                settingsManager.serverAddress :
                (remoteApiBaseUrl + ":" + remotePort);
        }
        if (isAuthenticated) {
            validateToken(function(response) {
                tokenValid = response.success;
                tokenStatus = response.success ? "валиден" : "невалиден";
                // УБРАТЬ ОЧИСТКУ! ТОКЕН ДОЛЖЕН СОХРАНЯТЬСЯ В НАСТРОЙКАХ!
                // if (!response.success) {
                // settingsManager.authToken = ""; // ЗАКОММЕНТИРОВАТЬ!
                // }
            });
        }
    }
    function clearAuth() {
        baseUrl = "";
        tokenValid = false;
        tokenStatus = "очищен";
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
            console.log("🔐 Ответ от /verify-token:", JSON.stringify(response, null, 2));
            // УЛУЧШЕННАЯ ПРОВЕРКА: учитываем различные форматы ответов
            var isValid = false;
            if (response.success) {
                // Если сервер явно указывает valid: true
                if (response.valid === true) {
                    isValid = true;
                }
                // Или если есть успешное сообщение
                else if (response.message && (
                    response.message.includes("Welcome") ||
                    response.message.includes("success") ||
                    response.message.includes("valid"))) {
                    isValid = true;
                }
                // Или если в данных ответа есть информация о пользователе
                else if (response.data && (response.data.userId || response.data.email)) {
                    isValid = true;
                }
            }
            // ДОПОЛНИТЕЛЬНАЯ ПРОВЕРКА: тестовый запрос к защищенному эндпоинту
            if (isValid) {
                console.log("🔐 Делаем тестовый запрос к защищенному эндпоинту...");
                var testXhr = new XMLHttpRequest();
                testXhr.open("GET", baseUrl + "/teachers", true);
                testXhr.setRequestHeader("Authorization", "Bearer " + authToken);
                testXhr.setRequestHeader("Content-Type", "application/json");
                testXhr.onreadystatechange = function() {
                    if (testXhr.readyState === XMLHttpRequest.DONE) {
                        console.log("🔐 Тестовый запрос статус:", testXhr.status);
                        if (testXhr.status === 200) {
                            isValid = true;
                            console.log("✅ Тестовый запрос подтвердил валидность токена");
                        } else {
                            isValid = false;
                            console.log("❌ Тестовый запрос показал невалидность токена");
                        }
                        // Вызываем callback с финальным результатом
                        if (callback) callback({
                            success: response.success,
                            valid: isValid,
                            message: response.message || (isValid ? "Токен валиден" : "Токен невалиден"),
                            error: response.error,
                            testStatus: testXhr.status
                        });
                    }
                };
                testXhr.send();
            } else {
                // Если первичная проверка не пройдена, сразу возвращаем результат
                if (callback) callback({
                    success: response.success,
                    valid: isValid,
                    message: response.message || (isValid ? "Токен валиден" : "Токен невалиден"),
                    error: response.error
                });
            }
        });
    }
    function sendRegistrationRequest(userData, callback) {
        sendRequest("POST", "/register", userData, callback);
    }
    function sendLoginRequest(login, password, callback) {
        var loginData = {
            email: login,
            password: password
        };
        sendRequest("POST", "/login", loginData, callback);
    }
    function sendRequest(method, endpoint, data, callback) {
        var xhr = new XMLHttpRequest();
        xhr.timeout = 10000;
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
                            status: xhr.status
                        });
                    } catch (e) {
                        if (callback) callback({
                            success: false,
                            error: "Ошибка формата ответа",
                            status: xhr.status
                        });
                    }
                } else {
                    try {
                        var errorResponse = JSON.parse(xhr.responseText);
                        if (callback) callback({
                            success: false,
                            error: errorResponse.error || "Ошибка сервера",
                            status: xhr.status
                        });
                    } catch (e) {
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
            if (callback) callback({
                success: false,
                error: "Таймаут",
                status: 408
            });
        };
        xhr.onerror = function() {
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
            if (isAuthenticated && endpoint !== "/verify-token" && endpoint !== "/login" && endpoint !== "/register") {
                xhr.setRequestHeader("Authorization", "Bearer " + authToken);
            }
            if (data) {
                xhr.send(JSON.stringify(data));
            } else {
                xhr.send();
            }
        } catch (error) {
            if (callback) callback({
                success: false,
                error: "Ошибка отправки",
                status: 0
            });
        }
    }
}
