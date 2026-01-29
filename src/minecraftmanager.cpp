#include "../include/minecraftmanager.h"
#include "../include/pathmanager.h"

#include <QDebug>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QStandardPaths>

#include "../include/minecraftextract.h"
#include "../include/minecraftlaunch.h"
#include <QFile>
#include <QProcess>

MinecraftManager::MinecraftManager(PathManager *paths, QObject *parent)
    : QObject(parent), m_pathManager(paths) {
  m_installedVersion = QString();
  qDebug() << "[MinecraftManager] Constructed. PathManager present:"
           << (m_pathManager != nullptr);

  // QML-visible startup messages
  qDebug() << "qml: [QML] Launcher iniciado";
  qDebug() << "qml: [QML] Versión:" << getLauncherVersion();

  // Report versionsDir early so logs match expected output
  qDebug() << "[MinecraftManager] checkInstallation() using versionsDir:"
           << versionsDir();

  // Check for presence of extractor and client binaries (from PathManager)
  if (m_pathManager) {
    QString extractor = m_pathManager->mcpelauncherExtract();
    QString client = m_pathManager->mcpelauncherClient();

    QFileInfo extFi(extractor);
    QFileInfo cliFi(client);

    if (extFi.isAbsolute() && extFi.exists()) {
      qDebug() << "[MinecraftManager] Found extractor binary:"
               << extFi.absoluteFilePath();
    } else if (!extFi.isAbsolute() && !extractor.isEmpty() &&
               QStandardPaths::findExecutable(extractor).isEmpty() == false) {
      qDebug() << "[MinecraftManager] Found extractor binary on PATH:"
               << extractor;
    } else {
      qWarning() << "[MinecraftManager] extractor binary NOT found:"
                 << extractor;
    }

    if (cliFi.isAbsolute() && cliFi.exists()) {
      qDebug() << "[MinecraftManager] Found client binary:"
               << cliFi.absoluteFilePath();
    } else if (!cliFi.isAbsolute() && !client.isEmpty() &&
               QStandardPaths::findExecutable(client).isEmpty() == false) {
      qDebug() << "[MinecraftManager] Found client binary on PATH:" << client;
    } else {
      qWarning() << "[MinecraftManager] client binary NOT found:" << client;
    }
  }

  // Try to detect an installed version at startup so QML bindings work
  checkInstallation();
  QVariantList avail = getAvailableVersions();
  if (!avail.isEmpty()) {
    QVariantMap first = avail.first().toMap();
    if (first.contains("name")) {
      m_installedVersion = first.value("name").toString();
      emit installedVersionChanged();
      emit availableVersionsChanged();
    }
  }
}

QString MinecraftManager::versionsDir() const {
  if (m_pathManager) {
    return m_pathManager->versionsDir();
  }

  // Fallback: permitir variable de entorno o AppData como antes
  QByteArray env = qgetenv("MINECRAFT_VERSIONS_DIR");
  if (!env.isEmpty()) {
    return QString::fromUtf8(env);
  }

  QString appData =
      QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
  if (appData.isEmpty()) {
    return QDir::cleanPath(QDir::currentPath() + "/versions");
  }
  return QDir::cleanPath(appData + "/versions");
}

#include <QDateTime>
#include <QDebug>
#include <QDir>
#include <QFileInfo>
#include <QJsonArray>
#include <QJsonDocument>

