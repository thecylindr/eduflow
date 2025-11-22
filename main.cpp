#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QIcon>
#include <QQmlContext>
#include "settings_manager.h"
#include <QLoggingCategory>
#include <QCoreApplication>
#include <QtGlobal>

typedef void (*QtMessageHandler)(QtMsgType, const QMessageLogContext &, const QString &);

QtMessageHandler defaultHandler = nullptr;

void messageHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg) {
    if (type == QtWarningMsg && msg.contains("QML import could not be resolved")) {
        return; // Suppress specific warnings
    }
    // Call the default handler for other messages
    if (defaultHandler) {
        defaultHandler(type, context, msg);
    }
}

int main(int argc, char *argv[])
{
    qputenv("QT_QUICK_CONTROLS_STYLE", "Material");
    qputenv("QSG_RENDER_LOOP", "basic");

    QGuiApplication app(argc, argv);

    defaultHandler = qInstallMessageHandler(messageHandler);

    SettingsManager settingsManager;
    QQmlApplicationEngine engine;

    app.setWindowIcon(QIcon(":/icons/app_icon.png"));
    app.setApplicationName("EduFlow");
    app.setApplicationVersion("0.0.31");
    app.setOrganizationName("NameLess Club");
    app.setOrganizationDomain("securesystems.com");

    engine.rootContext()->setContextProperty("appName", app.applicationName());
    engine.rootContext()->setContextProperty("appVersion", app.applicationVersion());
    engine.rootContext()->setContextProperty("organizationName", app.organizationName());
    engine.rootContext()->setContextProperty("settingsManager", &settingsManager);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        [](const QUrl &) { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    // Загружаем SplashScreen
    engine.loadFromModule("testing", "SplashScreen");

    return app.exec();
}
