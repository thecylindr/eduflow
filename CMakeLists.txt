cmake_minimum_required(VERSION 3.16)

project(student VERSION 0.0.37 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Core)

qt_standard_project_setup(REQUIRES 6.8)

# Добавляем файлы настроек
qt_add_executable(student
    main.cpp
    settings_manager.cpp
    settings_manager.h
)

qt_add_qml_module(student
    URI testing
    VERSION 1.0
    QML_FILES
        SplashScreen.qml
        Auth.qml
        Main.qml
)

set_target_properties(student PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER "com.securesystems.student"
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(student
    PRIVATE Qt6::Quick
    PRIVATE Qt6::Core
)

include(GNUInstallDirs)
install(TARGETS student
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
