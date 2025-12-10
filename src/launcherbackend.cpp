#include "../include/launcherbackend.h"
#include "../include/packagemanager.h"
#include "../include/workers.h"
#include <QDir>
#include <QStandardPaths>
#include <QDebug>
#include <QDBusInterface>
#include <QDBusConnection>
#include <QTimer>
#include <QFile>
#include <QDesktopServices>
#include <QUrl>

LauncherBackend::LauncherBackend(QObject *parent)
    : QObject(parent)
    , m_gameProcess(nullptr)
    , m_status("Listo")
    , m_packageManager(nullptr)
    , m_installAPKWorker(nullptr)
    , m_importWorldWorker(nullptr)
    , m_importPackWorker(nullptr)
    , m_runGameWorker(nullptr)
{
    // Configurar directorios para Flatpak
    m_appDir = qEnvironmentVariable("APP_DIR", "/app");
    
    QString configPath = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation);
    m_dataDir = configPath + "/minecraft-launcher";
    
    // Inicializar rutas de carpetas
    m_versionsPath = configPath + "/minecraft-launcher/versions";
    m_backgroundsPath = configPath + "/minecraft-launcher/backgrounds";
    m_iconsPath = configPath + "/minecraft-launcher/icons";
    m_profilesPath = configPath + "/minecraft-launcher/profiles";
    
    // Inicializar valores de sesión con defaults
    m_language = "EN";
    m_theme = "DARK";
    m_scale = 1.0;
    
    // Crear directorios si no existen
    QDir().mkpath(m_dataDir);
    QDir().mkpath(m_versionsPath);
    QDir().mkpath(m_backgroundsPath);
    QDir().mkpath(m_iconsPath);
    QDir().mkpath(m_profilesPath);
    
    // Configurar QSettings
    m_settings = new QSettings(
        QSettings::IniFormat,
        QSettings::UserScope,
        "org.lazheart",
        "minecraft-launcher",
        this
    );
    
    // Inicializar PackageManager
    initializePackageManager();

    qDebug() << "[Backend] Inicializado";
}

LauncherBackend::~LauncherBackend()
{
    if (m_gameProcess && m_gameProcess->state() != QProcess::NotRunning) {
        m_gameProcess->terminate();
        m_gameProcess->waitForFinished(3000);
    }
    
    cleanupWorkers();
}

QString LauncherBackend::version() const
{
    return "1.0.0";
}

QString LauncherBackend::status() const
{
    return m_status;
}

bool LauncherBackend::isRunning() const
{
    return m_gameProcess && m_gameProcess->state() != QProcess::NotRunning;
}

QString LauncherBackend::versionsPath() const
{
    return m_versionsPath;
}

QString LauncherBackend::backgroundsPath() const
{
    return m_backgroundsPath;
}

QString LauncherBackend::iconsPath() const
{
    return m_iconsPath;
}

QString LauncherBackend::profilesPath() const
{
    return m_profilesPath;
}

QString LauncherBackend::language() const
{
    return m_language;
}

QString LauncherBackend::theme() const
{
    return m_theme;
}

double LauncherBackend::scale() const
{
    return m_scale;
}

void LauncherBackend::setLanguage(const QString &language)
{
    if (m_language != language) {
        m_language = language;
        emit languageChanged(language);
        qDebug() << "[Backend] Idioma cambiado en sesión actual a:" << language;
    }
}

void LauncherBackend::setTheme(const QString &theme)
{
    if (m_theme != theme) {
        m_theme = theme;
        emit themeChanged(theme);
        qDebug() << "[Backend] Tema cambiado en sesión actual a:" << theme;
    }
}

void LauncherBackend::setScale(double scale)
{
    if (m_scale != scale) {
        m_scale = scale;
        emit scaleChanged(scale);
        qDebug() << "[Backend] Escala cambiada en sesión actual a:" << scale;
    }
}

