import QtQuick
import QtQuick.Layouts 1.15
import QtQuick.Controls
import "../../enhanced" as Enhanced

Item {
    id: portfolioView

    property var portfolios: []
    property var students: []
    property var events: []
    property bool isLoading: false
    property bool isMobile: Qt.platform.os === "android" || Qt.platform.os === "ios" ||
                           Qt.platform.os === "tvos" || Qt.platform.os === "wasm"

    function refreshPortfolios() {
        isLoading = true;
        mainWindow.mainApi.getPortfolio(function(response) {
            isLoading = false;
            if (response && response.success) {

                var responseData = response.data;
                var portfoliosData = [];

                if (responseData && responseData.data && Array.isArray(responseData.data)) {
                    portfoliosData = responseData.data;
                } else if (responseData && Array.isArray(responseData)) {
                    portfoliosData = responseData;
                } else if (responseData && responseData.success && Array.isArray(responseData.data)) {
                    portfoliosData = responseData.data;
                }

                var processedPortfolios = [];

                for (var i = 0; i < portfoliosData.length; i++) {
                    var portfolio = portfoliosData[i];
                    var studentName = getStudentName(portfolio.studentCode || portfolio.student_code);

                    var processedPortfolio = {
                        portfolioId: portfolio.portfolioId || portfolio.portfolio_id,
                        studentCode: portfolio.studentCode || portfolio.student_code,
                        studentName: studentName,
                        date: portfolio.date || "",
                        decree: portfolio.decree || "",
                        eventId: portfolio.eventId || portfolio.event_id,
                        eventName: getEventName(portfolio.eventId || portfolio.event_id)
                    };
                    processedPortfolios.push(processedPortfolio);
                }

                portfolioView.portfolios = processedPortfolios;
            } else {
                var errorMsg = response && response.error ? response.error : "Неизвестная ошибка";
                showMessage("Ошибка загрузки портфолио: " + errorMsg, "error");
            }
        });
    }

    function refreshStudents() {
        mainWindow.mainApi.getStudents(function(response) {
            if (response && response.success) {
                portfolioView.students = response.data || [];
                refreshEvents();
            } else {
                var errorMsg = response && response.error ? response.error : "Неизвестная ошибка";
                showMessage("Ошибка загрузки студентов: " + errorMsg, "error");
            }
        });
    }

    function refreshEvents() {
        mainWindow.mainApi.getEvents(function(response) {
            if (response && response.success) {
                portfolioView.events = response.data || [];
                refreshPortfolios();
            } else {
                var errorMsg = response && response.error ? response.error : "Неизвестная ошибка";
                showMessage("Ошибка загрузки событий: " + errorMsg, "error");
            }
        });
    }

    function showMessage(text, type) {
        if (mainWindow && mainWindow.showMessage) {
            mainWindow.showMessage(text, type);
        }
    }

    function getStudentName(studentCode) {
        if (!studentCode) {
            return "Неизвестный студент";
        }

        var studentsList = students || [];
        for (var i = 0; i < studentsList.length; i++) {
            var student = studentsList[i];
            if (!student) continue;

            var currentStudentCode = student.studentCode || student.student_code;
            if (currentStudentCode === studentCode) {
                var lastName = student.lastName || student.last_name || "";
                var firstName = student.firstName || student.first_name || "";
                var middleName = student.middleName || student.middle_name || "";
                return [lastName, firstName, middleName].filter(Boolean).join(" ") || "Неизвестный студент";
            }
        }
        return "Неизвестный студент";
    }

    function getEventName(eventId) {
        if (!eventId) {
            return "Без события";
        }

        var eventsList = events || [];
        for (var i = 0; i < eventsList.length; i++) {
            var event = eventsList[i];
            if (!event) continue;

            var currentEventId = event.eventId || event.event_id;
            if (currentEventId === eventId) {
                return event.eventType || event.event_type || "Без названия";
            }
        }
        return "Неизвестное событие";
    }

    function addPortfolio(portfolioData) {
        if (!portfolioData) {
            showMessage("Данные портфолио не указаны", "error");
            return;
        }

        isLoading = true;

        mainWindow.mainApi.addPortfolio(portfolioData, function(response) {
            isLoading = false;
            if (response && response.success) {
                showMessage(((response.message || response.data && response.data.message) || "Портфолио успешно добавлено"), "success");
                if (portfolioFormWindow.item) {
                    portfolioFormWindow.close();
                }
                refreshPortfolios();
            } else {
                var errorMsg = response && response.error ? response.error : "Неизвестная ошибка";
                showMessage("Ошибка добавления портфолио: " + errorMsg, "error");
                if (portfolioFormWindow.item) {
                    portfolioFormWindow.item.isSaving = false;
                }
            }
        });
    }

    function updatePortfolio(portfolioData) {
        if (!portfolioData) {
            showMessage("Данные портфолио не указаны", "error");
            return;
        }

        var portfolioId = portfolioData.portfolio_id || portfolioData.portfolioId;
        if (!portfolioId) {
            showMessage("ID портфолио не указан", "error");
            return;
        }

        isLoading = true;

        mainWindow.mainApi.updatePortfolio(portfolioId, portfolioData, function(response) {
            isLoading = false;
            if (response && response.success) {
                showMessage(((response.message || response.data && response.data.message) || "Портфолио успешно обновлено"), "success");
                if (portfolioFormWindow.item) {
                    portfolioFormWindow.close();
                }
                refreshPortfolios();
            } else {
                var errorMsg = response && response.error ? response.error : "Неизвестная ошибка";
                showMessage("Ошибка обновления портфолио: " + errorMsg, "error");
                if (portfolioFormWindow.item) {
                    portfolioFormWindow.item.isSaving = false;
                }
            }
        });
    }

    function deletePortfolio(portfolioId, portfolioDescription) {
        if (!portfolioId) {
            showMessage("ID портфолио не указан", "error");
            return;
        }

        if (confirm("Вы уверены, что хотите удалить портфолио:\n" + (portfolioDescription || "Без описания") + "?")) {
            isLoading = true;
            mainWindow.mainApi.deletePortfolio(portfolioId, function(response) {
                isLoading = false;
                if (response && response.success) {
                    showMessage(((response.message || response.data && response.data.message) || "Портфолио успешно удалено"), "success");
                    refreshPortfolios();
                } else {
                    var errorMsg = response && response.error ? response.error : "Неизвестная ошибка";
                    showMessage("Ошибка удаления портфолио: " + errorMsg, "error");
                }
            });
        }
    }

    function confirm(message) {
        console.log("Подтверждение:", message);
        return true;
    }

    Component.onCompleted: {
        console.log("PortfolioView: Component.onCompleted");
        refreshStudents();
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 15

        Column {
            Layout.fillWidth: true
            spacing: 8

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10

                Image {
                    source: "qrc:/icons/portfolio.png"
                    sourceSize: Qt.size(24, 24)
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "Управление портфолио"
                    font.pixelSize: 20
                    font.bold: true
                    color: "#2c3e50"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: "#e0e0e0"
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 50
            radius: 8
            color: "#9b59b6"
            border.color: "#8e44ad"
            border.width: 1

            // Мобильная версия - центрированные большие кнопки
            Row {
                anchors.centerIn: parent
                spacing: isMobile ? 30 : 15
                visible: isMobile

                // Кнопка обновления для мобильных
                Rectangle {
                    width: 50
                    height: 50
                    radius: 25
                    color: refreshMouseAreaMobile.containsPress ? "#8e44ad" : "transparent"

                    Image {
                        source: "qrc:/icons/refresh.png"
                        sourceSize: Qt.size(28, 28)
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        id: refreshMouseAreaMobile
                        anchors.fill: parent
                        onClicked: refreshPortfolios()
                    }
                }

                // Текст счетчика для мобильных
                Text {
                    text: "Всего: " + (portfolios ? portfolios.length : 0)
                    color: "white"
                    font.pixelSize: 16
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Кнопка добавления для мобильных
                Rectangle {
                    width: 50
                    height: 50
                    radius: 25
                    color: addMouseAreaMobile.containsPress ? "#8e44ad" : "transparent"

                    Text {
                        text: "+"
                        color: "white"
                        font.pixelSize: 32
                        font.bold: true
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        id: addMouseAreaMobile
                        anchors.fill: parent
                        onClicked: {
                            if (portfolioFormWindow.item) {
                                portfolioFormWindow.openForAdd();
                            } else {
                                portfolioFormWindow.active = true;
                            }
                        }
                    }
                }
            }

            // Десктопная версия - без изменений
            Row {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 15
                visible: !isMobile

                Text {
                    text: "Всего портфолио: " + (portfolios ? portfolios.length : 0)
                    color: "white"
                    font.pixelSize: 14
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }

                Item { width: 20 }

                Rectangle {
                    width: 100
                    height: 30
                    radius: 6
                    color: refreshMouseAreaDesktop.containsMouse ? "#8e44ad" : "#9b59b6"
                    border.color: refreshMouseAreaDesktop.containsMouse ? "#6c3483" : "white"
                    border.width: 2

                    Row {
                        anchors.centerIn: parent
                        spacing: 5

                        Image {
                            source: "qrc:/icons/refresh.png"
                            sourceSize: Qt.size(20, 20)
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "Обновить"
                            color: "white"
                            font.pixelSize: 12
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: refreshMouseAreaDesktop
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: refreshPortfolios()
                    }
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    width: 150
                    height: 30
                    radius: 6
                    color: addMouseAreaDesktop.containsMouse ? "#8e44ad" : "#9b59b6"
                    border.color: addMouseAreaDesktop.containsMouse ? "#6c3483" : "white"
                    border.width: 2

                    Row {
                        anchors.centerIn: parent
                        spacing: 5

                        Image {
                            source: "qrc:/icons/portfolio.png"
                            sourceSize: Qt.size(12, 12)
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "Добавить портфолио"
                            color: "white"
                            font.pixelSize: 12
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: addMouseAreaDesktop
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (portfolioFormWindow.item) {
                                portfolioFormWindow.openForAdd();
                            } else {
                                portfolioFormWindow.active = true;
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 30
            radius: 6
            color: "#fff3cd"
            border.color: "#ffeaa7"
            border.width: 1
            visible: isLoading

            Row {
                anchors.centerIn: parent
                spacing: 10

                Image {
                    source: "qrc:/icons/loading.png"
                    sourceSize: Qt.size(14, 14)
                }

                Text {
                    text: "Загрузка данных..."
                    color: "#856404"
                    font.pixelSize: 12
                    font.bold: true
                }
            }
        }

        Enhanced.EnhancedTableView {
            id: portfolioTable
            Layout.fillWidth: true
            Layout.fillHeight: true
            sourceModel: portfolioView.portfolios || []
            itemType: "portfolio"
            searchPlaceholder: "Поиск по студенту или приказу..."
            sortOptions: ["По студенту", "По дате", "По приказу"]
            sortRoles: ["studentName", "date", "decree"]

            onItemEditRequested: function(itemData) {
                if (!itemData) return;
                if (portfolioFormWindow.item) {
                    portfolioFormWindow.openForEdit(itemData);
                } else {
                    portfolioFormWindow.active = true;
                }
            }

            onItemDoubleClicked: function(itemData) {
                if (portfolioFormWindow.item) {
                    portfolioFormWindow.openForEdit(itemData);
                } else {
                    portfolioFormWindow.active = true;
                }
            }

            onItemDeleteRequested: function(itemData) {
                if (!itemData) return;
                var portfolioId = itemData.portfolioId;
                var description = itemData.description || "Без описания";
                deletePortfolio(portfolioId, description);
            }
        }
    }

    // Загрузчик формы портфолио
    Loader {
        id: portfolioFormWindow
        source: isMobile ? "../forms/PortfolioFormMobile.qml" : "../forms/PortfolioFormWindow.qml"
        active: true

        onLoaded: {
            if (item) {
                item.saved.connect(function(portfolioData) {
                    if (!portfolioData) return;

                    if (portfolioData.portfolio_id && portfolioData.portfolio_id !== 0) {
                        updatePortfolio(portfolioData);
                    } else {
                        addPortfolio(portfolioData);
                    }
                });

                item.cancelled.connect(function() {
                    if (item) {
                        item.closeWindow();
                    }
                });
            }
        }

        function openForAdd() {
            if (portfolioFormWindow.item) {
                portfolioFormWindow.item.students = portfolioView.students || [];
                portfolioFormWindow.item.openForAdd();
            } else {
                portfolioFormWindow.active = true;
            }
        }

        function openForEdit(portfolioData) {
            if (portfolioFormWindow.item) {
                portfolioFormWindow.item.students = portfolioView.students || [];
                portfolioFormWindow.item.openForEdit(portfolioData);
            } else {
                portfolioFormWindow.active = true;
            }
        }

        function close() {
            if (portfolioFormWindow.item) {
                portfolioFormWindow.item.closeWindow();
            }
        }
    }
}
