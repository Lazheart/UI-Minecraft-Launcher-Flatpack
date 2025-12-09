import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: settingsPage
    color: "#1e1e1e"

    // Propiedades para capturar los valores actuales
    property string currentLanguage: "EN"
    property string currentTheme: "DARK"
    property real currentScale: 1.0

    // Timer para actualizar componentes después de recarga de perfiles
    Timer {
        id: updateComponentsTimer
        interval: 100
        running: false
        onTriggered: {
            var profileData = profileManager.getProfile(profileManager.currentProfile)
            if (profileData && profileData.name) {
                var language = profileData.language || "EN"
                var theme = profileData.theme || "DARK"
                var scale = profileData.scale || 1.0
                
                languageCard.currentLanguage = language
                visualCard.currentTheme = theme
                visualCard.scaleValue = scale
                
                settingsPage.currentLanguage = language
                settingsPage.currentTheme = theme
                settingsPage.currentScale = scale
                settingsPage.scale = scale
                
                qDebug() << "[SettingsPage] Componentes actualizados con valores del perfil"
            }
        }
    }

    // Escuchar cambios de perfil para actualizar los componentes visuales
    Connections {
        target: profileManager
        function onCurrentProfileChanged(profile) {
            var profileData = profileManager.getProfile(profile)
            if (profileData && profileData.name) {
                // Actualizar los componentes visuales con los valores del perfil
                var language = profileData.language || "EN"
                var theme = profileData.theme || "DARK"
                var scale = profileData.scale || 1.0
                
                languageCard.currentLanguage = language
                visualCard.currentTheme = theme
                visualCard.scaleValue = scale
                
                settingsPage.currentLanguage = language
                settingsPage.currentTheme = theme
                settingsPage.currentScale = scale
                settingsPage.scale = scale
            }
        }
        
        function onProfilesChanged() {
            // Cuando los perfiles cambian, actualizar los componentes después de un pequeño delay
            updateComponentsTimer.restart()
        }
    }

    ScrollView {
        id: scrollView
        anchors.fill: parent
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        contentHeight: contentLayout.implicitHeight + 80

        Item {
            width: scrollView.width
            height: Math.max(scrollView.height, contentLayout.implicitHeight + 80)

            ColumnLayout {
                id: contentLayout
                width: Math.min(parent.width - 60, 1200)
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 40
                spacing: 32

                // Título
                Text {
                    text: "Settings"
                    font.pixelSize: 36
                    font.bold: true
                    color: "#ffffff"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                // Primera fila: Language y Profiles lado a lado
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 20

                    LanguageCard {
                        id: languageCard
                        Layout.fillWidth: true
                        onLanguageChanged: (language) => {
                            settingsPage.currentLanguage = language
                            launcherBackend.setLanguage(language)
                        }
                    }

                    ProfilesCard {
                        id: profilesCard
                        Layout.preferredWidth: 300
                        settingsPageRef: settingsPage
                    }
                }

                // Paths Card
                PathsCard {
                    Layout.fillWidth: true
                }

                // Visual Card
                VisualCard {
                    id: visualCard
                    Layout.fillWidth: true
                    onScaleChanged: (scale) => {
                        settingsPage.scale = scale
                        settingsPage.currentScale = scale
                        launcherBackend.setScale(scale)
                    }
                    onThemeChanged: (theme) => {
                        settingsPage.currentTheme = theme
                        launcherBackend.setTheme(theme)
                    }
                }

                // Debug Card - Full width with more space
                DebugCard {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 500
                }

                // Action Buttons Row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15
                    Layout.topMargin: 20

                    Button {
                        text: "SAVE"
                        Layout.preferredWidth: 150
                        Layout.preferredHeight: 45

                        background: Rectangle {
                            color: parent.pressed ? "#388E3C" : "#4CAF50"
                            radius: 4
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "#ffffff"
                            font.pixelSize: 13
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            // Actualizar el perfil actual con la configuración
                            launcherBackend.saveProfileSettings(profileManager.currentProfile)
                            // Recargar los perfiles para reflejar los cambios
                            profileManager.reloadProfiles()
                            console.log("[Settings] Settings saved to profile:", profileManager.currentProfile)
                        }
                    }

                    Button {
                        text: "RESET TO DEFAULT"
                        Layout.preferredWidth: 180
                        Layout.preferredHeight: 45

                        background: Rectangle {
                            color: parent.pressed ? "#d32f2f" : "#f44336"
                            radius: 4
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "#ffffff"
                            font.pixelSize: 13
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            // Resetear a valores por defecto
                            launcherBackend.applyProfileSettings("EN", "DARK", 1.0)
                            languageCard.currentLanguage = "EN"
                            visualCard.scaleValue = 1.0
                            visualCard.currentTheme = "DARK"
                            settingsPage.scale = 1.0
                            settingsPage.currentLanguage = "EN"
                            settingsPage.currentTheme = "DARK"
                            settingsPage.currentScale = 1.0
                            console.log("[Settings] Settings reset to default")
                        }
                    }

                    Item { Layout.fillWidth: true }
                }

                Item { Layout.fillHeight: true; Layout.minimumHeight: 20 }
            }
        }
    }
}
