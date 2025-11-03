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

    // Добавьте в MainAPI.qml новые методы
    function getSessions(callback) {
        sendRequest("GET", "/sessions", null, function(response) {
            if (callback) callback(response);
        });
    }

    function revokeSession(token, callback) {
        var data = {
            token: token
        };

        sendRequest("DELETE", "/sessions", data, function(response) {
            if (callback) callback(response);
        });
    }

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

    // Новые методы для работы с профилем и паролем
    function updateProfile(profileData, callback) {
            console.log("🔄 Обновление профиля. Данные:", JSON.stringify(profileData));

            sendRequest("PUT", "/profile", profileData, function(response) {
                console.log("📨 Ответ обновления профиля:", response);

                if (callback) {
                    if (response.success) {
                        callback({
                            success: true,
                            message: "Профиль успешно обновлен",
                            data: response.data,
                            status: response.status
                        });
                    } else {
                        callback({
                            success: false,
                            error: response.error || "Ошибка обновления профиля",
                            status: response.status
                        });
                    }
                }
            });
        }

    function changePassword(currentPassword, newPassword, callback) {
            console.log("🔄 Смена пароля");

            var passwordData = {
                currentPassword: currentPassword,
                newPassword: newPassword
            };

            sendRequest("POST", "/change-password", passwordData, function(response) {
                console.log("📨 Ответ смены пароля:", response);

                if (callback) {
                    if (response.success) {
                        callback({
                            success: true,
                            message: "Пароль успешно изменен",
                            data: response.data,
                            status: response.status
                        });
                    } else {
                        callback({
                            success: false,
                            error: response.error || "Ошибка смены пароля",
                            status: response.status
                        });
                    }
                }
            });
        }

    function getTeachers(callback) {
        sendRequest("GET", "/teachers", null, function(response) {
            if (response.success) {
                var responseData = response.data;
                var teachersArray = [];

                if (responseData && responseData.data && Array.isArray(responseData.data)) {
                    teachersArray = responseData.data;
                } else if (responseData && Array.isArray(responseData)) {
                    teachersArray = responseData;
                }

                console.log("📊 Получено преподавателей:", teachersArray.length);

                callback({
                    success: true,
                    data: teachersArray,
                    status: response.status
                });
            } else {
                console.log("❌ Ошибка загрузки преподавателей, возвращаем пустой массив");
                callback({
                    success: false,
                    error: response.error,
                    data: [],
                    status: response.status
                });
            }
        });
    }

    function getStudents(callback) {
        sendRequest("GET", "/students", null, function(response) {
            if (response.success) {
                var responseData = response.data;
                var studentsArray = [];

                if (responseData && responseData.data && Array.isArray(responseData.data)) {
                    studentsArray = responseData.data;
                } else if (responseData && Array.isArray(responseData)) {
                    studentsArray = responseData;
                }

                console.log("📊 Получено студентов:", studentsArray.length);

                callback({
                    success: true,
                    data: studentsArray,
                    status: response.status
                });
            } else {
                console.log("❌ Ошибка загрузки студентов, возвращаем пустой массив");
                callback({
                    success: false,
                    error: response.error,
                    data: [],
                    status: response.status
                });
            }
        });
    }

    function getGroups(callback) {
        sendRequest("GET", "/groups", null, function(response) {
            if (response.success) {
                var responseData = response.data;
                var groupsArray = [];

                if (responseData && responseData.data && Array.isArray(responseData.data)) {
                    groupsArray = responseData.data;
                } else if (responseData && Array.isArray(responseData)) {
                    groupsArray = responseData;
                }

                console.log("📊 Получено групп:", groupsArray.length);

                callback({
                    success: true,
                    data: groupsArray,
                    status: response.status
                });
            } else {
                console.log("❌ Ошибка загрузки групп, возвращаем пустой массив");
                callback({
                    success: false,
                    error: response.error,
                    data: [],
                    status: response.status
                });
            }
        });
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

    function getPortfolios(callback) {
        sendRequest("GET", "/portfolio", null, function(response) {
            if (response.success) {
                callback({
                    success: true,
                    data: response.data || [],
                    status: response.status
                });
            } else {
                callback({
                    success: false,
                    error: response.error,
                    data: [],
                    status: response.status
                });
            }
        });
    }

    function getEvents(callback) {
        sendRequest("GET", "/events", null, function(response) {
            if (response.success) {
                callback({
                    success: true,
                    data: response.data || [],
                    status: response.status
                });
            } else {
                callback({
                    success: false,
                    error: response.error,
                    data: [],
                    status: response.status
                });
            }
        });
    }

    function getProfile(callback) {
            sendRequest("GET", "/profile", null, function(response) {
                console.log("🔍 Полный ответ профиля:", JSON.stringify(response))

                if (response.success) {
                    var profileData = response.data || {}

                    // Детальная диагностика данных
                    console.log("📊 Анализ данных профиля:")
                    console.log("   - Логин:", profileData.login || "Отсутствует")
                    console.log("   - Имя:", profileData.firstName || "Отсутствует")
                    console.log("   - Фамилия:", profileData.lastName || "Отсутствует")
                    console.log("   - Email:", profileData.email || "Отсутствует")
                    console.log("   - Телефон:", profileData.phoneNumber || "Отсутствует")
                    console.log("   - Сессии:", profileData.sessions ? profileData.sessions.length : 0)

                    if (callback) {
                        callback({
                            success: true,
                            data: profileData,
                            status: response.status
                        });
                    }
                } else {
                    console.log("❌ Ошибка загрузки профиля:", response.error)
                    if (callback) {
                        callback({
                            success: false,
                            error: response.error || "Ошибка загрузки профиля",
                            status: response.status
                        });
                    }
                }
            });
        }

        // Добавьте этот метод для отладки структуры ответа
        function debugProfileStructure(callback) {
            sendRequest("GET", "/profile", null, function(response) {
                console.log("🔧 ДЕБАГ СТРУКТУРЫ ПРОФИЛЯ:")
                console.log("   Полный ответ:", JSON.stringify(response, null, 2))
                console.log("   Уровень data:", JSON.stringify(response.data, null, 2))

                if (response.data) {
                    console.log("   Ключи в data:", Object.keys(response.data))
                    if (response.data.user) {
                        console.log("   Ключи в user:", Object.keys(response.data.user))
                    }
                }

                if (callback) callback(response)
            })
        }

    function validateToken(callback) {
        var requestData = {
            token: authToken
        };

        sendRequest("POST", "/verify-token", requestData, function(response) {
            console.log("🔐 Ответ проверки токена:", response);
            if (callback) callback(response);
        });
    }

    function addTeacher(teacherData, callback) {
        console.log("➕ Добавление преподавателя Данные:", JSON.stringify(teacherData));

        var endpoint = "/teachers";
        sendRequest("POST", endpoint, teacherData, function(response) {
            console.log("📨 Ответ добавления преподавателя:", response);

            if (callback) {
                if (response.success) {
                    var responseData = response.data;
                    callback({
                        success: true,
                        message: responseData.message || "Преподаватель успешно добавлен",
                        data: responseData,
                        status: response.status
                    });
                } else {
                    callback(response);
                }
            }
        });
    }

    function addStudent(studentData, callback) {
        console.log("➕ Добавление студента Данные:", JSON.stringify(studentData));

        var endpoint = "/students";
        sendRequest("POST", endpoint, studentData, function(response) {
            console.log("📨 Ответ добавления студента:", response);

            if (callback) {
                if (response.success) {
                    var responseData = response.data;
                    callback({
                        success: true,
                        message: responseData.message || "Студент успешно добавлен",
                        data: responseData,
                        status: response.status
                    });
                } else {
                    callback(response);
                }
            }
        });
    }

    function updateStudent(studentCode, studentData, callback) {
        console.log("🔄 Обновление студента ID:", studentCode, "Данные:", JSON.stringify(studentData));

        var endpoint = "/students/" + studentCode;
        sendRequest("PUT", endpoint, studentData, function(response) {
            console.log("📨 Ответ обновления студента:", response);

            if (callback) {
                if (response.success) {
                    var responseData = response.data;
                    callback({
                        success: true,
                        message: responseData.message || "Операция выполнена успешно",
                        data: responseData,
                        status: response.status
                    });
                } else {
                    callback({
                        success: false,
                        error: response.error || "Неизвестная ошибка",
                        status: response.status
                    });
                }
            }
        });
    }

    function deleteStudent(studentCode, callback) {
        console.log("🗑️ Удаление студента ID:", studentCode);

        var endpoint = "/students/" + studentCode;
        sendRequest("DELETE", endpoint, null, function(response) {
            console.log("📨 Ответ удаления студента:", response);

            if (callback) {
                if (response.success) {
                    callback({
                        success: true,
                        message: "Студент успешно удален",
                        status: response.status
                    });
                } else {
                    callback({
                        success: false,
                        error: response.error || "Неизвестная ошибка",
                        status: response.status
                    });
                }
            }
        });
    }

    function addGroup(groupData, callback) {
        console.log("➕ Добавление группы Данные:", JSON.stringify(groupData));

        var endpoint = "/groups";
        sendRequest("POST", endpoint, groupData, function(response) {
            console.log("📨 Ответ добавления группы:", response);

            if (callback) {
                if (response.success) {
                    var responseData = response.data;
                    callback({
                        success: true,
                        message: responseData.message || "Группа успешно добавлена",
                        data: responseData,
                        status: response.status
                    });
                } else {
                    callback(response);
                }
            }
        });
    }

    function updateGroup(groupId, groupData, callback) {
        console.log("🔄 Обновление группы ID:", groupId, "Данные:", JSON.stringify(groupData));

        var endpoint = "/groups/" + groupId;
        sendRequest("PUT", endpoint, groupData, function(response) {
            console.log("📨 Ответ обновления группы:", response);

            if (callback) {
                if (response.success) {
                    var responseData = response.data;
                    callback({
                        success: true,
                        message: responseData.message || "Операция выполнена успешно",
                        data: responseData,
                        status: response.status
                    });
                } else {
                    callback({
                        success: false,
                        error: response.error || "Неизвестная ошибка",
                        status: response.status
                    });
                }
            }
        });
    }

    function deleteGroup(groupId, callback) {
        console.log("🗑️ Удаление группы ID:", groupId);

        var endpoint = "/groups/" + groupId;
        sendRequest("DELETE", endpoint, null, function(response) {
            console.log("📨 Ответ удаления группы:", response);

            if (callback) {
                if (response.success) {
                    callback({
                        success: true,
                        message: "Группа успешно удалена",
                        status: response.status
                    });
                } else {
                    callback({
                        success: false,
                        error: response.error || "Неизвестная ошибка",
                        status: response.status
                    });
                }
            }
        });
    }

    function updateTeacher(teacherId, teacherData, callback) {
        console.log("🔄 Обновление преподавателя ID:", teacherId, "Данные:", JSON.stringify(teacherData));

        var numericTeacherId = parseInt(teacherId);
        if (isNaN(numericTeacherId)) {
            console.log("❌ Неверный teacherId:", teacherId);
            if (callback) callback({
                success: false,
                error: "Неверный ID преподавателя"
            });
            return;
        }

        var endpoint = "/teachers/" + numericTeacherId;
        sendRequest("PUT", endpoint, teacherData, function(response) {
            console.log("📨 Ответ обновления преподавателя:", response);

            if (callback) {
                if (response.success) {
                    var responseData = response.data;
                    callback({
                        success: true,
                        message: responseData.message || "Операция выполнена успешно",
                        data: responseData,
                        status: response.status
                    });
                } else {
                    callback({
                        success: false,
                        error: response.error || "Неизвестная ошибка",
                        status: response.status
                    });
                }
            }
        });
    }

    function sendRequest(method, endpoint, data, callback) {
        if (!isAuthenticated) {
            if (callback) callback({
                success: false,
                error: "API не аутентифицирован",
                status: 401
            });
            return;
        }

        var xhr = new XMLHttpRequest();
        xhr.timeout = 10000;

        var normalizedBaseUrl = baseUrl.endsWith('/') ? baseUrl.slice(0, -1) : baseUrl;
        var normalizedEndpoint = endpoint.startsWith('/') ? endpoint : '/' + endpoint;
        var url = normalizedBaseUrl + normalizedEndpoint;

        xhr.onreadystatechange = function() {
            console.log("📨 Изменение состояния XHR:", xhr.readyState, "для", endpoint);

            if (xhr.readyState === XMLHttpRequest.DONE) {
                console.log("✅ Запрос завершен:", endpoint, "Статус:", xhr.status);

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
                        if (callback) callback({
                            success: false,
                            error: "Ошибка формата ответа",
                            status: xhr.status
                        });
                    }
                } else if (xhr.status === 401) {
                    if (callback) callback({
                        success: false,
                        error: "Ошибка доступа (401)",
                        status: xhr.status
                    });
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
