#ifndef THEMEMANAGER_H
#define THEMEMANAGER_H

#include <QObject>
#include <QString>
#include <QVariantMap>

class ThemeManager : public QObject {
  Q_OBJECT
  Q_PROPERTY(QVariantMap colors READ colors NOTIFY themeChanged)
  Q_PROPERTY(QString currentSource READ currentSource NOTIFY themeChanged)
  Q_PROPERTY(QString lastError READ lastError NOTIFY lastErrorChanged)

public:
  explicit ThemeManager(QObject *parent = nullptr);

  QVariantMap colors() const { return m_colors; }
  QString currentSource() const { return m_currentSource; }
  QString lastError() const { return m_lastError; }

  Q_INVOKABLE bool loadBundledTheme(const QString &themeName);
  Q_INVOKABLE bool loadFromFile(const QString &path);
  Q_INVOKABLE bool saveBundledDarkTemplateTo(const QString &destinationPath);

  static QVariantMap parseCssVariables(const QString &content);

signals:
  void themeChanged();
  void lastErrorChanged();

private:
  QVariantMap m_colors;
  QString m_currentSource;
  QString m_lastError;

  void setError(const QString &e);
  bool loadFromResourcePath(const QString &resourcePath, const QString &sourceLabel);
  static void mergeMap(QVariantMap &dest, const QVariantMap &overrides);
  static QString normalizeVarName(const QString &rawName);
};

#endif // THEMEMANAGER_H