void LauncherBackend::openFolder(const QString &path)
{
    if (path.isEmpty()) {
        qWarning() << "[Backend] Ruta vacía para abrir carpeta";
        emit errorOccurred("La ruta proporcionada está vacía");
        return;
    }
    
    qDebug() << "[Backend] Abriendo carpeta:" << path;
    
    QUrl folderUrl = QUrl::fromLocalFile(path);
    if (!QDesktopServices::openUrl(folderUrl)) {
        qWarning() << "[Backend] No se pudo abrir la carpeta:" << path;
        emit errorOccurred(QString("No se pudo abrir la carpeta: %1").arg(path));
    } else {
        qDebug() << "[Backend] Carpeta abierta exitosamente:" << path;
    }
}

void LauncherBackend::saveSettings()
{
    // Guardar permanentemente los valores actuales de sesión
    m_settings->setValue("language", m_language);
    m_settings->setValue("theme", m_theme);
    m_settings->setValue("scale", m_scale);
    m_settings->sync();
    
    qDebug() << "[Backend] Configuración guardada";
    qDebug() << "  - Idioma:" << m_language;
    qDebug() << "  - Tema:" << m_theme;
    qDebug() << "  - Escala:" << m_scale;
    
    showNotification("Settings Saved", "Your preferences have been saved");
}

void LauncherBackend::applySettings()
{
    // Aplicar la configuración (actualmente ya está aplicada en sesión)
    // Este método puede usarse para aplicar cambios a componentes si es necesario
    qDebug() << "[Backend] Configuración aplicada en sesión";
    qDebug() << "  - Idioma:" << m_language;
    qDebug() << "  - Tema:" << m_theme;
    qDebug() << "  - Escala:" << m_scale;
    
    showNotification("Settings Applied", "Your settings have been applied");
}

void LauncherBackend::resetSettings()
{
    // Resetear a valores por defecto
    m_language = "EN";
    m_theme = "DARK";
    m_scale = 1.0;
    
    // Guardar los valores por defecto
    m_settings->setValue("language", m_language);
    m_settings->setValue("theme", m_theme);
    m_settings->setValue("scale", m_scale);
    m_settings->sync();
    
    qDebug() << "[Backend] Configuración reseteada a valores por defecto";
    
    // Emitir signals para actualizar la UI
    emit languageChanged(m_language);
    emit themeChanged(m_theme);
    emit scaleChanged(m_scale);
    
    showNotification("Settings Reset", "Settings have been reset to default");
}

void LauncherBackend::applyProfileSettings(const QString &language, const QString &theme, double scale)
{
    // Aplicar los valores del perfil a la sesión actual sin guardar permanentemente
    m_language = language;
    m_theme = theme;
    m_scale = scale;
    
    qDebug() << "[Backend] Configuración del perfil cargada en sesión";
    qDebug() << "  - Idioma:" << m_language;
    qDebug() << "  - Tema:" << m_theme;
    qDebug() << "  - Escala:" << m_scale;
    
    // Emitir signals para actualizar la UI
    emit languageChanged(m_language);
    emit themeChanged(m_theme);
    emit scaleChanged(m_scale);
    
    showNotification("Profile Loaded", QString("Profile settings loaded: %1").arg(language));
}

void LauncherBackend::saveProfileSettings(const QString &profileName)
{
    // Guardar permanentemente los valores actuales como configuración del perfil
    // Los valores ya están en m_language, m_theme, m_scale
    m_settings->setValue(QString("profile/%1/language").arg(profileName), m_language);
    m_settings->setValue(QString("profile/%1/theme").arg(profileName), m_theme);
    m_settings->setValue(QString("profile/%1/scale").arg(profileName), m_scale);
    m_settings->sync();
    
    qDebug() << "[Backend] Configuración del perfil" << profileName << "guardada";
    qDebug() << "  - Idioma:" << m_language;
    qDebug() << "  - Tema:" << m_theme;
    qDebug() << "  - Escala:" << m_scale;
    
    showNotification("Profile Saved", QString("Profile '%1' configuration saved").arg(profileName));
}

