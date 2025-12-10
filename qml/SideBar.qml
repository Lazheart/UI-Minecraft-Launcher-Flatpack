import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "Media.js" as Media

Rectangle {
    id: sideBar
    width: 280
    color: "#171515"
    property color baseColor: "#171515"
    property color highlightColor: "#302C2C"
    property color listItemBaseColor: "#231f1f"

    signal addVersionsRequested()
    signal deleteVersionsRequested()
    signal importWorldsAddonsRequested()
    signal versionSelected(string version)
    
    property var versionsList: minecraftManager.getAvailableVersions()
    
    Connections {
        target: minecraftManager
        function onAvailableVersionsChanged() {
            // Actualizar la lista de versiones
            sideBar.versionsList = minecraftManager.getAvailableVersions()
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: 0
        
        // Sección Installed Versions
        Rectangle {
            id: versionsHeader
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: versionsMenu.isExpanded || headerMouse.containsMouse ? sideBar.highlightColor : sideBar.baseColor
            
            MouseArea {
                id: headerMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: versionsMenu.isExpanded = !versionsMenu.isExpanded
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10
                    
                    Item {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        
                        Image {
                            id: versionsIcon
                            anchors.fill: parent
                            source: Media.BedrockLogo
                            fillMode: Image.PreserveAspectFit
                            cache: true
                        }
                        
                        Rectangle {
                            anchors.fill: parent
                            color: "#4CAF50"
                            radius: 4
                            visible: versionsIcon.status !== Image.Ready
                            
                            Text {
                                anchors.centerIn: parent
                                text: "M"
                                font.pixelSize: 16
                                font.bold: true
                                color: "#ffffff"
                            }
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
            color: sideBar.highlightColor
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
                        model: Math.min(sideBar.versionsList.length, 5)
                        
                        Rectangle {
                            id: versionItem
                            width: parent.width
                            height: 40
                            color: versionMouse.containsMouse ? sideBar.highlightColor : sideBar.listItemBaseColor
                            
                            MouseArea {
                                id: versionMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: sideBar.versionSelected(sideBar.versionsList[index])
                            }
                            
                            Text {
                                anchors.fill: parent
                                anchors.margins: 10
                                text: sideBar.versionsList[index] || ""
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
            id: addButton
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: addMouse.containsMouse ? sideBar.highlightColor : sideBar.baseColor
            
            MouseArea {
                id: addMouse
                anchors.fill: parent
                hoverEnabled: true
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10
                    
                    Item {
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                        
                        Image {
                            id: addIcon
                            anchors.fill: parent
                            source: Media.BedrockLogo
                            fillMode: Image.PreserveAspectFit
                            cache: true
                        }
                        
                        Rectangle {
                            anchors.fill: parent
                            color: "#4CAF50"
                            radius: 3
                            visible: addIcon.status !== Image.Ready
                            
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

                onClicked: sideBar.addVersionsRequested()
            }
        }
        
        // Delete Versions
        Rectangle {
            id: deleteButton
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: deleteMouse.containsMouse ? sideBar.highlightColor : sideBar.baseColor
            
            MouseArea {
                id: deleteMouse
                anchors.fill: parent
                hoverEnabled: true
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10
                    
                    Item {
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                        
                        Image {
                            id: deleteIcon
                            anchors.fill: parent
                            source: Media.TrashIcon
                            fillMode: Image.PreserveAspectFit
                            cache: true
                        }
                        
                        Rectangle {
                            anchors.fill: parent
                            color: "#f44336"
                            radius: 3
                            visible: deleteIcon.status !== Image.Ready
                            
                            Text {
                                anchors.centerIn: parent
                                text: "✕"
                                color: "#ffffff"
                                font.bold: true
                                font.pixelSize: 16
                            }
                        }
                    }
                    
                    Text {
                        text: "Delete versions"
                        color: "#ffffff"
                        font.pixelSize: 13
                        Layout.fillWidth: true
                    }
                }

                onClicked: sideBar.deleteVersionsRequested()
            }
        }
        
        // Import Worlds / Addons Button
        Rectangle {
            id: importButton
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: importMouse.containsMouse ? sideBar.highlightColor : sideBar.baseColor
            
            Behavior on color {
                ColorAnimation { duration: 200 }
            }
            
            MouseArea {
                id: importMouse
                anchors.fill: parent
                hoverEnabled: true
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10
                    
                    Item {
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                        
                        Image {
                            id: importIcon
                            anchors.fill: parent
                            source: Media.LibreriaIcon
                            fillMode: Image.PreserveAspectFit
                            cache: true
                        }
                        
                        Rectangle {
                            anchors.fill: parent
                            color: "#4CAF50"
                            radius: 3
                            visible: importIcon.status !== Image.Ready
                            
                            Text {
                                anchors.centerIn: parent
                                text: "+"
                                color: "#ffffff"
                                font.bold: true
                                font.pixelSize: 16
                            }
                        }
                    }
                    
                    Text {
                        text: "Import Worlds\nand mods"
                        color: "#ffffff"
                        font.pixelSize: 13
                        Layout.fillWidth: true
                    }
                }

                onClicked: sideBar.importWorldsAddonsRequested()
            }
        }
        
        // Versión del Launcher
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: sideBar.baseColor
            
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
