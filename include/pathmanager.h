#ifndef PATHMANAGER_H
#define PATHMANAGER_H

#include <QObject>
#include <QString>

class PathManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool isFlatpak READ isFlatpak NOTIFY changed)
    Q_PROPERTY(QString homeDir READ homeDir NOTIFY changed)
    Q_PROPERTY(QString dataDir READ dataDir NOTIFY changed)
    Q_PROPERTY(QString launcherDir READ launcherDir NOTIFY changed)
    Q_PROPERTY(QString versionsDir READ versionsDir NOTIFY changed)
    Q_PROPERTY(QString profilesDir READ profilesDir NOTIFY changed)
    Q_PROPERTY(QString logsDir READ logsDir NOTIFY changed)
    Q_PROPERTY(QString configFile READ configFile NOTIFY changed)
    Q_PROPERTY(QString mcpelauncherExtract READ mcpelauncherExtract NOTIFY changed)
    Q_PROPERTY(QString mcpelauncherClient READ mcpelauncherClient NOTIFY changed)

public:
    explicit PathManager(QObject *parent = nullptr);

    bool isFlatpak() const;
    QString homeDir() const;
    QString dataDir() const;
    QString launcherDir() const;
    QString versionsDir() const;
    QString profilesDir() const;
    QString logsDir() const;
    QString configFile() const;
    QString mcpelauncherExtract() const;
    QString mcpelauncherClient() const;

    // Ensure directories exist (callable from code)
    Q_INVOKABLE void ensurePathsExist() const;

    // Copia (stage) un archivo externo a un area de datos accesible por la
    // aplicación (por ejemplo dentro de dataDir()/imports) y devuelve la ruta
    // destino. Si la copia falla devuelve cadena vacía.
    Q_INVOKABLE QString stageFileForExtraction(const QString &originalPath) const;
    Q_INVOKABLE bool removeStagedFile(const QString &path) const;

signals:
    void changed();

private:
    bool m_isFlatpak;
    QString m_homeDir;
    QString m_dataDir;
    QString m_launcherDir;
    QString m_versionsDir;
    QString m_profilesDir;
    QString m_logsDir;
    QString m_configFile;
    QString m_mcpelauncherExtract;
    QString m_mcpelauncherClient;

    void computePaths();
};

#endif // PATHMANAGER_H