void LauncherBackend::launchGame(const QString &profile)
{
    if (isRunning()) {
        emit errorOccurred("El juego ya está en ejecución");
        return;
    }

    setStatus("Iniciando Minecraft...");
    emit logMessage("Preparando para lanzar Minecraft");

    // Crear proceso si no existe
    if (!m_gameProcess) {
        m_gameProcess = new QProcess(this);
        connect(m_gameProcess, &QProcess::started, this, &LauncherBackend::onProcessStarted);
        connect(m_gameProcess, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
                this, &LauncherBackend::onProcessFinished);
        connect(m_gameProcess, &QProcess::errorOccurred, this, &LauncherBackend::onProcessError);
        connect(m_gameProcess, &QProcess::readyReadStandardOutput, this, &LauncherBackend::onProcessOutput);
        connect(m_gameProcess, &QProcess::readyReadStandardError, this, &LauncherBackend::onProcessOutput);
    }

    // Configurar el ejecutable del cliente
    QString clientBin = m_appDir + "/bin/mcpelauncher-client";
    
    if (!QFile::exists(clientBin)) {
        QString error = QString("No se encontró el cliente: %1").arg(clientBin);
        emit errorOccurred(error);
        setStatus("Error");
        return;
    }

    // Argumentos del juego
    QStringList arguments;
    if (!profile.isEmpty()) {
        arguments << "--profile" << profile;
    }

    emit logMessage(QString("Ejecutando: %1 %2").arg(clientBin, arguments.join(" ")));
    
    m_gameProcess->setProgram(clientBin);
    m_gameProcess->setArguments(arguments);
    m_gameProcess->start();
}

void LauncherBackend::stopGame()
{
    if (!isRunning()) {
        return;
    }

    setStatus("Deteniendo juego...");
    emit logMessage("Cerrando Minecraft");
    
    m_gameProcess->terminate();
    
    // Si no se cierra en 3 segundos, forzar cierre
    QTimer::singleShot(3000, this, [this]() {
        if (m_gameProcess && m_gameProcess->state() != QProcess::NotRunning) {
            emit logMessage("Forzando cierre del juego");
            m_gameProcess->kill();
        }
    });
}

QString LauncherBackend::getAppDir() const
{
    return m_appDir;
}

QString LauncherBackend::getDataDir() const
{
    return m_dataDir;
}

void LauncherBackend::showNotification(const QString &title, const QString &message)
{
    QDBusInterface notifications(
        "org.freedesktop.Notifications",
        "/org/freedesktop/Notifications",
        "org.freedesktop.Notifications",
        QDBusConnection::sessionBus()
    );

    if (notifications.isValid()) {
        QList<QVariant> args;
        args << "org.lazheart.minecraft-launcher"  // app_name
             << uint(0)                             // replaces_id
             << "minecraft-launcher"                // app_icon
             << title                               // summary
             << message                             // body
             << QStringList()                       // actions
             << QVariantMap()                       // hints
             << int(5000);                          // timeout (ms)
        
        notifications.callWithArgumentList(QDBus::AutoDetect, "Notify", args);
    }
}

void LauncherBackend::installVersion(const QString &name,
                                     const QString &apkRoute,
                                     const QString &iconPath,
                                     const QString &backgroundPath,
                                     bool useDefaultIcon,
                                     bool useDefaultBackground)
{
    const QString trimmedName = name.trimmed();
    const QString trimmedApk = apkRoute.trimmed();

    if (trimmedName.isEmpty() || trimmedApk.isEmpty()) {
        emit errorOccurred("Debe proporcionar un nombre y la ruta del APK");
        return;
    }

    emit logMessage(QString("[Installer] Solicitud de instalación: %1").arg(trimmedName));
    emit logMessage(QString("[Installer] APK: %1").arg(trimmedApk));
    emit logMessage(QString("[Installer] Icono: %1 (default=%2)")
                    .arg(iconPath.isEmpty() ? "<defecto>" : iconPath,
                         useDefaultIcon ? "sí" : "no"));
    emit logMessage(QString("[Installer] Fondo: %1 (default=%2)")
                    .arg(backgroundPath.isEmpty() ? "<defecto>" : backgroundPath,
                         useDefaultBackground ? "sí" : "no"));

    emit installVersionRequested(trimmedName,
                                 trimmedApk,
                                 iconPath,
                                 backgroundPath,
                                 useDefaultIcon,
                                 useDefaultBackground);

    showNotification("Install Version",
                     QString("Instalando %1...").arg(trimmedName));
}