QVariantList MinecraftManager::getAvailableVersions() {
  QVariantList list;
  QString dirPath = versionsDir();

  qDebug() << "[MinecraftManager] Scanning versions directory:" << dirPath;

  QDir dir(dirPath);
  if (!dir.exists()) {
    checkInstallation();
    if (m_availableVersions != list) {
        m_availableVersions = list;
        emit availableVersionsChanged();
    }
    return m_availableVersions;
  }

  QStringList entries =
      dir.entryList(QDir::Dirs | QDir::NoDotAndDotDot, QDir::Name);
  
  QDateTime latestDate;
  QString candidateLastVersion;

  for (const QString &entry : entries) {
    QString fullPath = QDir(dirPath).filePath(entry);
    QFileInfo vInfo(fullPath);
    QDir vDir(fullPath);
    QVariantMap m;
    m.insert("name", entry);
    m.insert("path", vDir.absolutePath());

    // Installation Date (DD/MM/YY)
    QDateTime birthTime = vInfo.birthTime();
    if (!birthTime.isValid()) birthTime = vInfo.lastModified();
    m.insert("installDate", birthTime.toString("dd/MM/yy"));

    // Track latest for m_lastActiveVersion if not set
    if (m_lastActiveVersion.isEmpty()) {
        if (!latestDate.isValid() || birthTime > latestDate) {
            latestDate = birthTime;
            candidateLastVersion = entry;
        }
    }

    // Detect custom icon
    QStringList iconFilters;
    iconFilters << "custom_icon.png" << "custom_icon.jpg" << "custom_icon.jpeg"
                << "custom_icon.svg";
    QStringList icons = vDir.entryList(iconFilters, QDir::Files);
    if (!icons.isEmpty()) {
      QString iconPath = "file://" + vDir.absoluteFilePath(icons.first());
      m.insert("icon", iconPath);
    }

    // Detect custom background
    QStringList bgFilters;
    bgFilters << "custom_background.png" << "custom_background.jpg"
              << "custom_background.jpeg";
    QStringList bgs = vDir.entryList(bgFilters, QDir::Files);
    if (!bgs.isEmpty()) {
      QString bgPath = "file://" + vDir.absoluteFilePath(bgs.first());
      m.insert("background", bgPath);
    }

    list.append(m);
  }

  qDebug() << "[MinecraftManager] Found" << list.size() << "versions";

  if (m_lastActiveVersion.isEmpty() && !candidateLastVersion.isEmpty()) {
      m_lastActiveVersion = candidateLastVersion;
      emit lastActiveVersionChanged();
  }

  if (m_availableVersions != list) {
    m_availableVersions = list;
    emit availableVersionsChanged();
  }

  checkInstallation();
  return m_availableVersions;
}

bool MinecraftManager::checkInstallation() {
  // Stub simple: comprobar que existe al menos una versión
  QDir dir(versionsDir());
  qDebug() << "[MinecraftManager] checkInstallation() using versionsDir:"
           << versionsDir();
  bool installed = dir.exists() &&
                   !dir.entryList(QDir::Dirs | QDir::NoDotAndDotDot).isEmpty();

  if (installed != m_isInstalled) {
    m_isInstalled = installed;
    emit isInstalledChanged();
  }
  return m_isInstalled;
}

bool MinecraftManager::isRunning() const {
  return m_gameProcess && m_gameProcess->state() != QProcess::NotRunning;
}

QString MinecraftManager::status() const {
  if (!m_status.isEmpty())
    return m_status;
  return isRunning() ? QStringLiteral("Running") : QStringLiteral("Stopped");
}

bool MinecraftManager::runGame(const QString &versionPath,
                               const QString &unused, const QString &profile) {
  Q_UNUSED(unused);
  qDebug() << "MinecraftManager::runGame version:" << versionPath
           << "profile:" << profile;
  if (!m_pathManager) {
    qWarning() << "runGame: no PathManager";
    return false;
  }

  if (isRunning()) {
    qWarning() << "runGame: game already running";
    return false;
  }

  QString client = m_pathManager->mcpelauncherClient();
  if (client.isEmpty()) {
    qWarning() << "runGame: mcpelauncher-client not configured";
    return false;
  }

  // Accept either a full path or a version name. If a plain name is passed,
  // construct the full path inside the versionsDir().
  QString fullVersionPath = versionPath;
  QFileInfo vfi(versionPath);
  if (!vfi.isAbsolute() && !versionPath.contains(QDir::separator())) {
    fullVersionPath = QDir(versionsDir()).filePath(versionPath);
    vfi.setFile(fullVersionPath);
  }

  // Update last active version
  QString versionName = vfi.fileName();
  if (m_lastActiveVersion != versionName) {
    m_lastActiveVersion = versionName;
    emit lastActiveVersionChanged();
  }

  if (!QDir(fullVersionPath).exists()) {
    qWarning() << "runGame: version path does not exist:" << fullVersionPath;
    return false;
  }

  QString profilePath =
      QDir(m_pathManager->profilesDir()).filePath(versionName);

  QStringList args;
  args << QStringLiteral("-dg") << fullVersionPath;
  if (!profile.isEmpty()) {
    args << QStringLiteral("-dd") << profilePath;
  }

  QProcess *proc = new QProcess(this);
  QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
  proc->setProcessEnvironment(env);

  proc->start(client, args);
  if (!proc->waitForStarted(5000)) {
    qWarning() << "runGame: failed to start";
    proc->deleteLater();
    return false;
  }

  m_gameProcess = proc;
  m_status = QStringLiteral("Running");
  emit statusChanged();
  emit isRunningChanged();

  connect(proc, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
          this, [this](int code, QProcess::ExitStatus es) {
            Q_UNUSED(code);
            Q_UNUSED(es);
            m_status = QStringLiteral("Stopped");
            emit statusChanged();
            m_gameProcess = nullptr;
            emit isRunningChanged();
          });

  return true;
}

