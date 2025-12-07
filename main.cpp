#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QIcon>
#include <QQmlContext>
#include "settings_manager.h"

int main(int argc, char *argv[])
{
    qputenv("QT_QUICK_CONTROLS_STYLE", "Material");
    qputenv("QSG_RENDER_LOOP", "basic");

    QGuiApplication app(argc, argv);

    SettingsManager settingsManager;
    QQmlApplicationEngine engine;

    app.setWindowIcon(QIcon(":/icons/app_icon.png"));
    app.setApplicationName("ЕдуФлоу");
    app.setApplicationVersion("0.0.32");
    app.setOrganizationName("NameLess Club");
    app.setOrganizationDomain("securesystems.com");

    app.setQuitOnLastWindowClosed(true);

    engine.rootContext()->setContextProperty("appName", app.applicationName());
    engine.rootContext()->setContextProperty("appVersion", app.applicationVersion());
    engine.rootContext()->setContextProperty("organizationName", app.organizationName());
    engine.rootContext()->setContextProperty("settingsManager", &settingsManager);

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, []() { QCoreApplication::exit(-1); },
                     Qt::QueuedConnection);

    // Определяем стартовый экран
    QString startScreen;
    bool isMobile = (QGuiApplication::platformName() == "android" ||
                     QGuiApplication::platformName() == "ios");

    if (isMobile) {
        startScreen = "SplashScreenMobile";
    } else {
        startScreen = "SplashScreen";
    }

    // Загружаем соответствующий QML
    engine.loadFromModule("EduFlow", startScreen);

    return app.exec();
}
