#include "../include/pathmanager.h"

#include <QCoreApplication>
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QStandardPaths>
#include <QUrl>

PathManager::PathManager(QObject *parent) : QObject(parent) {
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

void PathManager::computePaths() {
  m_isFlatpak = !qgetenv("FLATPAK_ID").isEmpty();
  m_homeDir = QDir::homePath();

  // 1. Variable de Entorno
  QByteArray envDataDir = qgetenv("MINECRAFT_DATA_DIR");
  if (!envDataDir.isEmpty()) {
    m_dataDir = QString::fromUtf8(envDataDir);
    qDebug() << "[PathManager] Using MINECRAFT_DATA_DIR override:" << m_dataDir;
  }
  // 2. Modo terminal/Portátil (Si existe carpeta 'data' local o estamos en
  // 'build')
  else {
    QString appDirPath = QCoreApplication::applicationDirPath();
    // Verificamos si estamos en una carpeta de build o si hay una carpeta
    // 'data' al lado del ejecutable
    bool isDev =
        appDirPath.contains("/build") || QDir(appDirPath).exists("data");

    if (isDev && !m_isFlatpak) {
      m_dataDir = QDir(appDirPath).filePath("data");
      qDebug()
          << "[PathManager] Terminal/Dev mode detected, using local data dir:"
          << m_dataDir;
    } else if (m_isFlatpak) {
      // 3. Flatpak
      QByteArray xdg = qgetenv("XDG_DATA_HOME");
      QString base;
      if (!xdg.isEmpty()) {
        base = QString::fromUtf8(xdg);
      } else {
        base = m_homeDir + "/.var/app/org.lazheart.minecraft-launcher/data";
      }
      // Aseguramos que termine en /minecraft para consistencia con los datos
      // existentes del usuario
      m_dataDir = QDir::cleanPath(base + "/minecraft");
      qDebug() << "[PathManager] Flatpak detected, using data dir:"
               << m_dataDir;
    } else {
      // 4. Nativo (Carpeta de datos estándar del sistema)
      m_dataDir =
          QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
      if (m_dataDir.isEmpty()) {
        m_dataDir = QDir::cleanPath(m_homeDir + "/.minecraft-launcher");
      }
      qDebug() << "[PathManager] Native mode, using AppDataLocation:"
               << m_dataDir;
    }
  }

  m_dataDir = QDir::cleanPath(m_dataDir);

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

  // Allow overriding the extractor/client binary via environment variables
  QByteArray envExtract = qgetenv("MCPELAUNCHER_EXTRACT");
  if (!envExtract.isEmpty()) {
    m_mcpelauncherExtract = QString::fromUtf8(envExtract);
    qDebug() << "[PathManager] MCPELAUNCHER_EXTRACT override:"
             << m_mcpelauncherExtract;
  }
  QByteArray envClient = qgetenv("MCPELAUNCHER_CLIENT");
  if (!envClient.isEmpty()) {
    m_mcpelauncherClient = QString::fromUtf8(envClient);
    qDebug() << "[PathManager] MCPELAUNCHER_CLIENT override:"
             << m_mcpelauncherClient;
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
QString PathManager::mcpelauncherExtract() const {
  return m_mcpelauncherExtract;
}
QString PathManager::mcpelauncherClient() const { return m_mcpelauncherClient; }

void PathManager::ensurePathsExist() const {
  QDir d;
  d.mkpath(m_launcherDir);
  d.mkpath(m_versionsDir);
  d.mkpath(m_profilesDir);
  d.mkpath(m_logsDir);
  // Ensure optional asset dirs exist as well
  QString backgrounds = QDir(m_dataDir).filePath("backgrounds");
  QString icons = QDir(m_dataDir).filePath("icons");
  d.mkpath(backgrounds);
  d.mkpath(icons);
  qDebug() << "[PathManager] ensurePathsExist created (or verified) dirs:";
  qDebug() << "  launcherDir=" << m_launcherDir;
  qDebug() << "  versionsDir=" << m_versionsDir;
  qDebug() << "  profilesDir=" << m_profilesDir;
  qDebug() << "  logsDir=" << m_logsDir;
  qDebug() << "  backgrounds=" << backgrounds;
  qDebug() << "  icons=" << icons;
}

QString PathManager::stageFileForExtraction(const QString &originalPath) const {
  if (originalPath.isEmpty())
    return QString();

  // Clean file:// URL if present
  QString path = originalPath;
  if (path.startsWith("file://")) {
    QUrl u(path);
    path = u.toLocalFile();
  }

  QFileInfo srcInfo(path);
  bool srcExists = srcInfo.exists();
  if (!srcExists) {
    // Best-effort fallback for portal paths (e.g. Flatpak file chooser)
    // Some portals expose files under /run/user/... which in some
    // confinement setups may not be visible to QFileInfo(). In that
    // case, attempt the copy anyway if the path looks like a portal
    // path. The copy may still fail if sandboxing prevents access.
    if (!path.startsWith("/run/user/")) {
      qWarning()
          << "[PathManager] stageFileForExtraction: source does not exist:"
          << path;
      return QString();
    }
    qDebug() << "[PathManager] stageFileForExtraction: source not visible to "
                "QFileInfo(), attempting portal fallback copy:"
             << path;
  }

  // If the file is already inside versionsDir or dataDir, return as-is
  QString abs = QDir::cleanPath(srcInfo.absoluteFilePath());
  if (abs.startsWith(QDir(m_versionsDir).absolutePath()) ||
      abs.startsWith(QDir(m_dataDir).absolutePath())) {
    qDebug() << "[PathManager] stageFileForExtraction: file already in data "
                "area, returning original:"
             << abs;
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
      tryPath = QDir(importsDir)
                    .filePath(QString("%1-%2.%3").arg(base).arg(i).arg(ext));
      ++i;
    } while (QFile::exists(tryPath) && i < 10000);
    dest = tryPath;
  }

  bool ok = QFile::copy(abs, dest);
  if (!ok) {
    qWarning()
        << "[PathManager] Failed to copy" << abs << "->" << dest
        << "; attempting stream-based fallback (may still fail due to sandbox)";
    // Fallback: try to open source and write bytes manually. This can
    // succeed in cases where QFile::copy fails but reading the file is
    // possible via QFile (some platform semantics differ).
    QFile in(abs);
    if (in.open(QIODevice::ReadOnly)) {
      QFile out(dest);
      if (out.open(QIODevice::WriteOnly)) {
        QByteArray data = in.readAll();
        qint64 written = out.write(data);
        out.close();
        in.close();
        if (written == data.size()) {
          qDebug()
              << "[PathManager] staged file for extraction via stream fallback:"
              << abs << "->" << dest;
          return QDir::cleanPath(dest);
        } else {
          qWarning() << "[PathManager] Stream fallback write incomplete"
                     << written << "vs" << data.size();
        }
      } else {
        qWarning() << "[PathManager] Failed to open dest for writing:" << dest;
      }
    } else {
      qWarning() << "[PathManager] Failed to open source for reading "
                    "(portal/sandbox may block):"
                 << abs;
    }
    return QString();
  }

  qDebug() << "[PathManager] staged file for extraction:" << abs << "->"
           << dest;
  return QDir::cleanPath(dest);
}

bool PathManager::removeStagedFile(const QString &path) const {
  if (path.isEmpty())
    return false;
  QString clean = QDir::cleanPath(path);
  QString importsDir = QDir(m_dataDir).filePath("imports");
  if (clean.startsWith(QDir(importsDir).absolutePath())) {
    if (QFile::exists(clean)) {
      bool ok = QFile::remove(clean);
      if (!ok)
        qWarning() << "[PathManager] removeStagedFile: failed to remove"
                   << clean;
      return ok;
    }
  }
  return false;
}
