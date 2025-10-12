#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QObject>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QVariantMap>
#include <QVariantList>

class DatabaseManager : public QObject
{
    Q_OBJECT

public:
    explicit DatabaseManager(QObject *parent = nullptr);
    ~DatabaseManager();

    // Методы для установки параметров подключения
    void setConnectionParams(const QString &host, int port,
                             const QString &databaseName,
                             const QString &username,
                             const QString &password);

    bool initializeDatabase();
    bool createTables();

    // CRUD операции
    bool addUser(const QString &username, const QString &password, const QString &email);
    bool addCourse(const QString &title, const QString &description, int instructorId);
    bool enrollStudent(int studentId, int courseId);
    bool validateUser(const QString &username, const QString &password);

    QVariantList getUsers();
    QVariantList getCourses();
    QString getDatabasePath() const;

signals:
    void databaseInitialized(bool success);
    void userAdded(bool success);
    void courseAdded(bool success);

private:
    QSqlDatabase m_db;
    QString m_host;
    int m_port;
    QString m_databaseName;
    QString m_username;
    QString m_password;

    bool createDatabaseIfNotExists();
    bool createPgCryptoExtension();
};

#endif // DATABASEMANAGER_H
