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

        // Отправляем DELETE запрос без тела
        sendRequest("DELETE", endpoint, null, function(response) {

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

    function getNewsList(callback) {
        sendRequest("GET", "/news", null, function(response) {
            if (callback) callback(response);
        });
    }

    function getNews(filename, callback) {
        // Кодируем имя файла для правильной передачи русских символов
        var encodedFilename = encodeURIComponent(filename);

        sendRequest("GET", "/news/" + encodedFilename, null, function(response) {
            if (callback) callback(response);
        });
    }

    function addNews(newsData, callback) {
        sendRequest("POST", "/news", newsData, function(response) {
            if (callback) callback(response);
        });
    }

    function updateNews(filename, newsData, callback) {
        sendRequest("PUT", "/news/" + filename, newsData, function(response) {
            if (callback) callback(response);
        });
    }

    function deleteNews(filename, callback) {
        sendRequest("DELETE", "/news/" + filename, null, function(response) {
            if (callback) callback(response);
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
                    console.log("Токен невалиден, очищаем...");
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
                console.log("Тест соединения с", baseUrl, ":", success ? "УСПЕХ" : "НЕУДАЧА");
                if (callback) callback(success);
            }
        };

        testXhr.ontimeout = function() {
            console.log("Таймаут теста соединения с", baseUrl);
            if (callback) callback(false);
        };

        testXhr.onerror = function() {
            console.log("Ошибка теста соединения с", baseUrl);
            if (callback) callback(false);
        };

        try {
            var testUrl = baseUrl + "/status";
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
            console.log("Ошибка теста соединения:", error);
            if (callback) callback(false);
        }
    }

    function getDashboard(callback) {
        sendRequest("GET", "/dashboard", null, function(response) {

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
                console.log("Ошибка загрузки преподавателей, возвращаем пустой массив");
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
                console.log("Ошибка загрузки студентов, возвращаем пустой массив");
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
                console.log("Ошибка загрузки групп, возвращаем пустой массив");
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
        authToken = "";
        baseUrl = "";
        tokenValid = false;
        tokenStatus = "очищен";
        settingsManager.authToken = "";
        console.log("Аутентификация очищена");
    }

    function getPortfolio(callback) {
        sendRequest("GET", "/portfolio", null, function(response) {
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

        // Согласуем с серверными требованиями
        var cleanPortfolioData = {
            student_code: portfolioData.student_code,
            date: portfolioData.date,
            decree: portfolioData.decree
        };

        sendRequest("POST", "/portfolio", cleanPortfolioData, function(response) {

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

        var endpoint = "/portfolio/" + portfolioId;
        sendRequest("PUT", endpoint, portfolioData, function(response) {

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
                var eventsData = response.data || {};
                var eventsArray = [];

                if (eventsData && eventsData.data && Array.isArray(eventsData.data)) {
                    eventsArray = eventsData.data;
                } else if (Array.isArray(eventsData)) {
                    eventsArray = eventsData;
                } else if (eventsData && Array.isArray(eventsData.events)) {
                    eventsArray = eventsData.events;
                } else {
                    eventsArray = [];
                }

                // ПРЕОБРАЗУЕМ ПОЛЯ ДЛЯ СОВМЕСТИМОСТИ
                var formattedEvents = eventsArray.map(function(event) {
                    var formattedEvent = {
                        id: event.id || 0,
                        eventId: event.event_id || event.eventId || 0,
                        eventType: event.event_type || event.eventType || "",
                        category: event.category || "", // 🔥 ЭТО поле должно сохраняться!
                        startDate: event.start_date || event.startDate || "",
                        endDate: event.end_date || event.endDate || "",
                        location: event.location || "",
                        lore: event.lore || "",
                        maxParticipants: event.max_participants || event.maxParticipants || 0,
                        currentParticipants: event.current_participants || event.currentParticipants || 0,
                        status: event.status || "active"
                    };

                    return formattedEvent;
                });

                callback({
                    success: true,
                    data: formattedEvents,
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

    function openPortfolioForm() {
        // Загружаем студентов перед открытием формы
        mainApi.loadStudentsForPortfolio(function(response) {
            if (response.success) {
                portfolioFormWindow.students = response.data;
                portfolioFormWindow.openForAdd();
            } else {
                showMessage("Не удалось загрузить список студентов", "error");
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
                console.log("Ошибка загрузки студентов:", response.error);
                showMessage("Не удалось загрузить список студентов", "error");
            }
        });
    }

    function getStudentsByGroup(groupId, callback) {

        var endpoint = "/groups/" + groupId + "/students";
        sendRequest("GET", endpoint, null, function(response) {

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
        getTeachers(function(response) {
            if (response.success) {
                var allSpecs = [];
                var teachers = response.data || [];

                // Собираем ВСЕ специализации всех преподавателей, кроме исключенного
                for (var i = 0; i < teachers.length; i++) {
                    var teacher = teachers[i];

                    // Если это преподаватель, которого нужно исключить, пропускаем
                    if (excludeTeacherId && teacher.teacher_id === excludeTeacherId) {
                        continue;
                    }

                    // Обрабатываем разные форматы специализаций
                    if (teacher.specializations && Array.isArray(teacher.specializations)) {
                        for (var j = 0; j < teacher.specializations.length; j++) {
                            var specObj = teacher.specializations[j];
                            var specName = specObj.name || specObj;
                            if (specName && specName.trim() !== "") {
                                allSpecs.push(specName.trim());
                            }
                        }
                    } else if (teacher.specialization && typeof teacher.specialization === 'string') {
                        var specArray = teacher.specialization.split(",").map(function(s) {
                            return s.trim();
                        }).filter(function(s) {
                            return s !== "";
                        });

                        for (var k = 0; k < specArray.length; k++) {
                            if (specArray[k].trim() !== "") {
                                allSpecs.push(specArray[k].trim());
                            }
                        }
                    } else {
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

                if (callback) {
                    callback({
                        success: true,
                        data: uniqueSpecs
                    });
                }
            } else {
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

                    callback({
                        success: true,
                        data: categoriesArray,
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

        var cleanEventData = {
            event_type: eventData.eventType,
            category: eventData.category,
            measureCode: eventData.measureCode,
            start_date: eventData.startDate,
            end_date: eventData.endDate,
            location: eventData.location,
            lore: eventData.lore
        };

        sendRequest("POST", "/events", cleanEventData, function(response) {
            if (callback) callback(response);
        });
    }

    function updateEvent(eventId, eventData, callback) {
        var endpoint = "/events/" + eventId;

        var updateData = {
            event_type: eventData.eventType,
            category: eventData.category,
            measure_code: eventData.measureCode,
            start_date: eventData.startDate,
            end_date: eventData.endDate,
            location: eventData.location,
            lore: eventData.lore
        };

        sendRequest("PUT", endpoint, updateData, function(response) {
            if (callback) callback(response);
        });
    }

    function deleteEvent(eventId, callback) {
        var endpoint = "/events/" + eventId;

        sendRequest("DELETE", endpoint, null, function(response) {
            if (callback) callback(response);
        });
    }

    function getPortfolioForEvents(callback) {

        sendRequest("GET", "/portfolio", null, function(response) {

            if (response.success) {
                var portfolioData = [];

                // Анализируем структуру ответа
                if (response.data && response.data.data && Array.isArray(response.data.data)) {
                    portfolioData = response.data.data;
                } else if (response.data && Array.isArray(response.data)) {
                    portfolioData = response.data;
                } else if (response.data && typeof response.data === 'object') {
                    portfolioData = Object.keys(response.data).map(function(key) {
                        return response.data[key];
                    });
                } else {
                    portfolioData = [];
                }

                // Фильтруем и форматируем данные
                var validPortfolios = portfolioData.filter(function(portfolio) {
                    var isValid = portfolio && (portfolio.portfolio_id || portfolio.id) && (portfolio.portfolio_id || portfolio.id) > 0;
                    return isValid;
                }).map(function(portfolio) {
                    var measureCode = portfolio.portfolio_id || portfolio.id;
                    return {
                        measure_code: measureCode,
                        decree: portfolio.decree || 0,
                        student_code: portfolio.student_code || 0,
                        student_name: portfolio.student_name || "Студент #" + (portfolio.student_code || "?"),
                        date: portfolio.date || "",
                        portfolio_id: measureCode
                    };
                });

                callback({
                    success: true,
                    data: validPortfolios,
                    status: response.status
                });
            } else {
                console.log("Ошибка загрузки портфолио:", response.error);
                callback({
                    success: false,
                    error: response.error || "Неизвестная ошибка при загрузке портфолио",
                    data: [],
                    status: response.status
                });
            }
        });
    }

    function getProfile(callback) {
        sendRequest("GET", "/profile", null, function(response) {

            if (response.success) {
                var profileData = response.data || {}

                if (callback) {
                    callback({
                        success: true,
                        data: profileData,
                        status: response.status
                    });
                }
            } else {
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

    function validateToken(callback) {
        var requestData = {
            token: authToken
        };

        sendRequest("POST", "/verify-token", requestData, function(response) {
            if (callback) callback(response);
        });
    }

    function addTeacher(teacherData, callback) {

        var endpoint = "/teachers";
        sendRequest("POST", endpoint, teacherData, function(response) {

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

        var endpoint = "/students";
        sendRequest("POST", endpoint, studentData, function(response) {

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

        var endpoint = "/students/" + studentCode;
        sendRequest("PUT", endpoint, studentData, function(response) {

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

        var endpoint = "/students/" + studentCode;
        sendRequest("DELETE", endpoint, null, function(response) {

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

        var endpoint = "/groups";
        sendRequest("POST", endpoint, groupData, function(response) {

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

        var endpoint = "/groups/" + groupId;
        sendRequest("PUT", endpoint, groupData, function(response) {

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

        var endpoint = "/groups/" + groupId;
        sendRequest("DELETE", endpoint, null, function(response) {

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

        var numericTeacherId = parseInt(teacherId);
        if (isNaN(numericTeacherId)) {
            if (callback) callback({
                success: false,
                error: "Неверный ID преподавателя"
            });
            return;
        }

        var endpoint = "/teachers/" + numericTeacherId;
        sendRequest("PUT", endpoint, teacherData, function(response) {

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

        var endpoint = "/teachers/" + teacherId;
        sendRequest("DELETE", endpoint, null, function(response) {

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
            xhr.timeout = 7500 // 7.5 секунд для windows
        } else if (Qt.platform.os === "android") {
            xhr.timeout = 7500 // 7.5 секунд для android
        } else {
            xhr.timeout = 4500; // 4.5 секунд для других ОС
        }

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
                            status: xhr.status
                        });
                    } catch (error) {
                        if (callback) callback({
                            success: false,
                            error: "Ошибка формата ответа: " + error.toString(),
                            status: xhr.status
                        });
                    }
                } else if (xhr.status === 0) {
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
                    if (callback) callback({
                        success: false,
                        error: "Ошибка доступа (401). Токен невалиден.",
                        status: xhr.status
                    });
                } else {
                    try {
                        var errorResponse = JSON.parse(xhr.responseText);

                        if (callback) callback({
                            success: false,
                            error: errorResponse.error || "Ошибка сервера (" + xhr.status + ")",
                            status: xhr.status
                        });
                    } catch (e) {
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
            console.log("Таймаут запроса к ", url);
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
            var networkErrorMsg = "Ошибка сети, возможно у вас включён VPN, неправильно введенные параметры подключения к серверу, или плохая связь.";

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
            }

            if (data) {
                var requestBody = JSON.stringify(data);
                xhr.send(requestBody);
            } else {
                xhr.send();
            }
        } catch (error) {
            console.log("  Критическая ошибка отправки:", error);
            if (callback) callback({
                success: false,
                error: "Ошибка отправки запроса: " + error.toString(),
                status: 0
            });
        }
    }
}
