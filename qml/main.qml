import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtGraphicalEffects 1.15

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 1200
    height: 800
    minimumWidth: 1000
    minimumHeight: 700
    title: "Enkidu Launcher"
    
    readonly property color backgroundColor: "#1e1e1e"
    readonly property color surfaceColor: "#2d2d2d"
    readonly property color accentColor: "#4CAF50"
    readonly property color textColor: "#ffffff"
    readonly property color secondaryTextColor: "#b0b0b0"
    
    property string currentPage: "Home"
    property bool sidebarVisible: true
    
    Component.onCompleted: {
        console.log("[QML] Launcher iniciado")
        console.log("[QML] Versión:", launcherBackend.version)
        minecraftManager.checkInstallation()
    }
    
    Connections {
        target: launcherBackend
        
        function onGameStarted() {
            showNotification("Game Started", "Minecraft is now running", "info")
            console.log("[QML] Juego iniciado")
        }
        
        function onGameStopped() {
            showNotification("Game Stopped", "Minecraft has been closed", "info")
            console.log("[QML] Juego detenido")
        }
        
        function onErrorOccurred(error) {
            showNotification("Error", error, "error")
        }
    }
    
    function showNotification(title, message, type) {
        notificationDialog.notificationTitle = title
        notificationDialog.notificationMessage = message
        notificationDialog.notificationType = type
        notificationDialog.open()
    }
    
    // Fondo
    Rectangle {
        anchors.fill: parent
        color: backgroundColor
    }
    
    // Diálogo de notificación
    Dialog {
        id: notificationDialog
        anchors.centerIn: parent
        
        property string notificationType: "info"
        property string notificationTitle: ""
        property string notificationMessage: ""
        
        contentItem: Rectangle {
            implicitWidth: 400
            implicitHeight: 200
            color: surfaceColor
            radius: 10
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15
                
                Text {
                    text: notificationDialog.notificationTitle
                    font.pixelSize: 18
                    font.bold: true
                    color: notificationDialog.notificationType === "error" ? "#f44336" : accentColor
                }
                
                Text {
                    text: notificationDialog.notificationMessage
                    font.pixelSize: 14
                    color: textColor
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
                
                Button {
                    Layout.alignment: Qt.AlignRight
                    text: "OK"
                    
                    background: Rectangle {
                        color: parent.pressed ? "#388E3C" : accentColor
                        radius: 4
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: textColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    onClicked: notificationDialog.close()
                }
            }
        }
    }

    InstallVersionDialog {
        id: installVersionDialog
        parent: mainWindow.contentItem
        anchorItem: stackView
        backgroundColor: "#171515"
        surfaceColor: "#0f0f0f"
        accentColor: mainWindow.accentColor
        textColor: mainWindow.textColor
        secondaryTextColor: mainWindow.secondaryTextColor

        onInstallRequested: function(name, apkPath, useDefaultIcon, iconPath, useDefaultBackground, backgroundPath) {
            launcherBackend.installVersion(name, apkPath, iconPath, backgroundPath, useDefaultIcon, useDefaultBackground)
        }
    }

    DeleteVersionDialog {
        id: deleteVersionDialog
        parent: mainWindow.contentItem
        anchorItem: stackView
        backgroundColor: "#171515"
        surfaceColor: "#0f0f0f"
        accentColor: mainWindow.accentColor
        textColor: mainWindow.textColor
        secondaryTextColor: mainWindow.secondaryTextColor
        deleteColor: "#f44336"

        onDeleteRequested: function(versions) {
            for (let i = 0; i < versions.length; i++) {
                minecraftManager.deleteVersion(versions[i])
            }
            showNotification("Success", "Selected versions deleted successfully", "info")
        }
    }

    ImportWorldsAddonsCard {
        id: importWorldsAddonsCard
        parent: mainWindow.contentItem
        anchors.centerIn: Overlay.overlay
        
        onImportRequested: function(path, type) {
            // Get the currently selected version from HomePage
            var selectedVersion = ""
            if (stackView.itemAt(0)) {
                selectedVersion = stackView.itemAt(0).selectedVersion
            }
            
            // If no version is selected, use the installed version
            if (selectedVersion === "") {
                selectedVersion = minecraftManager.installedVersion
            }
            
            if (selectedVersion === "") {
                showNotification("Error", "No version selected", "error")
                console.log("[QML] Import failed: No version selected")
                return
            }
            
            console.log("[QML] Import requested - Type:", type, "Path:", path, "Version:", selectedVersion)
            
            if (type === "World") {
                launcherBackend.importWorld(path, selectedVersion)
            } else if (type === "Addon") {
                launcherBackend.importPack(path, selectedVersion)
            } else {
                showNotification("Error", "Unknown import type: " + type, "error")
            }
        }

        onClosed: {
            console.log("[QML] Import card closed")
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
        // NavBar
        NavBar {
            id: navBar
            Layout.fillWidth: true
            
            currentPage: mainWindow.currentPage
            
            onNavigate: function(page) {
                mainWindow.currentPage = page
                stackView.currentIndex = getPageIndex(page)
            }
            
            onToggleSidebar: mainWindow.sidebarVisible = !mainWindow.sidebarVisible
        }
        
        // Contenedor principal: SideBar + Contenido
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0
            
            // SideBar
            SideBar {
                id: sideBar
                Layout.preferredWidth: mainWindow.sidebarVisible ? 280 : 0
                Layout.fillHeight: true
                visible: mainWindow.sidebarVisible
                clip: true

                Behavior on Layout.preferredWidth {
                    NumberAnimation { duration: 300 }
                }

                onAddVersionsRequested: installVersionDialog.open()
                onDeleteVersionsRequested: deleteVersionDialog.open()
                onImportWorldsAddonsRequested: importWorldsAddonsCard.show()
                onVersionSelected: function(version) {
                    if (stackView.itemAt(0)) {
                        stackView.itemAt(0).selectedVersion = version
                    }
                }
            }
            
            // Contenido principal
            StackLayout {
                id: stackView
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: 0
                
                HomePage { 
                    onInstallVersionRequested: installVersionDialog.open()
                }
                SettingsPage { }
                AboutPage { }
            }
        }
    }
    
    function getPageIndex(page) {
        switch(page) {
            case "Home": return 0
            case "Settings": return 1
            case "About": return 2
            default: return 0
        }
    }
}
