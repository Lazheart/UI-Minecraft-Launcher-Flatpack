#ifndef MINECRAFTMANAGER_H
#define MINECRAFTMANAGER_H

#include <QObject>
#include <QStringList>
#include <QVariant>

class PathManager;
class QProcess;

class MinecraftManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString installedVersion READ installedVersion NOTIFY installedVersionChanged)
    Q_PROPERTY(bool isInstalled READ checkInstallation NOTIFY availableVersionsChanged)
    Q_PROPERTY(bool isRunning READ isRunning NOTIFY isRunningChanged)
    Q_PROPERTY(QString status READ status NOTIFY statusChanged)
public:
    explicit MinecraftManager(PathManager *paths = nullptr, QObject *parent = nullptr);

    // Devuelve una lista de objetos { name, path } para cada versión disponible
    Q_INVOKABLE QVariantList getAvailableVersions() const;

    // Elimina una versión (ruta completa) y opcionalmente su perfil asociado
    Q_INVOKABLE void deleteVersion(const QString &versionPath, bool deleteProfile = true);

    // Solicita la instalación/extracción de un APK con nombre y posibles assets
    Q_INVOKABLE void installRequested(const QString &apkPath,
                                      const QString &name,
                                      bool useDefaultIcon,
                                      const QString &iconPath,
                                      bool useDefaultBackground,
                                      const QString &backgroundPath);

    // Comportamientos mínimos/auxiliares (stubs) que pueden ampliarse
    Q_INVOKABLE bool checkInstallation() const;
    Q_INVOKABLE bool isRunning() const;
    Q_INVOKABLE QString status() const;

    // Control del juego
    Q_INVOKABLE bool runGame(const QString &versionPath, const QString &unused, const QString &profile);
    Q_INVOKABLE void stopGame();
    // Import a selected file into a chosen version (versionPath must be full path)
    Q_INVOKABLE void importSelected(const QString &filePath,
                                    const QString &type,
                                    const QString &versionPath,
                                    bool useShared = false,
                                    bool useNvidia = false,
                                    bool useZink = false,
                                    bool useMangohud = false);

    QString installedVersion() const { return m_installedVersion; }

    Q_INVOKABLE QString getLauncherVersion() const;

signals:
    void availableVersionsChanged();
    void installedVersionChanged();
    void isRunningChanged();
    void statusChanged();
    // Señal emitida después de borrar una o varias versiones (listas de rutas eliminadas)
    void versionsDeleted(QVariantList deletedPaths);
    // Señales para notificar resultado de instalación/extracción
    void installSucceeded(const QString &versionPath);
    void installFailed(const QString &versionPath, const QString &reason);
    // Signals for import operations
    void importSucceeded(const QString &versionPath, const QString &filePath);
    void importFailed(const QString &versionPath, const QString &filePath, const QString &reason);

private:
    QString m_installedVersion;
    QString versionsDir() const;
    PathManager *m_pathManager = nullptr;
    QProcess *m_gameProcess = nullptr;
    QString m_status;
};

#endif // MINECRAFTMANAGER_H
