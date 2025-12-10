#include "../include/zipvalidator.h"
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QDebug>
#include <vector>
#include <zip.h>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

bool ZipValidator::isValidZip(const QString &filePath)
{
    QFile file(filePath);
    if (!file.exists()) {
        qWarning() << "[ZipValidator] File does not exist:" << filePath;
        return false;
    }
    
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "[ZipValidator] Cannot open file:" << filePath;
        return false;
    }
    
    // Leer la firma del ZIP (primeros 4 bytes deben ser PK\x03\x04)
    QByteArray header = file.read(4);
    file.close();
    
    if (header.size() < 4) {
        qWarning() << "[ZipValidator] File too small";
        return false;
    }
    
    // Firma PK (50 4B = 0x504B)
    return (static_cast<unsigned char>(header[0]) == 0x50 && 
            static_cast<unsigned char>(header[1]) == 0x4B) && 
           (static_cast<unsigned char>(header[2]) == 0x03 && 
            static_cast<unsigned char>(header[3]) == 0x04);
}

bool ZipValidator::hasPathTraversal(const QString &filePath)
{
    int err = 0;
    zip_t *zip = zip_open(filePath.toStdString().c_str(), 0, &err);
    
    if (!zip) {
        qWarning() << "[ZipValidator] Cannot open ZIP file:" << filePath << "Error code:" << err;
        return true; // Considerar como sospechoso si no se puede abrir
    }
    
    zip_int64_t numEntries = zip_get_num_entries(zip, 0);
    
    for (zip_int64_t i = 0; i < numEntries; ++i) {
        const char *name = zip_get_name(zip, i, 0);
        if (!name) continue;
        
        QString path = QString::fromUtf8(name);
        
        // Detectar path traversal (../ o ..\\)
        if (path.contains("..") || path.contains("..\\")) {
            qWarning() << "[ZipValidator] Path traversal detected:" << path;
            zip_close(zip);
            return true;
        }
    }
    
    zip_close(zip);
    return false;
}

bool ZipValidator::hasMinimumFiles(const QString &filePath, const QStringList &requiredFiles)
{
    int err = 0;
    zip_t *zip = zip_open(filePath.toStdString().c_str(), 0, &err);
    
    if (!zip) {
        return false;
    }
    
    QStringList foundFiles;
    zip_int64_t numEntries = zip_get_num_entries(zip, 0);
    
    for (zip_int64_t i = 0; i < numEntries; ++i) {
        const char *name = zip_get_name(zip, i, 0);
        if (name) {
            foundFiles.append(QString::fromUtf8(name));
        }
    }
    
    zip_close(zip);
    
    // Verificar que al menos existe uno de los archivos requeridos
    for (const QString &required : requiredFiles) {
        for (const QString &found : foundFiles) {
            if (found.contains(required, Qt::CaseInsensitive)) {
                return true;
            }
        }
    }
    
    return false;
}

QJsonObject ZipValidator::readManifestJson(const QString &zipPath)
{
    QJsonObject empty;
    
    int err = 0;
    zip_t *zip = zip_open(zipPath.toStdString().c_str(), 0, &err);
    
    if (!zip) {
        qWarning() << "[ZipValidator] Cannot open ZIP:" << zipPath;
        return empty;
    }
    
    // Buscar manifest.json
    zip_int64_t index = zip_name_locate(zip, "manifest.json", 0);
    if (index < 0) {
        qDebug() << "[ZipValidator] manifest.json not found in:" << zipPath;
        zip_close(zip);
        return empty;
    }
    
    // Leer el archivo
    zip_file_t *file = zip_fopen_index(zip, index, 0);
    if (!file) {
        qWarning() << "[ZipValidator] Cannot open manifest.json";
        zip_close(zip);
        return empty;
    }
    
    struct zip_stat sb;
    zip_stat_index(zip, index, 0, &sb);
    
    std::vector<char> buffer(sb.size + 1);
    zip_fread(file, buffer.data(), sb.size);
    buffer[sb.size] = '\0';
    
    zip_fclose(file);
    zip_close(zip);
    
    // Parsear JSON
    QJsonDocument doc = QJsonDocument::fromJson(QByteArray(buffer.data(), static_cast<int>(sb.size)));
    if (doc.isObject()) {
        return doc.object();
    }
    
    return empty;
}

