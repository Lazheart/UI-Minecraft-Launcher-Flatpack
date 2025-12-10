#ifndef PACKAGEINSPECTOR_H
#define PACKAGEINSPECTOR_H

#include <QString>
#include <QJsonObject>

class PackageInspector
{
public:
    enum PackageType {
        Unknown = 0,
        ResourcePack = 1,
        BehaviorPack = 2,
        World = 3,
        Addon = 4
    };

    // Analizar tipo de paquete
    static PackageType inspectPackage(const QString &zipPath);
    static QString packageTypeToString(PackageType type);
    
    // Extraer información
    static QJsonObject getPackageMetadata(const QString &zipPath);
    static QString getPackageUuid(const QString &zipPath);
    static QString getPackageName(const QString &zipPath);
    static QString getPackageVersion(const QString &zipPath);
    
    // Para mundos específicamente
    static QJsonObject getWorldMetadata(const QString &worldZipPath);
    static QString getWorldLevelName(const QString &worldZipPath);
    
private:
    static QJsonObject parseManifestJson(const QString &zipPath);
    static bool isResourcePack(const QJsonObject &manifest);
    static bool isBehaviorPack(const QJsonObject &manifest);
    static bool isWorld(const QJsonObject &manifest);
};

#endif // PACKAGEINSPECTOR_H
