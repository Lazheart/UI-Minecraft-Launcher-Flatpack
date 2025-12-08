#ifndef LAUNCHERBACKEND_H
#define LAUNCHERBACKEND_H

#include <QObject>
#include <QString>
#include <QProcess>
#include <QSettings>

class LauncherBackend : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString version READ version CONSTANT)
    Q_PROPERTY(QString status READ status NOTIFY statusChanged)
    Q_PROPERTY(bool isRunning READ isRunning NOTIFY isRunningChanged)

public:
    explicit LauncherBackend(QObject *parent = nullptr);
    ~LauncherBackend();

    QString version() const;
    QString status() const;
    bool isRunning() const;

    // Métodos invocables desde QML
    Q_INVOKABLE void launchGame(const QString &profile = QString());
    Q_INVOKABLE void stopGame();
    Q_INVOKABLE QString getAppDir() const;
    Q_INVOKABLE QString getDataDir() const;
    Q_INVOKABLE void showNotification(const QString &title, const QString &message);

signals:
    void statusChanged(const QString &status);
    void isRunningChanged(bool running);
    void gameStarted();
    void gameStopped();
    void errorOccurred(const QString &error);
    void logMessage(const QString &message);

private slots:
    void onProcessStarted();
    void onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus);
    void onProcessError(QProcess::ProcessError error);
    void onProcessOutput();

private:
    QProcess *m_gameProcess;
    QString m_status;
    QString m_appDir;
    QString m_dataDir;
    QSettings *m_settings;

    void setStatus(const QString &status);
    void setupEnvironment();
};

#endif // LAUNCHERBACKEND_H
