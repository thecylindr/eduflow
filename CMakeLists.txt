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
        auth/AuthTitleBar.qml
        auth/ServerConfig.qml
        auth/LoginForm.qml
        auth/BackgroundPolygons.qml
        auth/Message.qml
        auth/CopyrightFooter.qml
        auth/LoadingAnimation.qml
        auth/RegistrationForm.qml

        # Формы главного меню
        main/Main.qml

        main/MainTitleBar.qml
        main/InteractionsList.qml
        main/PolygonBackground.qml
        main/UserSettingsPanel.qml
        main/MainAPI.qml

        main/TeachersView.qml
        main/DashboardView.qml
        main/StudentsView.qml

        main/MainMessage.qml
        main/GroupsView.qml
        main/EventsView.qml
        main/AdaptiveSideBar.qml
)

qt_add_resources(EduFlow "resources"
    PREFIX "/"
    FILES
        icons/app-icon.png
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