void MinecraftManager::stopGame() {
  qDebug() << "MinecraftManager::stopGame()";
  if (!m_gameProcess)
    return;
  m_gameProcess->terminate();
  if (!m_gameProcess->waitForFinished(3000)) {
    m_gameProcess->kill();
  }
  m_status = QStringLiteral("Stopped");
  emit statusChanged();
  m_gameProcess = nullptr;
  emit isRunningChanged();
}

void MinecraftManager::deleteVersion(const QString &versionPath,
                                     bool deleteProfile) {
  qDebug() << "Deleting version at path:" << versionPath
           << ", deleteProfile:" << deleteProfile;
  if (versionPath.isEmpty()) {
    qDebug() << "No version path provided.";
    return;
  }
  // Si se pasó únicamente el nombre (no contiene '/'), construir la ruta
  // completa
  QString vpath = versionPath;
  if (!vpath.contains(QDir::separator()) && !vpath.startsWith("/")) {
    qDebug()
        << "Interpreting versionPath as name only, constructing full path.";
    vpath = QDir(versionsDir()).filePath(vpath);
  }

  QDir vdir(vpath);
  bool removed = vdir.removeRecursively();
  qDebug() << "[MinecraftManager] removeRecursively(" << vpath << ") =>"
           << removed;

  if (deleteProfile) {
    // Intentar derivar profiles dir de forma segura
    QString pdirPath;
    // Priorizar variable de entorno MINECRAFT_PROFILES_DIR
    QByteArray env = qgetenv("MINECRAFT_PROFILES_DIR");
    if (!env.isEmpty()) {
      pdirPath = QString::fromUtf8(env);
    } else {
      // Si versionsDir contiene '/versions', reemplazar la primera ocurrencia
      QString vdirRoot = versionsDir();
      int idx = vdirRoot.indexOf("/versions");
      if (idx != -1) {
        pdirPath = vdirRoot;
        pdirPath.replace(idx, 9, "/profiles");
      } else {
        // Si no, usar el mismo padre y añadir 'profiles'
        QDir parentDir(vdirRoot);
        parentDir.cdUp();
        pdirPath = QDir(parentDir.absolutePath()).filePath("profiles");
      }
    }

    // Construir ruta del profile a borrar: pdirPath + folderName
    QString folderName = QFileInfo(vpath).fileName();
    QString profilePath = QDir(pdirPath).filePath(folderName);
    QDir pdir(profilePath);
    bool premoved = pdir.removeRecursively();
    qDebug() << "[MinecraftManager] removeRecursively(profile:" << profilePath
             << ") =>" << premoved;
  }

  emit availableVersionsChanged();
  checkInstallation();

  QVariantList deletedList;
  if (removed)
    deletedList.append(vpath);
  // include profile path in deleted list if it existed and was removed
  // (we can't easily know profilePath here unless we recompute; recompute if
  // deleteProfile)
  if (deleteProfile) {
    QString folderName = QFileInfo(vpath).fileName();
    QString pdirRoot;
    QByteArray env = qgetenv("MINECRAFT_PROFILES_DIR");
    if (!env.isEmpty()) {
      pdirRoot = QString::fromUtf8(env);
    } else {
      QString vdirRoot = versionsDir();
      int idx = vdirRoot.indexOf("/versions");
      if (idx != -1) {
        pdirRoot = vdirRoot;
        pdirRoot.replace(idx, 9, "/profiles");
      } else {
        QDir parentDir(vdirRoot);
        parentDir.cdUp();
        pdirRoot = QDir(parentDir.absolutePath()).filePath("profiles");
      }
    }
    QString profilePath = QDir(pdirRoot).filePath(folderName);
    if (QDir(profilePath).exists())
      deletedList.append(profilePath);
  }

  qDebug() << "[MinecraftManager] Deleted entries:" << deletedList;
  emit versionsDeleted(deletedList);

  // Recompute installedVersion after deletion so QML reflects current state
  QVariantList availAfter = getAvailableVersions();
  QString newInstalled;
  if (!availAfter.isEmpty()) {
    QVariantMap first = availAfter.first().toMap();
    if (first.contains("name"))
      newInstalled = first.value("name").toString();
  }
  if (newInstalled != m_installedVersion) {
    m_installedVersion = newInstalled;
    emit installedVersionChanged();
    emit availableVersionsChanged();
  }
}

