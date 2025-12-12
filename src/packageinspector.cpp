#include "../include/packageinspector.h"
#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QFile>
#include <QFileInfo>
#include <vector>
#include <zip.h>

// Helpers: leer manifest.json dentro del ZIP y listar contenidos (implementación mínima)
static QJsonObject readManifestJsonFromZip(const QString &zipPath)
{
    QJsonObject empty;
    int err = 0;
    zip_t *zip = zip_open(zipPath.toStdString().c_str(), 0, &err);
    if (!zip) {
        qWarning() << "[PackageInspector] Cannot open ZIP:" << zipPath << "err:" << err;
        return empty;
    }

    zip_int64_t numEntries = zip_get_num_entries(zip, 0);
    zip_int64_t foundIndex = -1;

    for (zip_int64_t i = 0; i < numEntries; ++i) {
        const char *name = zip_get_name(zip, i, 0);
        if (!name) continue;
        QString sname = QString::fromUtf8(name);
        if (sname.endsWith("manifest.json", Qt::CaseInsensitive) || sname.contains("/manifest.json")) {
            foundIndex = i;
            break;
        }
    }

    if (foundIndex < 0) {
        zip_close(zip);
        return empty;
    }

    struct zip_stat sb;
    if (zip_stat_index(zip, foundIndex, 0, &sb) != 0) {
        zip_close(zip);
        return empty;
    }

    zip_file_t *file = zip_fopen_index(zip, foundIndex, 0);
    if (!file) {
        zip_close(zip);
        return empty;
    }

    std::vector<char> buffer(sb.size + 1);
    zip_fread(file, buffer.data(), sb.size);
    buffer[sb.size] = '\0';

    zip_fclose(file);
    zip_close(zip);

    QJsonDocument doc = QJsonDocument::fromJson(QByteArray(buffer.data(), static_cast<int>(sb.size)));
    if (doc.isObject()) return doc.object();
    return empty;
}

static QStringList listZipContentsMinimal(const QString &zipPath)
{
    QStringList contents;
    int err = 0;
    zip_t *zip = zip_open(zipPath.toStdString().c_str(), 0, &err);
    if (!zip) return contents;
    zip_int64_t numEntries = zip_get_num_entries(zip, 0);
    for (zip_int64_t i = 0; i < numEntries; ++i) {
        const char *name = zip_get_name(zip, i, 0);
        if (name) contents.append(QString::fromUtf8(name));
    }
    zip_close(zip);
    return contents;
}

PackageInspector::PackageType PackageInspector::inspectPackage(const QString &zipPath)
{
    QJsonObject manifest = parseManifestJson(zipPath);
    
    if (manifest.isEmpty()) {
        return Unknown;
    }
    
    // Detectar tipo basado en manifest.json
    if (isResourcePack(manifest)) {
        return ResourcePack;
    }
    if (isBehaviorPack(manifest)) {
        return BehaviorPack;
    }
    if (isWorld(manifest)) {
        return World;
    }
    
    return Unknown;
}

QString PackageInspector::packageTypeToString(PackageType type)
{
    switch (type) {
        case ResourcePack:
            return "Resource Pack";
        case BehaviorPack:
            return "Behavior Pack";
        case World:
            return "World";
        case Addon:
            return "Addon";
        case Unknown:
        default:
            return "Unknown";
    }
}

QJsonObject PackageInspector::getPackageMetadata(const QString &zipPath)
{
    QJsonObject metadata;
    QJsonObject manifest = parseManifestJson(zipPath);
    
    if (manifest.isEmpty()) {
        metadata["error"] = "No manifest.json found";
        return metadata;
    }
    
    // Extraer información común
    metadata["type"] = packageTypeToString(inspectPackage(zipPath));
    metadata["name"] = getPackageName(zipPath);
    metadata["uuid"] = getPackageUuid(zipPath);
    metadata["version"] = getPackageVersion(zipPath);
    
    // Información adicional del manifest
    if (manifest.contains("description")) {
        metadata["description"] = manifest["description"].toString();
    }
    
    return metadata;
}

