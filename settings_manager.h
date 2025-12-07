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
    Q_PROPERTY(bool isGridView READ isGridView WRITE setIsGridView NOTIFY isGridViewChanged)

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

    bool isGridView() const;
    void setIsGridView(bool isGridView);

    // Новый метод для проверки валидности токена
    Q_INVOKABLE bool hasValidToken() const;

    // Методы для первого запуска
    Q_INVOKABLE bool getFirstRun() const;
    Q_INVOKABLE void setFirstRun(bool firstRun);

private:
    QString getConfigPath() const;
    void loadSettings();
    void saveSettings();

    bool m_useLocalServer;
    QString m_serverAddress;
    QString m_apiPath;
    QString m_authToken;
    bool m_firstRun;
    bool m_isGridView;

signals:
    void useLocalServerChanged();
    void serverAddressChanged();
    void apiPathChanged();
    void authTokenChanged();
    void isGridViewChanged();
};

#endif
