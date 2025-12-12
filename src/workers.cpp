#include "../include/workers.h"
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QStandardPaths>
#include <QProcess>

// ============= InstallAPKWorker =============

InstallAPKWorker::InstallAPKWorker(const QString &apkPath, 
                                   const QString &versionName,
                                   const QString &extractorPath,
                                   const QString &targetDir)
    : m_apkPath(apkPath)
    , m_versionName(versionName)
    , m_extractorPath(extractorPath)
    , m_targetDir(targetDir)
{
}

void InstallAPKWorker::run()
{
    emit logMessage(QString("Iniciando instalación de versión: %1").arg(m_versionName));
    emit progress(0, 100);
    
    // Verificar que el APK existe
    if (!QFile::exists(m_apkPath)) {
        emit logMessage(QString("Error: Archivo APK no encontrado: %1").arg(m_apkPath));
        emit finished(false, QString("APK file not found: %1").arg(m_apkPath));
        return;
    }
    
    emit progress(10, 100);
    
    // Crear directorio destino
    QString targetPath = m_targetDir + "/" + m_versionName;
    QDir dir;
    if (!dir.mkpath(targetPath)) {
        emit logMessage(QString("Error: No se pudo crear directorio: %1").arg(targetPath));
        emit finished(false, QString("Failed to create directory: %1").arg(targetPath));
        return;
    }
    
    emit progress(20, 100);
    emit logMessage(QString("Ejecutando extractor: %1").arg(m_extractorPath));
    
    // Ejecutar mcpelauncher-extract
        // Determinar ruta del extractor (usar la ruta de Flatpak por defecto si no se pasó)
        QString extractorPath = m_extractorPath;
        if (extractorPath.isEmpty()) {
            bool isFlatpak = !qgetenv("FLATPAK_ID").isEmpty();
            extractorPath = isFlatpak ? QStringLiteral("/app/bin/mcpelauncher-extract") : QStringLiteral("mcpelauncher-extract");
        }

        emit logMessage(QString("Ejecutando extractor: %1").arg(extractorPath));

        // Ejecutar mcpelauncher-extract. El binario espera: <apk_path> <name>
        QProcess process;
        QStringList args;
        args << m_apkPath << m_versionName;
        process.start(extractorPath, args);
    
    if (!process.waitForStarted()) {
        emit logMessage(QString("Error: No se pudo iniciar el extractor"));
        emit finished(false, "Failed to start extractor process");
        return;
    }
    
    emit progress(50, 100);
    
    // Esperar a que termine
    if (!process.waitForFinished(600000)) { // 10 minutos timeout
        process.kill();
        emit logMessage(QString("Error: Extractor timeout"));
        emit finished(false, "Extractor process timeout");
        return;
    }
    
    emit progress(90, 100);
    
    if (process.exitCode() != 0) {
        QString errorMsg = QString::fromUtf8(process.readAllStandardError());
        emit logMessage(QString("Error del extractor: %1").arg(errorMsg));
        emit finished(false, QString("Extractor failed with code %1").arg(process.exitCode()));
        return;
    }
    
    emit progress(100, 100);
    emit logMessage(QString("Versión %1 instalada correctamente").arg(m_versionName));
    emit finished(true, QString("Successfully installed version: %1").arg(m_versionName));
}

// ============= ImportWorldWorker =============

ImportWorldWorker::ImportWorldWorker(const QString &worldZipPath, 
                                     const QString &destinationPath)
    : m_worldZipPath(worldZipPath)
    , m_destinationPath(destinationPath)
{
}

void ImportWorldWorker::run()
{
    emit logMessage(QString("Iniciando importación de mundo: %1").arg(m_worldZipPath));
    emit progress(0, 100);
    
    // Validar ZIP
    if (!validateWorldZip()) {
        emit finished(false, "Invalid world file");
        return;
    }
    
    emit progress(30, 100);
    emit logMessage("Extrayendo archivo...");
    
    // Extraer
    // Aquí necesitarás usar tu ZipValidator para extraer
    // Por ahora, placeholder
    
    emit progress(70, 100);
    
    QString worldName = extractWorldName();
    emit logMessage(QString("Mundo importado: %1").arg(worldName));
    emit progress(100, 100);
    emit finished(true, worldName);
}

bool ImportWorldWorker::validateWorldZip()
{
    QFile file(m_worldZipPath);
    if (!file.exists()) {
        emit logMessage(QString("Error: Archivo no encontrado: %1").arg(m_worldZipPath));
        return false;
    }
    
    // Validaciones básicas (extensión, etc.)
    if (!m_worldZipPath.endsWith(".mcworld", Qt::CaseInsensitive) &&
        !m_worldZipPath.endsWith(".zip", Qt::CaseInsensitive)) {
        emit logMessage("Error: Formato de archivo incorrecto (debe ser .mcworld o .zip)");
        return false;
    }
    
    return true;
}

QString ImportWorldWorker::extractWorldName()
{
    QFileInfo info(m_worldZipPath);
    return info.baseName();
}

// ============= ImportPackWorker =============

ImportPackWorker::ImportPackWorker(const QString &packZipPath, 
                                  const QString &versionsPath,
                                  const QString &versionName)
    : m_packZipPath(packZipPath)
    , m_versionsPath(versionsPath)
    , m_versionName(versionName)
{
}