QString PackageInspector::getPackageUuid(const QString &zipPath)
{
    QJsonObject manifest = parseManifestJson(zipPath);
    
    // El UUID generalmente está en header -> uuid
    if (manifest.contains("header") && manifest["header"].isObject()) {
        QJsonObject header = manifest["header"].toObject();
        if (header.contains("uuid")) {
            return header["uuid"].toString();
        }
    }
    
    // O directamente en uuid
    if (manifest.contains("uuid")) {
        return manifest["uuid"].toString();
    }
    
    return QString();
}

QString PackageInspector::getPackageName(const QString &zipPath)
{
    QJsonObject manifest = parseManifestJson(zipPath);
    
    // El nombre está en header -> name
    if (manifest.contains("header") && manifest["header"].isObject()) {
        QJsonObject header = manifest["header"].toObject();
        if (header.contains("name")) {
            return header["name"].toString();
        }
    }
    
    // O en formato antiguo: name
    if (manifest.contains("name")) {
        return manifest["name"].toString();
    }
    
    return QString();
}

QString PackageInspector::getPackageVersion(const QString &zipPath)
{
    QJsonObject manifest = parseManifestJson(zipPath);
    
    // La versión está en header -> version
    if (manifest.contains("header") && manifest["header"].isObject()) {
        QJsonObject header = manifest["header"].toObject();
        if (header.contains("version")) {
            QJsonArray version = header["version"].toArray();
            if (version.size() >= 3) {
                return QString("%1.%2.%3")
                    .arg(version[0].toInt())
                    .arg(version[1].toInt())
                    .arg(version[2].toInt());
            }
        }
    }
    
    return "1.0.0";
}

QJsonObject PackageInspector::getWorldMetadata(const QString &worldZipPath)
{
    QJsonObject metadata;
    
    // Los mundos tienen estructura diferente
    // Buscar level.dat o levelname.txt
    QStringList contents = listZipContentsMinimal(worldZipPath);
    
    bool hasDb = false;
    bool hasLevelDat = false;
    
    for (const QString &file : contents) {
        if (file.contains("db/") || file == "db") hasDb = true;
        if (file.contains("level.dat")) hasLevelDat = true;
    }
    
    metadata["hasDb"] = hasDb;
    metadata["hasLevelDat"] = hasLevelDat;
    metadata["isValidWorld"] = hasDb || hasLevelDat;
    
    return metadata;
}

QString PackageInspector::getWorldLevelName(const QString &worldZipPath)
{
    // Intentar leer levelname del manifest o del nombre del ZIP
    QJsonObject manifest = parseManifestJson(worldZipPath);
    
    if (manifest.contains("level_name")) {
        return manifest["level_name"].toString();
    }
    
    // Fallback: usar el nombre del archivo
    QFileInfo info(worldZipPath);
    return info.baseName();
}

QJsonObject PackageInspector::parseManifestJson(const QString &zipPath)
{
    return readManifestJsonFromZip(zipPath);
}

bool PackageInspector::isResourcePack(const QJsonObject &manifest)
{
    // Resource packs tienen módulos de tipo "resources"
    if (manifest.contains("modules") && manifest["modules"].isArray()) {
        QJsonArray modules = manifest["modules"].toArray();
        for (const QJsonValue &module : modules) {
            if (module.isObject()) {
                QJsonObject obj = module.toObject();
                if (obj.contains("type") && obj["type"].toString() == "resources") {
                    return true;
                }
            }
        }
    }
    
    return false;
}

bool PackageInspector::isBehaviorPack(const QJsonObject &manifest)
{
    // Behavior packs tienen módulos de tipo "data"
    if (manifest.contains("modules") && manifest["modules"].isArray()) {
        QJsonArray modules = manifest["modules"].toArray();
        for (const QJsonValue &module : modules) {
            if (module.isObject()) {
                QJsonObject obj = module.toObject();
                if (obj.contains("type") && obj["type"].toString() == "data") {
                    return true;
                }
            }
        }
    }
    
    return false;
}

bool PackageInspector::isWorld(const QJsonObject &manifest)
{
    // Los mundos tienen una estructura diferente, típicamente tienen
    // "format_version" o campos específicos de mundo
    return manifest.contains("format_version") || manifest.contains("level_name");
}
