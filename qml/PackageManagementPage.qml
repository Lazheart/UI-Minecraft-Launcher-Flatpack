import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3

Rectangle {
    color: "#1e1e1e"
    
    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20
        
        // ============= Header =============
        Text {
            text: "Package Management"
            font.pixelSize: 24
            font.bold: true
            color: "#ffffff"
        }
        
        // ============= Installed Versions Section =============
        GroupBox {
            width: parent.width
            title: "Installed Versions"
            
            Column {
                width: parent.width
                spacing: 10
                
                ListModel {
                    id: versionsModel
                }
                
                Repeater {
                    model: versionsModel
                    delegate: Rectangle {
                        width: parent.width
                        height: 60
                        color: "#2d2d2d"
                        radius: 5
                        border.color: "#4CAF50"
                        border.width: 1
                        
                        Row {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10
                            
                            Text {
                                text: modelData
                                color: "#ffffff"
                                anchors.verticalCenter: parent.verticalCenter
                                font.pixelSize: 16
                            }
                            
                            Item { width: 1; height: 1 }
                            
                            Button {
                                text: "View Worlds"
                                anchors.verticalCenter: parent.verticalCenter
                                onClicked: {
                                    console.log("View worlds for:", modelData)
                                    worldsModel.clear()
                                    var worlds = launcherBackend.getWorldsForVersion(modelData)
                                    worlds.forEach(function(w) {
                                        worldsModel.append({ name: w, version: modelData })
                                    })
                                }
                            }
                            
                            Button {
                                text: "Launch"
                                anchors.verticalCenter: parent.verticalCenter
                                onClicked: {
                                    console.log("Launching version:", modelData)
                                    launcherBackend.runGame(modelData)
                                }
                            }
                        }
                    }
                }
                
                Button {
                    text: "Refresh Versions"
                    width: parent.width
                    onClicked: loadInstalledVersions()
                }
            }
        }
        
        // ============= Install APK Section =============
        GroupBox {
            width: parent.width
            title: "Install Version from APK"
            
            Column {
                width: parent.width
                spacing: 10
                
                TextField {
                    id: apkPathField
                    width: parent.width
                    placeholderText: "APK file path..."
                }
                
                TextField {
                    id: versionNameField
                    width: parent.width
                    placeholderText: "Version name (e.g., 1.20.15)..."
                }
                
                Button {
                    text: "Browse APK"
                    width: parent.width
                    onClicked: apkFileDialog.open()
                }
                
                Button {
                    text: "Install APK"
                    width: parent.width
                    enabled: apkPathField.text.length > 0 && versionNameField.text.length > 0
                    onClicked: {
                        console.log("Installing APK:", apkPathField.text, "as", versionNameField.text)
                        launcherBackend.installAPK(apkPathField.text, versionNameField.text)
                        apkPathField.clear()
                        versionNameField.clear()
                    }
                }
                
                ProgressBar {
                    id: installProgress
                    width: parent.width
                    value: 0
                    from: 0
                    to: 100
                }
                
                Text {
                    id: installStatusText
                    color: "#b0b0b0"
                    font.pixelSize: 12
                }
            }
        }
        
        // ============= Import World Section =============
        GroupBox {
            width: parent.width
            title: "Import World"
            
            Column {
                width: parent.width
                spacing: 10
                
                TextField {
                    id: worldPathField
                    width: parent.width
                    placeholderText: "World file path (.mcworld or .zip)..."
                }
                
                ComboBox {
                    id: worldVersionCombo
                    width: parent.width
                    model: versionsModel
                    textRole: "modelData"
                }
                
                Button {
                    text: "Browse World"
                    width: parent.width
                    onClicked: worldFileDialog.open()
                }
                
                Button {
                    text: "Import World"
                    width: parent.width
                    enabled: worldPathField.text.length > 0 && worldVersionCombo.currentIndex >= 0
                    onClicked: {
                        console.log("Importing world:", worldPathField.text, "to", worldVersionCombo.currentText)
                        launcherBackend.importWorld(worldPathField.text, worldVersionCombo.currentText)
                        worldPathField.clear()
                    }
                }
                
                ProgressBar {
                    id: importWorldProgress
                    width: parent.width
                    value: 0
                    from: 0
                    to: 100
                }
                
                Text {
                    id: importWorldStatusText
                    color: "#b0b0b0"
                    font.pixelSize: 12
                }
            }
        }
        
        // ============= Import Pack Section =============
        GroupBox {
            width: parent.width
            title: "Import Pack (Resource/Behavior)"
            
            Column {
                width: parent.width
                spacing: 10
                
                TextField {
                    id: packPathField
                    width: parent.width
                    placeholderText: "Pack file path (.mcpack or .zip)..."
                }
                
                ComboBox {
                    id: packVersionCombo
                    width: parent.width
                    model: versionsModel
                    textRole: "modelData"
                }
                
                Button {
                    text: "Browse Pack"
                    width: parent.width
                    onClicked: packFileDialog.open()
                }
                
                Button {
                    text: "Import Pack"
                    width: parent.width
                    enabled: packPathField.text.length > 0 && packVersionCombo.currentIndex >= 0
                    onClicked: {
                        console.log("Importing pack:", packPathField.text, "to", packVersionCombo.currentText)
                        launcherBackend.importPack(packPathField.text, packVersionCombo.currentText)
                        packPathField.clear()
                    }
                }
                
                ProgressBar {
                    id: importPackProgress
                    width: parent.width
                    value: 0
                    from: 0
                    to: 100
                }
                
                Text {
                    id: importPackStatusText
                    color: "#b0b0b0"
                    font.pixelSize: 12
                }
            }
        }
        
        // ============= Worlds List Section =============
        GroupBox {
            width: parent.width
            title: "Imported Worlds"
            
            Column {
                width: parent.width
                spacing: 10
                
                ListModel {
                    id: worldsModel
                }
                
                Repeater {
                    model: worldsModel
                    delegate: Rectangle {
                        width: parent.width
                        height: 50
                        color: "#2d2d2d"
                        radius: 5
                        
                        Row {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10
                            
                            Text {
                                text: modelData.name + " (" + modelData.version + ")"
                                color: "#ffffff"
                                anchors.verticalCenter: parent.verticalCenter
                                font.pixelSize: 14
                            }
                            
                            Item { width: 1; height: 1 }
                            
                            Button {
                                text: "Play"
                                anchors.verticalCenter: parent.verticalCenter
                                onClicked: {
                                    console.log("Playing world:", modelData.name)
                                    launcherBackend.runGame(modelData.version, modelData.name)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Spacer
        Item { width: 1; height: 1; Layout.fillHeight: true }
    }
    
    // ============= File Dialogs =============
    FileDialog {
        id: apkFileDialog
        title: "Select APK file"
        folder: shortcuts.home
        nameFilters: [ "APK files (*.apk)", "All files (*)" ]
        onAccepted: {
            apkPathField.text = fileUrl.toString().replace(/^file:\/\//, "")
        }
    }
    
    FileDialog {
        id: worldFileDialog
        title: "Select World file"
        folder: shortcuts.home
        nameFilters: [ "World files (*.mcworld *.zip)", "All files (*)" ]
        onAccepted: {
            worldPathField.text = fileUrl.toString().replace(/^file:\/\//, "")
        }
    }
    
    FileDialog {
        id: packFileDialog
        title: "Select Pack file"
        folder: shortcuts.home
        nameFilters: [ "Pack files (*.mcpack *.zip)", "All files (*)" ]
        onAccepted: {
            packPathField.text = fileUrl.toString().replace(/^file:\/\//, "")
        }
    }
    
    // ============= Backend Connections =============
    Connections {
        target: launcherBackend
        
        // Install APK signals
        function onInstallProgress(current, total, message) {
            installProgress.value = (current / total) * 100
            installStatusText.text = message
        }
        
        function onInstallationCompleted(version) {
            installStatusText.text = "✓ Installation completed: " + version
            loadInstalledVersions()
        }
        
        // Import World signals
        function onImportProgress(current, total, message) {
            if (message.includes("mundo") || message.includes("world")) {
                importWorldProgress.value = (current / total) * 100
                importWorldStatusText.text = message
            } else if (message.includes("pack")) {
                importPackProgress.value = (current / total) * 100
                importPackStatusText.text = message
            }
        }
        
        function onImportCompleted(name) {
            importWorldStatusText.text = "✓ World imported: " + name
            importWorldProgress.value = 0
            loadInstalledVersions()
        }
        
        // Error signals
        function onOperationFailed(error) {
            console.error("Operation failed:", error)
            installStatusText.text = "✗ Error: " + error
            importWorldStatusText.text = "✗ Error: " + error
            importPackStatusText.text = "✗ Error: " + error
        }
        
        // Log messages
        function onLogMessage(message) {
            console.log("[Backend]", message)
        }
    }
    
    // ============= Functions =============
    function loadInstalledVersions() {
        versionsModel.clear()
        var versions = launcherBackend.getInstalledVersions()
        versions.forEach(function(v) {
            versionsModel.append({ modelData: v })
        })
    }
    
    Component.onCompleted: {
        loadInstalledVersions()
    }
}
