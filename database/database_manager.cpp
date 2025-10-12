#include "database_manager.h"
#include <QStandardPaths>
#include <QDir>
#include <QDebug>
#include <QDateTime>
#include <QSqlError>

DatabaseManager::DatabaseManager(QObject *parent)
    : QObject(parent), m_port(5432)
{
}

DatabaseManager::~DatabaseManager()
{
    if (m_db.isOpen()) {
        m_db.close();
    }
    QSqlDatabase::removeDatabase(QSqlDatabase::defaultConnection);
}

void DatabaseManager::setConnectionParams(const QString &host, int port,
                                          const QString &databaseName,
                                          const QString &username,
                                          const QString &password)
{
    m_host = host;
    m_port = port;
    m_databaseName = databaseName;
    m_username = username;
    m_password = password;
}

bool DatabaseManager::initializeDatabase()
{
    // Создаем подключение к PostgreSQL
    m_db = QSqlDatabase::addDatabase("QPSQL");

    m_db.setHostName(m_host);
    m_db.setPort(m_port);
    m_db.setDatabaseName(m_databaseName);
    m_db.setUserName(m_username);
    m_db.setPassword(m_password);

    // Пытаемся подключиться к базе данных
    if (!m_db.open()) {
        qDebug() << "Error: Could not connect to database. Attempting to create database...";

        // Если база данных не существует, пытаемся создать её
        if (!createDatabaseIfNotExists()) {
            qDebug() << "Error: Could not create database:" << m_db.lastError();
            emit databaseInitialized(false);
            return false;
        }

        // Переподключаемся к созданной базе данных
        if (!m_db.open()) {
            qDebug() << "Error: Could not open database after creation:" << m_db.lastError();
            emit databaseInitialized(false);
            return false;
        }
    }

    // Создаем расширение pgcrypto для хеширования паролей
    if (!createPgCryptoExtension()) {
        qDebug() << "Warning: Could not create pgcrypto extension";
    }

    // Создаем таблицы
    if (!createTables()) {
        qDebug() << "Error: Could not create tables";
        emit databaseInitialized(false);
        return false;
    }

    qDebug() << "EduFlow database initialized successfully with PostgreSQL";
    emit databaseInitialized(true);
    return true;
}

bool DatabaseManager::createDatabaseIfNotExists()
{
    // Подключаемся к системной базе данных postgres для создания новой БД
    QSqlDatabase sysDb = QSqlDatabase::addDatabase("QPSQL", "system_connection");
    sysDb.setHostName(m_host);
    sysDb.setPort(m_port);
    sysDb.setDatabaseName("postgres");
    sysDb.setUserName(m_username);
    sysDb.setPassword(m_password);

    if (!sysDb.open()) {
        qDebug() << "Error: Could not connect to postgres database:" << sysDb.lastError();
        return false;
    }

    // Проверяем существование базы данных
    QSqlQuery checkQuery(sysDb);
    checkQuery.prepare("SELECT 1 FROM pg_database WHERE datname = :databaseName");
    checkQuery.bindValue(":databaseName", m_databaseName);

    bool databaseExists = false;
    if (checkQuery.exec() && checkQuery.next()) {
        databaseExists = true;
    }

    // Если база данных не существует, создаем её
    if (!databaseExists) {
        QSqlQuery createQuery(sysDb);
        QString createDbSQL = QString("CREATE DATABASE %1").arg(m_databaseName);

        if (!createQuery.exec(createDbSQL)) {
            qDebug() << "Error: Could not create database:" << createQuery.lastError();
            sysDb.close();
            return false;
        }
        qDebug() << "Database" << m_databaseName << "created successfully";
    }

    sysDb.close();
    return true;
}

bool DatabaseManager::createPgCryptoExtension()
{
    QSqlQuery query(m_db);
    return query.exec("CREATE EXTENSION IF NOT EXISTS pgcrypto");
}

