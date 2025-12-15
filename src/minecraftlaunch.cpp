#include "../include/minecraftlaunch.h"
#include "../include/pathmanager.h"

#include <QProcess>
#include <QProcessEnvironment>
#include <QFileInfo>
#include <QDebug>
#include <QDir>

MinecraftLaunch::MinecraftLaunch(PathManager *paths, QObject *parent)
    : QObject(parent), m_paths(paths)
{
}

bool MinecraftLaunch::runGame(const QString &versionPath,
                              bool useNvidia,
                              bool useZink,
                              bool useShared,
                              bool useMangohud)
{
    if (!m_paths) {
        qWarning() << "MinecraftLaunch::runGame: no PathManager";
        return false;
    }

    QString client = m_paths->mcpelauncherClient();
    if (client.isEmpty()) {
        qWarning() << "MinecraftLaunch::runGame: mcpelauncher-client not configured";
        return false;
    }

    QString profilePath;
    // derive profile path from versions folder name
    QFileInfo vfi(versionPath);
    QString versionName = vfi.fileName();
    profilePath = QDir(m_paths->profilesDir()).filePath(versionName);

    QStringList args;
    args << QStringLiteral("-dg") << versionPath;
    if (!useShared) {
        args << QStringLiteral("-dd") << profilePath;
    }

    // The client accepts -ifp later when importing

    QString program;
    QStringList finalArgs;

    // If using mangohud, run: mangohud <client> <args>
    if (useMangohud) {
        program = QStringLiteral("mangohud");
        finalArgs = args;
        finalArgs.prepend(client);
    } else {
        // Otherwise run with setsid to detach the client from the launcher
        // command: setsid <client> <args>
        program = QStringLiteral("setsid");
        finalArgs = args;
        finalArgs.prepend(client);
    }

    QProcess *proc = new QProcess();
    QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
    if (useZink) {
        env.insert("MESA_LOADER_DRIVER_OVERRIDE", "zink");
    } else if (useNvidia) {
        env.insert("__NV_PRIME_RENDER_OFFLOAD", "1");
        env.insert("__VK_LAYER_NV_optimus", "NVIDIA_only");
        env.insert("__GLX_VENDOR_LIBRARY_NAME", "nvidia");
    }
    proc->setProcessEnvironment(env);

    qDebug() << "MinecraftLaunch::runGame launching" << program << finalArgs;
    proc->start(program, finalArgs);
    if (!proc->waitForStarted(5000)) {
        qWarning() << "MinecraftLaunch::runGame failed to start";
        proc->deleteLater();
        return false;
    }

    // Let the process run detached; delete proc when finished
    connect(proc, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished), proc, &QObject::deleteLater);
    return true;
}

bool MinecraftLaunch::importFile(const QString &versionPath,
                                 const QString &filePath,
                                 bool useShared,
                                 bool useNvidia,
                                 bool useZink,
                                 bool useMangohud)
{
    if (!m_paths) {
        qWarning() << "MinecraftLaunch::importFile: no PathManager";
        return false;
    }

    QString client = m_paths->mcpelauncherClient();
    if (client.isEmpty()) {
        qWarning() << "MinecraftLaunch::importFile: mcpelauncher-client not configured";
        return false;
    }

    QFileInfo vfi(versionPath);
    QString versionName = vfi.fileName();
    QString profilePath = QDir(m_paths->profilesDir()).filePath(versionName);

    QStringList args;
    args << QStringLiteral("-dg") << versionPath;
    if (!useShared) args << QStringLiteral("-dd") << profilePath;
    args << QStringLiteral("-ifp") << filePath;

    QString program = client;
    QStringList finalArgs = args;
    if (useMangohud) {
        finalArgs = args;
        finalArgs.prepend(program);
        program = QStringLiteral("mangohud");
    }

    QProcess *proc = new QProcess();
    QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
    if (useZink) {
        env.insert("MESA_LOADER_DRIVER_OVERRIDE", "zink");
    } else if (useNvidia) {
        env.insert("__NV_PRIME_RENDER_OFFLOAD", "1");
        env.insert("__VK_LAYER_NV_optimus", "NVIDIA_only");
        env.insert("__GLX_VENDOR_LIBRARY_NAME", "nvidia");
    }
    proc->setProcessEnvironment(env);

    qDebug() << "MinecraftLaunch::importFile launching" << program << finalArgs;
    proc->start(program, finalArgs);
    if (!proc->waitForStarted(5000)) {
        qWarning() << "MinecraftLaunch::importFile failed to start";
        proc->deleteLater();
        return false;
    }

    connect(proc, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished), proc, &QObject::deleteLater);
    return true;
}
