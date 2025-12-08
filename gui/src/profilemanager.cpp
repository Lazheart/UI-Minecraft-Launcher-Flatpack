#include "../include/profilemanager.h"
#include <QDebug>
#include <QDateTime>

ProfileManager::ProfileManager(QObject *parent)
    : QObject(parent)
    , m_currentProfile("Default")
{
    m_settings = new QSettings(
        QSettings::IniFormat,
        QSettings::UserScope,
        "org.lazheart",
        "minecraft-launcher",
        this
    );
    
    loadProfiles();
}

QVariantList ProfileManager::profiles() const
{
    return m_profiles;
}

QString ProfileManager::currentProfile() const
{
    return m_currentProfile;
}

void ProfileManager::setCurrentProfile(const QString &profile)
{
    if (m_currentProfile != profile) {
        m_currentProfile = profile;
        m_settings->setValue("currentProfile", profile);
        emit currentProfileChanged(profile);
        qDebug() << "[ProfileManager] Perfil cambiado a:" << profile;
    }
}

void ProfileManager::addProfile(const QString &name, const QString &version)
{
    if (name.isEmpty()) {
        qWarning() << "[ProfileManager] No se puede agregar un perfil sin nombre";
        return;
    }
    
    // Verificar si ya existe
    for (const QVariant &profileVar : m_profiles) {
        QVariantMap profile = profileVar.toMap();
        if (profile["name"].toString() == name) {
            qWarning() << "[ProfileManager] El perfil ya existe:" << name;
            return;
        }
    }
    
    QVariantMap newProfile;
    newProfile["name"] = name;
    newProfile["version"] = version.isEmpty() ? "latest" : version;
    newProfile["created"] = QDateTime::currentDateTime().toString(Qt::ISODate);
    
    m_profiles.append(newProfile);
    saveProfiles();
    emit profilesChanged();
    
    qDebug() << "[ProfileManager] Perfil agregado:" << name;
}

void ProfileManager::removeProfile(const QString &name)
{
    for (int i = 0; i < m_profiles.size(); ++i) {
        QVariantMap profile = m_profiles[i].toMap();
        if (profile["name"].toString() == name) {
            m_profiles.removeAt(i);
            saveProfiles();
            emit profilesChanged();
            qDebug() << "[ProfileManager] Perfil eliminado:" << name;
            
            // Si era el perfil actual, cambiar a Default
            if (m_currentProfile == name) {
                setCurrentProfile("Default");
            }
            return;
        }
    }
}

QVariantMap ProfileManager::getProfile(const QString &name) const
{
    for (const QVariant &profileVar : m_profiles) {
        QVariantMap profile = profileVar.toMap();
        if (profile["name"].toString() == name) {
            return profile;
        }
    }
    return QVariantMap();
}

void ProfileManager::updateProfile(const QString &name, const QVariantMap &data)
{
    for (int i = 0; i < m_profiles.size(); ++i) {
        QVariantMap profile = m_profiles[i].toMap();
        if (profile["name"].toString() == name) {
            // Actualizar solo los campos proporcionados
            for (auto it = data.begin(); it != data.end(); ++it) {
                profile[it.key()] = it.value();
            }
            m_profiles[i] = profile;
            saveProfiles();
            emit profilesChanged();
            qDebug() << "[ProfileManager] Perfil actualizado:" << name;
            return;
        }
    }
}

void ProfileManager::loadProfiles()
{
    m_profiles.clear();
    
    int size = m_settings->beginReadArray("profiles");
    for (int i = 0; i < size; ++i) {
        m_settings->setArrayIndex(i);
        QVariantMap profile;
        profile["name"] = m_settings->value("name").toString();
        profile["version"] = m_settings->value("version", "latest").toString();
        profile["created"] = m_settings->value("created").toString();
        m_profiles.append(profile);
    }
    m_settings->endArray();
    
    // Si no hay perfiles, crear uno por defecto
    if (m_profiles.isEmpty()) {
        addProfile("Default", "latest");
    }
    
    // Cargar perfil actual
    m_currentProfile = m_settings->value("currentProfile", "Default").toString();
    
    qDebug() << "[ProfileManager] Cargados" << m_profiles.size() << "perfiles";
}

void ProfileManager::saveProfiles()
{
    m_settings->beginWriteArray("profiles");
    for (int i = 0; i < m_profiles.size(); ++i) {
        m_settings->setArrayIndex(i);
        QVariantMap profile = m_profiles[i].toMap();
        m_settings->setValue("name", profile["name"]);
        m_settings->setValue("version", profile["version"]);
        m_settings->setValue("created", profile["created"]);
    }
    m_settings->endArray();
    m_settings->sync();
}
