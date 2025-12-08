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
            
            // Título
            Text {
                text: "Welcome to Enkidu Launcher"
                font.pixelSize: 32
                font.bold: true
                color: "#ffffff"
                Layout.topMargin: 20
            }
            
            // Contenido condicional
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                
                // Si NO hay versión instalada
                ColumnLayout {
                    anchors.centerIn: parent
                    visible: !minecraftManager.isInstalled
                    spacing: 20
                    
                    Text {
                        text: "Install new version clicking on icon of"
                        font.pixelSize: 16
                        color: "#b0b0b0"
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 80
                        color: "#4CAF50"
                        radius: 8
                        
                        Text {
                            anchors.centerIn: parent
                            text: "B"
                            font.pixelSize: 48
                            font.bold: true
                            color: "#ffffff"
                        }
                    }
                    
                    Text {
                        text: "install new version"
                        font.pixelSize: 14
                        color: "#ffffff"
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
                
                // Si SÍ hay versión instalada
                ColumnLayout {
                    anchors.fill: parent
                    visible: minecraftManager.isInstalled
                    spacing: 20
                    
                    // Información del juego
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 150
                        color: "#2d2d2d"
                        radius: 8
                        
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 10
                            
                            Text {
                                text: "Minecraft Status"
                                font.pixelSize: 18
                                font.bold: true
                                color: "#ffffff"
                            }
                            
                            GridLayout {
                                columns: 2
                                columnSpacing: 15
                                rowSpacing: 8
                                Layout.fillWidth: true
                                
                                Text {
                                    text: "Installed:"
                                    color: "#b0b0b0"
                                }
                                Text {
                                    text: "Yes"
                                    color: "#4CAF50"
                                    font.bold: true
                                }
                                
                                Text {
                                    text: "Version:"
                                    color: "#b0b0b0"
                                }
                                Text {
                                    text: minecraftManager.installedVersion || "Latest"
                                    color: "#ffffff"
                                }
                            }
                        }
                    }
                    
                    // Botones de acción
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 15
                        
                        Button {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 60
                            text: "PLAY"
                            enabled: !launcherBackend.isRunning
                            
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
                                console.log("[Home] Launching game with profile:", profileManager.currentProfile)
                                launcherBackend.launchGame(profileManager.currentProfile)
                            }
                        }
                        
                        Button {
                            Layout.preferredWidth: 150
                            Layout.preferredHeight: 60
                            text: "STOP"
                            enabled: launcherBackend.isRunning
                            
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
                                console.log("[Home] Stopping game")
                                launcherBackend.stopGame()
                            }
                        }
                    }
                    
                    // Estado actual
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        color: launcherBackend.isRunning ? "#1b5e20" : "#3d3d3d"
                        radius: 8
                        
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 5
                            
                            Text {
                                text: "Current Status"
                                font.pixelSize: 14
                                font.bold: true
                                color: "#ffffff"
                            }
                            
                            Text {
                                text: launcherBackend.status
                                font.pixelSize: 16
                                color: launcherBackend.isRunning ? "#81C784" : "#b0b0b0"
                                font.bold: true
                            }
                        }
                    }
                    
                    Item { Layout.fillHeight: true }
                }
            }
            
            Item { Layout.fillHeight: true }
        }
    }
}
