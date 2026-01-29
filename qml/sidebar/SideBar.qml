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
    // List of versions, bound to the manager's property for automatic updates
    property var versionsList: minecraftManager.availableVersions
    
    // Configuración de visualización y ordenado
    property string sortMode: "date" // "date" (default), "name", "tag"
    property bool isFullyExpanded: false

    function getSortedVersions() {
        if (!versionsList) return [];
        let list = Array.from(versionsList);
        if (sortMode === "date") {
            list.sort((a, b) => (b.timestamp || 0) - (a.timestamp || 0));
        } else if (sortMode === "name") {
            list.sort((a, b) => (a.name || "").localeCompare(b.name || ""));
        } else if (sortMode === "tag") {
            list.sort((a, b) => (a.tag || "").localeCompare(b.tag || ""));
        }
        return list;
    }

    Component.onCompleted: {
        // Initial refresh of the cache if needed
        minecraftManager.getAvailableVersions()
    }
    
    // No need for Connections onAvailableVersionsChanged anymore as property binding handles it
    
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
                    minecraftManager.getAvailableVersions()
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
            Layout.preferredHeight: {
                if (!isExpanded) return 0;
                let baseHeight = 30; // sortHeader height
                let items = getSortedVersions();
                let count = Math.min(items.length, 5);
                let totalSpacing = (count > 0) ? (count - 1) * 8 : 0;
                return count * 40 + totalSpacing + baseHeight;
            }
            color: sideBar.highlightColor
            clip: true
            
            property bool isExpanded: false
            
            Behavior on height {
                NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
            }

            // UI de Ordenado
            RowLayout {
                id: sortHeader
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 30
                spacing: 5
                anchors.margins: 4
                visible: versionsMenu.height > 20

                Text {
                    text: "Sort by:"
                    color: "#888888"
                    font.pixelSize: 10
                    Layout.margins: 4
                }

                Repeater {
                    model: ["date", "name", "tag"]
                    delegate: Rectangle {
                        width: 45
                        height: 18
                        radius: 4
                        color: sideBar.sortMode === modelData ? "#4CAF50" : "#3d3d3d"
                        
                        Text {
                            anchors.centerIn: parent
                            text: modelData.toUpperCase()
                            color: "#ffffff"
                            font.pixelSize: 9
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: sideBar.sortMode = modelData
                        }
                    }
                }
            }
            
            ScrollView {
                anchors.top: sortHeader.bottom
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                clip: true
                ScrollBar.vertical.policy: ScrollBar.AsNeeded
                
                Column {
                    width: parent.width
                    spacing: 1
                    // bottomPadding: 20
                    
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
                    
                    // Lista de versiones
                    Repeater {
                        model: sideBar.getSortedVersions()

                        Rectangle {
                            id: versionItem
                            width: parent.width
                            height: 40
                            color: versionMouse.containsMouse ? sideBar.listItemHoverColor : sideBar.listItemBaseColor

                            // Support model entries as string (path) or object {name, path}
                            property string versionPath: (typeof modelData === 'string') ? modelData : (modelData && modelData.path ? modelData.path : "")
                            property string versionName: (typeof modelData === 'string') ? (modelData.split("/").pop()) : (modelData && modelData.name ? modelData.name : (versionPath.split("/").pop()))
                            property string customIcon: (modelData && typeof modelData === 'object' && modelData.icon) ? modelData.icon : ""

                            MouseArea {
                                id: versionMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                    onClicked: {
                                        // Refrescar la lista al seleccionar una versión
                                        minecraftManager.getAvailableVersions()
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

                                    Rectangle {
                                        anchors.fill: parent
                                        radius: 4
                                        clip: true
                                        color: "transparent"

                                        Image {
                                            id: versionIconImg
                                            anchors.fill: parent
                                            source: customIcon !== "" ? customIcon : Media.DefaultVersionIcon
                                            fillMode: Image.PreserveAspectCrop
                                            cache: true
                                            smooth: true
                                            onStatusChanged: {
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
