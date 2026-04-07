#include "translator.h"
#include <QGuiApplication>
#include <QProcess>
#include <QFile>
#include <QDir>
#include <QDomDocument>
#include <QJsonDocument>
#include <QJsonObject>
#include <QDebug>
#include <QCoreApplication>
#include <QTextStream>
#include <QtGlobal>
#include <QFileInfo>
#include <QStandardPaths>

namespace {

QString normalizedLanguageCode(const QString& lang) {
    QString cleaned = lang.trimmed().toLower();
    if (cleaned.contains('_')) {
        cleaned = cleaned.section('_', 0, 0);
    }
    if (cleaned.contains('-')) {
        cleaned = cleaned.section('-', 0, 0);
    }
    return cleaned;
}

QStringList translationDirCandidates() {
    const QString appDir = QCoreApplication::applicationDirPath();
    const QString appName = QCoreApplication::applicationName();

    QStringList candidates;
    candidates << QDir::currentPath() + "/translations";
    candidates << appDir + "/translations";
    candidates << QDir(appDir).filePath("../translations");
    candidates << QDir(appDir).filePath("../share/minecraft-launcher-gui/translations");
    if (!appName.isEmpty()) {
        candidates << QDir(appDir).filePath("../share/" + appName + "/translations");
    }
    return candidates;
}

QString resolveFirstExistingDir(const QStringList& candidates) {
    for (const QString& path : candidates) {
        if (QDir(path).exists()) {
            return QDir(path).absolutePath();
        }
    }
    return QDir::currentPath() + "/translations";
}

bool compileTsToQm(const QString& tsPath, const QString& qmPath) {
    const QString lrelease = QStandardPaths::findExecutable("lrelease");
    if (lrelease.isEmpty()) {
        qWarning() << "No se encontró lrelease en PATH. Se intentará usar .qm precompilado:" << qmPath;
        return false;
    }

    QProcess process;
    qDebug() << "Compilando TS a QM con lrelease:" << tsPath << "->" << qmPath;
    process.start(lrelease, QStringList() << tsPath << "-qm" << qmPath);

    if (!process.waitForStarted()) {
        qWarning() << "No se pudo iniciar lrelease en:" << lrelease;
        return false;
    }

    if (!process.waitForFinished(15000)) {
        qWarning() << "Time out esperando lrelease.";
        return false;
    }

    if (process.exitCode() != 0) {
        qWarning() << "lrelease terminó con error:" << process.readAllStandardError();
    }

    return QFile::exists(qmPath);
}

}

Translator::Translator(QQmlApplicationEngine* engine, QObject* parent)
    : QObject(parent), m_engine(engine), m_currentLanguage("en")
{
    m_translationsPath = resolveFirstExistingDir(translationDirCandidates());
    qInfo() << "Directorio de traducciones activo:" << m_translationsPath;
}

QString Translator::currentLanguage() const {
    return m_currentLanguage;
}

bool Translator::setLanguage(const QString& lang) {
    const QString normalizedLang = normalizedLanguageCode(lang);
    if (normalizedLang.isEmpty()) {
        qWarning() << "Código de idioma inválido:" << lang;
        return false;
    }

    if (m_currentLanguage == normalizedLang && !m_translator.isEmpty()) {
        return true;
    }

    QString tsPath = QDir(m_translationsPath).filePath(QString("app_%1.ts").arg(normalizedLang));
    QString qmPath = QDir(m_translationsPath).filePath(QString("app_%1.qm").arg(normalizedLang));

    if (!QFile::exists(qmPath)) {
        if (!QFile::exists(tsPath)) {
            qWarning() << "No existe ni TS ni QM para idioma" << normalizedLang << "en" << m_translationsPath;
            return false;
        }
        if (!compileTsToQm(tsPath, qmPath)) {
            qWarning() << "No se pudo generar QM para idioma" << normalizedLang;
            return false;
        }
    }

    if (!QFile::exists(qmPath)) {
        qWarning() << "Archivo .qm no encontrado en:" << qmPath;
        return false;
    }

    // Si había una traducción cargada previamente, la removemos.
    if (!m_translator.isEmpty()) {
        qApp->removeTranslator(&m_translator);
    }

    // Instalamos la traducción en memoria.
    if (m_translator.load(qmPath)) {
        qApp->installTranslator(&m_translator);
        m_currentLanguage = normalizedLang;
        emit languageChanged();
        
        // Recargar la UI de QML de forma dinámica
        if (m_engine) {
            m_engine->retranslate();
        }
        return true;
    } else {
        qWarning() << "Fallo al inyectar QTranslator con archivo:" << qmPath;
        return false;
    }
}

