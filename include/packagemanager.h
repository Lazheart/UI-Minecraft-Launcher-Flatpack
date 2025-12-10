#ifndef PACKAGEMANAGER_H
#define PACKAGEMANAGER_H

#include <QObject>
#include <QString>
#include <QStringList>
#include <QJsonObject>

class PackageManager : public QObject
{
    Q_OBJECT

public:
    explicit PackageManager(const QString &versionsPath, 
                           const QString &profilesPath,
                           QObject *parent = nullptr);

    // Obtener listados
    Q_INVOKABLE QStringList getInstalledVersions();
    Q_INVOKABLE QStringList getWorldsForVersion(const QString &version);
    Q_INVOKABLE QStringList getResourcePacksForVersion(const QString &version);
    Q_INVOKABLE QStringList getBehaviorPacksForVersion(const QString &version);

    // Información de paquetes
    Q_INVOKABLE QJsonObject getWorldInfo(const QString &version, const QString &worldName);
    Q_INVOKABLE QJsonObject getPackageInfo(const QString &packagePath);

    // Validación
    Q_INVOKABLE bool validateZipFile(const QString &filePath);
    Q_INVOKABLE bool validateApkFile(const QString &filePath);

    // Paths
    QString getVersionPath(const QString &version) const;
    QString getWorldsPath(const QString &version) const;
    QString getResourcePacksPath(const QString &version) const;
    QString getBehaviorPacksPath(const QString &version) const;

signals:
    // Señales de progreso
    void installProgress(int current, int total, const QString &message);
    void importProgress(int current, int total, const QString &message);
    
    // Señales de finalización
    void installationCompleted(const QString &version);
    void importCompleted(const QString &worldOrPackName);
    void operationFailed(const QString &error);
    
    // Señales de información
    void logMessage(const QString &message);
    void versionsChanged();
    void worldsChanged(const QString &version);
    void packsChanged(const QString &version);

private:
    QString m_versionsPath;
    QString m_profilesPath;

    // Métodos privados de validación
    bool validateManifestJson(const QString &zipPath);
    QString extractPackageType(const QString &zipPath);
    QString extractPackageUuid(const QString &zipPath);
    
    // Métodos de creación de directorios
    void ensureDirectoryStructure(const QString &version);
};

#endif // PACKAGEMANAGER_H
