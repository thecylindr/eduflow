// MainAPI.qml
import QtQuick 2.15

QtObject {
    id: mainApi

    property string token: ""
    property string apiBaseUrl: ""
    property bool isInitialized: false

    function initialize(apiUrl, authToken) {
        apiBaseUrl = apiUrl;
        token = authToken;
        isInitialized = true;
        console.log("MainAPI инициализирован с URL:", apiBaseUrl);
    }

    function apiRequest(method, endpoint, data, callback) {
        if (!isInitialized) {
            callback("API не инициализирован", null);
            return;
        }

        if (!token) {
            callback("Токен авторизации отсутствует", null);
            return;
        }

        var xhr = new XMLHttpRequest();
        var url = apiBaseUrl + endpoint;

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                try {
                    var response = xhr.responseText ? JSON.parse(xhr.responseText) : {};

                    if (xhr.status === 200 || xhr.status === 201) {
                        console.log("API успех:", endpoint, response);
                        callback(null, response);
                    } else if (xhr.status === 401) {
                        console.error("Ошибка авторизации API:", endpoint);
                        callback("Ошибка авторизации", null);
                    } else {
                        console.error("Ошибка API:", endpoint, xhr.status, response);
                        callback(response.error || "Ошибка сервера: " + xhr.status, null);
                    }
                } catch (e) {
                    console.error("Ошибка парсинга ответа API:", endpoint, e);
                    callback("Ошибка парсинга ответа: " + e, null);
                }
            }
        };

        xhr.onerror = function() {
            console.error("Ошибка сети API:", endpoint);
            callback("Ошибка сети", null);
        };

        try {
            xhr.open(method, url, true);
            xhr.setRequestHeader("Authorization", "Bearer " + token);
            xhr.setRequestHeader("Content-Type", "application/json");
            xhr.send(data ? JSON.stringify(data) : null);
            console.log("API запрос отправлен:", method, url);
        } catch (error) {
            console.error("Ошибка отправки API запроса:", endpoint, error);
            callback("Ошибка отправки запроса: " + error, null);
        }
    }

    // Методы для работы с преподавателями
    function getTeachers(callback) {
        apiRequest("GET", "/teachers", null, callback);
    }

    function addTeacher(teacherData, callback) {
        apiRequest("POST", "/teachers", teacherData, callback);
    }

    function updateTeacher(teacherId, teacherData, callback) {
        apiRequest("PUT", "/teachers/" + teacherId, teacherData, callback);
    }

    function deleteTeacher(teacherId, callback) {
        apiRequest("DELETE", "/teachers/" + teacherId, null, callback);
    }

    // Методы для работы с группами
    function getGroups(callback) {
        apiRequest("GET", "/groups", null, callback);
    }

    function addGroup(groupData, callback) {
        apiRequest("POST", "/groups", groupData, callback);
    }

    function updateGroup(groupId, groupData, callback) {
        apiRequest("PUT", "/groups/" + groupId, groupData, callback);
    }

    function deleteGroup(groupId, callback) {
        apiRequest("DELETE", "/groups/" + groupId, null, callback);
    }

    // Методы для работы со студентами
    function getStudents(callback) {
        apiRequest("GET", "/students", null, callback);
    }

    function addStudent(studentData, callback) {
        apiRequest("POST", "/students", studentData, callback);
    }

    function updateStudent(studentId, studentData, callback) {
        apiRequest("PUT", "/students/" + studentId, studentData, callback);
    }

    function deleteStudent(studentId, callback) {
        apiRequest("DELETE", "/students/" + studentId, null, callback);
    }

    // Методы для работы с портфолио
    function getPortfolio(callback) {
        apiRequest("GET", "/portfolio", null, callback);
    }

    function addPortfolioItem(portfolioData, callback) {
        apiRequest("POST", "/portfolio", portfolioData, callback);
    }

    // Методы для работы с мероприятиями
    function getEvents(callback) {
        apiRequest("GET", "/events", null, callback);
    }

    function addEvent(eventData, callback) {
        apiRequest("POST", "/events", eventData, callback);
    }

    // Методы для работы со специализациями
    function getSpecializations(callback) {
        apiRequest("GET", "/specializations", null, callback);
    }

    // Методы для работы с профилем
    function getProfile(callback) {
        apiRequest("GET", "/profile", null, callback);
    }

    function updateProfile(profileData, callback) {
        apiRequest("PUT", "/profile", profileData, callback);
    }
}
