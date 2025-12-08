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
        }
        
        // Contenedor principal: SideBar + Contenido
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0
            
            // SideBar
            SideBar {
                Layout.preferredWidth: 280
                Layout.fillHeight: true
            }
            
            // Contenido principal
            StackLayout {
                id: stackView
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: 0
                
                HomePage { }
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
