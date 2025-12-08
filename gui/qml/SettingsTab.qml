import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    color: "#2d2d2d"
    opacity: 0.95
    radius: 8
    
    ScrollView {
        anchors.fill: parent
        anchors.margins: 20
        clip: true
        
        ColumnLayout {
            width: parent.width
            spacing: 25
            
            // Sección de perfiles
            GroupBox {
                Layout.fillWidth: true
                
                background: Rectangle {
                    color: "#3d3d3d"
                    radius: 8
                    border.color: "#4d4d4d"
                }
                
                label: Text {
                    text: "Perfiles"
                    color: "#ffffff"
                    font.pixelSize: 16
                    font.bold: true
                    padding: 10
                }
                
                ColumnLayout {
                    width: parent.width
                    spacing: 15
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        TextField {
                            id: newProfileName
                            Layout.fillWidth: true
                            placeholderText: "Nombre del nuevo perfil"
                            
                            background: Rectangle {
                                color: "#2d2d2d"
                                radius: 4
                                border.color: parent.activeFocus ? "#4CAF50" : "#555555"
                            }
                            
                            color: "#ffffff"
                        }
                        
                        Button {
                            text: "Agregar Perfil"
                            
                            background: Rectangle {
                                color: parent.pressed ? "#388E3C" : "#4CAF50"
                                radius: 4
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                color: "#ffffff"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            onClicked: {
                                if (newProfileName.text.trim() !== "") {
                                    profileManager.addProfile(newProfileName.text.trim())
                                    newProfileName.text = ""
                                }
                            }
                        }
                    }
                    
                    ListView {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 200
                        model: profileManager.profiles
                        spacing: 5
                        clip: true
                        
                        delegate: Rectangle {
                            width: ListView.view.width
                            height: 50
                            color: "#2d2d2d"
                            radius: 4
                            border.color: modelData.name === profileManager.currentProfile ? "#4CAF50" : "#555555"
                            border.width: 2
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 10
                                
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    
                                    Text {
                                        text: modelData.name
                                        color: "#ffffff"
                                        font.pixelSize: 14
                                        font.bold: true
                                    }
                                    
                                    Text {
                                        text: "Versión: " + (modelData.version || "latest")
                                        color: "#b0b0b0"
                                        font.pixelSize: 11
                                    }
                                }
                                
                                Button {
                                    text: "Eliminar"
                                    visible: modelData.name !== "Default"
                                    
                                    background: Rectangle {
                                        color: parent.pressed ? "#d32f2f" : "#f44336"
                                        radius: 4
                                    }
                                    
                                    contentItem: Text {
                                        text: parent.text
                                        color: "#ffffff"
                                        font.pixelSize: 11
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    
                                    onClicked: {
                                        profileManager.removeProfile(modelData.name)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Sección de gráficos
            GroupBox {
                Layout.fillWidth: true
                
                background: Rectangle {
                    color: "#3d3d3d"
                    radius: 8
                    border.color: "#4d4d4d"
                }
                
                label: Text {
                    text: "Gráficos"
                    color: "#ffffff"
                    font.pixelSize: 16
                    font.bold: true
                    padding: 10
                }
                
                ColumnLayout {
                    width: parent.width
                    spacing: 15
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: "Resolución de ventana:"
                            color: "#b0b0b0"
                            font.pixelSize: 13
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        ComboBox {
                            model: ["1920x1080", "1600x900", "1366x768", "1280x720"]
                            
                            background: Rectangle {
                                color: "#2d2d2d"
                                radius: 4
                                border.color: parent.activeFocus ? "#4CAF50" : "#555555"
                            }
                            
                            contentItem: Text {
                                text: parent.displayText
                                color: "#ffffff"
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 10
                            }
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: "Pantalla completa:"
                            color: "#b0b0b0"
                            font.pixelSize: 13
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Switch {
                            checked: false
                        }
                    }
                }
            }
            
            // Sección de información
            GroupBox {
                Layout.fillWidth: true
                
                background: Rectangle {
                    color: "#3d3d3d"
                    radius: 8
                    border.color: "#4d4d4d"
                }
                
                label: Text {
                    text: "Información"
                    color: "#ffffff"
                    font.pixelSize: 16
                    font.bold: true
                    padding: 10
                }
                
                GridLayout {
                    width: parent.width
                    columns: 2
                    columnSpacing: 15
                    rowSpacing: 10
                    
                    Text {
                        text: "Versión del Launcher:"
                        color: "#b0b0b0"
                        font.pixelSize: 13
                    }
                    Text {
                        text: launcherBackend.version
                        color: "#ffffff"
                        font.pixelSize: 13
                    }
                    
                    Text {
                        text: "Directorio de datos:"
                        color: "#b0b0b0"
                        font.pixelSize: 13
                    }
                    Text {
                        text: launcherBackend.getDataDir()
                        color: "#ffffff"
                        font.pixelSize: 11
                        elide: Text.ElideMiddle
                        Layout.fillWidth: true
                    }
                    
                    Text {
                        text: "Directorio de aplicación:"
                        color: "#b0b0b0"
                        font.pixelSize: 13
                    }
                    Text {
                        text: launcherBackend.getAppDir()
                        color: "#ffffff"
                        font.pixelSize: 11
                        elide: Text.ElideMiddle
                        Layout.fillWidth: true
                    }
                }
            }
            
            Item { Layout.fillHeight: true }
        }
    }
}
