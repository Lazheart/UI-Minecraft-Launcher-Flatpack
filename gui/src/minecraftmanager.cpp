#include "../include/minecraftmanager.h"
#include <QDir>
#include <QFile>
#include <QDebug>
#include <QStandardPaths>

MinecraftManager::MinecraftManager(QObject *parent)
    : QObject(parent)
    , m_isInstalled(false)
{
    QString homeDir = QStandardPaths::writableLocation(QStandardPaths::HomeLocation);
    m_gameDirectory = homeDir + "/.local/share/mcpelauncher";
    
    checkInstallation();
}

QString MinecraftManager::installedVersion() const
{
    return m_installedVersion;
}

bool MinecraftManager::isInstalled() const
{
    return m_isInstalled;
}

void MinecraftManager::checkInstallation()
{
    detectVersion();
    
    bool wasInstalled = m_isInstalled;
    m_isInstalled = !m_installedVersion.isEmpty();
    
    if (wasInstalled != m_isInstalled) {
        emit installationChanged(m_isInstalled);
    }
    
    if (m_isInstalled) {
        emit logMessage(QString("Minecraft detectado: versión %1").arg(m_installedVersion));
    } else {
        emit logMessage("Minecraft no está instalado");
    }
}

QStringList MinecraftManager::getAvailableVersions()
{
    QStringList versions;
    QDir versionsDir(m_gameDirectory + "/versions");
    
    if (versionsDir.exists()) {
        QStringList entries = versionsDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot);
        for (const QString &entry : entries) {
            versions << entry;
        }
    }
    
    return versions;
}

QString MinecraftManager::getGameDirectory() const
{
    return m_gameDirectory;
}

void MinecraftManager::detectVersion()
{
    // Intentar detectar la versión instalada
    QString versionFile = m_gameDirectory + "/versions/current.txt";
    
    if (QFile::exists(versionFile)) {
        QFile file(versionFile);
        if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
            m_installedVersion = QString::fromUtf8(file.readAll()).trimmed();
            emit versionChanged(m_installedVersion);
            file.close();
            return;
        }
    }
    
    // Si no hay archivo de versión, buscar en el directorio de versiones
    QStringList versions = getAvailableVersions();
    if (!versions.isEmpty()) {
        m_installedVersion = versions.first();
        emit versionChanged(m_installedVersion);
    } else {
        m_installedVersion.clear();
        emit versionChanged("");
    }
}
