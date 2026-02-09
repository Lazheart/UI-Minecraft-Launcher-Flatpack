import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import "../Media.js" as Media
import "cards"

Rectangle {
    color: "#1e1e1e"
    
    // Property to track selected version
    property string selectedVersion: ""

    onSelectedVersionChanged: {
        console.log("[HomePage] selectedVersion changed to:", selectedVersion)
    }
    
    // Señal para abrir el diálogo de instalación
    signal installVersionRequested()

    function getVersionBackground(versionName) {
        if (!versionName) return Media.DefaultVersionBackground;
        
        var versions = minecraftManager.availableVersions;
        var count = versions.length;
        for (var i = 0; i < count; i++) {
            var v = versions[i];
            if (v.name === versionName && v.background) {
                return v.background;
            }
        }
        
        return Media.VersionBackgrounds[versionName] || Media.DefaultVersionBackground;
    }
    
    ScrollView {
        id: homeScroll
        anchors.fill: parent
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        // Estado cuando no hay Minecraft instalado
        HomeEmptyState {
            id: emptyState
            anchors.fill: parent
            visible: !minecraftManager.isInstalled
            availableWidth: homeScroll.availableWidth
            availableHeight: homeScroll.availableHeight

            onInstallRequested: installVersionRequested()
        }

        // Dashboard cuando hay Minecraft instalado y no hay versión seleccionada
        HomeDashboard {
            id: dashboardView
            anchors.fill: parent
            visible: minecraftManager.isInstalled && selectedVersion === ""

            onVersionSelected: selectedVersion = versionName
        }

        // Vista de versión seleccionada
        HomeVersionSelected {
            id: versionSelectedView
            anchors.fill: parent
            visible: minecraftManager.isInstalled && selectedVersion !== ""
            availableHeight: homeScroll.availableHeight
            versionName: selectedVersion

            onBackRequested: selectedVersion = ""
        }
    }
}
