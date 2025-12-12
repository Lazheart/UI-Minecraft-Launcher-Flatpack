#ifndef LAUNCHERBACKEND_H
#define LAUNCHERBACKEND_H

#include <QObject>
#include <QString>
#include <QProcess>
#include <QSettings>
#include <QStringList>
#include <QJsonObject>

class PackageManager;
class InstallAPKWorker;
class ImportWorldWorker;
class ImportPackWorker;
class RunGameWorker;

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
    Q_PROPERTY(QString appDir READ getAppDir CONSTANT)
    Q_PROPERTY(QString dataDir READ getDataDir CONSTANT)
    Q_PROPERTY(QString binDir READ binDir CONSTANT)
    Q_PROPERTY(QString language READ language WRITE setLanguage NOTIFY languageChanged)
    Q_PROPERTY(QString theme READ theme WRITE setTheme NOTIFY themeChanged)
    Q_PROPERTY(double scale READ scale WRITE setScale NOTIFY scaleChanged)

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
    QString language() const;
    QString theme() const;
    double scale() const;

    // Métodos invocables desde QML
    Q_INVOKABLE void setLanguage(const QString &language);
    Q_INVOKABLE void setTheme(const QString &theme);
    Q_INVOKABLE void setScale(double scale);
    Q_INVOKABLE void applyProfileSettings(const QString &language, const QString &theme, double scale);
    Q_INVOKABLE void saveProfileSettings(const QString &profileName);
    Q_INVOKABLE void openFolder(const QString &path);
    Q_INVOKABLE void saveSettings();
    Q_INVOKABLE void applySettings();
    Q_INVOKABLE void resetSettings();
    Q_INVOKABLE void launchGame(const QString &profile = QString());
    Q_INVOKABLE void stopGame();
    Q_INVOKABLE QString getAppDir() const;
    Q_INVOKABLE QString getDataDir() const;
    Q_INVOKABLE QString binDir() const;
    Q_INVOKABLE QString getExtractorPath() const;
    Q_INVOKABLE QString getClientPath() const;
    Q_INVOKABLE void showNotification(const QString &title, const QString &message);
    Q_INVOKABLE void installVersion(const QString &name,
                                    const QString &apkRoute,
                                    const QString &iconPath = QString(),
                                    const QString &backgroundPath = QString(),
                                    bool useDefaultIcon = true,
                                    bool useDefaultBackground = true);
    
    // Package Management
    Q_INVOKABLE QStringList getInstalledVersions();
    Q_INVOKABLE QStringList getWorldsForVersion(const QString &version);
    Q_INVOKABLE QStringList getResourcePacksForVersion(const QString &version);
    Q_INVOKABLE QStringList getBehaviorPacksForVersion(const QString &version);
    Q_INVOKABLE QJsonObject getWorldInfo(const QString &version, const QString &worldName);
    Q_INVOKABLE QJsonObject getPackageInfo(const QString &packagePath);
    
    // Workers
    Q_INVOKABLE void installAPK(const QString &apkPath, const QString &versionName);
    Q_INVOKABLE void importWorld(const QString &worldZipPath, const QString &version);
    Q_INVOKABLE void importPack(const QString &packZipPath, const QString &version);
    Q_INVOKABLE void runGame(const QString &version, 
                            const QString &worldName = QString(),
                            const QString &profile = QString());
    Q_INVOKABLE void stopGameProcess();

signals:
    void statusChanged(const QString &status);
    void isRunningChanged(bool running);
    void gameStarted();
    void gameStopped();
    void errorOccurred(const QString &error);
    void logMessage(const QString &message);
    void languageChanged(const QString &language);
    void themeChanged(const QString &theme);
    void scaleChanged(double scale);
    void installVersionRequested(const QString &name,
                                 const QString &apkRoute,
                                 const QString &iconPath,
                                 const QString &backgroundPath,
                                 bool useDefaultIcon,
                                 bool useDefaultBackground);
    
    // Package Management signals
    void installProgress(int current, int total, const QString &message);
    void importProgress(int current, int total, const QString &message);
    void installationCompleted(const QString &version);
    void importCompleted(const QString &worldOrPackName);
    void operationFailed(const QString &error);
    void gameProcessStarted();
    void gameProcessStopped(int exitCode);
    void gameLogMessage(const QString &message);
    void versionsChanged();
    void worldsChanged(const QString &version);
    void packsChanged(const QString &version);
private:
    QProcess *m_gameProcess;
    QString m_status;
    QString m_appDir;
    QString m_dataDir;
    QString m_versionsPath;
    QString m_backgroundsPath;
    QString m_iconsPath;
    QString m_profilesPath;
    QString m_language;
    QString m_theme;
    double m_scale;
    QSettings *m_settings;
    
    // Package Management
    PackageManager *m_packageManager;
    
    // Workers
    InstallAPKWorker *m_installAPKWorker;
    ImportWorldWorker *m_importWorldWorker;
    ImportPackWorker *m_importPackWorker;
    RunGameWorker *m_runGameWorker;

    void setStatus(const QString &status);
    void setupEnvironment();
    void initializePackageManager();
    void cleanupWorkers();
    void emitStartupMessages();
    // Install APK slots
    void onInstallAPKProgress(int current, int total);
    void onInstallAPKFinished(bool success, const QString &message);
    void onInstallAPKLog(const QString &message);
    
    // Import World slots
    void onImportWorldProgress(int current, int total);
    void onImportWorldFinished(bool success, const QString &worldName);
    void onImportWorldLog(const QString &message);
    
    // Import Pack slots
    void onImportPackProgress(int current, int total);
    void onImportPackFinished(bool success, const QString &packName);
    void onImportPackLog(const QString &message);
    
    // Game Worker slots
    void onGameWorkerStarted();
    void onGameWorkerStopped(int exitCode);
    void onGameWorkerError(const QString &error);
    void onGameWorkerLog(const QString &message);
    void onProcessStarted();
    void onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus);
    void onProcessError(QProcess::ProcessError error);
    void onProcessOutput();
    // Console logging helper
    void onConsoleLog(const QString &message);
};

#endif // LAUNCHERBACKEND_H
