import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    color: "#2d2d2d"
    opacity: 0.95
    radius: 8
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 30
        spacing: 20
        
        // Información del juego
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            color: "#3d3d3d"
            radius: 8
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 10
                
                Text {
                    text: "Estado de Minecraft"
                    font.pixelSize: 16
                    font.bold: true
                    color: "#ffffff"
                }
                
                GridLayout {
                    columns: 2
                    columnSpacing: 15
                    rowSpacing: 8
                    
                    Text {
                        text: "Instalado:"
                        color: "#b0b0b0"
                        font.pixelSize: 13
                    }
                    Text {
                            text: minecraftManager.isInstalled ? "Sí" : "No"
                            color: minecraftManager.isInstalled ? "#4CAF50" : "#f44336"
                        font.pixelSize: 13
                        font.bold: true
                    }
                    
                    Text {
                        text: "Versión:"
                        color: "#b0b0b0"
                        font.pixelSize: 13
                    }
                    Text {
                        text: minecraftManager.installedVersion || "N/A"
                        color: "#ffffff"
                        font.pixelSize: 13
                    }
                    
                    Text {
                        text: "Directorio:"
                        color: "#b0b0b0"
                        font.pixelSize: 13
                    }
                    Text {
                        text: (typeof pathManager !== 'undefined') ? pathManager.versionsDir : ""
                        color: "#ffffff"
                        font.pixelSize: 11
                        elide: Text.ElideMiddle
                        Layout.fillWidth: true
                    }
                }
            }
        }
        
        // Espacio flexible
        Item {
            Layout.fillHeight: true
        }
        
        // Botones de acción
        RowLayout {
            Layout.fillWidth: true
            spacing: 15
            
            Button {
                id: playButton
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                text: "JUGAR"
                enabled: !minecraftManager.isRunning && minecraftManager.isInstalled
                
                background: Rectangle {
                    color: parent.enabled ? (parent.pressed ? "#388E3C" : "#4CAF50") : "#555555"
                    radius: 8
                }
                
                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 18
                    font.bold: true
                    color: parent.enabled ? "#ffffff" : "#888888"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: {
                    console.log("[QML] Iniciando juego con perfil:", profileManager.currentProfile)
                    minecraftManager.runGame(minecraftManager.installedVersion, "", profileManager.currentProfile)
                }
            }
            
            Button {
                id: stopButton
                Layout.preferredWidth: 150
                Layout.preferredHeight: 60
                text: "DETENER"
                enabled: minecraftManager.isRunning
                
                background: Rectangle {
                    color: parent.enabled ? (parent.pressed ? "#d32f2f" : "#f44336") : "#555555"
                    radius: 8
                }
                
                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 16
                    font.bold: true
                    color: parent.enabled ? "#ffffff" : "#888888"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: {
                    console.log("[QML] Deteniendo juego")
                    minecraftManager.stopGame()
                }
            }
        }
        
        // Mensaje de ayuda si no está instalado
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            color: "#FFA726"
            radius: 8
            visible: !minecraftManager.isInstalled
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15
                
                Text {
                    text: "⚠"
                    font.pixelSize: 32
                    color: "#ffffff"
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    
                    Text {
                        text: "Minecraft no está instalado"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#ffffff"
                    }
                    
                    Text {
                        text: "Por favor, instala Minecraft Bedrock para poder jugar"
                        font.pixelSize: 12
                        color: "#ffffff"
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }
}