void LauncherBackend::onProcessStarted()
{
    setStatus("Juego en ejecución");
    emit gameStarted();
    emit isRunningChanged(true);
    emit logMessage("Minecraft iniciado correctamente");
    showNotification("Minecraft Launcher", "El juego ha iniciado");
}

void LauncherBackend::onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    QString msg;
    if (exitStatus == QProcess::NormalExit) {
        msg = QString("El juego se cerró (código: %1)").arg(exitCode);
        setStatus("Listo");
    } else {
        msg = "El juego se cerró inesperadamente";
        setStatus("Error");
    }
    
    emit logMessage(msg);
    emit gameStopped();
    emit isRunningChanged(false);
}

void LauncherBackend::onProcessError(QProcess::ProcessError error)
{
    QString errorMsg;
    switch (error) {
        case QProcess::FailedToStart:
            errorMsg = "Error: No se pudo iniciar el juego";
            break;
        case QProcess::Crashed:
            errorMsg = "Error: El juego se crasheó";
            break;
        case QProcess::Timedout:
            errorMsg = "Error: Timeout al iniciar el juego";
            break;
        default:
            errorMsg = "Error desconocido al ejecutar el juego";
    }
    
    emit errorOccurred(errorMsg);
    emit logMessage(errorMsg);
    setStatus("Error");
}

void LauncherBackend::onProcessOutput()
{
    if (!m_gameProcess) return;
    
    QString stdOut = QString::fromUtf8(m_gameProcess->readAllStandardOutput());
    QString stdErr = QString::fromUtf8(m_gameProcess->readAllStandardError());
    
    if (!stdOut.isEmpty()) {
        emit gameLogMessage(stdOut);
    }
    if (!stdErr.isEmpty()) {
        emit gameLogMessage(stdErr);
    }
}

void LauncherBackend::setStatus(const QString &status)
{
    if (m_status != status) {
        m_status = status;
        emit statusChanged(m_status);
    }
}

// ============= Package Management =============

void LauncherBackend::initializePackageManager()
{
    if (!m_packageManager) {
        m_packageManager = new PackageManager(m_versionsPath, m_profilesPath, this);
        qDebug() << "[Backend] PackageManager inicializado";
    }
}

void LauncherBackend::cleanupWorkers()
{
    if (m_installAPKWorker) {
        if (m_installAPKWorker->isRunning()) {
            m_installAPKWorker->quit();
            m_installAPKWorker->wait();
        }
        delete m_installAPKWorker;
        m_installAPKWorker = nullptr;
    }
    
    if (m_importWorldWorker) {
        if (m_importWorldWorker->isRunning()) {
            m_importWorldWorker->quit();
            m_importWorldWorker->wait();
        }
        delete m_importWorldWorker;
        m_importWorldWorker = nullptr;
    }
    
    if (m_importPackWorker) {
        if (m_importPackWorker->isRunning()) {
            m_importPackWorker->quit();
            m_importPackWorker->wait();
        }
        delete m_importPackWorker;
        m_importPackWorker = nullptr;
    }
    
    if (m_runGameWorker) {
        if (m_runGameWorker->isRunning()) {
            m_runGameWorker->quit();
            m_runGameWorker->wait();
        }
        delete m_runGameWorker;
        m_runGameWorker = nullptr;
    }
}

QStringList LauncherBackend::getInstalledVersions()
{
    if (!m_packageManager) {
        qWarning() << "[Backend] PackageManager not initialized";
        return QStringList();
    }
    return m_packageManager->getInstalledVersions();
}

