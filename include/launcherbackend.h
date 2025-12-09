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
    Q_PROPERTY(QString versionsPath READ versionsPath CONSTANT)
    Q_PROPERTY(QString backgroundsPath READ backgroundsPath CONSTANT)
    Q_PROPERTY(QString iconsPath READ iconsPath CONSTANT)
    Q_PROPERTY(QString profilesPath READ profilesPath CONSTANT)

public:
    explicit LauncherBackend(QObject *parent = nullptr);
    ~LauncherBackend();

    QString version() const;
    QString status() const;
    bool isRunning() const;
    QString versionsPath() const;
    QString backgroundsPath() const;
    QString iconsPath() const;
    QString profilesPath() const;

    // Métodos invocables desde QML
    Q_INVOKABLE void openFolder(const QString &path);
    Q_INVOKABLE void launchGame(const QString &profile = QString());
    Q_INVOKABLE void stopGame();
    Q_INVOKABLE QString getAppDir() const;
    Q_INVOKABLE QString getDataDir() const;
    Q_INVOKABLE void showNotification(const QString &title, const QString &message);
    Q_INVOKABLE void installVersion(const QString &name,
                                    const QString &apkRoute,
                                    const QString &iconPath = QString(),
                                    const QString &backgroundPath = QString(),
                                    bool useDefaultIcon = true,
                                    bool useDefaultBackground = true);

signals:
    void statusChanged(const QString &status);
    void isRunningChanged(bool running);
    void gameStarted();
    void gameStopped();
    void errorOccurred(const QString &error);
    void logMessage(const QString &message);
    void installVersionRequested(const QString &name,
                                 const QString &apkRoute,
                                 const QString &iconPath,
                                 const QString &backgroundPath,
                                 bool useDefaultIcon,
                                 bool useDefaultBackground);

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
    QString m_versionsPath;
    QString m_backgroundsPath;
    QString m_iconsPath;
    QString m_profilesPath;
    QSettings *m_settings;

    void setStatus(const QString &status);
    void setupEnvironment();
};

#endif // LAUNCHERBACKEND_H
