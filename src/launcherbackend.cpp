#include "../include/launcherbackend.h"
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

    qDebug() << "[Backend] Inicializado";
    qDebug() << "[Backend] APP_DIR:" << m_appDir;
    qDebug() << "[Backend] DATA_DIR:" << m_dataDir;
    qDebug() << "[Backend] Versions path:" << m_versionsPath;
    qDebug() << "[Backend] Backgrounds path:" << m_backgroundsPath;
    qDebug() << "[Backend] Icons path:" << m_iconsPath;
    qDebug() << "[Backend] Profiles path:" << m_profilesPath;
}

LauncherBackend::~LauncherBackend()
{
    if (m_gameProcess && m_gameProcess->state() != QProcess::NotRunning) {
        m_gameProcess->terminate();
        m_gameProcess->waitForFinished(3000);
    }
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
        emit logMessage("[STDOUT] " + stdOut.trimmed());
    }
    
    if (!stdErr.isEmpty()) {
        emit logMessage("[STDERR] " + stdErr.trimmed());
    }
}

void LauncherBackend::setStatus(const QString &status)
{
    if (m_status != status) {
        m_status = status;
        emit statusChanged(m_status);
    }
}
