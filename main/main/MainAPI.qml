import QtQuick 2.15

QtObject {
    id: mainApi

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

        console.log("✅ API инициализирован. Платформа:", Qt.platform.os);
        console.log("   Base URL:", baseUrl);
        console.log("   Токен длина:", authToken.length);
        console.log("   Локальный сервер:", settingsManager.useLocalServer);

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

    // Функция для тестирования соединения
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

    function deleteTeacher(teacherId, callback) {
        console.log("🗑️ Удаление преподавателя ID:", teacherId);

        var endpoint = "/teachers/" + teacherId;
        sendRequest("DELETE", endpoint, null, function(response) {
            console.log("📨 Ответ удаления преподавателя:", response);

            if (callback) {
                if (response.success) {
                    callback({
                        success: true,
                        message: "Преподаватель успешно удален",
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
        if (!baseUrl || baseUrl === "") {
            console.log("❌ Base URL не установлен");
            if (callback) callback({
                success: false,
                error: "API не инициализирован",
                status: 0
            });
            return;
        }

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
        console.log("   Аутентифицирован:", isAuthenticated);

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
                } else if (xhr.status === 401) {
                    console.log("🔐 Ошибка аутентификации");
                    if (callback) callback({
                        success: false,
                        error: "Ошибка доступа (401). Токен невалиден.",
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

            if (isAuthenticated && authToken) {
                xhr.setRequestHeader("Authorization", "Bearer " + authToken);
                console.log("   Добавлен заголовок Authorization");
            }

            if (data) {
                var requestBody = JSON.stringify(data);
                console.log("📦 Тело запроса:", requestBody.substring(0, 200) + "...");
                xhr.send(requestBody);
            } else {
                xhr.send();
            }
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
