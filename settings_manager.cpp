#include "settings_manager.h"
#include <QStandardPaths>
#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QDebug>
#include <QCoreApplication>

SettingsManager::SettingsManager(QObject *parent)
    : QObject(parent)
    , m_useLocalServer(false)
    , m_serverAddress("http://localhost:5000")
    , m_apiPath("/api")
    , m_authToken("")
    , m_firstRun(true)
    , m_isGridView(false)
{
    QCoreApplication::setApplicationName("EduFlow");
    QCoreApplication::setOrganizationName("NameLess");
    QCoreApplication::setOrganizationDomain("eduflow.com");
    loadSettings();
}

bool SettingsManager::useLocalServer() const
{
    return m_useLocalServer;
}

void SettingsManager::setUseLocalServer(bool useLocalServer)
{
    if (m_useLocalServer != useLocalServer) {
        m_useLocalServer = useLocalServer;
        qDebug() << "Setting useLocalServer to:" << m_useLocalServer;
        emit useLocalServerChanged();
        saveSettings();
    }
}

QString SettingsManager::serverAddress() const
{
    return m_serverAddress;
}

void SettingsManager::setServerAddress(const QString &serverAddress)
{
    if (m_serverAddress != serverAddress) {
        m_serverAddress = serverAddress;
        qDebug() << "Setting serverAddress to:" << m_serverAddress;
        emit serverAddressChanged();
        saveSettings();
    }
}

QString SettingsManager::apiPath() const
{
    return m_apiPath;
}

void SettingsManager::setApiPath(const QString &apiPath)
{
    if (m_apiPath != apiPath) {
        m_apiPath = apiPath;
        emit apiPathChanged();
        saveSettings();
    }
}

QString SettingsManager::authToken() const
{
    return m_authToken;
}

void SettingsManager::setAuthToken(const QString &authToken)
{
    if (m_authToken != authToken) {
        m_authToken = authToken;
        qDebug() << "Setting authToken, length:" << m_authToken.length();
        if (m_authToken.length() > 0) {
            qDebug() << "Auth token first 10 chars:" << m_authToken.left(10) + "...";
        }
        emit authTokenChanged();
        saveSettings();
    }
}

bool SettingsManager::isGridView() const
{
    return m_isGridView;
}

void SettingsManager::setIsGridView(bool isGridView)
{
    if (m_isGridView != isGridView) {
        m_isGridView = isGridView;
        qDebug() << "Setting isGridView to:" << m_isGridView;
        emit isGridViewChanged();
        saveSettings();
    }
}

bool SettingsManager::hasValidToken() const
{
    // Токен считается валидным если он не пустой и имеет достаточную длину (сессионные токены обычно 64 символа)
    return !m_authToken.isEmpty() && m_authToken.length() >= 32;
}

// Методы для первого запуска
bool SettingsManager::getFirstRun() const
{
    return m_firstRun;
}

void SettingsManager::setFirstRun(bool firstRun)
{
    if (m_firstRun != firstRun) {
        m_firstRun = firstRun;
        qDebug() << "Setting firstRun to:" << m_firstRun;
        saveSettings();
    }
}

QString SettingsManager::getConfigPath() const
{
    QString configDir;
    // Принудительно используем правильные имена
    QString appName = "EduFlow";
    QString orgName = "EduFlow";
#ifdef Q_OS_WINDOWS
    // Windows: AppData/Roaming/EduFlow/EduFlow
    configDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    // Переопределяем путь с правильными именами
    configDir = QStandardPaths::writableLocation(QStandardPaths::GenericConfigLocation) + "/" + orgName + "/" + appName;
#else
    // Linux: ~/.config/EduFlow/EduFlow
    configDir = QStandardPaths::writableLocation(QStandardPaths::GenericConfigLocation) + "/" + orgName + "/" + appName;
#endif
    QDir dir(configDir);
    if (!dir.exists()) {
        bool created = dir.mkpath(".");
        qDebug() << "Config directory created:" << created << "at:" << configDir;
    }
    QString configFile = configDir + "/config.json";
    qDebug() << "Config file path:" << configFile;
    return configFile;
}

void SettingsManager::loadSettings()
{
    QString configFile = getConfigPath();
    QFile file(configFile);
    if (file.exists()) {
        qDebug() << "Config file exists, loading...";
        if (file.open(QIODevice::ReadOnly)) {
            QByteArray data = file.readAll();
            file.close();
            QJsonDocument doc = QJsonDocument::fromJson(data);
            if (!doc.isNull() && doc.isObject()) {
                QJsonObject obj = doc.object();
                m_useLocalServer = obj.value("useLocalServer").toBool(false);
                m_serverAddress = obj.value("serverAddress").toString("http://localhost:5000");
                m_apiPath = obj.value("apiPath").toString("/api");
                m_authToken = obj.value("authToken").toString("");
                m_firstRun = obj.value("firstRun").toBool(true);
                m_isGridView = obj.value("isGridView").toBool(false);
                qDebug() << "Config loaded successfully:";
                qDebug() << "  useLocalServer:" << m_useLocalServer;
                qDebug() << "  serverAddress:" << m_serverAddress;
                qDebug() << "  authToken length:" << m_authToken.length();
                qDebug() << "  firstRun:" << m_firstRun;
                qDebug() << "  isGridView:" << m_isGridView;
                if (m_authToken.length() > 0) {
                    qDebug() << "  authToken (first 10):" << m_authToken.left(10) + "...";
                }
            } else {
                qDebug() << "Invalid JSON in config file, using defaults";
            }
        } else {
            qDebug() << "Failed to open config file for reading, using defaults";
        }
    } else {
        qDebug() << "Config file not found, using defaults and creating new config";
        saveSettings(); // Create with default values
    }
}

void SettingsManager::saveSettings()
{
    QString configFile = getConfigPath();
    QFile file(configFile);
    if (file.open(QIODevice::WriteOnly)) {
        QJsonObject obj;
        obj["useLocalServer"] = m_useLocalServer;
        obj["serverAddress"] = m_serverAddress;
        obj["apiPath"] = m_apiPath;
        obj["authToken"] = m_authToken;
        obj["firstRun"] = m_firstRun;
        obj["isGridView"] = m_isGridView;
        QJsonDocument doc(obj);
        QByteArray data = doc.toJson(QJsonDocument::Indented);
        qint64 bytesWritten = file.write(data);
        file.close();
        qDebug() << "Settings saved to:" << configFile;
        qDebug() << "  authToken length:" << m_authToken.length();
        qDebug() << "  firstRun:" << m_firstRun;
        qDebug() << "  isGridView:" << m_isGridView;
        if (m_authToken.length() > 0) {
            qDebug() << "  authToken (first 7):" << m_authToken.left(7) + "...";
        }
    } else {
        qDebug() << "Failed to open config file for writing:" << file.errorString();
    }
}
