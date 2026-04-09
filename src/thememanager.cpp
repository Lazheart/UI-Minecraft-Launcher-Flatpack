#include "../include/thememanager.h"

#include <QDebug>
#include <QFile>
#include <QRegularExpression>
#include <QResource>
#include <QUrl>

namespace {

QVariantMap readBundled(const QString &resourcePath) {
  QFile f(resourcePath);
  if (!f.open(QIODevice::ReadOnly | QIODevice::Text)) {
    return {};
  }
  return ThemeManager::parseCssVariables(QString::fromUtf8(f.readAll()));
}

QString normalizeBundledThemeName(const QString &themeName) {
  QString key = themeName.trimmed().toUpper();
  if (key == QLatin1String("LIGTH"))
    key = QStringLiteral("LIGHT");
  if (key == QLatin1String("CLARO"))
    return QStringLiteral("LIGHT");
  if (key == QLatin1String("OSCURO"))
    return QStringLiteral("DARK");
  return key;
}

} // namespace

ThemeManager::ThemeManager(QObject *parent) : QObject(parent) {
  m_colors = readBundled(":/themes/dark.css");
  m_currentSource = QStringLiteral("bundled:DARK");
}

void ThemeManager::setError(const QString &e) {
  m_lastError = e;
  emit lastErrorChanged();
}

QString ThemeManager::normalizeVarName(const QString &rawName) {
  QString n = rawName.trimmed();
  if (n.startsWith(QLatin1String("--")))
    n = n.mid(2);
  return n.replace(QLatin1Char('-'), QLatin1Char('_'));
}

QVariantMap ThemeManager::parseCssVariables(const QString &content) {
  QVariantMap out;
  QString stripped;
  stripped.reserve(content.size());
  bool inLineComment = false;
  bool blockComment = false;
  for (int i = 0; i < content.size(); ++i) {
    const QChar c = content.at(i);
    if (blockComment) {
      if (c == QLatin1Char('*') && i + 1 < content.size() &&
          content.at(i + 1) == QLatin1Char('/')) {
        blockComment = false;
        ++i;
      }
      continue;
    }
    if (inLineComment) {
      if (c == QLatin1Char('\n') || c == QLatin1Char('\r'))
        inLineComment = false;
      continue;
    }
    if (c == QLatin1Char('/') && i + 1 < content.size()) {
      if (content.at(i + 1) == QLatin1Char('/')) {
        inLineComment = true;
        ++i;
        continue;
      }
      if (content.at(i + 1) == QLatin1Char('*')) {
        blockComment = true;
        ++i;
        continue;
      }
    }
    stripped.append(c);
  }

  static const QRegularExpression re(
      QStringLiteral(R"(--([\w-]+)\s*:\s*([^;]+);)"));
  QRegularExpressionMatchIterator it = re.globalMatch(stripped);
  while (it.hasNext()) {
    QRegularExpressionMatch m = it.next();
    const QString key = normalizeVarName(m.captured(1));
    QString val = m.captured(2).trimmed();
    if (!key.isEmpty() && !val.isEmpty())
      out.insert(key, val);
  }
  return out;
}

void ThemeManager::mergeMap(QVariantMap &dest, const QVariantMap &overrides) {
  for (auto it = overrides.constBegin(); it != overrides.constEnd(); ++it)
    dest.insert(it.key(), it.value());
}

bool ThemeManager::loadFromResourcePath(const QString &resourcePath,
                                        const QString &sourceLabel) {
  m_lastError.clear();
  emit lastErrorChanged();
  QVariantMap bundled = readBundled(resourcePath);
  if (bundled.isEmpty()) {
    setError(QStringLiteral("No se pudo leer el recurso: ") + resourcePath);
    return false;
  }
  m_colors = bundled;
  m_currentSource = sourceLabel;
  emit themeChanged();
  return true;
}

bool ThemeManager::loadBundledTheme(const QString &themeName) {
  const QString normalized = normalizeBundledThemeName(themeName);
  if (normalized == QLatin1String("LIGHT"))
    return loadFromResourcePath(QStringLiteral(":/themes/light.css"),
                                QStringLiteral("bundled:LIGHT"));
  return loadFromResourcePath(QStringLiteral(":/themes/dark.css"),
                              QStringLiteral("bundled:DARK"));
}

bool ThemeManager::loadFromFile(const QString &path) {
  m_lastError.clear();
  emit lastErrorChanged();
  QString localPath = path;
  const QUrl u(path);
  if (u.isLocalFile())
    localPath = u.toLocalFile();
  QFile f(localPath);
  if (!f.exists()) {
    setError(QStringLiteral("El archivo no existe: ") + localPath);
    return false;
  }
  if (!f.open(QIODevice::ReadOnly | QIODevice::Text)) {
    setError(QStringLiteral("No se pudo abrir: ") + localPath);
    return false;
  }
  const QString content = QString::fromUtf8(f.readAll());
  QVariantMap parsed = parseCssVariables(content);
  if (parsed.isEmpty()) {
    setError(QStringLiteral("No se encontraron variables CSS (--nombre: valor;)"));
    return false;
  }
  QVariantMap base = readBundled(QStringLiteral(":/themes/dark.css"));
  mergeMap(base, parsed);
  m_colors = base;
  m_currentSource = localPath;
  emit themeChanged();
  qDebug() << "[ThemeManager] Tema cargado desde archivo:" << localPath;
  return true;
}

bool ThemeManager::saveBundledDarkTemplateTo(const QString &destinationPath) {
  m_lastError.clear();
  emit lastErrorChanged();
  QFile src(QStringLiteral(":/themes/dark.css"));
  if (!src.open(QIODevice::ReadOnly | QIODevice::Text)) {
    setError(QStringLiteral("No se pudo leer la plantilla embebida"));
    return false;
  }
  const QByteArray data = src.readAll();
  QString localPath = destinationPath;
  const QUrl du(destinationPath);
  if (du.isLocalFile())
    localPath = du.toLocalFile();
  QFile dst(localPath);
  if (!dst.open(QIODevice::WriteOnly | QIODevice::Truncate | QIODevice::Text)) {
    setError(QStringLiteral("No se pudo escribir: ") + localPath);
    return false;
  }
  if (dst.write(data) < 0) {
    setError(QStringLiteral("Error al escribir el archivo"));
    return false;
  }
  dst.close();
  qDebug() << "[ThemeManager] Plantilla dark guardada en:" << localPath;
  return true;
}

