import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15

Rectangle {
    id: newsView
    color: "transparent"

    property bool isMobile: Qt.platform.os === "android" || Qt.platform.os === "ios" ||
                           Qt.platform.os === "tvos" || Qt.platform.os === "wasm"
    property var newsList: []
    property var currentNews: null
    property bool isLoading: false

    // Обновление layout при изменении размеров
    onWidthChanged: Qt.callLater(updateLayout)
    onHeightChanged: Qt.callLater(updateLayout)

    function updateLayout() {
        // Принудительное обновление всех текстовых элементов
        if (currentNews && currentNews.content) {
            for (var i = 0; i < currentNews.content.length; i++) {
                if (mobileNewsContentColumn.children[i] && mobileNewsContentColumn.children[i].children[0]) {
                    mobileNewsContentColumn.children[i].children[0].updateLayout()
                }
                if (newsContentColumn.children[i] && newsContentColumn.children[i].children[0]) {
                    newsContentColumn.children[i].children[0].updateLayout()
                }
            }
        }
    }

    function loadNewsList() {
        isLoading = true

        mainWindow.mainApi.getNewsList(function(response) {
            isLoading = false

            if (response.success) {
                var responseData = response.data
                if (responseData && responseData.data && Array.isArray(responseData.data)) {
                    newsList = responseData.data
                } else if (responseData && Array.isArray(responseData)) {
                    newsList = responseData
                } else {
                    newsList = []
                }

                console.log("Загружено новостей:", newsList.length)

                if (newsList.length > 0 && !currentNews) {
                    loadNewsItem(newsList[0])
                }
            } else {
                console.log("Ошибка загрузки списка новостей:", response.error)
                mainWindow.showMessage("Ошибка загрузки списка новостей", "error")
            }
        })
    }

    function loadNewsItem(newsItem) {
        if (!newsItem || !newsItem.filename) {
            console.log("Неверный элемент новости")
            return
        }

        isLoading = true
        console.log("Загрузка новости:", newsItem.filename)

        mainWindow.mainApi.getNews(newsItem.filename, function(response) {
            isLoading = false

            if (response.success) {
                var newsData = response.data
                if (newsData && newsData.data) {
                    currentNews = newsData.data
                } else {
                    currentNews = newsData
                }

                if (currentNews) {
                    currentNews.filename = newsItem.filename
                    currentNews.title = newsItem.title || currentNews.title
                    currentNews.author = newsItem.author || currentNews.author
                    currentNews.date = newsItem.date || currentNews.date
                }

                console.log("Новость загружена:", currentNews ? currentNews.title : "null")

                // Обновляем layout после загрузки новости
                Qt.callLater(updateLayout)
            } else {
                console.log("Ошибка загрузки новости:", response.error)
                mainWindow.showMessage("Ошибка загрузки новости", "error")
            }
        })
    }

    Component.onCompleted: {
        console.log("NewsView инициализирован")
        loadNewsList()
    }

    // Мобильный layout - список сверху, контент снизу
    ColumnLayout {
        anchors.fill: parent
        spacing: 8
        visible: isMobile

        // Горизонтальный список новостей для мобильных
        Rectangle {
            id: mobileNewsList
            Layout.fillWidth: true
            Layout.preferredHeight: 110
            color: "#ffffff"
            radius: 12
            border.color: "#e0e0e0"
            border.width: 1
            visible: newsList.length > 0

            Column {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 5

                // Заголовок списка
                Row {
                    width: parent.width
                    spacing: 8

                    Image {
                        source: "qrc:/icons/news.png"
                        sourceSize: Qt.size(20, 20)
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "Новости"
                        font.pixelSize: 20  // УВЕЛИЧЕНО с 18
                        font.bold: true
                        color: "#2c3e50"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // Горизонтальный скролл новостей
                ScrollView {
                    width: parent.width
                    height: parent.height - 30
                    clip: true
                    ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                    ScrollBar.horizontal.policy: ScrollBar.AsNeeded
                    contentWidth: newsRow.width
                    contentHeight: availableHeight

                    Row {
                        id: newsRow
                        spacing: 10
                        height: parent.height

                        Repeater {
                            model: newsList

                            delegate: Rectangle {
                                width: 140
                                height: 50
                                radius: 8
                                color: currentNews && currentNews.filename === modelData.filename ?
                                       "#e3f2fd" : (mobileNewsMouseArea.containsMouse ? "#f5f5f5" : "#fafafa")
                                border.color: currentNews && currentNews.filename === modelData.filename ?
                                            "#3498db" : "#e0e0e0"
                                border.width: 2

                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    spacing: 4

                                    Text {
                                        text: modelData.title || "Без названия"
                                        font.pixelSize: 14
                                        font.bold: true
                                        color: "#2c3e50"
                                        width: parent.width
                                        elide: Text.ElideRight
                                        maximumLineCount: 2
                                        wrapMode: Text.WordWrap
                                    }

                                    Text {
                                        text: modelData.date || ""
                                        font.pixelSize: 12
                                        color: "#7f8c8d"
                                        width: parent.width
                                        elide: Text.ElideRight
                                        maximumLineCount: 1
                                    }
                                }

                                MouseArea {
                                    id: mobileNewsMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: loadNewsItem(modelData)
                                }
                            }
                        }
                    }
                }
            }
        }

        // Контент новости для мобильных
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#ffffff"
            radius: 12
            border.color: "#e0e0e0"
            border.width: 1

            onWidthChanged: Qt.callLater(updateLayout)
            onHeightChanged: Qt.callLater(updateLayout)

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 10

                // Заголовок новости
                Text {
                    id: mobileNewsTitle
                    Layout.fillWidth: true
                    text: currentNews ? currentNews.title : "Выберите новость"
                    font.pixelSize: 24
                    font.bold: true
                    color: "#2c3e50"
                    wrapMode: Text.WordWrap
                    maximumLineCount: 3
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                    visible: currentNews
                }

                // Автор и дата для мобильных
                Column {
                    Layout.fillWidth: true
                    spacing: 6
                    visible: currentNews

                    Row {
                        spacing: 6
                        width: parent.width

                        Image {
                            source: "qrc:/icons/profile.png"
                            sourceSize: Qt.size(20, 20)
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: currentNews ? (currentNews.author || "Неизвестный автор") : ""
                            font.pixelSize: 16
                            color: "#7f8c8d"
                            anchors.verticalCenter: parent.verticalCenter
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }
                    }

                    Row {
                        spacing: 6
                        width: parent.width

                        Image {
                            source: "qrc:/icons/calendar.png"
                            sourceSize: Qt.size(16, 16)
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: currentNews ? (currentNews.date || "Дата не указана") : ""
                            font.pixelSize: 16
                            color: "#7f8c8d"
                            anchors.verticalCenter: parent.verticalCenter
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }
                    }
                }

                // Разделитель
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#3498db"
                    opacity: 0.3
                    visible: currentNews
                }

                // Контент новости
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: currentNews
                    ScrollBar.vertical.policy: ScrollBar.AsNeeded
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    contentWidth: availableWidth
                    contentHeight: mobileNewsContentColumn.height
                    clip: true

                    Column {
                        id: mobileNewsContentColumn
                        width: parent.width
                        spacing: 8

                        Repeater {
                            model: currentNews ? currentNews.content : []

                            delegate: Column {
                                width: parent.width
                                spacing: 2

                                FormattedText {
                                    width: parent.width
                                    text: modelData.text || ""
                                    formats: modelData.formats || []
                                    alignment: modelData.alignment || "left"
                                    isMobile: newsView.isMobile
                                }

                                // Разделитель после заголовков
                                Rectangle {
                                    width: parent.width
                                    height: 2
                                    color: "#3498db"
                                    opacity: 0.5
                                    visible: {
                                        if (!modelData.formats || !Array.isArray(modelData.formats))
                                            return false;

                                        for (var i = 0; i < modelData.formats.length; i++) {
                                            var formatType = modelData.formats[i].type;
                                            if (formatType === "header1" || formatType === "header2" || formatType === "header3")
                                                return true;
                                        }
                                        return false;
                                    }
                                }
                            }
                        }
                    }
                }

                // Сообщение при отсутствии выбранной новости
                Column {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 12
                    visible: !currentNews

                    Image {
                        source: "qrc:/icons/news.png"
                        sourceSize: Qt.size(80, 80)
                        anchors.horizontalCenter: parent.horizontalCenter
                        opacity: 0.5
                    }

                    Text {
                        text: "Выберите новость из списка выше"
                        font.pixelSize: 18
                        color: "#7f8c8d"
                        anchors.horizontalCenter: parent.horizontalCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }
    }

    // Десктопный layout - список справа, контент слева
    RowLayout {
        anchors.fill: parent
        spacing: 12
        visible: !isMobile

        // Область контента новости
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#ffffff"
            radius: 12
            border.color: "#e0e0e0"
            border.width: 1

            onWidthChanged: Qt.callLater(updateLayout)
            onHeightChanged: Qt.callLater(updateLayout)

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 12

                // Заголовок новости
                Text {
                    id: newsTitle
                    Layout.fillWidth: true
                    text: currentNews ? currentNews.title : "Выберите новость"
                    font.pixelSize: 32
                    font.bold: true
                    color: "#2c3e50"
                    wrapMode: Text.WordWrap
                    maximumLineCount: 3
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                    visible: currentNews
                }

                // Автор и дата
                Row {
                    Layout.fillWidth: true
                    spacing: 15
                    visible: currentNews

                    Row {
                        spacing: 6
                        width: Math.min(parent.width * 0.4, implicitWidth)

                        Image {
                            source: "qrc:/icons/profile.png"
                            sourceSize: Qt.size(16, 16)
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: currentNews ? (currentNews.author || "Неизвестный автор") : ""
                            font.pixelSize: 16
                            color: "#7f8c8d"
                            anchors.verticalCenter: parent.verticalCenter
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }
                    }

                    Row {
                        spacing: 6
                        width: Math.min(parent.width * 0.4, implicitWidth)

                        Image {
                            source: "qrc:/icons/calendar.png"
                            sourceSize: Qt.size(16, 16)
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: currentNews ? (currentNews.date || "Дата не указана") : ""
                            font.pixelSize: 16
                            color: "#7f8c8d"
                            anchors.verticalCenter: parent.verticalCenter
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }
                    }
                }

                // Разделитель
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#3498db"
                    opacity: 0.3
                    visible: currentNews
                }

                // Контент новости с поддержкой копирования
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: currentNews
                    ScrollBar.vertical.policy: ScrollBar.AsNeeded
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    contentWidth: availableWidth
                    contentHeight: newsContentColumn.height
                    clip: true

                    Column {
                        id: newsContentColumn
                        width: parent.width
                        spacing: 10

                        Repeater {
                            model: currentNews ? currentNews.content : []

                            delegate: Column {
                                width: parent.width
                                spacing: 2

                                FormattedText {
                                    width: parent.width
                                    text: modelData.text || ""
                                    formats: modelData.formats || []
                                    alignment: modelData.alignment || "left"
                                    isMobile: newsView.isMobile
                                }

                                // Разделитель после заголовков
                                Rectangle {
                                    width: parent.width
                                    height: 2
                                    color: "#3498db"
                                    opacity: 0.5
                                    visible: {
                                        if (!modelData.formats || !Array.isArray(modelData.formats))
                                            return false;

                                        for (var i = 0; i < modelData.formats.length; i++) {
                                            var formatType = modelData.formats[i].type;
                                            if (formatType === "header1" || formatType === "header2" || formatType === "header3")
                                                return true;
                                        }
                                        return false;
                                    }
                                }
                            }
                        }
                    }
                }

                // Сообщение при отсутствии выбранной новости
                Column {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 12
                    visible: !currentNews

                    Image {
                        source: "qrc:/icons/news.png"
                        sourceSize: Qt.size(100, 100)
                        anchors.horizontalCenter: parent.horizontalCenter
                        opacity: 0.5
                    }

                    Text {
                        text: "Выберите новость из списка справа"
                        font.pixelSize: 20
                        color: "#7f8c8d"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }

        // Список новостей (справа на десктопе)
        Rectangle {
            id: newsListContainer
            Layout.preferredWidth: 280
            Layout.fillHeight: true
            color: "#ffffff"
            radius: 12
            border.color: "#e0e0e0"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 8

                // Заголовок списка новостей
                Row {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 8

                    Image {
                        source: "qrc:/icons/news.png"
                        sourceSize: Qt.size(20, 20)
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "Новости"
                        font.pixelSize: 20
                        font.bold: true
                        color: "#2c3e50"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // Разделитель
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#3498db"
                    opacity: 0.3
                }

                // Список новостей
                ListView {
                    id: newsListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: newsList
                    clip: true
                    spacing: 6
                    boundsBehavior: Flickable.StopAtBounds

                    delegate: Rectangle {
                        width: newsListView.width
                        height: 70
                        radius: 6
                        color: currentNews && currentNews.filename === modelData.filename ?
                               "#e3f2fd" : (mouseArea.containsMouse ? "#f5f5f5" : "#fafafa")
                        border.color: currentNews && currentNews.filename === modelData.filename ?
                                    "#3498db" : "transparent"
                        border.width: 2

                        Column {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 4

                            Text {
                                text: modelData.title || "Без названия"
                                font.pixelSize: 15
                                font.bold: true
                                color: "#2c3e50"
                                width: parent.width
                                elide: Text.ElideRight
                                maximumLineCount: 2
                                wrapMode: Text.WordWrap
                            }

                            Row {
                                width: parent.width
                                spacing: 8

                                Row {
                                    spacing: 4
                                    width: Math.min(parent.width * 0.5, implicitWidth)

                                    Image {
                                        source: "qrc:/icons/user.png"
                                        sourceSize: Qt.size(10, 10)
                                        visible: modelData.author
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: modelData.author || ""
                                        font.pixelSize: 12
                                        color: "#7f8c8d"
                                        visible: modelData.author
                                        anchors.verticalCenter: parent.verticalCenter
                                        elide: Text.ElideRight
                                        maximumLineCount: 1
                                    }
                                }

                                Text {
                                    text: "•"
                                    font.pixelSize: 10
                                    color: "#7f8c8d"
                                    visible: modelData.author && modelData.date
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Row {
                                    spacing: 4
                                    width: Math.min(parent.width * 0.4, implicitWidth)

                                    Image {
                                        source: "qrc:/icons/calendar.png"
                                        sourceSize: Qt.size(10, 10)
                                        visible: modelData.date
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: modelData.date || ""
                                        font.pixelSize: 12
                                        color: "#7f8c8d"
                                        visible: modelData.date
                                        anchors.verticalCenter: parent.verticalCenter
                                        elide: Text.ElideRight
                                        maximumLineCount: 1
                                    }
                                }
                            }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: loadNewsItem(modelData)
                        }
                    }

                    Rectangle {
                        visible: newsList.length === 0 && !isLoading
                        width: parent.width
                        height: 60
                        color: "transparent"

                        Column {
                            anchors.centerIn: parent
                            spacing: 8

                            Image {
                                source: "qrc:/icons/news.png"
                                sourceSize: Qt.size(24, 24)
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text: "Новостей нет"
                                color: "#7f8c8d"
                                font.pixelSize: 16
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                }
            }
        }
    }

    // Индикатор загрузки
    Rectangle {
        anchors.fill: parent
        color: "#ccffffff"
        visible: isLoading
        z: 10

        Column {
            anchors.centerIn: parent
            spacing: 12

            BusyIndicator {
                anchors.horizontalCenter: parent.horizontalCenter
                width: isMobile ? 30 : 40
                height: isMobile ? 30 : 40
                running: isLoading
            }

            Text {
                text: "Загрузка..."
                font.pixelSize: isMobile ? 16 : 18
                color: "#2c3e50"
            }
        }
    }
}
