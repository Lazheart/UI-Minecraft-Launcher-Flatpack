#include "../include/versionsapihandler.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDebug>

VersionsApiHandler::VersionsApiHandler(QObject *parent)
    : QObject(parent), m_networkManager(new QNetworkAccessManager(this)) {}

void VersionsApiHandler::fetchVersions() {
  if (m_isLoading)
    return;

  m_isLoading = true;
  emit isLoadingChanged();

  QNetworkRequest request{QUrl(API_VERSIONS_LIST)};
  QNetworkReply *reply = m_networkManager->get(request);

  connect(reply, &QNetworkReply::finished, this, [this, reply]() {
    onReplyFinished(reply);
  });
}

void VersionsApiHandler::onReplyFinished(QNetworkReply *reply) {
  m_isLoading = false;
  emit isLoadingChanged();

  if (reply->error() == QNetworkReply::NoError) {
    parseAndSortVersions(reply->readAll());
  } else {
    emit errorOccurred(reply->errorString());
    qWarning() << "[VersionsApiHandler] API Error:" << reply->errorString();
    
    // Fallback for testing development if the API is not available
    // parseAndSortVersions("{\"versions\": [\"1.14.1\", \"1.12.1\", \"1.2.13\", \"1.20\", \"1.20.0.1\"]}");
  }

  reply->deleteLater();
}

bool VersionsApiHandler::compareVersions(const QString &v1, const QString &v2) {
  QStringList parts1 = v1.split('.');
  QStringList parts2 = v2.split('.');

  int maxParts = std::max(parts1.size(), parts2.size());

  for (int i = 0; i < maxParts; ++i) {
    int n1 = (i < parts1.size()) ? parts1[i].toInt() : 0;
    int n2 = (i < parts2.size()) ? parts2[i].toInt() : 0;

    if (n1 > n2)
      return true; // v1 is newer
    if (n1 < n2)
      return false; // v2 is newer
  }

  return false; // Equal
}

void VersionsApiHandler::parseAndSortVersions(const QByteArray &data) {
  QJsonDocument doc = QJsonDocument::fromJson(data);
  if (!doc.isObject())
    return;

  QJsonObject obj = doc.object();
  if (!obj.contains("versions"))
    return;

  QJsonArray versionsArray = obj["versions"].toArray();
  QStringList rawVersions;
  for (const QJsonValue &val : versionsArray) {
    rawVersions << val.toString();
  }

  // Sort: newer to older (reverse order of compareVersions)
  std::sort(rawVersions.begin(), rawVersions.end(), compareVersions);

  m_versions = rawVersions;
  emit versionsChanged();
}
