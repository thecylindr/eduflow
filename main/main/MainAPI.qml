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
        // Используем токен в URL вместо тела запроса
        var endpoint = "/sessions/" + encodeURIComponent(token);

        console.log("🎯 Endpoint для отзыва:", endpoint)

        // Отправляем DELETE запрос без тела
        sendRequest("DELETE", endpoint, null, function(response) {
            console.log("📨 Ответ отзыва сессии:", JSON.stringify(response))

            if (callback) {
                if (response.success) {
                    callback({
                        success: true,
                        message: "Сессия успешно отозвана",
                        data: response.data,
                        status: response.status
                    });
                } else {
                    callback({
                        success: false,
                        error: response.error || "Ошибка отзыва сессии",
                        status: response.status
                    });
                }
            }
        });
    }

    function initialize(token, url) {
        authToken = token && token.length > 0 ? token : settingsManager.authToken || "";

        // ОСОБАЯ ЛОГИКА ДЛЯ WINDOWS
        if (Qt.platform.os === "windows") {
            if (url && url.length > 0) {
                baseUrl = url;
            } else {
                if (settingsManager.useLocalServer) {
                    // НА WINDOWS ВСЕГДА ИСПОЛЬЗУЕМ 127.0.0.1 ВМЕСТО LOCALHOST
                    var serverAddress = settingsManager.serverAddress;
                    if (serverAddress.includes("localhost")) {
                        baseUrl = serverAddress.replace("localhost", "127.0.0.1");
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

        if (isAuthenticated) {
            validateToken(function(response) {
                tokenValid = response.success;
                tokenStatus = response.success ? "валиден" : "невалиден";

                if (!response.success) {
                    console.log("❌ Токен невалиден, очищаем...");
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
        sendRequest("PUT", "/profile", profileData, function(response) {
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

    function getPortfolio(callback) {
        sendRequest("GET", "/portfolio", null, function(response) {
            console.log("📊 Ответ портфолио:", JSON.stringify(response));
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

    function addPortfolio(portfolioData, callback) {
        // Передаем все обязательные поля для сервера
        var fullPortfolioData = {
            student_code: portfolioData.student_code,
            event_id: portfolioData.event_id,
            date: portfolioData.date,
            description: portfolioData.description,
            passport_series: portfolioData.passport_series || "",
            passport_number: portfolioData.passport_number || "",
            file_path: portfolioData.file_path || ""
        };

        sendRequest("POST", "/portfolio", fullPortfolioData, function(response) {
            if (callback) {
                if (response.success) {
                    callback({
                        success: true,
                        message: response.data?.message || "Портфолио успешно добавлено",
                        data: response.data,
                        status: response.status
                    });
                } else {
                    callback({
                        success: false,
                        error: response.error || "Ошибка добавления портфолио",
                        status: response.status
                    });
                }
            }
        });
    }

    function updatePortfolio(portfolioId, portfolioData, callback) {
        // При обновлении передаем только редактируемые поля
        var updatePortfolioData = {
            student_code: portfolioData.student_code,
            event_id: portfolioData.event_id,
            date: portfolioData.date,
            description: portfolioData.description
        };

        var endpoint = "/portfolio/" + portfolioId;
        sendRequest("PUT", endpoint, updatePortfolioData, function(response) {
            if (callback) {
                if (response.success) {
                    callback({
                        success: true,
                        message: response.data?.message || "Портфолио успешно обновлено",
                        data: response.data,
                        status: response.status
                    });
                } else {
                    callback({
                        success: false,
                        error: response.error || "Ошибка обновления портфолио",
                        status: response.status
                    });
                }
            }
        });
    }

    function deletePortfolio(portfolioId, callback) {
        var endpoint = "/portfolio/" + portfolioId;
        sendRequest("DELETE", endpoint, null, function(response) {
            if (callback) {
                if (response.success) {
                    callback({
                        success: true,
                        message: response.data?.message || "Портфолио успешно удалено",
                        status: response.status
                    });
                } else {
                    callback({
                        success: false,
                        error: response.error || "Ошибка удаления портфолио",
                        status: response.status
                    });
                }
            }
        });
    }

    function getEvents(callback) {
        sendRequest("GET", "/events", null, function(response) {
            if (response.success) {
                var eventsData = response.data || [];
                callback({
                    success: true,
                    data: eventsData,
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

    function addEvent(eventData, callback) {
        // Передаем все обязательные поля для сервера
        var fullEventData = {
            event_type: eventData.event_type,
            event_category_id: eventData.event_category_id,
            start_date: eventData.start_date,
            end_date: eventData.end_date,
            location: eventData.location,
            lore: eventData.lore,
            max_participants: eventData.max_participants,
            measure_code: eventData.measure_code || 0,
            current_participants: eventData.current_participants || 0,
            status: eventData.status || "active"
        };

        sendRequest("POST", "/events", fullEventData, function(response) {
            if (callback) {
                if (response.success) {
                    callback({
                        success: true,
                        message: response.data?.message || "Событие успешно добавлено",
                        data: response.data,
                        status: response.status
                    });
                } else {
                    callback({
                        success: false,
                        error: response.error || "Ошибка добавления события",
                        status: response.status
                    });
                }
            }
        });
    }

    function updateEvent(eventId, eventData, callback) {
        // При обновлении передаем только редактируемые поля
        var updateEventData = {
            event_type: eventData.event_type,
            event_category_id: eventData.event_category_id,
            start_date: eventData.start_date,
            end_date: eventData.end_date,
            location: eventData.location,
            lore: eventData.lore,
            max_participants: eventData.max_participants
        };

        var endpoint = "/events/" + eventId;
        sendRequest("PUT", endpoint, updateEventData, function(response) {
            if (callback) {
                if (response.success) {
                    callback({
                        success: true,
                        message: response.data?.message || "Событие успешно обновлено",
                        data: response.data,
                        status: response.status
                    });
                } else {
                    callback({
                        success: false,
                        error: response.error || "Ошибка обновления события",
                        status: response.status
                    });
                }
            }
        });
    }

    function deleteEvent(eventId, callback) {
        var endpoint = "/events/" + eventId;
        sendRequest("DELETE", endpoint, null, function(response) {
            if (callback) {
                if (response.success) {
                    callback({
                        success: true,
                        message: response.data?.message || "Событие успешно удалено",
                        status: response.status
                    });
                } else {
                    callback({
                        success: false,
                        error: response.error || "Ошибка удаления события",
                        status: response.status
                    });
                }
            }
        });
    }

    function getEventCategories(callback) {
        sendRequest("GET", "/event-categories", null, function(response) {
            if (response.success) {
                var categoriesData = response.data || [];
                console.log("📊 Получено категорий событий:", categoriesData.length);

                callback({
                    success: true,
                    data: categoriesData,
                    status: response.status
                });
            } else {
                console.log("❌ Ошибка загрузки категорий событий, возвращаем пустой массив");
                callback({
                    success: false,
                    error: response.error,
                    data: [],
                    status: response.status
                });
            }
        });
    }

    function addEventCategory(categoryData, callback) {
        console.log("➕ Добавление категории события:", JSON.stringify(categoryData));

        sendRequest("POST", "/event-categories", categoryData, function(response) {
            console.log("📨 Ответ добавления категории события:", response);

            if (callback) {
                if (response.success) {
                    callback({
                        success: true,
                        message: response.data?.message || "Категория события успешно добавлена",
                        data: response.data,
                        status: response.status
                    });
                } else {
                    callback({
                        success: false,
                        error: response.error || "Ошибка добавления категории события",
                        status: response.status
                    });
                }
            }
        });
    }

    function updateEventCategory(categoryId, categoryData, callback) {
        console.log("🔄 Обновление категории события ID:", categoryId, "Данные:", JSON.stringify(categoryData));

        var endpoint = "/event-categories/" + categoryId;
        sendRequest("PUT", endpoint, categoryData, function(response) {
            console.log("📨 Ответ обновления категории события:", response);

            if (callback) {
                if (response.success) {
                    callback({
                        success: true,
                        message: response.data?.message || "Категория события успешно обновлена",
                        data: response.data,
                        status: response.status
                    });
                } else {
                    callback({
                        success: false,
                        error: response.error || "Ошибка обновления категории события",
                        status: response.status
                    });
                }
            }
        });
    }

    function deleteEventCategory(categoryId, callback) {
        console.log("🗑️ Удаление категории события ID:", categoryId);

        var endpoint = "/event-categories/" + categoryId;
        sendRequest("DELETE", endpoint, null, function(response) {
            console.log("📨 Ответ удаления категории события:", response);

            if (callback) {
                if (response.success) {
                    callback({
                        success: true,
                        message: response.data?.message || "Категория события успешно удалена",
                        status: response.status
                    });
                } else {
                    callback({
                        success: false,
                        error: response.error || "Ошибка удаления категории события",
                        status: response.status
                    });
                }
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
