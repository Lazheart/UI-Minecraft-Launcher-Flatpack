import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: sideBar
    width: 280
    color: "#1e1e1e"
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: 0
        
        // Sección Installed Versions
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: "#2d2d2d"
            
            MouseArea {
                anchors.fill: parent
                onClicked: versionsMenu.isExpanded = !versionsMenu.isExpanded
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10
                    
                    Rectangle {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        color: "#4CAF50"
                        radius: 4
                        
                        Text {
                            anchors.centerIn: parent
                            text: "M"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#ffffff"
                        }
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        
                        Text {
                            text: "Installed Versions"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#ffffff"
                        }
                    }
                    
                    Text {
                        text: versionsMenu.isExpanded ? "▼" : "▶"
                        font.pixelSize: 12
                        color: "#4CAF50"
                    }
                }
            }
        }
        
        // Contenedor de versiones
        Rectangle {
            id: versionsMenu
            Layout.fillWidth: true
            Layout.preferredHeight: isExpanded ? 200 : 0
            color: "#252525"
            clip: true
            
            property bool isExpanded: false
            
            Behavior on height {
                NumberAnimation { duration: 300 }
            }
            
            ScrollView {
                anchors.fill: parent
                clip: true
                
                Column {
                    width: parent.width
                    spacing: 0
                    
                    // Si no hay versiones
                    Rectangle {
                        width: parent.width
                        height: 80
                        color: "transparent"
                        visible: minecraftManager.getAvailableVersions().length === 0
                        
                        Text {
                            anchors.centerIn: parent
                            text: "Not versions Installed"
                            color: "#888888"
                            font.pixelSize: 12
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            width: parent.width - 20
                        }
                    }
                    
                    // Lista de versiones (máximo 5)
                    Repeater {
                        model: Math.min(minecraftManager.getAvailableVersions().length, 5)
                        
                        Rectangle {
                            width: parent.width
                            height: 40
                            color: index % 2 === 0 ? "#2d2d2d" : "#252525"
                            
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: parent.color = "#3d3d3d"
                                onExited: parent.color = index % 2 === 0 ? "#2d2d2d" : "#252525"
                            }
                            
                            Text {
                                anchors.fill: parent
                                anchors.margins: 10
                                text: minecraftManager.getAvailableVersions()[index] || ""
                                color: "#ffffff"
                                font.pixelSize: 12
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }
            }
        }
        
        // Espaciador flexible
        Item {
            Layout.fillHeight: true
        }
        
        // Pie de SideBar - Add Versions
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: "#2d2d2d"
            
            MouseArea {
                anchors.fill: parent
                onClicked: console.log("[SideBar] Add versions")
                hoverEnabled: true
                onEntered: parent.color = "#3d3d3d"
                onExited: parent.color = "#2d2d2d"
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10
                    
                    Image {
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                        source: "file:///home/lazheart/Escritorio/UI-Minecraft-Launcher-Flatpack/assets/media/bedrockLogo.png"
                        cache: true
                        
                        Rectangle {
                            anchors.fill: parent
                            color: "#4CAF50"
                            radius: 3
                            visible: parent.status !== Image.Ready
                            
                            Text {
                                anchors.centerIn: parent
                                text: "+"
                                font.pixelSize: 18
                                font.bold: true
                                color: "#ffffff"
                            }
                        }
                    }
                    
                    Text {
                        text: "Add versions"
                        color: "#ffffff"
                        font.pixelSize: 13
                        Layout.fillWidth: true
                    }
                }
            }
        }
        
        // Delete Versions
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: "#2d2d2d"
            
            MouseArea {
                anchors.fill: parent
                onClicked: console.log("[SideBar] Delete versions")
                hoverEnabled: true
                onEntered: parent.color = "#3d3d3d"
                onExited: parent.color = "#2d2d2d"
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10
                    
                    Rectangle {
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                        color: "#f44336"
                        radius: 3
                        
                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 16
                        }
                    }
                    
                    Text {
                        text: "Delete versions"
                        color: "#ffffff"
                        font.pixelSize: 13
                        Layout.fillWidth: true
                    }
                }
            }
        }
        
        // Versión del Launcher
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: "#1e1e1e"
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 5
                
                Text {
                    text: "Version del Launcher"
                    color: "#888888"
                    font.pixelSize: 11
                }
                
                Text {
                    text: launcherBackend.version
                    color: "#4CAF50"
                    font.pixelSize: 13
                    font.bold: true
                }
            }
        }
    }
}
