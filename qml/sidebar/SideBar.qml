import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../Media.js" as Media

Rectangle {
    id: sideBar
    width: 280
    color: "#171515"
    property color baseColor: "#171515"
    property color highlightColor: "#302C2C"
    property color listItemBaseColor: "#231f1f"
    // Color de hover para items de la lista (usar verde como el resto de la UI)
    property color listItemHoverColor: "#4CAF50"

    signal addVersionsRequested()
    signal deleteVersionsRequested()
    signal importWorldsAddonsRequested()
    signal versionSelected(string version)
    
    // Keep an explicit list here and initialize on completion.
    // Using a stable array for the Repeater model avoids intermittent UI desync.
    property var versionsList: []

    Component.onCompleted: {
        sideBar.versionsList = minecraftManager.getAvailableVersions()
    }
    
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
                onClicked: {
                    // Al hacer click en el encabezado, refrescar la lista
                    sideBar.versionsList = minecraftManager.getAvailableVersions()
                    versionsMenu.isExpanded = !versionsMenu.isExpanded
                }
                
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
                        visible: sideBar.versionsList.length === 0

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
                    // Use an array slice as the model so Repeater uses a stable list
                    Repeater {
                        model: sideBar.versionsList ? sideBar.versionsList.slice(0, 5) : []

                        Rectangle {
                            id: versionItem
                            width: parent.width
                            height: 40
                            color: versionMouse.containsMouse ? sideBar.listItemHoverColor : sideBar.listItemBaseColor

                            // Support model entries as string (path) or object {name, path}
                            property string versionPath: (typeof modelData === 'string') ? modelData : (modelData && modelData.path ? modelData.path : "")
                            property string versionName: (typeof modelData === 'string') ? (modelData.split("/").pop()) : (modelData && modelData.name ? modelData.name : (versionPath.split("/").pop()))
                            property string customIcon: (modelData && typeof modelData === 'object' && modelData.icon) ? modelData.icon : ""

                            Component.onCompleted: {
                                if (typeof modelData === 'object') {
                                    console.log("[SideBar] Item for", versionName, "modelData:", JSON.stringify(modelData))
                                    console.log("[SideBar] Icon path from modelData:", modelData.icon)
                                } else {
                                    console.log("[SideBar] Item for", versionName, "modelData is not an object:", typeof modelData)
                                }
                            }

                            MouseArea {
                                id: versionMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                    onClicked: {
                                        // Refrescar la lista al seleccionar una versión
                                        sideBar.versionsList = minecraftManager.getAvailableVersions()
                                        sideBar.versionSelected(versionName)
                                    }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 6
                                spacing: 10

                                Rectangle {
                                    id: versionIconWrapper
                                    color: "transparent"
                                    radius: 6
                                    clip: true
                                    Layout.preferredWidth: 34
                                    Layout.preferredHeight: 34
                                    Layout.alignment: Qt.AlignVCenter

                                    Image {
                                        id: versionIconImg
                                        anchors.fill: parent
                                        source: customIcon !== "" ? customIcon : Media.DefaultVersionIcon
                                        fillMode: Image.PreserveAspectFit
                                        cache: true
                                        smooth: true
                                        onStatusChanged: {
                                            if (status === Image.Ready) {
                                                console.log("[SideBar] Icon loaded for", versionName, ":", source)
                                            }
                                            if (status === Image.Error) {
                                                console.log("[SideBar] Icon error for", versionName, "source:", source)
                                                if (customIcon !== "" && source !== Media.DefaultVersionIcon) {
                                                    versionIconImg.source = Media.DefaultVersionIcon
                                                } else if (Media.DefaultVersionIconFallback && versionIconImg.source !== Media.DefaultVersionIconFallback) {
                                                    versionIconImg.source = Media.DefaultVersionIconFallback
                                                }
                                            }
                                        }
                                    }
                                }

                                Text {
                                    id: versionNameText
                                    text: versionName
                                    color: "#ffffff"
                                    font.pixelSize: 12
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                }
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
                    text: {"Launcher v" + minecraftManager.getLauncherVersion()}
                    color: "#4CAF50"
                    font.pixelSize: 13
                    font.bold: true
                }
            }
        }
    }
}
