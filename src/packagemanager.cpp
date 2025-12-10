#include "../include/packagemanager.h"
#include "../include/zipvalidator.h"
#include "../include/packageinspector.h"
#include <QDir>
#include <QFile>
#include <QDebug>
#include <QJsonDocument>
#include <QJsonArray>

PackageManager::PackageManager(const QString &versionsPath, 
                               const QString &profilesPath,
                               QObject *parent)
    : QObject(parent)
    , m_versionsPath(versionsPath)
    , m_profilesPath(profilesPath)
{
    qDebug() << "[PackageManager] Inicializado";
    qDebug() << "[PackageManager] Versions path:" << versionsPath;
    qDebug() << "[PackageManager] Profiles path:" << profilesPath;
}

QStringList PackageManager::getInstalledVersions()
{
    QStringList versions;
    QDir versionsDir(m_versionsPath);
    
    if (!versionsDir.exists()) {
        qWarning() << "[PackageManager] Versions directory does not exist:" << m_versionsPath;
        return versions;
    }
    
    // Obtener solo directorios (cada versión es un directorio)
    QFileInfoList entries = versionsDir.entryInfoList(QDir::Dirs | QDir::NoDotAndDotDot);
    for (const QFileInfo &info : entries) {
        versions.append(info.fileName());
    }
    
    qDebug() << "[PackageManager] Found versions:" << versions;
    return versions;
}

QStringList PackageManager::getWorldsForVersion(const QString &version)
{
    QStringList worlds;
    QString worldsPath = getWorldsPath(version);
    QDir worldsDir(worldsPath);
    
    if (!worldsDir.exists()) {
        qDebug() << "[PackageManager] Worlds directory does not exist:" << worldsPath;
        return worlds;
    }
    
    QFileInfoList entries = worldsDir.entryInfoList(QDir::Dirs | QDir::NoDotAndDotDot);
    for (const QFileInfo &info : entries) {
        worlds.append(info.fileName());
    }
    
    qDebug() << "[PackageManager] Found worlds for version" << version << ":" << worlds;
    return worlds;
}

QStringList PackageManager::getResourcePacksForVersion(const QString &version)
{
    QStringList packs;
    QString packsPath = getResourcePacksPath(version);
    QDir packsDir(packsPath);
    
    if (!packsDir.exists()) {
        qDebug() << "[PackageManager] Resource packs directory does not exist:" << packsPath;
        return packs;
    }
    
    QFileInfoList entries = packsDir.entryInfoList(QDir::Dirs | QDir::NoDotAndDotDot);
    for (const QFileInfo &info : entries) {
        packs.append(info.fileName());
    }
    
    qDebug() << "[PackageManager] Found resource packs for version" << version << ":" << packs;
    return packs;
}

QStringList PackageManager::getBehaviorPacksForVersion(const QString &version)
{
    QStringList packs;
    QString packsPath = getBehaviorPacksPath(version);
    QDir packsDir(packsPath);
    
    if (!packsDir.exists()) {
        qDebug() << "[PackageManager] Behavior packs directory does not exist:" << packsPath;
        return packs;
    }
    
    QFileInfoList entries = packsDir.entryInfoList(QDir::Dirs | QDir::NoDotAndDotDot);
    for (const QFileInfo &info : entries) {
        packs.append(info.fileName());
    }
    
    qDebug() << "[PackageManager] Found behavior packs for version" << version << ":" << packs;
    return packs;
}

QJsonObject PackageManager::getWorldInfo(const QString &version, const QString &worldName)
{
    QJsonObject info;
    QString worldPath = getWorldsPath(version) + "/" + worldName;
    
    // Buscar level.dat o levelname.txt
    QDir worldDir(worldPath);
    if (!worldDir.exists()) {
        qWarning() << "[PackageManager] World path does not exist:" << worldPath;
        info["error"] = "World directory not found";
        return info;
    }
    
    info["name"] = worldName;
    info["path"] = worldPath;
    info["version"] = version;
    
    // Puedes añadir más información leyendo archivos de metadatos
    return info;
}

QJsonObject PackageManager::getPackageInfo(const QString &packagePath)
{
    return PackageInspector::getPackageMetadata(packagePath);
}

bool PackageManager::validateZipFile(const QString &filePath)
{
    return ZipValidator::isValidZip(filePath) && !ZipValidator::hasPathTraversal(filePath);
}

bool PackageManager::validateApkFile(const QString &filePath)
{
    // Un APK es un ZIP, así que usamos la misma validación
    return ZipValidator::isValidZip(filePath) && ZipValidator::validateFileSize(filePath);
}

QString PackageManager::getVersionPath(const QString &version) const
{
    return m_versionsPath + "/" + version;
}

QString PackageManager::getWorldsPath(const QString &version) const
{
    return getVersionPath(version) + "/worlds";
}

QString PackageManager::getResourcePacksPath(const QString &version) const
{
    return getVersionPath(version) + "/resource_packs";
}

QString PackageManager::getBehaviorPacksPath(const QString &version) const
{
    return getVersionPath(version) + "/behavior_packs";
}

void PackageManager::ensureDirectoryStructure(const QString &version)
{
    QDir dir;
    dir.mkpath(getWorldsPath(version));
    dir.mkpath(getResourcePacksPath(version));
    dir.mkpath(getBehaviorPacksPath(version));
    
    qDebug() << "[PackageManager] Directory structure ensured for version:" << version;
}