void MinecraftManager::installRequested(const QString &apkPath,
                                        const QString &name,
                                        bool useDefaultIcon,
                                        const QString &iconPath,
                                        bool useDefaultBackground,
                                        const QString &backgroundPath,
                                        const QString &tag) {
  qDebug() << "[MinecraftManager] installRequested: apk=" << apkPath
           << " name=" << name << " useDefaultIcon=" << useDefaultIcon
           << " iconPath=" << iconPath
           << " useDefaultBackground=" << useDefaultBackground
           << " backgroundPath=" << backgroundPath
           << " tag=" << tag;

  if (apkPath.isEmpty() || name.isEmpty()) {
    qWarning() << "installRequested: apkPath or name is empty";
    return;
  }

  // Stage APK if needed (e.g. Flatpak portal /run/user/ paths) so the
  // external extractor can access a regular file path.
  QString stagedApk;
  QString apkToUse = apkPath;
  if (m_pathManager) {
    stagedApk = m_pathManager->stageFileForExtraction(apkPath);
    if (!stagedApk.isEmpty()) {
      qDebug() << "[MinecraftManager] Using staged APK for extraction:"
               << stagedApk;
      apkToUse = stagedApk;
    }
  }

  // Pre-stage user-provided icon/background so we have accessible file paths
  QString stagedIcon;
  QString stagedBackground;
  QString iconToUse = iconPath;
  QString bgToUse = backgroundPath;
  if (!useDefaultIcon && !iconPath.isEmpty() && m_pathManager) {
    stagedIcon = m_pathManager->stageFileForExtraction(iconPath);
    if (!stagedIcon.isEmpty()) {
      qDebug() << "[MinecraftManager] Using staged icon for later copy:"
               << stagedIcon;
      iconToUse = stagedIcon;
    }
  }
  if (!useDefaultBackground && !backgroundPath.isEmpty() && m_pathManager) {
    stagedBackground = m_pathManager->stageFileForExtraction(backgroundPath);
    if (!stagedBackground.isEmpty()) {
      qDebug() << "[MinecraftManager] Using staged background for later copy:"
               << stagedBackground;
      bgToUse = stagedBackground;
    }
  }

  // Use MinecraftExtract to perform extraction
  MinecraftExtract extractor(m_pathManager);
  QString extractorErr;
  bool ok = extractor.extractApk(apkToUse, name, &extractorErr);
  if (!ok) {
    qWarning() << "Extraction failed:" << extractorErr;
    // Emitir señal de fallo con razón
    QString versionFolderAttempt = QDir(versionsDir()).filePath(name);

    // Si la extracción creó una carpeta parcial, eliminarla para evitar
    // versiones "fantasma"
    QDir vdirAttempt(versionFolderAttempt);
    if (vdirAttempt.exists()) {
      qDebug() << "[MinecraftManager] Removing incomplete version folder due "
                  "to extraction failure:"
               << versionFolderAttempt;
      bool removed = vdirAttempt.removeRecursively();
      if (!removed)
        qWarning()
            << "[MinecraftManager] Failed to remove incomplete version folder:"
            << versionFolderAttempt;
    }

    // Intentar limpiar cualquier archivo staged (apk, icon, background) que
    // hayamos creado
    if (m_pathManager) {
      QString importsDir = QDir(m_pathManager->dataDir()).filePath("imports");
      auto tryRemoveIfStagedLocal = [&](const QString &p) {
        if (p.isEmpty())
          return;
        QString clean = QDir::cleanPath(p);
        if (clean.startsWith(QDir(importsDir).absolutePath())) {
          qDebug() << "[MinecraftManager] Removing staged file after failed "
                      "extraction:"
                   << clean;
          if (!QFile::remove(clean)) {
            qWarning() << "[MinecraftManager] Failed to remove staged file:"
                       << clean;
          }
        } else {
          qDebug() << "[MinecraftManager] Not a staged file (skipping):"
                   << clean;
        }
      };

      QString apkCleanup = stagedApk.isEmpty() ? apkPath : stagedApk;
      tryRemoveIfStagedLocal(apkCleanup);
      if (!useDefaultIcon) {
        QString iconCleanup = stagedIcon.isEmpty() ? iconPath : stagedIcon;
        tryRemoveIfStagedLocal(iconCleanup);
      }
      if (!useDefaultBackground) {
        QString bgCleanup =
            stagedBackground.isEmpty() ? backgroundPath : stagedBackground;
        tryRemoveIfStagedLocal(bgCleanup);
      }
    }

    qDebug() << "[MinecraftManager] installFailed: extraction failed and "
                "cleanup attempted for version:"
             << name;
    qDebug() << "[MinecraftManager] extraction error message:" << extractorErr;
    emit installFailed(versionFolderAttempt, extractorErr);
    return;
  }

  // After extraction, the version folder should exist: versionsDir()/name
  QString versionFolder = QDir(versionsDir()).filePath(name);
  qDebug() << "[MinecraftManager] versionFolder after extraction:"
           << versionFolder;
  QDir vdir(versionFolder);
  if (!vdir.exists()) {
    qWarning() << "Expected version folder not found after extraction:"
               << versionFolder;
    return;
  }

  // Copy user-provided icon/background into the version folder (if provided and
  // not default).
  if (!useDefaultIcon && !iconToUse.isEmpty()) {
    QFileInfo iconFi(iconToUse);
    QString ext = iconFi.suffix();
    if (ext.isEmpty())
      ext = "png";
    QString destIcon = QDir(versionFolder).filePath("custom_icon." + ext);

    // Remove any existing custom icons to avoid duplicates with different
    // extensions
    QStringList oldIcons =
        QDir(versionFolder)
            .entryList(QStringList() << "custom_icon.*", QDir::Files);
    for (const QString &old : oldIcons)
      QFile::remove(QDir(versionFolder).filePath(old));

    bool copied = QFile::copy(iconToUse, destIcon);
    qDebug() << "[MinecraftManager] copy icon" << iconToUse << "->" << destIcon
             << "=>" << copied;
    if (!copied)
      qWarning() << "Failed to copy icon to" << destIcon;
  }

  if (!useDefaultBackground && !bgToUse.isEmpty()) {
    QFileInfo bgFi(bgToUse);
    QString ext = bgFi.suffix();
    if (ext.isEmpty())
      ext = "jpg";
    QString destBg = QDir(versionFolder).filePath("custom_background." + ext);

    // Remove any existing custom backgrounds
    QStringList oldBgs =
        QDir(versionFolder)
            .entryList(QStringList() << "custom_background.*", QDir::Files);
    for (const QString &old : oldBgs)
      QFile::remove(QDir(versionFolder).filePath(old));

    bool copied = QFile::copy(bgToUse, destBg);
    qDebug() << "[MinecraftManager] copy background" << bgToUse << "->"
             << destBg << "=>" << copied;
    if (!copied)
      qWarning() << "Failed to copy background to" << destBg;
  }

  // Notify UI and consumers that versions changed
  // Save tag if provided
  if (!tag.isEmpty()) {
    QString tagFilePath = QDir(versionFolder).filePath("tag.txt");
    QFile tagFile(tagFilePath);
    if (tagFile.open(QIODevice::WriteOnly | QIODevice::Text)) {
      QTextStream out(&tagFile);
      out << tag;
      tagFile.close();
      qDebug() << "[MinecraftManager] tag saved to" << tagFilePath;
    } else {
      qWarning() << "[MinecraftManager] failed to save tag to" << tagFilePath;
    }
  }

  // Update installedVersion so QML bindings reflect the new installation
  m_installedVersion = name;
  emit installedVersionChanged();
  emit availableVersionsChanged();
  checkInstallation();
  qDebug() << "[MinecraftManager] installRequested completed for" << name
           << "folder:" << versionFolder;

  // Emitir señal de éxito con la ruta de la versión creada
  // Intentar limpiar archivos staged que se copiaron a dataDir/imports
  if (m_pathManager) {
    QString importsDir = QDir(m_pathManager->dataDir()).filePath("imports");
    auto tryRemoveIfStaged = [&](const QString &p) {
      if (p.isEmpty())
        return;
      QString clean = QDir::cleanPath(p);
      if (clean.startsWith(QDir(importsDir).absolutePath())) {
        qDebug() << "[MinecraftManager] Removing staged file:" << clean;
        if (!QFile::remove(clean)) {
          qWarning() << "[MinecraftManager] Failed to remove staged file:"
                     << clean;
        }
      } else {
        qDebug() << "[MinecraftManager] Not a staged file (skipping):" << clean;
      }
    };

    // remove the actual files used for extraction / copy operations
    QString apkCleanup = stagedApk.isEmpty() ? apkPath : stagedApk;
    tryRemoveIfStaged(apkCleanup);
    if (!useDefaultIcon) {
      QString iconCleanup = stagedIcon.isEmpty() ? iconPath : stagedIcon;
      tryRemoveIfStaged(iconCleanup);
    }
    if (!useDefaultBackground) {
      QString bgCleanup =
          stagedBackground.isEmpty() ? backgroundPath : stagedBackground;
      tryRemoveIfStaged(bgCleanup);
    }
  }

  // Update last active version with the newly installed version
  QString versionName = QFileInfo(versionFolder).fileName();
  if (m_lastActiveVersion != versionName) {
    m_lastActiveVersion = versionName;
    emit lastActiveVersionChanged();
  }

  emit installSucceeded(versionFolder);
}

