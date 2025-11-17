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
    Q_PROPERTY(QString authToken READ authToken WRITE setAuthToken NOTIFY authTokenChanged)
public:
    explicit SettingsManager(QObject *parent = nullptr);
    bool useLocalServer() const;
    void setUseLocalServer(bool useLocalServer);
    QString serverAddress() const;
    void setServerAddress(const QString &serverAddress);
    QString apiPath() const;
    void setApiPath(const QString &apiPath);
    QString authToken() const;
    void setAuthToken(const QString &authToken);
    // Новый метод для проверки валидности токена
    Q_INVOKABLE bool hasValidToken() const;
private:
    QString getConfigPath() const;
    void loadSettings();
    void saveSettings();
    bool m_useLocalServer;
    QString m_serverAddress;
    QString m_apiPath;
    QString m_authToken;
signals:
    void useLocalServerChanged();
    void serverAddressChanged();
    void apiPathChanged();
    void authTokenChanged();
};
#endif
