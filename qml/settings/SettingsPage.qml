import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "cards"

Rectangle {
    id: settingsPage
    color: themeManager.colors["settings_page_bg"]

    // Propiedades para capturar los valores actuales
    property string currentLanguage: "EN"
    property string currentTheme: "DARK"
    property real currentScale: 1.0

    function normalizeBundledTheme(themeValue) {
        var raw = String(themeValue || "").trim()
        var upper = raw.toUpperCase()

        if (upper === "LIGTH")
            upper = "LIGHT"

        if (upper === "LIGHT" || upper === "CLARO")
            return "LIGHT"
        if (upper === "DARK" || upper === "OSCURO")
            return "DARK"

        return raw
    }

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
                var customThemePath = profileData.customThemePath ? String(profileData.customThemePath) : ""
                var scale = profileData.scale || 1.0

                if (customThemePath.length === 0)
                    theme = normalizeBundledTheme(theme)
                
                languageCard.currentLanguage = language
                visualCard.currentTheme = theme
                visualCard.scaleValue = scale
                
                settingsPage.currentLanguage = language
                settingsPage.currentTheme = theme
                settingsPage.currentScale = scale
                
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
                var customThemePath = profileData.customThemePath ? String(profileData.customThemePath) : ""
                var scale = profileData.scale || 1.0

                if (customThemePath.length === 0)
                    theme = normalizeBundledTheme(theme)
                
                languageCard.currentLanguage = language
                visualCard.currentTheme = theme
                visualCard.scaleValue = scale
                
                settingsPage.currentLanguage = language
                settingsPage.currentTheme = theme
                settingsPage.currentScale = scale
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
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOn
        ScrollBar.vertical.policy: ScrollBar.AlwaysOn
        contentHeight: contentLayout.implicitHeight + 80
        contentWidth: Math.max(scrollView.availableWidth, contentLayout.implicitWidth + 80)

        Item {
            width: Math.max(scrollView.availableWidth, contentLayout.implicitWidth + 80)
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
                    text: qsTr("Settings")
                    font.pixelSize: 36
                    font.bold: true
                    color: themeManager.colors["text_primary"]
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                // Primera fila: Language y Profiles adaptable (GridLayout)
                GridLayout {
                    Layout.fillWidth: true
                    columns: contentLayout.width > 1100 ? 2 : 1
                    rowSpacing: 20
                    columnSpacing: 20

                    LanguageCard {
                        id: languageCard
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop
                        onLanguageChanged: (language) => {
                            settingsPage.currentLanguage = language
                            translator.setLanguage(language)
                            // Persist to profile manager for current profile
                            profileManager.updateProfile(profileManager.currentProfile, { language: language })
                        }
                    }

                    ProfilesCard {
                        id: profilesCard
                        Layout.preferredWidth: parent.columns === 2 ? 300 : -1
                        Layout.fillWidth: parent.columns === 1
                        Layout.alignment: Qt.AlignTop
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
                        settingsPage.currentScale = scale
                        profileManager.updateProfile(profileManager.currentProfile, { scale: scale })
                    }
                    onThemeChanged: (theme) => {
                        settingsPage.currentTheme = theme
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
                        text: qsTr("SAVE")
                        Layout.preferredWidth: 150
                        Layout.preferredHeight: 45

                        background: Rectangle {
                            color: parent.pressed ? themeManager.colors["accent_pressed"] : themeManager.colors["accent"]
                            radius: 4
                        }

                        contentItem: Text {
                            text: parent.text
                            color: themeManager.colors["text_primary"]
                            font.pixelSize: 13
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            // Actualizar el perfil actual con la configuración
                            profileManager.updateProfile(profileManager.currentProfile, {
                                language: languageCard.currentLanguage,
                                theme: visualCard.currentTheme,
                                scale: visualCard.scaleValue
                            })
                            // Guardar los cambios en el archivo
                            profileManager.saveProfiles()
                            console.log("[Settings] Settings saved to disk for profile:", profileManager.currentProfile)
                        }
                    }

                    Button {
                        text: qsTr("RESET TO DEFAULT") 
                        Layout.preferredWidth: 180
                        Layout.preferredHeight: 45

                        background: Rectangle {
                            color: parent.pressed ? themeManager.colors["error_dark"] : themeManager.colors["error"]
                            radius: 4
                        }

                        contentItem: Text {
                            text: parent.text
                            color: themeManager.colors["text_primary"]
                            font.pixelSize: 13
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            // Cargar la última configuración guardada
                            profileManager.reloadProfiles()
                            console.log("[Settings] Settings reset to last saved state")
                        }
                    }

                    Item { Layout.fillWidth: true }
                }

                Item { Layout.fillHeight: true; Layout.minimumHeight: 20 }
            }
        }
    }
}
