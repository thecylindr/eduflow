cmake_minimum_required(VERSION 3.16)
project(EduFlowApp VERSION 0.0.37 LANGUAGES CXX)
set(QT_ANDROID_NO_STYLE_WARNINGS ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Core Gui QuickControls2)

qt_standard_project_setup(REQUIRES 6.8)

# Добавляем файлы настроек
qt_add_executable(EduFlowApp
    main.cpp
    settings_manager.cpp
    settings_manager.h
)

if(ANDROID)
    set_target_properties(EduFlowApp PROPERTIES
        QT_ANDROID_APP_ORIENTATION "portrait"
        ANDROID_MANIFEST_SCREEN_ORIENTATION "portrait"
        ANDROID_MANIFEST "${CMAKE_CURRENT_SOURCE_DIR}/android/AndroidManifest.xml"
        QT_ANDROID_APP_NAME "EduFlow"
        QT_ANDROID_COMPILE_SDK_VERSION 36
        #QT_ANDROID_APP_ICON "@mipmap/app_icon"
    )

    qt_android_generate_deployment_settings(EduFlowApp)
    qt_android_add_apk_target(EduFlowApp)

endif()

qt_add_qml_module(EduFlowApp
    URI EduFlow
    VERSION 1.0
    QML_FILES
    splash/SplashScreenMobile.qml
    splash/WelcomeScreen.qml
    splash/SplashScreen.qml

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
        #main/main/InteractionsList.qml
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
        main/forms/PortfolioFormWindow.qml
        main/forms/EventFormWindow.qml
        # Компонет отображения данных с таблиц
        enhanced/EnhancedTableView.qml
        enhanced/EnhancedSearchBox.qml
        enhanced/EnhancedSortComboBox.qml
        enhanced/EnhancedViewToggle.qml
        enhanced/EnhancedListItem.qml
        enhanced/EnhancedGridItem.qml
        enhanced/EnhancedGroupBox.qml


        main/view/settings/ServerPage.qml
        main/view/settings/SessionsPage.qml
        main/view/settings/SecurityPage.qml
        main/view/settings/ProfilePage.qml
        main/view/settings/SettingsMainPage.qml
        main/view/settings/AboutPage.qml
        main/forms/GroupViewFormWindow.qml
        common/SparksBackground.qml
        common/TitleBarMobile.qml
        main/main/AdaptiveSideBarMobile.qml
        common/MobileCloseApp.qml
        common/BottomBlur.qml
        main/view/NewsView.qml
        main/view/FormattedText.qml
        main/view/FAQView.qml
        QML_FILES
        QML_FILES main/forms/GroupViewFormMobile.qml
        QML_FILES main/forms/EventFormMobile.qml
        QML_FILES main/forms/GroupFormMobile.qml
        QML_FILES main/forms/PortfolioFormMobile.qml
        QML_FILES main/forms/StudentFormMobile.qml
        QML_FILES main/forms/TeacherFormMobile.qml
    )

qt_add_resources(EduFlowApp "resources"
    PREFIX "/"
    FILES
        # Основные иконки
        icons/app_icon.png
        icons/faq.png
        icons/copy.png
        icons/check.png
        icons/events.png
        icons/groups.png
        icons/home.png
        icons/portfolio.png
        icons/expand.png
        icons/settings.png
        icons/settings.gif
        icons/statistics.png
        icons/students.png
        icons/teachers.png
        icons/loading.png
        icons/about.png
        icons/activity.png
        icons/calendar.png
        icons/cross.png
        icons/edit.png
        icons/email.png
        icons/email.gif
        icons/git.png
        icons/eye.png
        icons/eye-off.png
        icons/info.png
        icons/ip.png
        icons/language.png
        icons/link.png
        icons/logout.png

        icons/windows.png
        icons/android.png
        icons/linux.gif
        icons/linux.png
        icons/os.png

        icons/organization.png
        icons/phone.png
        icons/phone.gif
        icons/ping.png
        icons/platform.png
        icons/profile.png
        icons/profile.gif
        icons/refresh.png
        icons/revoke.png
        icons/save.png
        icons/security.png
        icons/security.gif
        icons/server.png
        icons/server.gif
        icons/sessions.png
        icons/sessions.gif
        icons/pencil.gif
        icons/pencil.png
        icons/status-active.png
        icons/status-connection.png
        icons/status-inactive.png
        icons/status-warning.png
        icons/time.png
        icons/earth.png
        icons/test.gif
        icons/warning.gif
        icons/user.png
        icons/version.png
        icons/search.gif
        icons/search.png
        icons/sidebar.png
        icons/add.png
        icons/news.png

        # Добавляем файл конфигурации стилей
        qtquickcontrols2.conf
)

set_target_properties(EduFlowApp PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER "com.securesystems.EduFlow"
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE`
)

target_link_libraries(EduFlowApp
    PRIVATE Qt6::Quick
    PRIVATE Qt6::Core
)

include(GNUInstallDirs)
install(TARGETS EduFlowApp
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