void ImportPackWorker::run()
{
    emit logMessage(QString("Iniciando importación de pack: %1").arg(m_packZipPath));
    emit progress(0, 100);
    
    if (!validatePackZip()) {
        emit finished(false, "Invalid pack file");
        return;
    }
    
    emit progress(30, 100);
    
    PackType packType = detectPackType();
    emit logMessage(QString("Tipo de pack detectado: %1")
        .arg(packType == Resource ? "Resource" : packType == Behavior ? "Behavior" : "Unknown"));
    
    emit progress(50, 100);
    
    // Determinar ruta destino según tipo
    QString destDir;
    if (packType == Resource) {
        destDir = m_versionsPath + "/" + m_versionName + "/resource_packs";
    } else if (packType == Behavior) {
        destDir = m_versionsPath + "/" + m_versionName + "/behavior_packs";
    } else {
        emit finished(false, "Unknown pack type");
        return;
    }
    
    // Crear directorio si no existe
    QDir dir;
    dir.mkpath(destDir);
    
    emit progress(70, 100);
    emit logMessage("Extrayendo pack...");
    
    // Extraer aquí usando ZipValidator
    
    QString packName = extractPackUuid();
    if (packName.isEmpty()) {
        QFileInfo info(m_packZipPath);
        packName = info.baseName();
    }
    
    emit progress(100, 100);
    emit logMessage(QString("Pack importado: %1").arg(packName));
    emit finished(true, packName);
}

bool ImportPackWorker::validatePackZip()
{
    QFile file(m_packZipPath);
    if (!file.exists()) {
        emit logMessage(QString("Error: Archivo no encontrado: %1").arg(m_packZipPath));
        return false;
    }
    
    if (!m_packZipPath.endsWith(".mcpack", Qt::CaseInsensitive) &&
        !m_packZipPath.endsWith(".zip", Qt::CaseInsensitive)) {
        emit logMessage("Error: Formato de archivo incorrecto (debe ser .mcpack o .zip)");
        return false;
    }
    
    return true;
}

ImportPackWorker::PackType ImportPackWorker::detectPackType()
{
    // Placeholder: leer manifest.json y determinar tipo
    return Unknown;
}

QString ImportPackWorker::extractPackUuid()
{
    // Placeholder: extraer UUID del manifest.json
    return QString();
}

// ============= RunGameWorker =============

RunGameWorker::RunGameWorker(const QString &versionPath,
                            const QString &worldPath,
                            const QString &profilePath)
    : m_versionPath(versionPath)
    , m_worldPath(worldPath)
    , m_profilePath(profilePath)
    , m_gameProcess(nullptr)
{
}

RunGameWorker::~RunGameWorker()
{
    if (m_gameProcess) {
        if (m_gameProcess->state() != QProcess::NotRunning) {
            m_gameProcess->terminate();
            m_gameProcess->waitForFinished(3000);
        }
        delete m_gameProcess;
    }
}

void RunGameWorker::run()
{
    emit logMessage(QString("Preparando lanzamiento del juego desde: %1").arg(m_versionPath));
    
    // Crear el proceso
    m_gameProcess = new QProcess();
    
    setupEnvironment();
    
    emit logMessage("Construyendo comando de lanzamiento...");
    
    // Comando base (usar ruta Flatpak si corresponde)
    QString program;
    bool isFlatpak = !qgetenv("FLATPAK_ID").isEmpty();
    program = isFlatpak ? QStringLiteral("/app/bin/mcpelauncher-client") : QStringLiteral("mcpelauncher-client");
    QStringList arguments;
    
    // Añadir rutas
    arguments << "-dg" << m_versionPath;
    
    if (!m_worldPath.isEmpty()) {
        arguments << "-w" << m_worldPath;
    }
    
    if (!m_profilePath.isEmpty()) {
        arguments << "-p" << m_profilePath;
    }
    
    emit logMessage(QString("Ejecutando: %1 %2").arg(program, arguments.join(" ")));
    emit gameStarted();
    
    m_gameProcess->start(program, arguments);
    
    if (!m_gameProcess->waitForStarted()) {
        emit errorOccurred("Failed to start game process");
        emit logMessage("Error: No se pudo iniciar el juego");
        return;
    }
    
    // Leer output mientras se ejecuta
    while (m_gameProcess->state() == QProcess::Running) {
        m_gameProcess->waitForReadyRead(1000);
        readProcessOutput();
    }
    
    // Leer output final
    readProcessOutput();
    
    int exitCode = m_gameProcess->exitCode();
    emit gameStopped(exitCode);
    emit logMessage(QString("Juego finalizado con código: %1").arg(exitCode));
}

void RunGameWorker::stopGame()
{
    if (m_gameProcess && m_gameProcess->state() != QProcess::NotRunning) {
        m_gameProcess->terminate();
        m_gameProcess->waitForFinished(3000);
    }
}

void RunGameWorker::setupEnvironment()
{
    // Aquí puedes configurar variables de entorno si es necesario
    // Por ejemplo: MESA_LOADER_DRIVER_OVERRIDE, mangohud, etc.
    
    bool isFlatpak = !qgetenv("FLATPAK_ID").isEmpty();
    if (isFlatpak) {
        emit logMessage("Detectado Flatpak, configurando entorno...");
        // Configurar variables específicas de Flatpak si es necesario
    }
}

void RunGameWorker::readProcessOutput()
{
    if (!m_gameProcess) return;
    
    // Leer stdout
    QString output = QString::fromUtf8(m_gameProcess->readAllStandardOutput());
    if (!output.isEmpty()) {
        emit logMessage(output.trimmed());
    }
    
    // Leer stderr
    QString error = QString::fromUtf8(m_gameProcess->readAllStandardError());
    if (!error.isEmpty()) {
        emit logMessage("[STDERR] " + error.trimmed());
    }
}
