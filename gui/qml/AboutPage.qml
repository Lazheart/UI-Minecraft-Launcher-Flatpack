import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    color: "#1e1e1e"
    
    ScrollView {
        anchors.fill: parent
        clip: true
        
        ColumnLayout {
            width: parent.width
            spacing: 20
            anchors.margins: 30
            
            Text {
                text: "About Enkidu Launcher"
                font.pixelSize: 32
                font.bold: true
                color: "#ffffff"
                Layout.topMargin: 20
            }
            
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                color: "#2d2d2d"
                radius: 8
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15
                    
                    Text {
                        text: "Minecraft Bedrock Launcher"
                        font.pixelSize: 18
                        font.bold: true
                        color: "#4CAF50"
                    }
                    
                    Text {
                        text: "Version: " + launcherBackend.version
                        color: "#b0b0b0"
                        font.pixelSize: 12
                    }
                    
                    Text {
                        text: "A modern Qt Quick/QML interface for launching Minecraft Bedrock Edition on Linux."
                        color: "#b0b0b0"
                        font.pixelSize: 12
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                color: "#2d2d2d"
                radius: 8
                Layout.preferredHeight: 150
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 10
                    
                    Text {
                        text: "Features"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#ffffff"
                    }
                    
                    Text {
                        text: "✓ Modern Qt Quick/QML UI\n✓ Profile Management\n✓ Real-time Logging\n✓ Flatpak Integration"
                        color: "#b0b0b0"
                        font.pixelSize: 11
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                }
            }
            
            Item { Layout.fillHeight: true }
        }
    }
}
