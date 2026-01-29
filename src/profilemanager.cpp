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

void ProfileManager::addProfileWithSettings(const QString &name, const QString &language, 
                                           const QString &theme, double scale)
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
    newProfile["language"] = language;
    newProfile["theme"] = theme;
    newProfile["scale"] = scale;
    newProfile["created"] = QDateTime::currentDateTime().toString(Qt::ISODate);
    
    m_profiles.append(newProfile);
    saveProfiles();
    emit profilesChanged();
    
    qDebug() << "[ProfileManager] Perfil agregado con configuraci\u00f3n:" << name 
             << "Language:" << language << "Theme:" << theme << "Scale:" << scale;
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
    // Sincronizar QSettings para asegurar que se leen cambios recientes
    m_settings->sync();
    
    m_profiles.clear();
    
    int size = m_settings->beginReadArray("profiles");
    for (int i = 0; i < size; ++i) {
        m_settings->setArrayIndex(i);
        QVariantMap profile;
        QString profileName = m_settings->value("name").toString();
        profile["name"] = profileName;
        profile["version"] = m_settings->value("version", "latest").toString();
        profile["created"] = m_settings->value("created").toString();
        
        m_profiles.append(profile);
    }
    m_settings->endArray();
    
    // Ahora cargar los valores de configuración (language, theme, scale)
    // que pueden estar guardados por LauncherBackend::saveProfileSettings()
    for (int i = 0; i < m_profiles.size(); ++i) {
        QVariantMap profile = m_profiles[i].toMap();
        QString profileName = profile["name"].toString();
        
        QString langKey = QString("profile/%1/language").arg(profileName);
        QString themeKey = QString("profile/%1/theme").arg(profileName);
        QString scaleKey = QString("profile/%1/scale").arg(profileName);
        
        // Cargar del archivo si existe, si no, usar valores por defecto
        profile["language"] = m_settings->value(langKey, "EN").toString();
        profile["theme"] = m_settings->value(themeKey, "DARK").toString();
        profile["scale"] = m_settings->value(scaleKey, 1.0).toDouble();
        
        m_profiles[i] = profile;
        
        qDebug() << "[ProfileManager] Perfil cargado:" << profileName 
                 << "Language:" << profile["language"] 
                 << "Theme:" << profile["theme"] 
                 << "Scale:" << profile["scale"];
    }
    
    // Si no hay perfiles, crear uno por defecto
    if (m_profiles.isEmpty()) {
        addProfile("Default", "latest");
    }
    
    // Cargar perfil actual
    m_currentProfile = m_settings->value("currentProfile", "Default").toString();
    
    qDebug() << "[ProfileManager] Cargados" << m_profiles.size() << "perfiles";
}

void ProfileManager::reloadProfiles()
{
    qDebug() << "[ProfileManager] Iniciando reloadProfiles()";
    QString currentProfileName = m_currentProfile;
    loadProfiles();
    emit profilesChanged();
    // Emitir cambio de perfil actual para que los componentes se actualicen
    emit currentProfileChanged(currentProfileName);
    qDebug() << "[ProfileManager] Perfiles recargados exitosamente";
}

void ProfileManager::saveProfiles()
{
    m_settings->beginWriteArray("profiles");
    for (int i = 0; i < m_profiles.size(); ++i) {
        m_settings->setArrayIndex(i);
        QVariantMap profile = m_profiles[i].toMap();
        m_settings->setValue("name", profile["name"]);
        m_settings->setValue("version", profile.value("version", "latest"));
        m_settings->setValue("created", profile["created"]);
        m_settings->setValue("language", profile.value("language", "EN"));
        m_settings->setValue("theme", profile.value("theme", "DARK"));
        m_settings->setValue("scale", profile.value("scale", 1.0));
    }
    m_settings->endArray();
    m_settings->sync();
}
