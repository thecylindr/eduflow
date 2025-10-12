#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QIcon>
#include <QQmlContext>
#include "settings_manager.h"


int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // Инициализация менеджера настроек

    SettingsManager settingsManager;

    QQmlApplicationEngine engine;

    // Устанавливаем иконку приложения
    app.setWindowIcon(QIcon(":/icons/app-icon.png"));
    app.setApplicationName("EduFlow");
    app.setApplicationVersion("0.0.37");
    app.setOrganizationName("NameLess Club");
    app.setOrganizationDomain("securesystems.com");

    // Устанавливаем контекстные свойства для передачи в QML
    engine.rootContext()->setContextProperty("appName", app.applicationName());
    engine.rootContext()->setContextProperty("appVersion", app.applicationVersion());
    engine.rootContext()->setContextProperty("organizationName", app.organizationName());
    engine.rootContext()->setContextProperty("settingsManager", &settingsManager);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    // Загружаем SplashScreen
    engine.loadFromModule("testing", "SplashScreen");

    return app.exec();
}


