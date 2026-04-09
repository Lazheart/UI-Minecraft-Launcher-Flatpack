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
#include <QFileInfoList>
#include <QStandardPaths>
#include <QUrl>

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

QString Translator::lastError() const {
    return m_lastError;
}

void Translator::setError(const QString& errorText) {
    if (m_lastError == errorText)
        return;
    m_lastError = errorText;
    emit lastErrorChanged();
}

bool Translator::setLanguage(const QString& lang) {
    setError(QString());
    const QString normalizedLang = normalizedLanguageCode(lang);
    if (normalizedLang.isEmpty()) {
        const QString msg = QStringLiteral("Código de idioma inválido: ") + lang;
        qWarning() << msg;
        setError(msg);
        return false;
    }

    if (m_currentLanguage == normalizedLang && !m_translator.isEmpty()) {
        return true;
    }

    QString tsPath = QDir(m_translationsPath).filePath(QString("app_%1.ts").arg(normalizedLang));
    QString qmPath = QDir(m_translationsPath).filePath(QString("app_%1.qm").arg(normalizedLang));

    if (!QFile::exists(qmPath)) {
        if (!QFile::exists(tsPath)) {
            const QString msg = QStringLiteral("No existe ni TS ni QM para idioma ") + normalizedLang;
            qWarning() << msg << "en" << m_translationsPath;
            setError(msg);
            return false;
        }
        if (!compileTsToQm(tsPath, qmPath)) {
            const QString msg = QStringLiteral("No se pudo generar QM para idioma ") + normalizedLang;
            qWarning() << msg;
            setError(msg);
            return false;
        }
    }

    if (!QFile::exists(qmPath)) {
        const QString msg = QStringLiteral("Archivo .qm no encontrado: ") + qmPath;
        qWarning() << msg;
        setError(msg);
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
        const QString msg = QStringLiteral("Fallo al cargar traducción: ") + qmPath;
        qWarning() << msg;
        setError(msg);
        return false;
    }
}

