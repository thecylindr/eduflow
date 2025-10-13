// main/MainAPI.qml
import QtQml 2.15

QtObject {
    id: mainApi

    property string authToken: ""
    property string baseUrl: ""
    property bool useLocalServer: false

    // Кэширование данных
    property var teachersCache: null
    property var studentsCache: null
    property var groupsCache: null
    property var cacheTimestamp: ({})

    function setConfig(token, serverAddress, isLocal) {
        authToken = token;
        baseUrl = serverAddress;
        useLocalServer = isLocal;
        clearCache() // Очищаем кэш при смене конфигурации
    }

    function clearCache() {
        teachersCache = null
        studentsCache = null
        groupsCache = null
        cacheTimestamp = {}
    }

    function isCacheValid(key, maxAgeMs = 30000) {
        if (!cacheTimestamp[key]) return false
        return (Date.now() - cacheTimestamp[key]) < maxAgeMs
    }

    function apiRequest(method, endpoint, data, callback, useCache = false, cacheKey = null) {
        // Проверка кэша для GET запросов
        if (method === "GET" && useCache && cacheKey && isCacheValid(cacheKey)) {
            var cachedData = getCachedData(cacheKey)
            if (cachedData) {
                console.log("Using cached data for:", cacheKey)
                callback({
                    success: true,
                    data: cachedData,
                    cached: true
                })
                return
            }
        }

        var xhr = new XMLHttpRequest();
        xhr.timeout = 8000; // Уменьшен таймаут

        var url = baseUrl + endpoint;

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                try {
                    var response = xhr.responseText ? JSON.parse(xhr.responseText) : {};

                    if (xhr.status >= 200 && xhr.status < 300) {
                        // Сохраняем в кэш для GET запросов
                        if (method === "GET" && useCache && cacheKey) {
                            setCachedData(cacheKey, response)
                        }

                        callback({
                            success: true,
                            data: response,
                            message: response.message || "Успешно"
                        });
                    } else {
                        callback({
                            success: false,
                            error: response.error || "Ошибка: " + xhr.status,
                            status: xhr.status
                        });
                    }
                } catch (e) {
                    callback({
                        success: false,
                        error: "Ошибка парсинга ответа: " + e
                    });
                }
            }
        };

        xhr.ontimeout = function() {
            callback({ success: false, error: "Таймаут соединения" });
        };

        xhr.onerror = function() {
            callback({ success: false, error: "Ошибка сети" });
        };

        try {
            xhr.open(method, url, true);
            xhr.setRequestHeader("Content-Type", "application/json");
            if (authToken) {
                xhr.setRequestHeader("Authorization", "Bearer " + authToken);
            }
            xhr.send(data ? JSON.stringify(data) : null);
        } catch (error) {
            callback({ success: false, error: "Ошибка отправки: " + error });
        }
    }

    function getCachedData(key) {
        switch(key) {
            case "teachers": return teachersCache;
            case "students": return studentsCache;
            case "groups": return groupsCache;
            default: return null;
        }
    }

    function setCachedData(key, data) {
        cacheTimestamp[key] = Date.now()
        switch(key) {
            case "teachers": teachersCache = data; break;
            case "students": studentsCache = data; break;
            case "groups": groupsCache = data; break;
        }
    }

    // Teachers API
    function getTeachers(callback) {
        apiRequest("GET", "/teachers", null, callback, true, "teachers");
    }

    function addTeacher(teacherData, callback) {
        apiRequest("POST", "/teachers", teacherData, function(result) {
            if (result.success) clearCache();
            callback(result);
        });
    }

    function updateTeacher(teacherId, teacherData, callback) {
        apiRequest("PUT", "/teachers/" + teacherId, teacherData, function(result) {
            if (result.success) clearCache();
            callback(result);
        });
    }

    function deleteTeacher(teacherId, callback) {
        apiRequest("DELETE", "/teachers/" + teacherId, null, function(result) {
            if (result.success) clearCache();
            callback(result);
        });
    }

    // Students API
    function getStudents(callback) {
        apiRequest("GET", "/students", null, callback, true, "students");
    }

    function addStudent(studentData, callback) {
        apiRequest("POST", "/students", studentData, function(result) {
            if (result.success) clearCache();
            callback(result);
        });
    }

    function updateStudent(studentId, studentData, callback) {
        apiRequest("PUT", "/students/" + studentId, studentData, function(result) {
            if (result.success) clearCache();
            callback(result);
        });
    }

    function deleteStudent(studentId, callback) {
        apiRequest("DELETE", "/students/" + studentId, null, function(result) {
            if (result.success) clearCache();
            callback(result);
        });
    }

    // Groups API
    function getGroups(callback) {
        apiRequest("GET", "/groups", null, callback, true, "groups");
    }

    function addGroup(groupData, callback) {
        apiRequest("POST", "/groups", groupData, function(result) {
            if (result.success) clearCache();
            callback(result);
        });
    }

    function updateGroup(groupId, groupData, callback) {
        apiRequest("PUT", "/groups/" + groupId, groupData, function(result) {
            if (result.success) clearCache();
            callback(result);
        });
    }

    function deleteGroup(groupId, callback) {
        apiRequest("DELETE", "/groups/" + groupId, null, function(result) {
            if (result.success) clearCache();
            callback(result);
        });
    }

    // Profile API
    function getProfile(callback) {
        apiRequest("GET", "/profile", null, callback);
    }

    function updateProfile(profileData, callback) {
        apiRequest("PUT", "/profile", profileData, callback);
    }
}
