import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../Media.js" as Media

Rectangle {
    id: navBar
    height: 80
    color: "#121111"
    
    // Signal para cambiar de página
    signal navigate(string page)
    signal toggleSidebar()
    
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
                source: Media.LogoImage
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
                text: "Kon Launcher"
                font.pixelSize: 20
                font.bold: true
                color: "#ffffff"
                Layout.fillWidth: true
            }
        }
        
        // Botón toggle sidebar
        Button {
            Layout.preferredWidth: 50
            Layout.preferredHeight: 50
            
            background: Rectangle {
                color: parent.hovered ? "#2d2d2d" : "#1e1e1e"
                radius: 6
                border.color: parent.hovered ? "#4CAF50" : "transparent"
                border.width: 1
                Behavior on color { ColorAnimation { duration: 200 } }
            }
            
            contentItem: Text {
                text: "☰"
                font.pixelSize: 24
                color: "#4CAF50"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            
            onClicked: navBar.toggleSidebar()
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
                        navBar.navigate("Home")
                    }
            }
            
            
            NavBarButton {
                text: "Settings"
                isActive: navBar.currentPage === "Settings"
                onClicked: {
                    navBar.navigate("Settings")
                }
            }
            
            NavBarButton {
                text: "About"
                isActive: navBar.currentPage === "About"
                onClicked: {
                    navBar.navigate("About")
                }
            }
        }
    }
}
