// FAQView.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.15

Rectangle {
    id: faqView
    color: "transparent"
    property bool isMobile: false

    property var faqItems: [
        {
            question: "Что это за проект?",
            answer: "Курсовая работа студента из техникума обучающегося на программиста, представляющая собой полноценную систему управления образовательным процессом. Проект демонстрирует навыки разработки современного программного обеспечения с использованием передовых технологий."
        },
        {
            question: "Для чего он предназначен?",
            answer: "Система предназначена для автоматизации образовательного процесса в учебных заведениях. Она предоставляет инструменты для управления студентами, преподавателями, учебными группами, портфолио учащихся и образовательными событиями."
        },
        {
            question: "Для кого он актуален?",
            answer: "Проект актуален для:\n• Учебных заведений (техникумы, колледжи, вузы)\n• Преподавателей и администрации\n• Студентов для отслеживания своего прогресса\n• Разработчиков как пример современного подхода к созданию образовательных систем"
        },
        {
            question: "Как начать создавать и вносить данные?",
            answer: "1. Войдите в систему с вашими учетными данными\n2. Перейдите в соответствующий раздел (Студенты, Преподаватели, Группы)\n3. Используйте кнопку 'Добавить' для создания новых записей\n4. Заполните необходимые поля формы\n5. Сохраните изменения"
        },
        {
            question: "Как изменить пароль?",
            answer: isMobile ?
                "Свайпните вправо с левого края экрана для открытия меню, выберите 'Настройки', затем перейдите в 'Безопасность' и нажмите 'Изменить пароль'. Введите текущий пароль, новый пароль и подтверждение." :
                "Нажмите на кнопку настроек в левой панели, чтобы открыть их, далее выберите: Безопасность -> Изменить пароль. Введите текущий пароль, новый пароль и подтверждение."
        },
        {
            question: "Как управлять активными сессиями?",
            answer: isMobile ?
                "В настройках выберите раздел 'Активные сессии'. Здесь вы можете просмотреть все устройства, на которых выполнен вход, и при необходимости отозвать доступ для неиспользуемых сессий." :
                "Перейдите в Настройки -> Активные сессии. В этом разделе отображаются все активные подключения к вашему аккаунту с возможностью отзыва подозрительных сессий."
        },
        {
            question: "Как проверить подключение к серверу?",
            answer: isMobile ?
                "В разделе настроек 'Сервер' вы можете проверить отклик с сервером. Нажмите 'Проверить отклик' для измерения времени отклика. Рекомендуемое значение - менее 120 мс." :
                "Перейдите в Настройки -> Сервер. Используйте кнопку 'Проверить отклик' для измерения времени отклика сервера. Круговая диаграмма визуализирует качество соединения."
        },
        {
            question: "Как просмотреть информацию о программе?",
            answer: isMobile ?
                "В меню настроек выберите 'О программе'. Здесь вы найдете информацию о версии, разработчике, а также ссылки на исходный код проекта на Gitflic." :
                "В разделе настроек 'О программе' представлена подробная информация о версии приложения, используемых технологиях (Qt, C++17), а также ссылки на клиентскую и серверную части проекта."
        },
        {
            question: "Как работать с портфолио студентов?",
            answer: "Перейдите в раздел 'Портфолио'. Здесь вы можете:\n• Просматривать существующие портфолио студентов\n• Добавлять новые достижения и проекты\n• Прикреплять файлы и документы\n• Отслеживать прогресс обучения"
        },
        {
            question: "Как создавать учебные группы?",
            answer: "В разделе 'Группы' используйте кнопку 'Добавить группу'. Заполните:\n• Название группы\n• Куратора (преподавателя)\n• Список студентов\n• Учебный план\nСохраните группу для начала работы с ней."
        },
        {
            question: "Где можно посмотреть новости системы?",
            answer: isMobile ?
                "В главном меню выберите раздел 'Новости'. Здесь отображаются последние обновления системы, важные объявления и образовательные материалы." :
                "В левой панели навигации выберите 'Новости'. В правой части отображается список новостей, при выборе которых в основной области показывается полное содержание."
        },
        {
            question: "Что делать при проблемах с подключением?",
            answer: "1. Проверьте интернет-соединение\n2. Убедитесь, что сервер доступен (раздел 'Сервер' в настройках)\n3. Проверьте правильность введенных учетных данных\n4. При необходимости обратитесь к администратору системы"
        },
        {
            question: "Как выйти из системы?",
            answer: isMobile ?
                "Свайпните для открытия меню, выберите 'Настройки' и нажмите кнопку 'Выйти из системы' в нижней части экрана." :
                "В левой панели нажмите на значок настроек и выберите 'Выйти из системы' в нижней части окна настроек."
        }
    ]

    ScrollView {
            anchors.fill: parent
            anchors.margins: isMobile ? 8 : 12
            clip: true
            ScrollBar.vertical.policy: ScrollBar.AsNeeded
            ScrollBar.horizontal.policy: ScrollBar.AsNeeded

            ColumnLayout {
                width: parent.width
                spacing: isMobile ? 8 : 12

                // Заголовок
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: isMobile ? 60 : 80
                    radius: isMobile ? 8 : 12
                    color: "#ffffff"
                    border.color: "#e0e0e0"
                    border.width: 1

                    Column {
                        anchors.centerIn: parent
                        width: parent.width - (isMobile ? 16 : 24)
                        spacing: isMobile ? 2 : 4

                        Text {
                            text: "Часто задаваемые вопросы"
                            font.pixelSize: isMobile ? 18 : 20
                            font.bold: true
                            color: "#2c3e50"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            text: "Ответы на популярные вопросы о системе " + appName
                            font.pixelSize: isMobile ? 12 : 12
                            color: "#7f8c8d"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }

                // Список FAQ
                Repeater {
                    model: faqItems

                    delegate: Rectangle {
                        id: faqItem
                        Layout.fillWidth: true
                        Layout.preferredHeight: questionRow.height + (showAnswer ? answerContent.height + 12 : 0)
                        radius: isMobile ? 6 : 8
                        color: questionMouseArea.containsMouse ? "#f8f9fa" : "#ffffff"
                        border.color: questionMouseArea.containsMouse ? "#3498db" : "#e0e0e0"
                        border.width: 1

                        property bool showAnswer: false

                        Behavior on height {
                            NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
                        }

                        // Вопрос
                        Item {
                            id: questionRow
                            width: parent.width - (isMobile ? 12 : 16)
                            height: isMobile ? 50 : 50
                            anchors.top: parent.top
                            anchors.horizontalCenter: parent.horizontalCenter

                            Row {
                                anchors.fill: parent
                                spacing: isMobile ? 8 : 12

                                // Номер вопроса
                                Rectangle {
                                    width: isMobile ? 24 : 24
                                    height: isMobile ? 24 : 24
                                    radius: isMobile ? 12 : 12
                                    color: "#3498db"
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        text: index + 1
                                        font.pixelSize: isMobile ? 12 : 12
                                        font.bold: true
                                        color: "white"
                                        anchors.centerIn: parent
                                    }
                                }

                                // Текст вопроса
                                Text {
                                    width: parent.width - (isMobile ? 80 : 80)
                                    text: modelData.question
                                    font.pixelSize: isMobile ? 14 : 14
                                    font.bold: true
                                    color: "#2c3e50"
                                    wrapMode: Text.WordWrap
                                    elide: Text.ElideRight
                                    maximumLineCount: 2
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                // Стрелка раскрытия
                                Image {
                                    source: "qrc:/icons/expand.png"
                                    sourceSize: Qt.size(isMobile ? 18 : 16, isMobile ? 18 : 16)
                                    rotation: faqItem.showAnswer ? 180 : 0
                                    fillMode: Image.PreserveAspectFit
                                    mipmap: true
                                    antialiasing: true
                                    anchors.verticalCenter: parent.verticalCenter

                                    Behavior on rotation {
                                        NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
                                    }
                                }
                            }

                            // MouseArea только для вопроса
                            MouseArea {
                                id: questionMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    faqItem.showAnswer = !faqItem.showAnswer
                                }
                            }
                        }

                        // Контейнер для ответа и кнопки
                        Item {
                            id: answerContainer
                            width: parent.width - (isMobile ? 16 : 20)
                            height: showAnswer ? answerContent.height : 0
                            anchors.top: questionRow.bottom
                            anchors.topMargin: showAnswer ? 8 : 0
                            anchors.horizontalCenter: parent.horizontalCenter
                            clip: true

                            Behavior on height {
                                NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
                            }

                            ColumnLayout {
                                id: answerContent
                                width: parent.width
                                spacing: 8

                                // Текст ответа с возможностью копирования
                                TextEdit {
                                    id: answerText
                                    Layout.fillWidth: true
                                    text: modelData.answer
                                    font.pixelSize: isMobile ? 14 : 13
                                    color: "#5d6d7e"
                                    wrapMode: Text.WordWrap
                                    selectByMouse: true
                                    readOnly: true
                                    selectionColor: "#3498db"
                                    selectedTextColor: "white"
                                    onActiveFocusChanged: if (!activeFocus) deselect()
                                }

                                // Кнопка копирования - ВНУТРИ контейнера ответа
                                Rectangle {
                                    id: copyButton
                                    Layout.preferredWidth: Math.min(copyText.width + 20, parent.width * 0.5)
                                    Layout.preferredHeight: isMobile ? 32 : 28
                                    Layout.alignment: Qt.AlignRight
                                    radius: 6
                                    color: copyMouseArea.containsPress ? "#3498db" :
                                          (copyMouseArea.containsMouse ? "#e3f2fd" : "#f8f9fa")
                                    border.color: copyMouseArea.containsMouse ? "#3498db" : "#bdc3c7"
                                    border.width: 1

                                    Row {
                                        id: copyText
                                        anchors.centerIn: parent
                                        spacing: 6

                                        Image {
                                            source: "qrc:/icons/copy.png"
                                            sourceSize: Qt.size(isMobile ? 14 : 12, isMobile ? 14 : 12)
                                            fillMode: Image.PreserveAspectFit
                                            mipmap: true
                                            antialiasing: true
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        Text {
                                            text: "Копировать"
                                            font.pixelSize: isMobile ? 12 : 10
                                            color: copyMouseArea.containsMouse ? (copyMouseArea.containsPress ? "white" : "#3498db") : "#7f8c8d"
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }

                                    MouseArea {
                                        id: copyMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            answerText.selectAll()
                                            answerText.copy()
                                            answerText.deselect()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Информационный блок
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: infoColumn.height + 16
                    radius: isMobile ? 6 : 8
                    color: "#e8f4f8"
                    border.color: "#b3e5fc"
                    border.width: 1

                    Column {
                        id: infoColumn
                        anchors.centerIn: parent
                        width: parent.width - (isMobile ? 16 : 24)
                        spacing: isMobile ? 6 : 6

                        Text {
                            text: "Нужна дополнительная помощь?"
                            font.pixelSize: isMobile ? 14 : 14
                            font.bold: true
                            color: "#0277bd"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            width: parent.width
                            text: "Если вы не нашли ответ на свой вопрос или столкнулись с технической проблемой, обратитесь к администратору системы или проверьте документацию проекта."
                            font.pixelSize: isMobile ? 12 : 12
                            color: "#0288d1"
                            lineHeight: 1.3
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }

                // Отступ внизу
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: isMobile ? 10 : 15
                }
            }
        }
    }
