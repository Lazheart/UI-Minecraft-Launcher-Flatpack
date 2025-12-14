#include "../include/minecraftextract.h"
#include "../include/pathmanager.h"

#include <QProcess>
#include <QDebug>

MinecraftExtract::MinecraftExtract(PathManager *paths, QObject *parent)
    : QObject(parent), m_paths(paths)
{
}

bool MinecraftExtract::extractApk(const QString &apkPath, const QString &name, QString *outStdErr)
{
    if (!m_paths) {
        qWarning() << "MinecraftExtract: no PathManager provided";
        return false;
    }
    // Construir la ruta objetivo donde se extraerá el APK: <versionsDir>/<name>
    QString versionsRoot = m_paths->versionsDir();
    QString targetDir = QDir(versionsRoot).filePath(name);

    qDebug() << "MinecraftExtract: will extract to targetDir:" << targetDir;

    // Asegurar que existe el directorio destino antes de invocar el extractor
    QDir().mkpath(targetDir);

    QString extractor = m_paths->mcpelauncherExtract();
    qDebug() << "MinecraftExtract: running extractor:" << extractor << "apk:" << apkPath << "target:" << targetDir;

    QProcess proc;
    QStringList args;
    // Pasamos al extractor la ruta del APK y la ruta completa del directorio objetivo
    args << apkPath << targetDir;
    proc.start(extractor, args);
    bool started = proc.waitForStarted(5000);
    if (!started) {
        qWarning() << "MinecraftExtract: failed to start extractor";
        if (outStdErr) *outStdErr = "failed to start extractor";
        return false;
    }

    bool finished = proc.waitForFinished(120000); // 2 minutes timeout
    QByteArray stdoutData = proc.readAllStandardOutput();
    QByteArray stderrData = proc.readAllStandardError();

    qDebug() << "MinecraftExtract: extractor stdout:" << stdoutData;
    if (!stderrData.isEmpty()) qDebug() << "MinecraftExtract: extractor stderr:" << stderrData;

    if (outStdErr) *outStdErr = QString::fromUtf8(stderrData);

    if (!finished) {
        qWarning() << "MinecraftExtract: extractor timeout";
        return false;
    }

    int rc = proc.exitCode();
    qDebug() << "MinecraftExtract: extractor exit code:" << rc;
    return rc == 0;
}
