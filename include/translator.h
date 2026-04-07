#pragma once

#include <QObject>
#include <QTranslator>
#include <QQmlApplicationEngine>
#include <QJsonObject>
#include <QString>

class Translator : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString currentLanguage READ currentLanguage NOTIFY languageChanged)

public:
    explicit Translator(QQmlApplicationEngine* engine, QObject* parent = nullptr);

    // 2. Compilación para runtime (de .ts a .qm y carga en ram)
    Q_INVOKABLE bool setLanguage(const QString& lang);
    
    // 3. Exportador a JSON (lee app_en.ts y crea un .json asociado)
    Q_INVOKABLE bool exportToJson(const QString& outputFile = "translations/export.json");
    
    // 4. Importador desde JSON (lee un .json y actualiza el .ts destino)
    Q_INVOKABLE bool importFromJson(const QString& lang, const QString& jsonFilePath);

    QString currentLanguage() const;

signals:
    void languageChanged();

private:
    QQmlApplicationEngine* m_engine;
    QTranslator m_translator;
    QString m_currentLanguage;
    QString m_translationsPath;
};
