#pragma once

#include <QObject>
#include <QTranslator>
#include <QQmlApplicationEngine>
#include <QJsonObject>
#include <QString>
#include <QStringList>

class Translator : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString currentLanguage READ currentLanguage NOTIFY languageChanged)
    Q_PROPERTY(QString lastError READ lastError NOTIFY lastErrorChanged)

public:
    explicit Translator(QQmlApplicationEngine* engine, QObject* parent = nullptr);

    // 2. Compilación para runtime (de .ts a .qm y carga en ram)
    Q_INVOKABLE bool setLanguage(const QString& lang);
    
    // 3. Exportador a JSON (lee app_en.ts y crea un .json asociado)
    Q_INVOKABLE bool exportToJson(const QString& outputFile = "translations/export.json");
    
    // 4. Importador desde JSON (lee un .json y actualiza el .ts destino)
    Q_INVOKABLE bool importFromJson(const QString& lang, const QString& jsonFilePath);

    // 5. Listar idiomas disponibles detectados en translations/app_<lang>.ts|qm
    Q_INVOKABLE QStringList availableLanguages() const;

    // 6. Eliminar idioma personalizado (protege EN/ES)
    Q_INVOKABLE bool deleteLanguage(const QString& lang);

    QString currentLanguage() const;
    QString lastError() const;

signals:
    void languageChanged();
    void lastErrorChanged();

private:
    QQmlApplicationEngine* m_engine;
    QTranslator m_translator;
    QString m_currentLanguage;
    QString m_translationsPath;
    QString m_lastError;

    void setError(const QString& errorText);
};