QStringList LauncherBackend::getWorldsForVersion(const QString &version)
{
    if (!m_packageManager) {
        return QStringList();
    }
    return m_packageManager->getWorldsForVersion(version);
}

QStringList LauncherBackend::getResourcePacksForVersion(const QString &version)
{
    if (!m_packageManager) {
        return QStringList();
    }
    return m_packageManager->getResourcePacksForVersion(version);
}

QStringList LauncherBackend::getBehaviorPacksForVersion(const QString &version)
{
    if (!m_packageManager) {
        return QStringList();
    }
    return m_packageManager->getBehaviorPacksForVersion(version);
}

QJsonObject LauncherBackend::getWorldInfo(const QString &version, const QString &worldName)
{
    if (!m_packageManager) {
        return QJsonObject();
    }
    return m_packageManager->getWorldInfo(version, worldName);
}

QJsonObject LauncherBackend::getPackageInfo(const QString &packagePath)
{
    if (!m_packageManager) {
        return QJsonObject();
    }
    return m_packageManager->getPackageInfo(packagePath);
}

void LauncherBackend::installAPK(const QString &apkPath, const QString &versionName)
{
    emit logMessage(QString("Iniciando instalación de APK: %1").arg(apkPath));
    
    QString extractorPath = m_appDir + "/bin/mcpelauncher-extract";
    
    if (!QFile::exists(extractorPath)) {
        QString error = QString("Extractor no encontrado: %1").arg(extractorPath);
        emit errorOccurred(error);
        emit operationFailed(error);
        return;
    }
    
    // Crear y conectar worker
    if (m_installAPKWorker) {
        delete m_installAPKWorker;
    }
    
    m_installAPKWorker = new InstallAPKWorker(apkPath, versionName, extractorPath, m_versionsPath);
    
    connect(m_installAPKWorker, &InstallAPKWorker::progress, this, &LauncherBackend::onInstallAPKProgress);
    connect(m_installAPKWorker, &InstallAPKWorker::finished, this, &LauncherBackend::onInstallAPKFinished);
    connect(m_installAPKWorker, &InstallAPKWorker::logMessage, this, &LauncherBackend::onInstallAPKLog);
    
    m_installAPKWorker->start();
}

void LauncherBackend::importWorld(const QString &worldZipPath, const QString &version)
{
    emit logMessage(QString("Iniciando importación de mundo: %1").arg(worldZipPath));
    
    if (!m_packageManager) {
        emit operationFailed("PackageManager not initialized");
        return;
    }
    
    QString destPath = m_packageManager->getWorldsPath(version);
    
    if (m_importWorldWorker) {
        delete m_importWorldWorker;
    }
    
    m_importWorldWorker = new ImportWorldWorker(worldZipPath, destPath);
    
    connect(m_importWorldWorker, &ImportWorldWorker::progress, this, &LauncherBackend::onImportWorldProgress);
    connect(m_importWorldWorker, &ImportWorldWorker::finished, this, &LauncherBackend::onImportWorldFinished);
    connect(m_importWorldWorker, &ImportWorldWorker::logMessage, this, &LauncherBackend::onImportWorldLog);
    
    m_importWorldWorker->start();
}

void LauncherBackend::importPack(const QString &packZipPath, const QString &version)
{
    emit logMessage(QString("Iniciando importación de pack: %1").arg(packZipPath));
    
    if (!m_packageManager) {
        emit operationFailed("PackageManager not initialized");
        return;
    }
    
    if (m_importPackWorker) {
        delete m_importPackWorker;
    }
    
    m_importPackWorker = new ImportPackWorker(packZipPath, m_versionsPath, version);
    
    connect(m_importPackWorker, &ImportPackWorker::progress, this, &LauncherBackend::onImportPackProgress);
    connect(m_importPackWorker, &ImportPackWorker::finished, this, &LauncherBackend::onImportPackFinished);
    connect(m_importPackWorker, &ImportPackWorker::logMessage, this, &LauncherBackend::onImportPackLog);
    
    m_importPackWorker->start();
}

