#include "../include/minecraftmanager.h"
#include "../include/pathmanager.h"

#include <QDir>
#include <QStandardPaths>
#include <QDebug>
#include <QFileInfo>
#include <QFile>

#include "../include/minecraftextract.h"

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

bool MinecraftManager::checkInstallation()
{
    // Stub simple: comprobar que existe al menos una versión
    QDir dir(versionsDir());
    qDebug() << "[MinecraftManager] checkInstallation() using versionsDir:" << versionsDir();
    return dir.exists() && !dir.entryList(QDir::Dirs | QDir::NoDotAndDotDot).isEmpty();
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
    emit installSucceeded(versionFolder);
}
