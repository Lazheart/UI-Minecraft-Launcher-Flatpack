#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QFileInfo>
#include <QUrl>

#include "../include/minecraftmanager.h"
#include "../include/pathmanager.h"
#include "../include/profilemanager.h"
#include "../include/versionsapihandler.h"
#include "../include/loghandler.h"

int main(int argc, char **argv) {
  QGuiApplication app(argc, argv);
  app.setApplicationName("minecraft");

  // Initialize LogHandler
  LogHandler logHandler;
  qInstallMessageHandler(LogHandler::messageOutput);

  QQmlApplicationEngine engine;

  PathManager pathManager;
  MinecraftManager minecraftManager(&pathManager);
  ProfileManager profileManager;
  VersionsApiHandler versionsApiHandler;

  engine.rootContext()->setContextProperty("pathManager", &pathManager);
  engine.rootContext()->setContextProperty("minecraftManager",
                                           &minecraftManager);
  engine.rootContext()->setContextProperty("profileManager", &profileManager);
  engine.rootContext()->setContextProperty("versionsApiHandler", &versionsApiHandler);
  engine.rootContext()->setContextProperty("logHandler", &logHandler);

  qDebug() << "[main] Exposed pathManager and minecraftManager to QML";
  qDebug() << "[main] pathManager.versionsDir=" << pathManager.versionsDir();
  qDebug() << "[main] pathManager.profilesDir=" << pathManager.profilesDir();
  qDebug() << "[main] pathManager.mcpelauncherExtract="
           << pathManager.mcpelauncherExtract();

  const QUrl url(QStringLiteral("qrc:/main.qml"));
  engine.load(url);

  if (engine.rootObjects().isEmpty())
    return -1;

  // Soporte para abrir archivos .mcworld directamente (asociación de
  // archivos / doble clic). Si se pasa una ruta .mcworld como argumento
  // al ejecutable del launcher, lanzamos automáticamente la versión
  // instalada y delegamos la importación al cliente mediante -ifp,
  // simulando el arrastre del archivo a la ventana del juego.
  QStringList appArgs = app.arguments();
  QString worldArg;
  for (int i = 1; i < appArgs.size(); ++i) {
    QString a = appArgs.at(i);
    if (a.startsWith("-"))
      continue;
    if (a.startsWith("file://")) {
      QUrl u(a);
      a = u.toLocalFile();
    }
    if (a.endsWith(".mcworld", Qt::CaseInsensitive)) {
      worldArg = a;
      break;
    }
  }

  if (!worldArg.isEmpty()) {
    QFileInfo fi(worldArg);
    if (!fi.exists()) {
      qWarning() << "[main] .mcworld argument does not exist:" << worldArg;
    } else {
      QString targetVersion = minecraftManager.installedVersion();
      if (targetVersion.isEmpty()) {
        targetVersion = minecraftManager.lastActiveVersion();
      }

      if (targetVersion.isEmpty()) {
        qWarning() << "[main] No installed/lastActive version found to import"
                   << worldArg;
      } else {
        qDebug() << "[main] Launching import for .mcworld from CLI:" << worldArg
                 << "into version" << targetVersion;
        minecraftManager.importSelected(worldArg, "World", targetVersion);
      }
    }
  }

  return app.exec();
}
