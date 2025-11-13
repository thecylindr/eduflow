cmake_minimum_required(VERSION 3.16)

project(EduFlow VERSION 0.0.37 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Core)

qt_standard_project_setup(REQUIRES 6.8)

# Добавляем файлы настроек
qt_add_executable(EduFlow
    main.cpp
    settings_manager.cpp
    settings_manager.h
)

qt_add_qml_module(EduFlow
    URI testing
    VERSION 1.0
    QML_FILES
        SplashScreen.qml

        # Формы для авторизации & регистрации
                auth/Auth.qml
                auth/AuthAPI.qml
                auth/ServerConfig.qml
                auth/LoginForm.qml
                auth/Message.qml
                auth/CopyrightFooter.qml
                auth/LoadingAnimation.qml
                auth/RegistrationForm.qml

                # Формы главного меню
                main/main/Main.qml
                main/main/InteractionsList.qml
                main/main/MainAPI.qml
                main/main/AdaptiveSideBar.qml
                main/main/MainMessage.qml

                # Представления (Views)
                main/view/DashboardView.qml
                main/view/TeachersView.qml
                main/view/StudentsView.qml
                main/view/GroupsView.qml
                main/view/EventsView.qml
                main/view/PortfolioView.qml
                main/view/SettingsView.qml

                # Общие компоненты
                common/PolygonBackground.qml
                common/DialogTitleBar.qml
                common/TitleBar.qml

                # Формы вывода информации и для добавления в таблицу данных
                main/forms/TeacherFormWindow.qml
                main/forms/GroupFormWindow.qml
                main/forms/StudentFormWindow.qml

                # Компонет отображения данных с таблиц
                enhanced/EnhancedTableView.qml
                enhanced/EnhancedSearchBox.qml
                enhanced/EnhancedSortComboBox.qml
                enhanced/EnhancedViewToggle.qml
                enhanced/EnhancedListItem.qml
                enhanced/EnhancedGridItem.qml
                enhanced/EnhancedGroupBox.qml
                enhanced/EnhancedTextField.qml






                QML_FILES main/view/settings/ServerPage.qml
                QML_FILES main/view/settings/SessionsPage.qml
                QML_FILES main/view/settings/SecurityPage.qml
                QML_FILES main/view/settings/ProfilePage.qml
                QML_FILES main/view/settings/RequirementItem.qml
                QML_FILES main/view/settings/PasswordField.qml
                QML_FILES main/view/settings/SettingsMainPage.qml
                QML_FILES main/view/settings/AboutPage.qml
                QML_FILES main/forms/PortfolioFormWindow.qml
                QML_FILES main/forms/EventFormWindow.qml
)

qt_add_resources(EduFlow "resources"
    PREFIX "/"
    FILES
        # Основные иконки
        icons/app-icon.png
        icons/check.png
        icons/events.png
        icons/groups.png
        icons/home.png
        icons/portfolio.png
        icons/settings.png
        icons/statistics.png
        icons/students.png
        icons/teachers.png
        icons/loading.png

        # Иконки для настроек
        icons/about.png
        icons/activity.png
        icons/calendar.png
        icons/cross.png
        icons/edit.png
        icons/email.png
        icons/eye.png
        icons/eye-off.png
        icons/info.png
        icons/ip.png
        icons/language.png
        icons/link.png
        icons/logout.png
        icons/os.png
        icons/organization.png
        icons/phone.png
        icons/ping.png
        icons/platform.png
        icons/profile.png
        icons/refresh.png
        icons/revoke.png
        icons/save.png
        icons/security.png
        icons/server.png
        icons/sessions.png

        # Статусы сессий
        icons/status-active.png
        icons/status-connection.png  # используем как status-current
        icons/status-inactive.png
        icons/status-warning.png
        icons/time.png

        icons/user.png
        icons/version.png
)

set_target_properties(EduFlow PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER "com.securesystems.EduFlow"
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(EduFlow
    PRIVATE Qt6::Quick
    PRIVATE Qt6::Core
)

include(GNUInstallDirs)
install(TARGETS EduFlow
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
