#ifndef ZIPVALIDATOR_H
#define ZIPVALIDATOR_H

#include <QString>
#include <QStringList>
#include <QJsonObject>

class ZipValidator
{
public:
    // Validación de archivos zip
    static bool isValidZip(const QString &filePath);
    static bool hasPathTraversal(const QString &filePath);
    static bool hasMinimumFiles(const QString &filePath, const QStringList &requiredFiles);
    
    // Información de paquetes
    static QJsonObject readManifestJson(const QString &zipPath);
    static QStringList listZipContents(const QString &zipPath);
    
    // Seguridad
    static bool validateFileSize(const QString &filePath, qint64 maxSizeBytes = 2000000000); // 2GB default
    static bool validateZipStructure(const QString &zipPath);
    
    // Extracción segura
    static bool safeExtractZip(const QString &zipPath, 
                              const QString &targetDir,
                              QStringList &extractedFiles,
                              QString &errorMessage);

private:
    static const int MAX_FILES_IN_ZIP = 10000;
    static const qint64 MAX_INDIVIDUAL_FILE_SIZE = 2000000000; // 2GB
};

#endif // ZIPVALIDATOR_H
