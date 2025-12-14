#include "../include/pathmanager.h"

#include <QDir>
#include <QStandardPaths>
#include <QCoreApplication>
#include <QDebug>

PathManager::PathManager(QObject *parent)
    : QObject(parent)
{
    computePaths();
    qDebug() << "[PathManager] computed paths:";
    qDebug() << "  isFlatpak=" << m_isFlatpak;
    qDebug() << "  homeDir=" << m_homeDir;
    qDebug() << "  dataDir=" << m_dataDir;
    qDebug() << "  launcherDir=" << m_launcherDir;
    qDebug() << "  versionsDir=" << m_versionsDir;
    qDebug() << "  profilesDir=" << m_profilesDir;
    qDebug() << "  logsDir=" << m_logsDir;
    qDebug() << "  extractor=" << m_mcpelauncherExtract;
    qDebug() << "  client=" << m_mcpelauncherClient;

    ensurePathsExist();
}

void PathManager::computePaths()
{
    QByteArray flatpak = qgetenv("FLATPAK_ID");
    m_isFlatpak = !flatpak.isEmpty();

    m_homeDir = QDir::homePath();

    if (m_isFlatpak) {
        QByteArray xdg = qgetenv("XDG_DATA_HOME");
        if (!xdg.isEmpty()) {
            m_dataDir = QString::fromUtf8(xdg) + "/" + QCoreApplication::applicationName();
        } else {
            m_dataDir = QDir::cleanPath(m_homeDir + "/.var/app/org.lazheart.minecraft-launcher/data");
        }
    } else {
        m_dataDir = QDir::cleanPath(m_homeDir + "/.local/share/minecraft-launcher");
    }

    m_launcherDir = QDir::cleanPath(m_dataDir + "/minecraft-bedrock");
    m_versionsDir = QDir::cleanPath(m_launcherDir + "/versions");
    m_profilesDir = QDir::cleanPath(m_launcherDir + "/profiles");
    m_logsDir = QDir::cleanPath(m_launcherDir + "/logs");
    m_configFile = QDir::cleanPath(m_launcherDir + "/config.json");

    if (m_isFlatpak) {
        m_mcpelauncherExtract = "/app/bin/mcpelauncher-extract";
        m_mcpelauncherClient = "/app/bin/mcpelauncher-client";
    } else {
        m_mcpelauncherExtract = "mcpelauncher-extract";
        m_mcpelauncherClient = "mcpelauncher-client";
    }
}

bool PathManager::isFlatpak() const { return m_isFlatpak; }
QString PathManager::homeDir() const { return m_homeDir; }
QString PathManager::dataDir() const { return m_dataDir; }
QString PathManager::launcherDir() const { return m_launcherDir; }
QString PathManager::versionsDir() const { return m_versionsDir; }
QString PathManager::profilesDir() const { return m_profilesDir; }
QString PathManager::logsDir() const { return m_logsDir; }
QString PathManager::configFile() const { return m_configFile; }
QString PathManager::mcpelauncherExtract() const { return m_mcpelauncherExtract; }
QString PathManager::mcpelauncherClient() const { return m_mcpelauncherClient; }

void PathManager::ensurePathsExist() const
{
    QDir d;
    d.mkpath(m_launcherDir);
    d.mkpath(m_versionsDir);
    d.mkpath(m_profilesDir);
    d.mkpath(m_logsDir);
    qDebug() << "[PathManager] ensurePathsExist created (or verified) dirs:";
    qDebug() << "  launcherDir=" << m_launcherDir;
    qDebug() << "  versionsDir=" << m_versionsDir;
    qDebug() << "  profilesDir=" << m_profilesDir;
    qDebug() << "  logsDir=" << m_logsDir;
}
