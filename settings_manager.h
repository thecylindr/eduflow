#ifndef SETTINGS_MANAGER_H
#define SETTINGS_MANAGER_H

#include <QObject>
#include <QString>

class SettingsManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool useLocalServer READ useLocalServer WRITE setUseLocalServer NOTIFY useLocalServerChanged)
    Q_PROPERTY(QString serverAddress READ serverAddress WRITE setServerAddress NOTIFY serverAddressChanged)
    Q_PROPERTY(QString apiPath READ apiPath WRITE setApiPath NOTIFY apiPathChanged)

public:
    explicit SettingsManager(QObject *parent = nullptr);

    bool useLocalServer() const;
    void setUseLocalServer(bool useLocalServer);

    QString serverAddress() const;
    void setServerAddress(const QString &serverAddress);

    QString apiPath() const;
    void setApiPath(const QString &apiPath);

private:
    QString getConfigPath() const;
    void loadSettings();
    void saveSettings();

    bool m_useLocalServer;
    QString m_serverAddress;
    QString m_apiPath;

signals:
    void useLocalServerChanged();
    void serverAddressChanged();
    void apiPathChanged();
};

#endif
