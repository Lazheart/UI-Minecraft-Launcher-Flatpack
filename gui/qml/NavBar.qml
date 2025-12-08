import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: navBar
    height: 80
    color: "#2d2d2d"
    
    // Signal para cambiar de página
    signal navigate(string page)
    
    property string currentPage: "Home"
    
    RowLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 20
        
        // Logo y nombre
        RowLayout {
            Layout.preferredWidth: 250
            spacing: 10
            
            Image {
                Layout.preferredWidth: 50
                Layout.preferredHeight: 50
                source: "file:///home/lazheart/Escritorio/UI-Minecraft-Launcher-Flatpack/assets/media/logo.svg"
                cache: true
                
                Rectangle {
                    anchors.fill: parent
                    color: "#4CAF50"
                    radius: 8
                    visible: parent.status !== Image.Ready
                    
                    Text {
                        anchors.centerIn: parent
                        text: "EL"
                        font.pixelSize: 24
                        font.bold: true
                        color: "#ffffff"
                    }
                }
            }
            
            Text {
                text: "Enkidu Launcher"
                font.pixelSize: 20
                font.bold: true
                color: "#ffffff"
                Layout.fillWidth: true
            }
        }
        
        // Espaciador
        Item {
            Layout.fillWidth: true
        }
        
        // Botones de navegación
        RowLayout {
            spacing: 10
            
            NavBarButton {
                text: "Home"
                isActive: navBar.currentPage === "Home"
                onClicked: {
                    navBar.currentPage = "Home"
                    navBar.navigate("Home")
                }
            }
            
            NavBarButton {
                text: "Settings"
                isActive: navBar.currentPage === "Settings"
                onClicked: {
                    navBar.currentPage = "Settings"
                    navBar.navigate("Settings")
                }
            }
            
            NavBarButton {
                text: "About"
                isActive: navBar.currentPage === "About"
                onClicked: {
                    navBar.currentPage = "About"
                    navBar.navigate("About")
                }
            }
        }
    }
}
