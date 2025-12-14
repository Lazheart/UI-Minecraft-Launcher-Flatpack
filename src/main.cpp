#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "../include/pathmanager.h"
#include "../include/minecraftmanager.h"

int main(int argc, char **argv)
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("minecraft-launcher-gui");

    QQmlApplicationEngine engine;

    PathManager pathManager;
    MinecraftManager minecraftManager(&pathManager);

    engine.rootContext()->setContextProperty("pathManager", &pathManager);
    engine.rootContext()->setContextProperty("minecraftManager", &minecraftManager);

    qDebug() << "[main] Exposed pathManager and minecraftManager to QML";
    qDebug() << "[main] pathManager.versionsDir=" << pathManager.versionsDir();
    qDebug() << "[main] pathManager.profilesDir=" << pathManager.profilesDir();
    qDebug() << "[main] pathManager.mcpelauncherExtract=" << pathManager.mcpelauncherExtract();

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    engine.load(url);

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
