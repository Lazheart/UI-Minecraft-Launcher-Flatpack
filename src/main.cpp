#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "../include/minecraftmanager.h"
#include "../include/pathmanager.h"
#include "../include/profilemanager.h"

int main(int argc, char **argv) {
  QGuiApplication app(argc, argv);
  app.setApplicationName("minecraft");

  QQmlApplicationEngine engine;

  PathManager pathManager;
  MinecraftManager minecraftManager(&pathManager);
  ProfileManager profileManager;

  engine.rootContext()->setContextProperty("pathManager", &pathManager);
  engine.rootContext()->setContextProperty("minecraftManager",
                                           &minecraftManager);
  engine.rootContext()->setContextProperty("profileManager", &profileManager);

  qDebug() << "[main] Exposed pathManager and minecraftManager to QML";
  qDebug() << "[main] pathManager.versionsDir=" << pathManager.versionsDir();
  qDebug() << "[main] pathManager.profilesDir=" << pathManager.profilesDir();
  qDebug() << "[main] pathManager.mcpelauncherExtract="
           << pathManager.mcpelauncherExtract();

  const QUrl url(QStringLiteral("qrc:/main.qml"));
  engine.load(url);

  if (engine.rootObjects().isEmpty())
    return -1;

  return app.exec();
}