QStringList ZipValidator::listZipContents(const QString &zipPath)
{
    QStringList contents;
    
    int err = 0;
    zip_t *zip = zip_open(zipPath.toStdString().c_str(), 0, &err);
    
    if (!zip) {
        return contents;
    }
    
    zip_int64_t numEntries = zip_get_num_entries(zip, 0);
    
    for (zip_int64_t i = 0; i < numEntries; ++i) {
        const char *name = zip_get_name(zip, i, 0);
        if (name) {
            contents.append(QString::fromUtf8(name));
        }
    }
    
    zip_close(zip);
    return contents;
}

bool ZipValidator::validateFileSize(const QString &filePath, qint64 maxSizeBytes)
{
    QFile file(filePath);
    if (!file.exists()) {
        qWarning() << "[ZipValidator] File does not exist:" << filePath;
        return false;
    }
    
    qint64 fileSize = file.size();
    
    if (fileSize > maxSizeBytes) {
        qWarning() << "[ZipValidator] File exceeds maximum size. Size:" << fileSize 
                   << "Max:" << maxSizeBytes;
        return false;
    }
    
    return true;
}

bool ZipValidator::validateZipStructure(const QString &zipPath)
{
    int err = 0;
    zip_t *zip = zip_open(zipPath.toStdString().c_str(), 0, &err);
    
    if (!zip) {
        qWarning() << "[ZipValidator] Invalid ZIP structure:" << zipPath;
        return false;
    }
    
    zip_int64_t numEntries = zip_get_num_entries(zip, 0);
    
    // Verificar número de archivos
    if (numEntries > MAX_FILES_IN_ZIP) {
        qWarning() << "[ZipValidator] Too many files in ZIP:" << numEntries;
        zip_close(zip);
        return false;
    }
    
    // Verificar tamaño de archivos individuales
    for (zip_int64_t i = 0; i < numEntries; ++i) {
        struct zip_stat sb;
        zip_stat_index(zip, i, 0, &sb);
        
        if (sb.size > MAX_INDIVIDUAL_FILE_SIZE) {
            qWarning() << "[ZipValidator] File too large in ZIP:" << sb.name;
            zip_close(zip);
            return false;
        }
    }
    
    zip_close(zip);
    return true;
}

bool ZipValidator::safeExtractZip(const QString &zipPath, 
                                  const QString &targetDir,
                                  QStringList &extractedFiles,
                                  QString &errorMessage)
{
    // Validaciones previas
    if (!isValidZip(zipPath)) {
        errorMessage = "Invalid ZIP file";
        return false;
    }
    
    if (hasPathTraversal(zipPath)) {
        errorMessage = "ZIP contains suspicious paths (path traversal)";
        return false;
    }
    
    if (!validateZipStructure(zipPath)) {
        errorMessage = "ZIP structure validation failed";
        return false;
    }
    
    // Crear directorio destino
    QDir targetDirObj(targetDir);
    if (!targetDirObj.mkpath(".")) {
        errorMessage = QString("Cannot create target directory: %1").arg(targetDir);
        return false;
    }
    
    // Extraer archivos
    int err = 0;
    zip_t *zip = zip_open(zipPath.toStdString().c_str(), 0, &err);
    
    if (!zip) {
        errorMessage = "Cannot open ZIP file for extraction";
        return false;
    }
    
    zip_int64_t numEntries = zip_get_num_entries(zip, 0);
    
    for (zip_int64_t i = 0; i < numEntries; ++i) {
        struct zip_stat sb;
        zip_stat_index(zip, i, 0, &sb);
        
        QString entryName = QString::fromUtf8(sb.name);
        QString targetPath = targetDir + "/" + entryName;
        
        if (entryName.endsWith("/")) {
            // Es un directorio
            QDir().mkpath(targetPath);
        } else {
            // Es un archivo
            zip_file_t *file = zip_fopen_index(zip, i, 0);
            if (!file) {
                errorMessage = QString("Cannot read entry: %1").arg(entryName);
                zip_close(zip);
                return false;
            }
            
            // Crear directorio padre si es necesario
            QFileInfo fileInfo(targetPath);
            QDir().mkpath(fileInfo.dir().absolutePath());
            
            // Escribir archivo
            QFile outFile(targetPath);
            if (!outFile.open(QIODevice::WriteOnly)) {
                errorMessage = QString("Cannot write file: %1").arg(targetPath);
                zip_fclose(file);
                zip_close(zip);
                return false;
            }
            
            char buffer[4096];
            zip_int64_t len;
            while ((len = zip_fread(file, buffer, sizeof(buffer))) > 0) {
                outFile.write(buffer, len);
            }
            
            outFile.close();
            zip_fclose(file);
            extractedFiles.append(entryName);
        }
    }
    
    zip_close(zip);
    return true;
}
