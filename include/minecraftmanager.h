#ifndef MINECRAFTMANAGER_H
#define MINECRAFTMANAGER_H

#include <QObject>
#include <QString>
#include <QStringList>

class MinecraftManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString installedVersion READ installedVersion NOTIFY versionChanged)
    Q_PROPERTY(bool isInstalled READ isInstalled NOTIFY installationChanged)

public:
    explicit MinecraftManager(QObject *parent = nullptr);

    QString installedVersion() const;
    bool isInstalled() const;

    Q_INVOKABLE void checkInstallation();
    Q_INVOKABLE QStringList getAvailableVersions();
    Q_INVOKABLE QString getGameDirectory() const;
    Q_INVOKABLE bool deleteVersion(const QString &version);

signals:
    void versionChanged(const QString &version);
    void installationChanged(bool installed);
    void logMessage(const QString &message);

private:
    QString m_installedVersion;
    bool m_isInstalled;
    QString m_gameDirectory;

    void detectVersion();
};

#endif // MINECRAFTMANAGER_H
