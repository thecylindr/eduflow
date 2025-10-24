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

                # Диалоги и формы
                main/dialog/ConfirmDialog.qml
                main/dialog/UserSettingsPanel.qml
                main/dialog/StudentDialog.qml
                main/dialog/GroupsDialog.qml
                main/dialog/TeachersDialog.qml
                main/dialog/StudentFormWindow.qml
                main/dialog/TeacherFormWindow.qml
                main/dialog/GroupFormWindow.qml

                # Общие компоненты
                common/PolygonBackground.qml
                common/TitleBar.qml

                # Улучшенные компоненты - ТОЛЬКО ОДИН EnhancedTableView
                enhanced/EnhancedTableView.qml





                enhanced/ActionButtons.qml
                QML_FILES enhanced/EnhancedSearchBox.qml
                QML_FILES enhanced/EnhancedSortComboBox.qml
                QML_FILES enhanced/EnhancedViewToggle.qml
                QML_FILES enhanced/EnhancedListItem.qml
                QML_FILES enhanced/EnhancedGridItem.qml
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
