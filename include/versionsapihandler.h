#ifndef VERSIONSAPIHANDLER_H
#define VERSIONSAPIHANDLER_H

#include <QObject>
#include <QStringList>
#include <QNetworkAccessManager>
#include <QNetworkReply>

class VersionsApiHandler : public QObject {
  Q_OBJECT
  Q_PROPERTY(QStringList versions READ versions NOTIFY versionsChanged)
  Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)

public:
  explicit VersionsApiHandler(QObject *parent = nullptr);

  QStringList versions() const { return m_versions; }
  bool isLoading() const { return m_isLoading; }

  Q_INVOKABLE void fetchVersions();

signals:
  void versionsChanged();
  void isLoadingChanged();
  void errorOccurred(const QString &error);

private slots:
  void onReplyFinished(QNetworkReply *reply);

private:
  void parseAndSortVersions(const QByteArray &data);
  static bool compareVersions(const QString &v1, const QString &v2);

  QStringList m_versions;
  bool m_isLoading = false;
  QNetworkAccessManager *m_networkManager;
  const QString API_VERSIONS_LIST = "https://mcbedrock.com/api/versions";
};

#endif // VERSIONSAPIHANDLER_H
