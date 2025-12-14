#include "../include/pathmanager.h"

#include <QDir>
#include <QStandardPaths>
#include <QCoreApplication>
#include <QDebug>
#include <QFile>
#include <QFileInfo>
#include <QUrl>

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

QString PathManager::stageFileForExtraction(const QString &originalPath) const
{
    if (originalPath.isEmpty()) return QString();

    // Clean file:// URL if present
    QString path = originalPath;
    if (path.startsWith("file://")) {
        QUrl u(path);
        path = u.toLocalFile();
    }

    QFileInfo srcInfo(path);
    if (!srcInfo.exists()) {
        qWarning() << "[PathManager] stageFileForExtraction: source does not exist:" << path;
        return QString();
    }

    // If the file is already inside versionsDir or dataDir, return as-is
    QString abs = QDir::cleanPath(srcInfo.absoluteFilePath());
    if (abs.startsWith(QDir(m_versionsDir).absolutePath()) || abs.startsWith(QDir(m_dataDir).absolutePath())) {
        qDebug() << "[PathManager] stageFileForExtraction: file already in data area, returning original:" << abs;
        return abs;
    }

    // Create imports dir
    QString importsDir = QDir(m_dataDir).filePath("imports");
    QDir().mkpath(importsDir);

    QString dest = QDir(importsDir).filePath(srcInfo.fileName());

    // If destination exists, try to generate a unique name
    if (QFile::exists(dest)) {
        QString base = srcInfo.completeBaseName();
        QString ext = srcInfo.suffix();
        int i = 1;
        QString tryPath;
        do {
            tryPath = QDir(importsDir).filePath(QString("%1-%2.%3").arg(base).arg(i).arg(ext));
            ++i;
        } while (QFile::exists(tryPath) && i < 10000);
        dest = tryPath;
    }

    bool ok = QFile::copy(abs, dest);
    if (!ok) {
        qWarning() << "[PathManager] Failed to copy" << abs << "->" << dest;
        return QString();
    }

    qDebug() << "[PathManager] staged file for extraction:" << abs << "->" << dest;
    return QDir::cleanPath(dest);
}