void LauncherBackend::runGame(const QString &version, const QString &worldName, const QString &profile)
{
    emit logMessage(QString("Preparando lanzamiento de versión: %1").arg(version));
    
    if (!m_packageManager) {
        emit errorOccurred("PackageManager not initialized");
        return;
    }
    
    QString versionPath = m_packageManager->getVersionPath(version);
    QString worldPath;
    
    if (!worldName.isEmpty()) {
        worldPath = m_packageManager->getWorldsPath(version) + "/" + worldName;
    }
    
    if (m_runGameWorker) {
        if (m_runGameWorker->isRunning()) {
            emit errorOccurred("El juego ya está en ejecución");
            return;
        }
        delete m_runGameWorker;
    }
    
    m_runGameWorker = new RunGameWorker(versionPath, worldPath, profile);
    
    connect(m_runGameWorker, &RunGameWorker::gameStarted, this, &LauncherBackend::onGameWorkerStarted);
    connect(m_runGameWorker, &RunGameWorker::gameStopped, this, &LauncherBackend::onGameWorkerStopped);
    connect(m_runGameWorker, &RunGameWorker::errorOccurred, this, &LauncherBackend::onGameWorkerError);
    connect(m_runGameWorker, &RunGameWorker::logMessage, this, &LauncherBackend::onGameWorkerLog);
    
    m_runGameWorker->start();
}

void LauncherBackend::stopGameProcess()
{
    if (m_runGameWorker && m_runGameWorker->isRunning()) {
        m_runGameWorker->stopGame();
    }
}

// ============= Slots for Workers =============

void LauncherBackend::onGameWorkerStarted()
{
    emit gameStarted();
    emit gameProcessStarted();
    setStatus("Juego en ejecución");
}

void LauncherBackend::onGameWorkerStopped(int exitCode)
{
    emit gameStopped();
    emit gameProcessStopped(exitCode);
    setStatus("Listo");
}

void LauncherBackend::onGameWorkerError(const QString &error)
{
    emit errorOccurred(error);
}

void LauncherBackend::onGameWorkerLog(const QString &message)
{
    emit gameLogMessage(message);
    emit logMessage(message);
}

void LauncherBackend::onInstallAPKProgress(int current, int total)
{
    emit installProgress(current, total, QString("Instalando APK... %1/%2").arg(current, total));
}

void LauncherBackend::onInstallAPKFinished(bool success, const QString &message)
{
    if (success) {
        emit installationCompleted(message);
        emit versionsChanged();
        showNotification("Installation Complete", message);
    } else {
        emit operationFailed(message);
        showNotification("Installation Failed", message);
    }
}

void LauncherBackend::onInstallAPKLog(const QString &message)
{
    emit logMessage(message);
}

void LauncherBackend::onImportWorldProgress(int current, int total)
{
    emit importProgress(current, total, QString("Importando mundo... %1/%2").arg(current, total));
}

void LauncherBackend::onImportWorldFinished(bool success, const QString &worldName)
{
    if (success) {
        emit importCompleted(worldName);
        emit worldsChanged(QString()); // TODO: pasar versión
        showNotification("Import Complete", QString("Mundo importado: %1").arg(worldName));
    } else {
        emit operationFailed(worldName);
        showNotification("Import Failed", worldName);
    }
}

void LauncherBackend::onImportWorldLog(const QString &message)
{
    emit logMessage(message);
}

void LauncherBackend::onImportPackProgress(int current, int total)
{
    emit importProgress(current, total, QString("Importando pack... %1/%2").arg(current, total));
}

void LauncherBackend::onImportPackFinished(bool success, const QString &packName)
{
    if (success) {
        emit importCompleted(packName);
        emit packsChanged(QString()); // TODO: pasar versión
        showNotification("Import Complete", QString("Pack importado: %1").arg(packName));
    } else {
        emit operationFailed(packName);
        showNotification("Import Failed", packName);
    }
}

void LauncherBackend::onImportPackLog(const QString &message)
{
    emit logMessage(message);
}
