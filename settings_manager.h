#ifndef SETTINGS_MANAGER_H
#define SETTINGS_MANAGER_H

#include <QObject>
#include <QString>
#include "json.hpp"

class SettingsManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool useLocalServer READ useLocalServer WRITE setUseLocalServer NOTIFY settingsChanged)
    Q_PROPERTY(QString serverAddress READ serverAddress WRITE setServerAddress NOTIFY settingsChanged)
    Q_PROPERTY(QString authToken READ authToken WRITE setAuthToken NOTIFY settingsChanged)

public:
    explicit SettingsManager(QObject *parent = nullptr);

    bool useLocalServer() const;
    QString serverAddress() const;
    QString authToken() const;

public slots:
    void setUseLocalServer(bool value);
    void setServerAddress(const QString &value);
    void setAuthToken(const QString &value);
    void saveSettings();
    void loadSettings();

signals:
    void settingsChanged();

private:
    QString m_configPath;
    nlohmann::json m_settings;
    bool m_useLocalServer;
    QString m_serverAddress;
    QString m_authToken;
};

#endif
