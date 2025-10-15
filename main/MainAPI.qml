// main/MainAPI.qml
import QtQuick 2.15

QtObject {
    id: mainApi

    property string authToken: ""
    property string baseUrl: ""
    property bool useLocalServer: false
    property string remoteApiBaseUrl: "https://deltablast.fun"
    property int remotePort: 5000

    function setConfig(token, url, local) {
        authToken = token || "";
        baseUrl = url || "";
        useLocalServer = local || false;
    }

    function clearCache() {
        // Очистка кэша если нужна
    }

    function getProfile(callback) {
        sendRequest("GET", "/profile", null, callback);
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

    function sendRequest(method, endpoint, data, callback) {
        if (!authToken || authToken.length === 0) {
            console.error("No auth token available for API request");
            if (callback) callback({
                success: false,
                error: "Токен авторизации отсутствует",
                status: 401
            });
            return;
        }

        var xhr = new XMLHttpRequest();
        xhr.timeout = 10000;

        var url = baseUrl + endpoint;
        console.log("🚀 Sending", method, "request to:", url);
        console.log("🔑 Using token:", authToken ? "***" + authToken.slice(-8) : "none");

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                console.log("📨 Response status:", xhr.status);
                console.log("📄 Response text:", xhr.responseText);

                if (xhr.status === 200 || xhr.status === 201) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        if (callback) callback({
                            success: true,
                            data: response,
                            status: xhr.status
                        });
                    } catch (e) {
                        console.error("❌ JSON parse error:", e);
                        if (callback) callback({
                            success: false,
                            error: "Ошибка формата ответа сервера",
                            status: xhr.status
                        });
                    }
                } else {
                    try {
                        var errorResponse = JSON.parse(xhr.responseText);
                        if (callback) callback({
                            success: false,
                            error: errorResponse.error || "Ошибка сервера: " + xhr.status,
                            status: xhr.status
                        });
                    } catch (e) {
                        if (callback) callback({
                            success: false,
                            error: "Ошибка сети: " + xhr.status,
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
                error: "Ошибка сети",
                status: 0
            });
        };

        try {
            xhr.open(method, url, true);
            xhr.setRequestHeader("Content-Type", "application/json");
            xhr.setRequestHeader("Authorization", "Bearer " + authToken);

            if (data) {
                xhr.send(JSON.stringify(data));
            } else {
                xhr.send();
            }
        } catch (error) {
            console.error("❌ Request error:", error);
            if (callback) callback({
                success: false,
                error: "Ошибка отправки запроса: " + error,
                status: 0
            });
        }
    }
}
