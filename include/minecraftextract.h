#ifndef MINECRAFTEXTRACT_H
#define MINECRAFTEXTRACT_H

#include <QObject>
#include <QString>

class PathManager;

class MinecraftExtract : public QObject
{
    Q_OBJECT
public:
    explicit MinecraftExtract(PathManager *paths = nullptr, QObject *parent = nullptr);

    // Ejecuta el extractor externo.
    // Comportamiento: crea/asegura el directorio objetivo `versionsDir()/name`,
    // luego invoca el binario extractor pasando `apkPath` y la ruta completa
    // del directorio objetivo (apkPath, targetDir). Devuelve true si el
    // extractor finaliza con código 0. Si `outStdErr` se proporciona, se
    // rellena con la salida stderr del extractor.
    bool extractApk(const QString &apkPath, const QString &name, QString *outStdErr = nullptr);

private:
    PathManager *m_paths;
};

#endif // MINECRAFTEXTRACT_H
// Como nota final, el extractor externo `mcpelauncher-extract` es responsable
// de manejar la extracción real del APK y crear la estructura de directorios
// alguien quiere mas referencia sobre esto me base en https://codeberg.org/bry254/Launcher-minecraft-egui
// para el manejo y uso de los binarios del launcher