bool Translator::exportToJson(const QString& outputFile) {
    QString baseTsPath = QDir(m_translationsPath).filePath("app_en.ts");
    QFile tsFile(baseTsPath);
    
    if (!tsFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "No se puedo abrir la fuente base de traducción:" << baseTsPath;
        return false;
    }

    QDomDocument doc;
    QString errorMsg;
    int errorLine, errorColumn;
    if (!doc.setContent(&tsFile, &errorMsg, &errorLine, &errorColumn)) {
        tsFile.close();
        qWarning() << "XML Malformado en:" << baseTsPath << errorMsg << "Línea:" << errorLine;
        return false;
    }
    tsFile.close();

    QJsonObject jsonObj;
    QDomElement root = doc.documentElement(); // <TS>
    QDomNodeList contextList = root.elementsByTagName("context");

    for (int i = 0; i < contextList.count(); ++i) {
        QDomElement contextElement = contextList.at(i).toElement();
        QDomElement nameElement = contextElement.firstChildElement("name");
        QString contextName = nameElement.text();

        QDomNodeList messageList = contextElement.elementsByTagName("message");
        for (int j = 0; j < messageList.count(); ++j) {
            QDomElement messageElement = messageList.at(j).toElement();
            QDomElement sourceElement = messageElement.firstChildElement("source");
            
            if (!sourceElement.isNull()) {
                QString sourceText = sourceElement.text();
                // Ignorar strings en blanco
                if (!sourceText.isEmpty()) {
                    QString key = contextName + "." + sourceText;
                    jsonObj[key] = sourceText; // El texto en ingles base lo sacamos al JSON
                }
            }
        }
    }

    QJsonDocument jsonDoc(jsonObj);
    const QFileInfo outputInfo(outputFile);
    const QString outputDir = outputInfo.absolutePath();
    if (!outputDir.isEmpty() && outputDir != "." && !QDir().mkpath(outputDir)) {
        qWarning() << "No se pudo crear el directorio destino para JSON:" << outputDir;
        return false;
    }

    QFile jsonFile(outputFile);
    if (!jsonFile.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qWarning() << "No se pudo crear en disco el JSON:" << outputFile;
        return false;
    }
    
    jsonFile.write(jsonDoc.toJson(QJsonDocument::Indented));
    jsonFile.close();
    qInfo() << "Exportación completada:" << outputFile;
    return true;
}

bool Translator::importFromJson(const QString& lang, const QString& jsonFilePath) {
    const QString normalizedLang = normalizedLanguageCode(lang);
    if (normalizedLang.isEmpty()) {
        qWarning() << "Código de idioma inválido para importación:" << lang;
        return false;
    }

    QFile jsonFile(jsonFilePath);
    if (!jsonFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "Imposible abrir el JSON:" << jsonFilePath;
        return false;
    }
    QByteArray jsonData = jsonFile.readAll();
    jsonFile.close();

    QJsonParseError parseError;
    QJsonDocument jsonDoc = QJsonDocument::fromJson(jsonData, &parseError);
    if (parseError.error != QJsonParseError::NoError || !jsonDoc.isObject()) {
        qWarning() << "Error de Sintaxis JSON:" << parseError.errorString();
        return false;
    }

    QJsonObject jsonObj = jsonDoc.object();

    QString targetTsPath = QDir(m_translationsPath).filePath(QString("app_%1.ts").arg(normalizedLang));
    QFile targetTsFile(targetTsPath);
    
    // Regla: Siempre usar app_en.ts como plantilla base si es un nuevo idioma.
    if (!targetTsFile.exists()) {
        QString baseTsPath = QDir(m_translationsPath).filePath("app_en.ts");
        if (!QFile::copy(baseTsPath, targetTsPath)) {
            qWarning() << "Falla al copiar idioma default" << baseTsPath << "a" << targetTsPath;
            return false;
        }
        // Aplicamos permisos seguros sobre la creación.
        QFile::setPermissions(targetTsPath, QFileDevice::ReadOwner | QFileDevice::WriteOwner | QFileDevice::ReadUser | QFileDevice::WriteUser);
    }

    if (!targetTsFile.open(QIODevice::ReadWrite | QIODevice::Text)) {
        qWarning() << "No se pudo editar el TS:" << targetTsPath;
        return false;
    }

    QDomDocument doc;
    QString errorMsg;
    int errorLine, errorColumn;
    if (!doc.setContent(&targetTsFile, &errorMsg, &errorLine, &errorColumn)) {
        targetTsFile.close();
        qWarning() << "Fallo parseo XML de Qt:" << targetTsPath << errorMsg << "Línea:" << errorLine;
        return false;
    }

    QDomElement root = doc.documentElement();
    // Reasignamos target lang al nuevo
    root.setAttribute("language", normalizedLang);

    QDomNodeList contextList = root.elementsByTagName("context");

    for (int i = 0; i < contextList.count(); ++i) {
        QDomElement contextElement = contextList.at(i).toElement();
        QDomElement nameElement = contextElement.firstChildElement("name");
        QString contextName = nameElement.text();

        QDomNodeList messageList = contextElement.elementsByTagName("message");
        for (int j = 0; j < messageList.count(); ++j) {
            QDomElement messageElement = messageList.at(j).toElement();
            QDomElement sourceElement = messageElement.firstChildElement("source");
            QDomElement translationElement = messageElement.firstChildElement("translation");
            
            if (!sourceElement.isNull()) {
                QString sourceText = sourceElement.text();
                QString key = contextName + "." + sourceText;

                if (jsonObj.contains(key)) {
                    QString translatedText = jsonObj[key].toString();
                    
                    if (translationElement.isNull()) {
                         // Por safety, si el XML no viene con el nodo <translation>
                         translationElement = doc.createElement("translation");
                         messageElement.appendChild(translationElement);
                    }

                    // Removemos type="unfinished" o "vanished" porque el JSON marca la finalización.
                    if (translationElement.hasAttribute("type")) {
                        translationElement.removeAttribute("type");
                    }
                    
                    // Borrado completo de la traducción previa.
                    QDomNode oldNode = translationElement.firstChild();
                    while (!oldNode.isNull()) {
                        translationElement.removeChild(oldNode);
                        oldNode = translationElement.firstChild();
                    }
                    
                    // Insertamos el nuevo texto.
                    QDomText newText = doc.createTextNode(translatedText);
                    translationElement.appendChild(newText);
                }
            }
        }
    }

    targetTsFile.resize(0); 
    QTextStream out(&targetTsFile);
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    out.setCodec("UTF-8");
#endif
    doc.save(out, 4, QDomNode::EncodingFromDocument);
    targetTsFile.close();
    qInfo() << "Importación consolidada en TS:" << targetTsPath;

    return true;
}
