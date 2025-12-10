#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include <QDebug>
#include <QDir>

#include "../include/launcherbackend.h"
#include "../include/minecraftmanager.h"
#include "../include/profilemanager.h"

int main(int argc, char *argv[])
{
    // Configurar atributos de la aplicación antes de crear QGuiApplication
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication::setApplicationName("Minecraft Bedrock Launcher");
    QGuiApplication::setOrganizationName("org.lazheart");
    QGuiApplication::setOrganizationDomain("lazheart.org");
    QGuiApplication::setApplicationVersion("1.0.0");

    QGuiApplication app(argc, argv);

    // Configurar el ícono de la aplicación
    QIcon::setThemeName("breeze");
    app.setWindowIcon(QIcon::fromTheme("minecraft-launcher"));

    // Crear el motor QML
    QQmlApplicationEngine engine;

    // Crear instancias de los backends
    LauncherBackend *launcherBackend = new LauncherBackend(&app);
    MinecraftManager *minecraftManager = new MinecraftManager(&app);
    ProfileManager *profileManager = new ProfileManager(&app);

    // Exponer los backends al contexto QML
    engine.rootContext()->setContextProperty("launcherBackend", QVariant::fromValue(launcherBackend));
    engine.rootContext()->setContextProperty("minecraftManager", QVariant::fromValue(minecraftManager));
    engine.rootContext()->setContextProperty("profileManager", QVariant::fromValue(profileManager));

    // Configurar rutas de importación para módulos QML
    engine.addImportPath("qrc:/");
    engine.addImportPath(":/");

    // Cargar el archivo QML principal
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl) {
            qCritical() << "Error: No se pudo cargar el archivo QML principal";
            QCoreApplication::exit(-1);
        }
    }, Qt::QueuedConnection);

    engine.load(url);

    if (engine.rootObjects().isEmpty()) {
        qCritical() << "Error: La ventana principal no se pudo crear";
        return -1;
    }

    qDebug() << "[GUI] Minecraft Bedrock Launcher iniciado correctamente";
    qDebug() << "[GUI] Plataforma:" << QGuiApplication::platformName();
    qDebug() << "[GUI] Directorio de trabajo:" << QDir::currentPath();

    return app.exec();
}
