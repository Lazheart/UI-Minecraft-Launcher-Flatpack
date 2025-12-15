#include "../include/minecraftmanager.h"
#include "../include/pathmanager.h"

#include <QDir>
#include <QStandardPaths>
#include <QDebug>
#include <QFileInfo>
#include <QFile>

#include "../include/minecraftextract.h"
#include "../include/minecraftlaunch.h"
#include <QProcess>
#include <QFile>

MinecraftManager::MinecraftManager(PathManager *paths, QObject *parent)
    : QObject(parent), m_pathManager(paths)
{
    m_installedVersion = QString();
    qDebug() << "[MinecraftManager] Constructed. PathManager present:" << (m_pathManager != nullptr);
}

QString MinecraftManager::versionsDir() const
{
    if (m_pathManager) {
        return m_pathManager->versionsDir();
    }

    // Fallback: permitir variable de entorno o AppData como antes
    QByteArray env = qgetenv("MINECRAFT_VERSIONS_DIR");
    if (!env.isEmpty()) {
        return QString::fromUtf8(env);
    }

    QString appData = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    if (appData.isEmpty()) {
        return QDir::cleanPath(QDir::currentPath() + "/versions");
    }
    return QDir::cleanPath(appData + "/versions");
}

QVariantList MinecraftManager::getAvailableVersions() const
{
    QVariantList list;
    QString dirPath = versionsDir();

    qDebug() << "[MinecraftManager] Scanning versions directory:" << dirPath;

    QDir dir(dirPath);
    if (!dir.exists()) {
        return list; // vacío
    }

    QStringList entries = dir.entryList(QDir::Dirs | QDir::NoDotAndDotDot, QDir::Name);
    for (const QString &entry : entries) {
        QString fullPath = QDir(dirPath).filePath(entry);
        QVariantMap m;
        m.insert("name", entry);
        m.insert("path", QDir(fullPath).absolutePath());
        list.append(m);
    }

    qDebug() << "[MinecraftManager] Found" << list.size() << "versions";

    return list;
}

bool MinecraftManager::checkInstallation() const
{
    // Stub simple: comprobar que existe al menos una versión
    QDir dir(versionsDir());
    qDebug() << "[MinecraftManager] checkInstallation() using versionsDir:" << versionsDir();
    return dir.exists() && !dir.entryList(QDir::Dirs | QDir::NoDotAndDotDot).isEmpty();
}

bool MinecraftManager::isRunning() const
{
    return m_gameProcess && m_gameProcess->state() != QProcess::NotRunning;
}

QString MinecraftManager::status() const
{
    if (!m_status.isEmpty()) return m_status;
    return isRunning() ? QStringLiteral("Running") : QStringLiteral("Stopped");
}

bool MinecraftManager::runGame(const QString &versionPath, const QString &unused, const QString &profile)
{
    qDebug() << "MinecraftManager::runGame version:" << versionPath << "profile:" << profile;
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

    QFileInfo vfi(versionPath);
    QString versionName = vfi.fileName();
    QString profilePath = QDir(m_pathManager->profilesDir()).filePath(versionName);

    QStringList args;
    args << QStringLiteral("-dg") << versionPath;
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

    connect(proc, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished), this, [this](int code, QProcess::ExitStatus es){
        Q_UNUSED(code);
        Q_UNUSED(es);
        m_status = QStringLiteral("Stopped");
        emit statusChanged();
        m_gameProcess = nullptr;
        emit isRunningChanged();
    });

    return true;
}

void MinecraftManager::stopGame()
{
    qDebug() << "MinecraftManager::stopGame()";
    if (!m_gameProcess) return;
    m_gameProcess->terminate();
    if (!m_gameProcess->waitForFinished(3000)) {
        m_gameProcess->kill();
    }
    m_status = QStringLiteral("Stopped");
    emit statusChanged();
    m_gameProcess = nullptr;
    emit isRunningChanged();
}

void MinecraftManager::deleteVersion(const QString &versionPath, bool deleteProfile)
{
    qDebug() << "Deleting version at path:" << versionPath << ", deleteProfile:" << deleteProfile;
    if (versionPath.isEmpty()) {
        qDebug() << "No version path provided.";
        return;
    }
    // Si se pasó únicamente el nombre (no contiene '/'), construir la ruta completa
    QString vpath = versionPath;
    if (!vpath.contains(QDir::separator()) && !vpath.startsWith("/")) {
        qDebug() << "Interpreting versionPath as name only, constructing full path.";
        vpath = QDir(versionsDir()).filePath(vpath);
    }

    QDir vdir(vpath);
    bool removed = vdir.removeRecursively();
    qDebug() << "[MinecraftManager] removeRecursively(" << vpath << ") =>" << removed;

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
        qDebug() << "[MinecraftManager] removeRecursively(profile:" << profilePath << ") =>" << premoved;
    }

    emit availableVersionsChanged();

    QVariantList deletedList;
    if (removed) deletedList.append(vpath);
    // include profile path in deleted list if it existed and was removed
    // (we can't easily know profilePath here unless we recompute; recompute if deleteProfile)
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
        if (QDir(profilePath).exists()) deletedList.append(profilePath);
    }

    qDebug() << "[MinecraftManager] Deleted entries:" << deletedList;
    emit versionsDeleted(deletedList);
}

