#include "settings_manager.h"
#include <QStandardPaths>
#include <QDir>
#include <QDebug>
#include <fstream>
#include <exception>

SettingsManager::SettingsManager(QObject *parent) : QObject(parent)
{
    QString configDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir dir(configDir);
    if (!dir.exists()) {
        dir.mkpath(".");
    }
    m_configPath = dir.filePath("config.json");
    qDebug() << "Config file path:" << m_configPath;

    // Значения по умолчанию
    m_useLocalServer = false;
    m_serverAddress = "http://localhost:5000";
    m_authToken = "";

    loadSettings();
}

void SettingsManager::loadSettings()
{
    try {
        std::ifstream file(m_configPath.toStdString());
        if (file.good()) {
            m_settings = nlohmann::json::parse(file);
            m_useLocalServer = m_settings.value("useLocalServer", false);
            m_serverAddress = QString::fromStdString(m_settings.value("serverAddress", "http://localhost:5000"));
            m_authToken = QString::fromStdString(m_settings.value("authToken", ""));
            qDebug() << "Settings loaded:" << m_useLocalServer << m_serverAddress << "Token:" << (m_authToken.isEmpty() ? "empty" : "present");
        } else {
            qDebug() << "Config file doesn't exist, using defaults";
        }
    } catch (const std::exception &e) {
        qWarning() << "Error loading settings:" << e.what();
    }
    emit settingsChanged();
}

void SettingsManager::saveSettings()
{
    try {
        m_settings["useLocalServer"] = m_useLocalServer;
        m_settings["serverAddress"] = m_serverAddress.toStdString();
        m_settings["authToken"] = m_authToken.toStdString();

        std::ofstream file(m_configPath.toStdString());
        file << m_settings.dump(4);
        file.close();
        qDebug() << "Settings saved to:" << m_configPath;
    } catch (const std::exception &e) {
        qWarning() << "Error saving settings:" << e.what();
    }
}

// Геттеры
bool SettingsManager::useLocalServer() const { return m_useLocalServer; }
QString SettingsManager::serverAddress() const { return m_serverAddress; }
QString SettingsManager::authToken() const { return m_authToken; }

// Сеттеры
void SettingsManager::setUseLocalServer(bool value) {
    m_useLocalServer = value;
    saveSettings();
    emit settingsChanged();
}

void SettingsManager::setServerAddress(const QString &value) {
    m_serverAddress = value;
    saveSettings();
    emit settingsChanged();
}

void SettingsManager::setAuthToken(const QString &value) {
    m_authToken = value;
    saveSettings();
    emit settingsChanged();
}
