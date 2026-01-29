import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import "../Media.js" as Media

Rectangle {
    color: "#1e1e1e"
    
    // Property to track selected version
    property string selectedVersion: ""
    
    // Get full data for the selected version
    property var selectedVersionData: {
        if (selectedVersion === "") return null;
        var versions = minecraftManager.availableVersions;
        for (var i = 0; i < versions.length; i++) {
            if (versions[i].name === selectedVersion) return versions[i];
        }
        return null;
    }
    
    // Señal para abrir el diálogo de instalación
    signal installVersionRequested()

    function getVersionBackground(versionName) {
        if (!versionName) return Media.DefaultVersionBackground;
        
        var versions = minecraftManager.availableVersions;
        var count = versions.length;
        for (var i = 0; i < count; i++) {
            var v = versions[i];
            if (v.name === versionName && v.background) {
                return v.background;
            }
        }
        
        return Media.VersionBackgrounds[versionName] || Media.DefaultVersionBackground;
    }
    
    ScrollView {
        id: homeScroll
        anchors.fill: parent
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        Loader {
            id: contentLoader
            width: homeScroll.availableWidth
            sourceComponent: minecraftManager.isInstalled ? (selectedVersion !== "" ? versionSelectedComponent : dashboardComponent) : emptyComponent
        }

        Component {
            id: emptyComponent

            Item {
                id: emptyRoot
                width: parent ? parent.width : emptyColumn.implicitWidth
                // Use explicit height based on content or available scroll area
                height: Math.max(homeScroll.availableHeight, emptyColumn.implicitHeight + 80)
                implicitWidth: emptyColumn.implicitWidth
                implicitHeight: emptyColumn.implicitHeight + 80

                Column {
                    id: emptyColumn
                    width: Math.min(parent.width - 40, 420)
                    spacing: 20
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: Math.max(40, (parent.height - implicitHeight) / 2)

                    Text {
                        text: "Welcome to Kon Launcher"
                        font.pixelSize: 32
                        font.bold: true
                        color: "#ffffff"
                        horizontalAlignment: Text.AlignHCenter
                        width: parent.width
                    }

                    Column {
                        spacing: 20
                        anchors.horizontalCenter: parent.horizontalCenter

                        Text {
                            text: "Install new version clicking on icon of"
                            font.pixelSize: 16
                            color: "#b0b0b0"
                            horizontalAlignment: Text.AlignHCenter
                            width: parent.width
                        }

                        Item {
                            width: 80
                            height: 80

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: installVersionRequested()
                                cursorShape: Qt.PointingHandCursor

                                Image {
                                    id: installIcon
                                    anchors.fill: parent
                                    source: Media.BedrockLogo
                                    fillMode: Image.PreserveAspectFit
                                    cache: true
                                    opacity: parent.containsMouse ? 0.8 : 1.0
                                    Behavior on opacity { NumberAnimation { duration: 200 } }
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    color: "#4CAF50"
                                    radius: 8
                                    visible: installIcon.status !== Image.Ready
                                    opacity: parent.containsMouse ? 0.8 : 1.0
                                    Behavior on opacity { NumberAnimation { duration: 200 } }

                                    Text {
                                        anchors.centerIn: parent
                                        text: "B"
                                        font.pixelSize: 48
                                        font.bold: true
                                        color: "#ffffff"
                                    }
                                }
                            }
                        }

                        Text {
                            text: "Install new version"
                            font.pixelSize: 14
                            color: "#ffffff"
                            horizontalAlignment: Text.AlignHCenter
                            width: parent.width
                        }
                    }
                }
            }
        }

        Component {
            id: dashboardComponent

            Item {
                id: dashboardRoot
                width: parent ? parent.width : 0
                height: implicitHeight
                implicitWidth: dashboardLayout.implicitWidth
                implicitHeight: dashboardLayout.implicitHeight + 80

                ColumnLayout {
                    id: dashboardLayout
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 40
                    spacing: 30

                    // 1. Welcome Header
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 20
                        spacing: 8

                        Text {
                            text: "Hello, " + (profileManager ? profileManager.currentProfile : "User")
                            font.pixelSize: 32
                            font.bold: true
                            color: "#ffffff"
                        }

                        Text {
                            text: "Welcome back to Kon Launcher. What do you want to play today?"
                            font.pixelSize: 16
                            color: "#b0b0b0"
                        }
                    }

                    // 2. Quick Launch & Stats Row
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 20

                    // Quick Launch Card
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 180
                        color: "#2d2d2d"
                        radius: 12
                        clip: true

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 25
                            spacing: 15

                                RowLayout {
                                    Layout.fillWidth: true
                                    
                                    ColumnLayout {
                                        spacing: 5
                                        Text {
                                            text: "READY TO PLAY"
                                            font.pixelSize: 12
                                            font.bold: true
                                            color: "#4CAF50"
                                            font.letterSpacing: 1.5
                                        }
                                        Text {
                                            text: "Minecraft " + (minecraftManager.lastActiveVersion || "Latest")
                                            font.pixelSize: 24
                                            font.bold: true
                                            color: "#ffffff"
                                        }
                                    }

                                    Item { Layout.fillWidth: true }

                                    // Status Badge
                                    Rectangle {
                                        Layout.preferredWidth: 100
                                        Layout.preferredHeight: 30
                                        color: minecraftManager.isRunning ? "#1b5e20" : "#3d3d3d"
                                        radius: 15
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: minecraftManager.isRunning ? "EJECUTANDO" : "DETENIDO"
                                            font.pixelSize: 10
                                            font.bold: true
                                            color: minecraftManager.isRunning ? "#81C784" : "#b0b0b0"
                                        }
                                    }
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 15

                                    Button {
                                        id: actionButtonHome
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 50
                                        text: "START GAME"
                                        enabled: !minecraftManager.isRunning

                                        background: Rectangle {
                                            color: parent.enabled ? (parent.pressed ? "#388E3C" : "#4CAF50") : "#444444"
                                            radius: 8
                                        }

                                        contentItem: Item {
                                            Row {
                                                anchors.centerIn: parent
                                                spacing: 10
                                                Text {
                                                    text: "▶"
                                                    font.pixelSize: 16
                                                    color: "#ffffff"
                                                    visible: !minecraftManager.isRunning
                                                    verticalAlignment: Text.AlignVCenter
                                                }
                                                Text {
                                                    text: actionButtonHome.text
                                                    font.pixelSize: 16
                                                    font.bold: true
                                                    color: actionButtonHome.enabled ? "#ffffff" : "#888888"
                                                    verticalAlignment: Text.AlignVCenter
                                                }
                                            }
                                        }

                                        onClicked: {
                                            var version = minecraftManager.installedVersion
                                            minecraftManager.runGame(version, "", profileManager.currentProfile)
                                        }
                                    }

                                    Button {
                                        Layout.preferredWidth: 60
                                        Layout.preferredHeight: 50
                                        visible: minecraftManager.isRunning
                                        
                                        background: Rectangle {
                                            color: parent.pressed ? "#d32f2f" : "#f44336"
                                            radius: 8
                                        }
                                        
                                        contentItem: Text {
                                            text: "■"
                                            font.pixelSize: 20
                                            color: "white"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                        
                                        onClicked: minecraftManager.stopGame()
                                    }
                                }
                            }
                        }

                        // Stats Card
                        Rectangle {
                            Layout.preferredWidth: 250
                            Layout.preferredHeight: 180
                            color: "#1e1e1e"
                            radius: 12
                            border.color: "#333333"
                            border.width: 1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 20
                                spacing: 15

                                Text {
                                    text: "INSTALLED VERSIONS"
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: "#888888"
                                }

                                Text {
                                    text: minecraftManager.availableVersions.length
                                    font.pixelSize: 48
                                    font.bold: true
                                    color: "#ffffff"
                                }

                                Text {
                                    text: "Versions loaded"
                                    font.pixelSize: 14
                                    color: "#666666"
                                }
                            }
                        }
                    }

                    // 3. Installed Versions Gallery
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 20

                        Text {
                            text: "Your Versions"
                            font.pixelSize: 20
                            font.bold: true
                            color: "#ffffff"
                        }

                        Flow {
                            id: galleryFlow
                            Layout.fillWidth: true
                            // Flow's childrenRect.height is expensive, but for now we need some height.
                            // Let's use implicitHeight which should be calculated by Flow
                            Layout.preferredHeight: implicitHeight
                            spacing: 15
                            
                            // Explicitly bind width to parent to help Flow calculate layout
                            width: parent.width

                            Repeater {
                                model: minecraftManager.availableVersions
                                
                                delegate: Item {
                                    width: 160
                                    height: 220

                                    Rectangle {
                                        id: cardBackground
                                        anchors.fill: parent
                                        color: "#2d2d2d"
                                        radius: 10
                                        border.color: mouseArea.containsMouse ? "#4CAF50" : "transparent"
                                        border.width: 2
                                        visible: false // Hidden because it's used as a mask
                                    }

                                    OpacityMask {
                                        anchors.fill: parent
                                        source: contentLayer
                                        maskSource: Rectangle {
                                            width: cardBackground.width
                                            height: cardBackground.height
                                            radius: cardBackground.radius
                                        }
                                    }

                                    // Move card background to a separate layer or just use it as mask source
                                    // Here we use a simpler approach: clip the Column to the card shape.
                                    // However, since clip: true doesn't work for radius, we use the OpacityMask above.
                                    // We need to group the content into another Item to use it as 'source' for OpacityMask.
                                    
                                    Item {
                                        id: contentLayer
                                        anchors.fill: parent
                                        visible: false // Rendered via OpacityMask

                                        // Explicit background for the card inside the mask
                                        Rectangle {
                                            anchors.fill: parent
                                            color: "#2d2d2d"
                                            radius: 10
                                        }

                                        Column {
                                            anchors.fill: parent
                                            spacing: 0

                                            // Version Image Placeholder/Background
                                            Rectangle {
                                                width: parent.width
                                                height: 120
                                                color: "#3d3d3d"
                                                
                                                Image {
                                                    anchors.fill: parent
                                                    source: modelData.background || Media.DefaultVersionBackground
                                                    fillMode: Image.PreserveAspectCrop
                                                    opacity: 0.6
                                                    asynchronous: true
                                                }
                                                
                                                Rectangle {
                                                    anchors.centerIn: parent
                                                    width: 48
                                                    height: 48
                                                    color: "#222"
                                                    radius: 8
                                                    opacity: 0.8
                                                    
                                                    Image {
                                                        anchors.fill: parent
                                                        anchors.margins: 8
                                                        source: modelData.icon || Media.DefaultVersionIcon
                                                        fillMode: Image.PreserveAspectFit
                                                        asynchronous: true
                                                    }
                                                }
                                            }

                                            // Version Text
                                            Column {
                                                width: parent.width
                                                padding: 12
                                                spacing: 4

                                                Text {
                                                    text: modelData.name
                                                    font.pixelSize: 16
                                                    font.bold: true
                                                    color: "#ffffff"
                                                    elide: Text.ElideRight
                                                    width: parent.width - 24
                                                }

                                                Text {
                                                    text: modelData.tag || modelData.name
                                                    font.pixelSize: 12
                                                    color: "#888888"
                                                }

                                                Text {
                                                    text: modelData.installDate || ""
                                                    font.pixelSize: 10
                                                    color: "#666666"
                                                    font.italic: true
                                                }
                                            }
                                        }
                                    }

                                    // Border overlay (stays on top of OpacityMask)
                                    Rectangle {
                                        anchors.fill: parent
                                        color: "transparent"
                                        radius: 10
                                        border.color: mouseArea.containsMouse ? "#4CAF50" : "transparent"
                                        border.width: 2
                                        z: 5
                                    }

                                    MouseArea {
                                        id: mouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            selectedVersion = modelData.name
                                        }
                                    }

                                    // Hover effect overlay
                                    Rectangle {
                                        anchors.fill: parent
                                        color: "white"
                                        opacity: mouseArea.containsMouse ? 0.05 : 0
                                        radius: 10
                                        z: 6
                                    }
                                }
                            }
                        }
                    }

                    Item { Layout.fillHeight: true; Layout.preferredHeight: 40 }
                }
            }
        }

        Component {
            id: versionSelectedComponent

            Item {
                id: rootSelected
                width: parent ? parent.width : 0
                // Height covers at least the viewport to avoid black gaps
                height: Math.max(homeScroll.availableHeight, contentColumn.implicitHeight)
                implicitHeight: contentColumn.implicitHeight

                // Background Image
                Rectangle {
                    anchors.fill: parent
                    color: "#1e1e1e"
                    z: 0

                    Image {
                        id: backgroundImage
                        anchors.fill: parent
                        source: getVersionBackground(selectedVersion)
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: true

                        onStatusChanged: {
                            if (status === Image.Error) {
                                if (backgroundImage.source !== Media.DefaultVersionBackground) {
                                    backgroundImage.source = Media.DefaultVersionBackground
                                }
                            }
                        }
                    }

                    // Filtro de oscurecimiento para mejorar la lectura del texto
                    Rectangle {
                        anchors.fill: parent
                        color: "black"
                        opacity: 0.45
                    }
                }

                // Main content column
                ColumnLayout {
                    id: contentColumn
                    width: parent.width
                    height: parent.height
                    spacing: 0
                    // No anchors.fill to avoid circular height dependency

                    // Header Area (Back Button + Graphic Options)
                    Item {
                        id: headerArea
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        z: 10

                        // Back to Home Button (Left)
                        Button {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 30
                            width: 160
                            height: 40
                            text: "← Back to Home"
                            
                            background: Rectangle {
                                color: parent.pressed ? "#3d3d3d" : "#1e1e1e"
                                radius: 8
                                border.color: parent.hovered ? "#4CAF50" : "#555555"
                                border.width: 1
                                opacity: 0.9
                            }

                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 14
                                color: "#ffffff"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: {
                                selectedVersion = ""
                            }
                        }

                        // Graphic Options Button (Right)
                        Button {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.rightMargin: 30
                            width: 200
                            height: 40
                            
                            background: Rectangle {
                                color: parent.pressed ? "#3d3d3d" : "#2d2d2d"
                                radius: 8
                                border.color: parent.hovered ? "#4CAF50" : "#555555"
                                border.width: 1
                                opacity: 0.9
                            }

                            contentItem: Item {
                                anchors.fill: parent
                                
                                Row {
                                    anchors.centerIn: parent
                                    spacing: 8
                                    
                                    Image {
                                        width: 16
                                        height: 16
                                        source: Media.DropperIcon
                                        fillMode: Image.PreserveAspectFit
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        text: "Graphic Options"
                                        font.pixelSize: 13
                                        color: "#ffffff"
                                        font.bold: true
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }

                            onClicked: {
                                console.log("[Home] Opening graphic options")
                            }
                        }
                    }

                    // Center Content (Left-aligned Welcome, Greeting, Version Info)
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumHeight: 350

                        ColumnLayout {
                            anchors.left: parent.left
                            anchors.leftMargin: 60
                            anchors.top: parent.top
                            anchors.topMargin: 40
                            spacing: 20
                            z: 1

                            Text {
                                text: "Welcome to Kon Launcher"
                                font.pixelSize: 32
                                font.bold: true
                                color: "#ffffff"
                            }

                            Text {
                                text: "Hola " + (profileManager ? profileManager.currentProfile : "Usuario")
                                font.pixelSize: 24
                                color: "#4CAF50"
                                font.bold: true
                            }
                            
                            // Version Info Box
                            Rectangle {
                                Layout.preferredWidth: 500
                                Layout.preferredHeight: 160
                                color: "#2d2d2d"
                                radius: 8
                                opacity: 0.9

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 20
                                    spacing: 10

                                    Text {
                                        text: "Version Information"
                                        font.pixelSize: 16
                                        font.bold: true
                                        color: "#ffffff"
                                    }

                                    GridLayout {
                                        columns: 2
                                        columnSpacing: 15
                                        rowSpacing: 8
                                        Layout.fillWidth: true

                                        Text {
                                            text: "Selected:"
                                            color: "#b0b0b0"
                                        }
                                        Text {
                                            text: selectedVersion
                                            color: "#4CAF50"
                                            font.bold: true
                                        }

                                        Text {
                                            text: "Tag:"
                                            color: "#b0b0b0"
                                        }
                                        Text {
                                            text: (selectedVersionData && selectedVersionData.tag) ? selectedVersionData.tag : "None"
                                            color: "#ffffff"
                                        }

                                        Text {
                                            text: "Created:"
                                            color: "#b0b0b0"
                                        }
                                        Text {
                                            text: (selectedVersionData && selectedVersionData.installDate) ? selectedVersionData.installDate : "Unknown"
                                            color: "#ffffff"
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Footer Area (Play/Stop Button Only)
                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 100
                        z: 10

                        // Play/Stop Button (Centered)
                        Button {
                            id: actionButton
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 40
                            width: 250
                            height: 60
                            
                            property bool isGameRunning: minecraftManager.isRunning
                            
                            text: isGameRunning ? "STOP" : "PLAY"
                            
                            background: Rectangle {
                                color: parent.isGameRunning ? 
                                       (parent.pressed ? "#d32f2f" : "#f44336") : // Red for Stop
                                       (parent.pressed ? "#388E3C" : "#4CAF50")   // Green for Play
                                radius: 8
                            }

                            contentItem: Item {
                                anchors.fill: parent
                                
                                Row {
                                    anchors.centerIn: parent
                                    spacing: 15
                                    
                                    Text {
                                        text: actionButton.isGameRunning ? "■" : "▶"
                                        font.pixelSize: 24
                                        color: "#ffffff"
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        text: actionButton.text
                                        font.pixelSize: 24
                                        font.bold: true
                                        font.letterSpacing: 5
                                        color: "#ffffff"
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }

                            onClicked: {
                                if (isGameRunning) {
                                    console.log("[Home] Stopping game")
                                    minecraftManager.stopGame()
                                } else {
                                    console.log("[Home] Launching game version:", selectedVersion)
                                    minecraftManager.runGame(selectedVersion, "", profileManager.currentProfile)
                                }
                            }
                        }
                    }
                }

            }
        }
    }
}
