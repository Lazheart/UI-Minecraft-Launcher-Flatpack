#ifndef WORKERS_H
#define WORKERS_H

#include <QThread>
#include <QString>
#include <QProcess>

// ============= InstallAPKWorker =============
class InstallAPKWorker : public QThread
{
    Q_OBJECT

public:
    InstallAPKWorker(const QString &apkPath, 
                    const QString &versionName,
                    const QString &extractorPath,
                    const QString &targetDir);

protected:
    void run() override;

signals:
    void progress(int current, int total);
    void finished(bool success, const QString &message);
    void logMessage(const QString &message);

private:
    QString m_apkPath;
    QString m_versionName;
    QString m_extractorPath;
    QString m_targetDir;
};

// ============= ImportWorldWorker =============
class ImportWorldWorker : public QThread
{
    Q_OBJECT

public:
    ImportWorldWorker(const QString &worldZipPath, 
                     const QString &destinationPath);

protected:
    void run() override;

signals:
    void progress(int current, int total);
    void finished(bool success, const QString &worldName);
    void logMessage(const QString &message);

private:
    QString m_worldZipPath;
    QString m_destinationPath;

    bool validateWorldZip();
    QString extractWorldName();
};

// ============= ImportPackWorker =============
class ImportPackWorker : public QThread
{
    Q_OBJECT

public:
    ImportPackWorker(const QString &packZipPath, 
                    const QString &versionsPath,
                    const QString &versionName);

protected:
    void run() override;

signals:
    void progress(int current, int total);
    void finished(bool success, const QString &packName);
    void logMessage(const QString &message);

private:
    QString m_packZipPath;
    QString m_versionsPath;
    QString m_versionName;

    enum PackType { Resource, Behavior, Unknown };
    
    bool validatePackZip();
    PackType detectPackType();
    QString extractPackUuid();
};

// ============= RunGameWorker =============
class RunGameWorker : public QThread
{
    Q_OBJECT

public:
    RunGameWorker(const QString &versionPath,
                 const QString &worldPath = QString(),
                 const QString &profilePath = QString());
    
    ~RunGameWorker();
    
    void stopGame();

protected:
    void run() override;

signals:
    void gameStarted();
    void gameStopped(int exitCode);
    void errorOccurred(const QString &error);
    void logMessage(const QString &message);

private:
    QString m_versionPath;
    QString m_worldPath;
    QString m_profilePath;
    QProcess *m_gameProcess;
    
    void setupEnvironment();
    void readProcessOutput();
};

#endif // WORKERS_H
