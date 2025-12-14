#ifndef MINECRAFTLAUNCH_H
#define MINECRAFTLAUNCH_H

#include <QObject>
#include <QString>
#include <QStringList>

class PathManager;

class MinecraftLaunch : public QObject
{
    Q_OBJECT
public:
    explicit MinecraftLaunch(PathManager *paths = nullptr, QObject *parent = nullptr);

    // Ejecuta el cliente para una versión específica.
    // Devuelve true si el proceso se lanzó correctamente.
    bool runGame(const QString &versionPath,
                 bool useNvidia = false,
                 bool useZink = false,
                 bool useShared = false,
                 bool useMangohud = false);

    // Importa un archivo (world/addon) usando el cliente con la opción -ifp
    // versionPath debe ser la ruta completa a la carpeta de la versión.
    bool importFile(const QString &versionPath,
                    const QString &filePath,
                    bool useShared = false,
                    bool useNvidia = false,
                    bool useZink = false,
                    bool useMangohud = false);

private:
    PathManager *m_paths;
};

#endif // MINECRAFTLAUNCH_H