bool Translator::exportToJson(const QString& outputFile) {
    setError(QString());
    QString localOutputFile = outputFile;
    const QUrl outputUrl(outputFile);
    if (outputUrl.isLocalFile())
        localOutputFile = outputUrl.toLocalFile();

    QString baseTsPath = QDir(m_translationsPath).filePath("app_en.ts");
    QFile tsFile(baseTsPath);
    
    if (!tsFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        const QString msg = QStringLiteral("No se pudo abrir la fuente base de traducción: ") + baseTsPath;
        qWarning() << msg;
        setError(msg);
        return false;
    }

    QDomDocument doc;
    QString errorMsg;
    int errorLine, errorColumn;
    if (!doc.setContent(&tsFile, &errorMsg, &errorLine, &errorColumn)) {
        tsFile.close();
        const QString msg = QStringLiteral("XML malformado en ") + baseTsPath;
        qWarning() << msg << errorMsg << "Línea:" << errorLine;
        setError(msg);
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
    const QFileInfo outputInfo(localOutputFile);
    const QString outputDir = outputInfo.absolutePath();
    if (!outputDir.isEmpty() && outputDir != "." && !QDir().mkpath(outputDir)) {
        const QString msg = QStringLiteral("No se pudo crear el directorio destino para JSON: ") + outputDir;
        qWarning() << msg;
        setError(msg);
        return false;
    }

    QFile jsonFile(localOutputFile);
    if (!jsonFile.open(QIODevice::WriteOnly | QIODevice::Text)) {
        const QString msg = QStringLiteral("No se pudo crear el JSON: ") + localOutputFile;
        qWarning() << msg;
        setError(msg);
        return false;
    }
    
    jsonFile.write(jsonDoc.toJson(QJsonDocument::Indented));
    jsonFile.close();
    qInfo() << "Exportación completada:" << localOutputFile;
    return true;
}

bool Translator::importFromJson(const QString& lang, const QString& jsonFilePath) {
    setError(QString());
    QString localJsonPath = jsonFilePath;
    const QUrl jsonUrl(jsonFilePath);
    if (jsonUrl.isLocalFile())
        localJsonPath = jsonUrl.toLocalFile();

    const QString normalizedLang = normalizedLanguageCode(lang);
    if (normalizedLang.isEmpty()) {
        const QString msg = QStringLiteral("Código de idioma inválido para importación: ") + lang;
        qWarning() << msg;
        setError(msg);
        return false;
    }

    QFile jsonFile(localJsonPath);
    if (!jsonFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        const QString msg = QStringLiteral("No se pudo abrir el JSON: ") + localJsonPath;
        qWarning() << msg;
        setError(msg);
        return false;
    }
    QByteArray jsonData = jsonFile.readAll();
    jsonFile.close();

    QJsonParseError parseError;
    QJsonDocument jsonDoc = QJsonDocument::fromJson(jsonData, &parseError);
    if (parseError.error != QJsonParseError::NoError || !jsonDoc.isObject()) {
        const QString msg = QStringLiteral("Error de sintaxis JSON: ") + parseError.errorString();
        qWarning() << msg;
        setError(msg);
        return false;
    }

    QJsonObject jsonObj = jsonDoc.object();

    QString targetTsPath = QDir(m_translationsPath).filePath(QString("app_%1.ts").arg(normalizedLang));
    QFile targetTsFile(targetTsPath);
    
    // Regla: Siempre usar app_en.ts como plantilla base si es un nuevo idioma.
    if (!targetTsFile.exists()) {
        QString baseTsPath = QDir(m_translationsPath).filePath("app_en.ts");
        if (!QFile::copy(baseTsPath, targetTsPath)) {
            const QString msg = QStringLiteral("No se pudo copiar plantilla base a: ") + targetTsPath;
            qWarning() << msg << "desde" << baseTsPath;
            setError(msg);
            return false;
        }
        // Aplicamos permisos seguros sobre la creación.
        QFile::setPermissions(targetTsPath, QFileDevice::ReadOwner | QFileDevice::WriteOwner | QFileDevice::ReadUser | QFileDevice::WriteUser);
    }

    if (!targetTsFile.open(QIODevice::ReadWrite | QIODevice::Text)) {
        const QString msg = QStringLiteral("No se pudo editar el TS: ") + targetTsPath;
        qWarning() << msg;
        setError(msg);
        return false;
    }

    QDomDocument doc;
    QString errorMsg;
    int errorLine, errorColumn;
    if (!doc.setContent(&targetTsFile, &errorMsg, &errorLine, &errorColumn)) {
        targetTsFile.close();
        const QString msg = QStringLiteral("Fallo parseo XML de Qt en: ") + targetTsPath;
        qWarning() << msg << errorMsg << "Línea:" << errorLine;
        setError(msg);
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

QStringList Translator::availableLanguages() const {
    QDir dir(m_translationsPath);
    QStringList out;

    const QFileInfoList files =
        dir.entryInfoList(QStringList() << "app_*.ts" << "app_*.qm", QDir::Files);

    for (const QFileInfo& fi : files) {
        const QString base = fi.completeBaseName();
        if (!base.startsWith("app_"))
            continue;
        const QString code = normalizedLanguageCode(base.mid(4));
        if (code.isEmpty())
            continue;
        const QString upper = code.toUpper();
        if (!out.contains(upper))
            out.append(upper);
    }

    if (!out.contains(QStringLiteral("EN")))
        out.append(QStringLiteral("EN"));
    if (!out.contains(QStringLiteral("ES")))
        out.append(QStringLiteral("ES"));

    out.sort();
    return out;
}

bool Translator::deleteLanguage(const QString& lang) {
    setError(QString());
    const QString normalizedLang = normalizedLanguageCode(lang);
    if (normalizedLang.isEmpty()) {
        setError(QStringLiteral("Código de idioma inválido"));
        return false;
    }

    const QString upper = normalizedLang.toUpper();
    if (upper == QLatin1String("EN") || upper == QLatin1String("ES")) {
        setError(QStringLiteral("No se puede eliminar un idioma por defecto"));
        return false;
    }

    QDir dir(m_translationsPath);
    const QString tsPath = dir.filePath(QStringLiteral("app_%1.ts").arg(normalizedLang));
    const QString qmPath = dir.filePath(QStringLiteral("app_%1.qm").arg(normalizedLang));

    bool changed = false;
    if (QFile::exists(tsPath)) {
        if (!QFile::remove(tsPath)) {
            setError(QStringLiteral("No se pudo eliminar: ") + tsPath);
            return false;
        }
        changed = true;
    }
    if (QFile::exists(qmPath)) {
        if (!QFile::remove(qmPath)) {
            setError(QStringLiteral("No se pudo eliminar: ") + qmPath);
            return false;
        }
        changed = true;
    }

    if (!changed) {
        setError(QStringLiteral("No se encontraron archivos del idioma: ") + upper);
        return false;
    }

    return true;
}
