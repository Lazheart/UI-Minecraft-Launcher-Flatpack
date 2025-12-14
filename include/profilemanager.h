#ifndef PROFILEMANAGER_H
#define PROFILEMANAGER_H

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QSettings>

class ProfileManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList profiles READ profiles NOTIFY profilesChanged)
    Q_PROPERTY(QString currentProfile READ currentProfile WRITE setCurrentProfile NOTIFY currentProfileChanged)

public:
    explicit ProfileManager(QObject *parent = nullptr);

    QVariantList profiles() const;
    QString currentProfile() const;
    void setCurrentProfile(const QString &profile);

    Q_INVOKABLE void addProfile(const QString &name, const QString &version = QString());
    Q_INVOKABLE void addProfileWithSettings(const QString &name, const QString &language, 
                                           const QString &theme, double scale);
    Q_INVOKABLE void removeProfile(const QString &name);
    Q_INVOKABLE QVariantMap getProfile(const QString &name) const;
    Q_INVOKABLE void updateProfile(const QString &name, const QVariantMap &data);
    Q_INVOKABLE void reloadProfiles();

signals:
    void profilesChanged();
    void currentProfileChanged(const QString &profile);

private:
    QSettings *m_settings;
    QVariantList m_profiles;
    QString m_currentProfile;

    void loadProfiles();
    void saveProfiles();
};

#endif // PROFILEMANAGER_H
