import QtQuick

QtObject {
    id: mainApi

    property string authToken: ""
    property string baseUrl: ""
    property bool isAuthenticated: authToken !== "" && baseUrl !== ""
    property bool tokenValid: false
    property string tokenStatus: "не проверен"
    property string remoteApiBaseUrl: "http://deltablast.fun"
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

    function getDashboard(callback) {
        console.log("📊 Запрос данных дашборда...")

        sendRequest("GET", "/dashboard", null, function(response) {
            console.log("📨 Ответ дашборда:", JSON.stringify(response))

            if (callback) {
                if (response.success) {
                    callback({
                        success: true,
                        data: response.data,
                        status: response.status
                    });
                } else {
                    callback({
                        success: false,
                        error: response.error || "Ошибка загрузки дашборда",
                        status: response.status
                    });
                }
            }
        });
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
                var responseData = response.data;
                var portfolioData = [];

                // ИСПРАВЛЕНИЕ: Правильно извлекаем данные из ответа
                if (responseData && responseData.data && Array.isArray(responseData.data)) {
                    portfolioData = responseData.data;
                } else if (responseData && Array.isArray(responseData)) {
                    portfolioData = responseData;
                }

                // Преобразуем даты обратно в ДД.ММ.ГГГГ для отображения
                portfolioData.forEach(function(item) {
                    if (item.date) {
                        var parts = item.date.split('-');
                        if (parts.length === 3) {
                            item.date = parts[2] + '.' + parts[1] + '.' + parts[0];
                        }
                    }
                });

                callback({
                    success: true,
                    data: portfolioData,
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

    // В функции addPortfolio
    function addPortfolio(portfolioData, callback) {
        console.log("➕ Добавление портфолио:", JSON.stringify(portfolioData));

        // Согласуем с серверными требованиями
        var cleanPortfolioData = {
            student_code: portfolioData.student_code,
            date: portfolioData.date,
            decree: portfolioData.decree
        };

        sendRequest("POST", "/portfolio", cleanPortfolioData, function(response) {
            console.log("📨 Ответ добавления портфолио:", response);

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

    // В функции updatePortfolio
    function updatePortfolio(portfolioId, portfolioData, callback) {
        console.log("🔄 Обновление портфолио ID:", portfolioId, "Данные:", JSON.stringify(portfolioData));

        var endpoint = "/portfolio/" + portfolioId;
        sendRequest("PUT", endpoint, portfolioData, function(response) {
            console.log("📨 Ответ обновления портфолио:", response);

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
            console.log("📨 СЫРОЙ ОТВЕТ событий:", JSON.stringify(response));

            if (response.success) {
                // 🔥 ИСПРАВЛЕНИЕ: response.data уже содержит массив событий
                var eventsData = response.data || [];
                var eventsArray = [];

                console.log("📊 Анализ структуры данных событий:");
                console.log("   Тип данных:", typeof eventsData);
                console.log("   Это массив?", Array.isArray(eventsData));

                if (Array.isArray(eventsData)) {
                    eventsArray = eventsData;
                    console.log("✅ Формат 1: response.data - массив, длина:", eventsArray.length);
                } else if (eventsData && eventsData.data && Array.isArray(eventsData.data)) {
                    eventsArray = eventsData.data;
                    console.log("✅ Формат 2: response.data.data - массив, длина:", eventsArray.length);
                } else {
                    console.log("❌ Неизвестный формат данных событий");
                    eventsArray = [];
                }

                console.log("📊 Получено событий с сервера:", eventsArray.length);

                // 🔥 ДЕБАГ: выводим структуру первого события
                if (eventsArray.length > 0) {
                    console.log("🔍 Структура первого события:", JSON.stringify(eventsArray[0]));
                    console.log("🏷️ Категория первого события:", eventsArray[0].category);
                }

                // ПРЕОБРАЗУЕМ ПОЛЯ ДЛЯ СОВМЕСТИМОСТИ
                var formattedEvents = eventsArray.map(function(event) {
                    var formattedEvent = {
                        id: event.id || 0,
                        eventId: event.event_id || 0,
                        eventType: event.event_type || "",
                        // 🔥 ИСПРАВЛЕНИЕ: используем category из ответа сервера
                        category: event.category || "", // Наименование категории
                        startDate: event.start_date || "",
                        endDate: event.end_date || "",
                        location: event.location || "",
                        lore: event.lore || "",
                        maxParticipants: event.max_participants || 0,
                        currentParticipants: event.current_participants || 0,
                        status: event.status || "active"
                    };

                    console.log("🔄 Преобразовано событие:", formattedEvent.id,
                              "Категория:", formattedEvent.category,
                              "Тип:", formattedEvent.eventType);

                    return formattedEvent;
                });

                callback({
                    success: true,
                    data: formattedEvents,
                    status: response.status
                });
            } else {
                console.log("❌ Ошибка загрузки событий:", response.error);
                callback({
                    success: false,
                    error: response.error,
                    data: [],
                    status: response.status
                });
            }
        });
    }

    function openPortfolioForm() {
        // Загружаем студентов перед открытием формы
        mainApi.loadStudentsForPortfolio(function(response) {
            if (response.success) {
                portfolioFormWindow.students = response.data;
                portfolioFormWindow.openForAdd();
            } else {
                console.log("❌ Ошибка загрузки студентов:", response.error);
                showMessage("❌ Не удалось загрузить список студентов", "error");
            }
        });
    }

    function editPortfolio(portfolioData) {
        // Загружаем студентов перед открытием формы редактирования
        mainApi.loadStudentsForPortfolio(function(response) {
            if (response.success) {
                portfolioFormWindow.students = response.data;
                portfolioFormWindow.openForEdit(portfolioData);
            } else {
                console.log("❌ Ошибка загрузки студентов:", response.error);
                showMessage("❌ Не удалось загрузить список студентов", "error");
            }
        });
    }

    function getStudentsByGroup(groupId, callback) {
        console.log("👥 Запрос студентов группы ID:", groupId);

        var endpoint = "/groups/" + groupId + "/students";
        sendRequest("GET", endpoint, null, function(response) {
            console.log("📨 Ответ студентов группы:", response);

            if (callback) {
                if (response.success) {
                    var studentsData = response.data || [];
                    var studentsArray = [];

                    if (studentsData && studentsData.data && Array.isArray(studentsData.data)) {
                        studentsArray = studentsData.data;
                    } else if (Array.isArray(studentsData)) {
                        studentsArray = studentsData;
                    }

                    callback({
                        success: true,
                        data: studentsArray,
                        status: response.status
                    });
                } else {
                    callback({
                        success: false,
                        error: response.error || "Ошибка загрузки студентов группы",
                        data: [],
                        status: response.status
                    });
                }
            }
        });
    }

    function getAllTeachersSpecializations(excludeTeacherId, callback) {
        console.log("📚 Загрузка всех специализаций преподавателей, исключая ID:", excludeTeacherId);

        getTeachers(function(response) {
            if (response.success) {
                var allSpecs = [];
                var teachers = response.data || [];

                console.log("👨‍🏫 Загружено преподавателей:", teachers.length);

                // Собираем ВСЕ специализации всех преподавателей, кроме исключенного
                for (var i = 0; i < teachers.length; i++) {
                    var teacher = teachers[i];

                    // Если это преподаватель, которого нужно исключить, пропускаем
                    if (excludeTeacherId && teacher.teacher_id === excludeTeacherId) {
                        console.log("🚫 Пропускаем преподавателя с ID:", excludeTeacherId);
                        continue;
                    }

                    console.log("🔍 Анализ преподавателя:", teacher.first_name, teacher.last_name);

                    // Обрабатываем разные форматы специализаций
                    if (teacher.specializations && Array.isArray(teacher.specializations)) {
                        console.log("📋 Формат 1: teacher.specializations - массив");
                        for (var j = 0; j < teacher.specializations.length; j++) {
                            var specObj = teacher.specializations[j];
                            var specName = specObj.name || specObj;
                            if (specName && specName.trim() !== "") {
                                allSpecs.push(specName.trim());
                                console.log("   ➕ Специализация:", specName.trim());
                            }
                        }
                    } else if (teacher.specialization && typeof teacher.specialization === 'string') {
                        console.log("📋 Формат 2: teacher.specialization - строка:", teacher.specialization);
                        var specArray = teacher.specialization.split(",").map(function(s) {
                            return s.trim();
                        }).filter(function(s) {
                            return s !== "";
                        });

                        for (var k = 0; k < specArray.length; k++) {
                            if (specArray[k].trim() !== "") {
                                allSpecs.push(specArray[k].trim());
                                console.log("   ➕ Специализация:", specArray[k].trim());
                            }
                        }
                    } else {
                        console.log("⚠️ Неизвестный формат специализаций:", teacher.specialization, teacher.specializations);
                    }
                }

                // Убираем дубликаты
                var uniqueSpecs = [];
                var seen = {};
                for (var m = 0; m < allSpecs.length; m++) {
                    var specName = allSpecs[m];
                    if (!seen[specName]) {
                        seen[specName] = true;
                        uniqueSpecs.push(specName);
                    }
                }

                console.log("✅ Уникальных специализаций найдено (исключая преподавателя", excludeTeacherId, "):", uniqueSpecs.length);

                if (callback) {
                    callback({
                        success: true,
                        data: uniqueSpecs
                    });
                }
            } else {
                console.log("❌ Ошибка загрузки преподавателей:", response.error);
                if (callback) {
                    callback({
                        success: false,
                        error: response.error
                    });
                }
            }
        });
    }

    function getEventCategories(callback) {
            sendRequest("GET", "/event-categories", null, function(response) {
                if (response.success) {
                    var categoriesData = response.data || {};
                    var categoriesArray = [];

                    if (categoriesData && categoriesData.data && Array.isArray(categoriesData.data)) {
                        categoriesArray = categoriesData.data;
                    } else if (Array.isArray(categoriesData)) {
                        categoriesArray = categoriesData;
                    }

                    console.log("📊 Получено категорий событий:", categoriesArray.length);

                    callback({
                        success: true,
                        data: categoriesArray,
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

            // Валидация длины полей согласно серверной схеме
            if (categoryData.event_type && categoryData.event_type.length > 24) {
                console.log("❌ Слишком длинное короткое наименование (макс. 24 символа)");
                if (callback) callback({
                    success: false,
                    error: "Короткое наименование (event_type) не должно превышать 24 символа"
                });
                return;
            }

            if (categoryData.category && categoryData.category.length > 64) {
                console.log("❌ Слишком длинное полное наименование (макс. 64 символа)");
                if (callback) callback({
                    success: false,
                    error: "Полное наименование (category) не должно превышать 64 символа"
                });
                return;
            }

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

            // Валидация длины полей
            if (categoryData.category && categoryData.category.length > 64) {
                console.log("❌ Слишком длинное полное наименование (макс. 64 символа)");
                if (callback) callback({
                    success: false,
                    error: "Полное наименование (category) не должно превышать 64 символа"
                });
                return;
            }

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

    function getPortfolioForEvents(callback) {
        console.log("📚 Загрузка списка портфолио для событий...");

        sendRequest("GET", "/portfolio", null, function(response) {
            console.log("📦 Получен ответ портфолио для событий:", JSON.stringify(response));

            if (response.success) {
                var portfolioData = [];

                // Анализируем структуру ответа
                if (response.data && response.data.data && Array.isArray(response.data.data)) {
                    console.log("✅ Формат 1: response.data.data - массив");
                    portfolioData = response.data.data;
                } else if (response.data && Array.isArray(response.data)) {
                    console.log("✅ Формат 2: response.data - массив");
                    portfolioData = response.data;
                } else if (response.data && typeof response.data === 'object') {
                    console.log("✅ Формат 3: response.data - объект, преобразуем в массив");
                    portfolioData = Object.keys(response.data).map(function(key) {
                        return response.data[key];
                    });
                } else {
                    console.log("❌ Неизвестный формат данных:", typeof response.data);
                    portfolioData = [];
                }

                console.log("📊 Извлечено записей портфолио:", portfolioData.length);

                // Фильтруем и форматируем данные
                var validPortfolios = portfolioData.filter(function(portfolio) {
                    // 🔥 ИСПРАВЛЕНИЕ: используем portfolio_id как measure_code
                    var isValid = portfolio && (portfolio.portfolio_id || portfolio.id) && (portfolio.portfolio_id || portfolio.id) > 0;
                    if (!isValid) {
                        console.log("⚠️ Отфильтровано невалидное портфолио:", portfolio);
                    }
                    return isValid;
                }).map(function(portfolio) {
                    // 🔥 ИСПРАВЛЕНИЕ: используем portfolio_id как measure_code
                    var measureCode = portfolio.portfolio_id || portfolio.id;
                    return {
                        measure_code: measureCode,
                        decree: portfolio.decree || 0,
                        student_code: portfolio.student_code || 0,
                        student_name: portfolio.student_name || "Студент #" + (portfolio.student_code || "?"),
                        date: portfolio.date || "",
                        portfolio_id: measureCode // Сохраняем оригинальный ID
                    };
                });

                console.log("✅ Валидных портфолио после фильтрации:", validPortfolios.length);

                if (validPortfolios.length > 0) {
                    console.log("📋 Примеры валидных портфолио:");
                    for (var i = 0; i < Math.min(3, validPortfolios.length); i++) {
                        var p = validPortfolios[i];
                        console.log("   " + p.measure_code + " - Приказ №" + p.decree + " - " + p.student_name);
                    }
                } else {
                    console.log("⚠️ Нет валидных портфолио для отображения");
                }

                callback({
                    success: true,
                    data: validPortfolios,
                    status: response.status
                });
            } else {
                console.log("❌ Ошибка загрузки портфолио:", response.error);
                callback({
                    success: false,
                    error: response.error || "Неизвестная ошибка при загрузке портфолио",
                    data: [],
                    status: response.status
                });
            }
        });
    }

    function debugGetPortfolio(callback) {
        console.log("🔍 Дебаг: Запрос портфолио...");
        sendRequest("GET", "/portfolio", null, function(response) {
            console.log("🔍 Дебаг: Полный ответ портфолио:", JSON.stringify(response, null, 2));

            if (response.success) {
                console.log("🔍 Дебаг: Успешный ответ, анализируем структуру...");
                console.log("🔍 Дебаг: Тип response.data:", typeof response.data);
                console.log("🔍 Дебаг: response.data keys:", response.data ? Object.keys(response.data) : "null");

                if (Array.isArray(response.data)) {
                    console.log("🔍 Дебаг: response.data - массив, длина:", response.data.length);
                    if (response.data.length > 0) {
                        console.log("🔍 Дебаг: Первый элемент:", JSON.stringify(response.data[0], null, 2));
                    }
                } else if (response.data && response.data.data) {
                    console.log("🔍 Дебаг: response.data.data - массив, длина:", response.data.data.length);
                    if (response.data.data.length > 0) {
                        console.log("🔍 Дебаг: Первый элемент data:", JSON.stringify(response.data.data[0], null, 2));
                    }
                }
            }

            if (callback) callback(response);
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