void MinecraftManager::importSelected(const QString &filePath,
                                      const QString &type,
                                      const QString &versionPath,
                                      bool useShared, bool useNvidia,
                                      bool useZink, bool useMangohud) {
  qDebug() << "MinecraftManager::importSelected file:" << filePath
           << "type:" << type << "version:" << versionPath;

  if (versionPath.isEmpty()) {
    qWarning() << "importSelected: versionPath empty";
    emit importFailed(versionPath, filePath, "No version selected");
    return;
  }

  if (!m_pathManager) {
    qWarning() << "importSelected: no PathManager available";
    emit importFailed(versionPath, filePath, "Internal error: no PathManager");
    return;
  }

  // Resolve versionPath to a full path if a simple name was provided
  QString fullVersionPath = versionPath;
  QFileInfo vfi(versionPath);
  if (!vfi.isAbsolute() && !versionPath.contains(QDir::separator())) {
    fullVersionPath = QDir(versionsDir()).filePath(versionPath);
  }

  // Stage file to ensure accessibility
  QString staged = m_pathManager->stageFileForExtraction(filePath);
  QString fileToUse = staged.isEmpty() ? filePath : staged;

  // Create launcher and call import
  MinecraftLaunch launcher(m_pathManager);
  bool ok = launcher.importFile(fullVersionPath, fileToUse, useShared,
                                useNvidia, useZink, useMangohud);
  if (!ok) {
    qWarning() << "importSelected: launcher failed to start";
    emit importFailed(versionPath, fileToUse,
                      "Failed to start client for import");
    return;
  }

  qDebug() << "importSelected: import started for" << fileToUse << "into"
           << versionPath;
  emit importSucceeded(versionPath, fileToUse);

  // If we staged the file, try to remove it after starting the import
  if (!staged.isEmpty()) {
    if (!QFile::remove(staged)) {
      qWarning() << "importSelected: failed to remove staged file:" << staged;
    } else {
      qDebug() << "importSelected: removed staged file:" << staged;
    }
  }
}

QString MinecraftManager::getLauncherVersion() const {
#ifdef APP_VERSION
  return QString::fromUtf8(APP_VERSION);
#else
  return QStringLiteral("0.0.0");
#endif
}