bool DatabaseManager::createTables()
{
    QSqlQuery query(m_db);

    QStringList tables = {
        // Таблица пользователей с использованием pgcrypto для паролей
        "CREATE TABLE IF NOT EXISTS users ("
        "id SERIAL PRIMARY KEY, "
        "username VARCHAR(50) UNIQUE NOT NULL, "
        "password_hash TEXT NOT NULL, "
        "email VARCHAR(100) UNIQUE, "
        "role VARCHAR(20) DEFAULT 'student', "
        "created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, "
        "last_login TIMESTAMP"
        ");",

        "CREATE TABLE IF NOT EXISTS courses ("
        "id SERIAL PRIMARY KEY, "
        "title VARCHAR(200) NOT NULL, "
        "description TEXT, "
        "instructor_id INTEGER, "
        "created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, "
        "is_active BOOLEAN DEFAULT true, "
        "FOREIGN KEY (instructor_id) REFERENCES users (id) ON DELETE SET NULL"
        ");",

        "CREATE TABLE IF NOT EXISTS enrollments ("
        "id SERIAL PRIMARY KEY, "
        "student_id INTEGER, "
        "course_id INTEGER, "
        "enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, "
        "progress INTEGER DEFAULT 0, "
        "FOREIGN KEY (student_id) REFERENCES users (id) ON DELETE CASCADE, "
        "FOREIGN KEY (course_id) REFERENCES courses (id) ON DELETE CASCADE, "
        "UNIQUE(student_id, course_id)"
        ");"
    };

    for (const QString &tableSql : tables) {
        if (!query.exec(tableSql)) {
            qDebug() << "Error creating table:" << query.lastError();
            return false;
        }
    }

    return true;
}

bool DatabaseManager::addUser(const QString &username, const QString &password, const QString &email)
{
    QSqlQuery query(m_db);

    // Используем pgcrypto для безопасного хеширования пароля
    query.prepare("INSERT INTO users (username, password_hash, email) "
                  "VALUES (:username, crypt(:password, gen_salt('bf')), :email)");
    query.bindValue(":username", username);
    query.bindValue(":password", password);
    query.bindValue(":email", email);

    bool success = query.exec();
    if (!success) {
        qDebug() << "Error adding user:" << query.lastError();
    }

    emit userAdded(success);
    return success;
}

bool DatabaseManager::addCourse(const QString &title, const QString &description, int instructorId)
{
    QSqlQuery query(m_db);

    query.prepare("INSERT INTO courses (title, description, instructor_id) "
                  "VALUES (:title, :description, :instructor_id)");
    query.bindValue(":title", title);
    query.bindValue(":description", description);
    query.bindValue(":instructor_id", instructorId);

    bool success = query.exec();
    if (!success) {
        qDebug() << "Error adding course:" << query.lastError();
    }

    emit courseAdded(success);
    return success;
}

bool DatabaseManager::enrollStudent(int studentId, int courseId)
{
    QSqlQuery query(m_db);

    query.prepare("INSERT INTO enrollments (student_id, course_id) "
                  "VALUES (:student_id, :course_id)");
    query.bindValue(":student_id", studentId);
    query.bindValue(":course_id", courseId);

    bool success = query.exec();
    if (!success) {
        qDebug() << "Error enrolling student:" << query.lastError();
    }

    return success;
}

QString DatabaseManager::getDatabasePath() const
{
    return QString("PostgreSQL: %1:%2/%3").arg(m_host).arg(m_port).arg(m_databaseName);
}

bool DatabaseManager::validateUser(const QString &username, const QString &password)
{
    QSqlQuery query(m_db);

    // Используем pgcrypto для проверки пароля
    query.prepare("SELECT id FROM users WHERE username = :username AND password_hash = crypt(:password, password_hash)");
    query.bindValue(":username", username);
    query.bindValue(":password", password);

    if (query.exec() && query.next()) {
        return true;
    }

    qDebug() << "User validation failed:" << query.lastError();
    return false;
}

QVariantList DatabaseManager::getUsers()
{
    QVariantList users;
    QSqlQuery query("SELECT id, username, email, role FROM users", m_db);

    while (query.next()) {
        QVariantMap user;
        user["id"] = query.value(0);
        user["username"] = query.value(1);
        user["email"] = query.value(2);
        user["role"] = query.value(3);
        users.append(user);
    }

    return users;
}

QVariantList DatabaseManager::getCourses()
{
    QVariantList courses;
    QSqlQuery query("SELECT id, title, description, instructor_id FROM courses WHERE is_active = true", m_db);

    while (query.next()) {
        QVariantMap course;
        course["id"] = query.value(0);
        course["title"] = query.value(1);
        course["description"] = query.value(2);
        course["instructor_id"] = query.value(3);
        courses.append(course);
    }

    return courses;
}