void MinecraftManager::installRequested(const QString &apkPath,
                                       const QString &name,
                                       bool useDefaultIcon,
                                       const QString &iconPath,
                                       bool useDefaultBackground,
                                       const QString &backgroundPath)
{
    qDebug() << "[MinecraftManager] installRequested: apk=" << apkPath << " name=" << name
             << " useDefaultIcon=" << useDefaultIcon << " iconPath=" << iconPath
             << " useDefaultBackground=" << useDefaultBackground << " backgroundPath=" << backgroundPath;

    if (apkPath.isEmpty() || name.isEmpty()) {
        qWarning() << "installRequested: apkPath or name is empty";
        return;
    }

    // Use MinecraftExtract to perform extraction
    MinecraftExtract extractor(m_pathManager);
    QString extractorErr;
    bool ok = extractor.extractApk(apkPath, name, &extractorErr);
    if (!ok) {
        qWarning() << "Extraction failed:" << extractorErr;
        // Emitir señal de fallo con razón
        QString versionFolderAttempt = QDir(versionsDir()).filePath(name);
        emit installFailed(versionFolderAttempt, extractorErr);
        return;
    }

    // After extraction, the version folder should exist: versionsDir()/name
    QString versionFolder = QDir(versionsDir()).filePath(name);
    qDebug() << "[MinecraftManager] versionFolder after extraction:" << versionFolder;
    QDir vdir(versionFolder);
    if (!vdir.exists()) {
        qWarning() << "Expected version folder not found after extraction:" << versionFolder;
        return;
    }

    // Copy user-provided icon/background into the version folder (if provided and not default)
    if (!useDefaultIcon && !iconPath.isEmpty()) {
        QFileInfo iconFi(iconPath);
        QString destIcon = QDir(versionFolder).filePath(iconFi.fileName());
        if (QFile::exists(destIcon)) QFile::remove(destIcon);
        bool copied = QFile::copy(iconPath, destIcon);
        qDebug() << "[MinecraftManager] copy icon" << iconPath << "->" << destIcon << "=>" << copied;
        if (!copied) qWarning() << "Failed to copy icon to" << destIcon;
    }

    if (!useDefaultBackground && !backgroundPath.isEmpty()) {
        QFileInfo bgFi(backgroundPath);
        QString destBg = QDir(versionFolder).filePath(bgFi.fileName());
        if (QFile::exists(destBg)) QFile::remove(destBg);
        bool copied = QFile::copy(backgroundPath, destBg);
        qDebug() << "[MinecraftManager] copy background" << backgroundPath << "->" << destBg << "=>" << copied;
        if (!copied) qWarning() << "Failed to copy background to" << destBg;
    }

    // Notify UI and consumers that versions changed
    emit availableVersionsChanged();
    qDebug() << "[MinecraftManager] installRequested completed for" << name << "folder:" << versionFolder;

    // Emitir señal de éxito con la ruta de la versión creada
    // Intentar limpiar archivos staged que se copiaron a dataDir/imports
    if (m_pathManager) {
        QString importsDir = QDir(m_pathManager->dataDir()).filePath("imports");
        auto tryRemoveIfStaged = [&](const QString &p) {
            if (p.isEmpty()) return;
            QString clean = QDir::cleanPath(p);
            if (clean.startsWith(QDir(importsDir).absolutePath())) {
                qDebug() << "[MinecraftManager] Removing staged file:" << clean;
                if (!QFile::remove(clean)) {
                    qWarning() << "[MinecraftManager] Failed to remove staged file:" << clean;
                }
            } else {
                qDebug() << "[MinecraftManager] Not a staged file (skipping):" << clean;
            }
        };

        tryRemoveIfStaged(apkPath);
        if (!useDefaultIcon) tryRemoveIfStaged(iconPath);
        if (!useDefaultBackground) tryRemoveIfStaged(backgroundPath);
    }

    emit installSucceeded(versionFolder);
}

void MinecraftManager::importSelected(const QString &filePath,
                                     const QString &type,
                                     const QString &versionPath,
                                     bool useShared,
                                     bool useNvidia,
                                     bool useZink,
                                     bool useMangohud)
{
    qDebug() << "MinecraftManager::importSelected file:" << filePath << "type:" << type << "version:" << versionPath;

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

    // Stage file to ensure accessibility
    QString staged = m_pathManager->stageFileForExtraction(filePath);
    QString fileToUse = staged.isEmpty() ? filePath : staged;

    // Create launcher and call import
    MinecraftLaunch launcher(m_pathManager);
    bool ok = launcher.importFile(versionPath, fileToUse, useShared, useNvidia, useZink, useMangohud);
    if (!ok) {
        qWarning() << "importSelected: launcher failed to start";
        emit importFailed(versionPath, fileToUse, "Failed to start client for import");
        return;
    }

    qDebug() << "importSelected: import started for" << fileToUse << "into" << versionPath;
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
