import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../Media.js" as Media

Rectangle {
    color: "#1e1e1e"
    
    // Property to track selected version
    property string selectedVersion: ""
    
    // Señal para abrir el diálogo de instalación
    signal installVersionRequested()

    function getVersionBackground(versionName) {
        if (!versionName) return Media.DefaultVersionBackground;
        
        var versions = minecraftManager.availableVersions;
        for (var i = 0; i < versions.length; i++) {
            if (versions[i].name === versionName) {
                if (versions[i].background) {
                    console.log("[Home] Found custom background for", versionName, ":", versions[i].background);
                    return versions[i].background;
                }
                break;
            }
        }
        
        var fallback = Media.VersionBackgrounds[versionName] || Media.DefaultVersionBackground;
        return fallback;
    }
    
    ScrollView {
        id: homeScroll
        anchors.fill: parent
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AsNeeded
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        Item {
            id: contentRoot
            // Width: allow horizontal scrolling if needed
            width: Math.max(homeScroll.availableWidth, contentLoader.implicitWidth)
            // Height: use contentLoader's implicitHeight to enable vertical scrolling
            height: contentLoader.implicitHeight

            Loader {
                id: contentLoader
                // NO anchors.fill - use width binding instead
                width: parent.width
                // implicitHeight is automatically calculated from the loaded item
                sourceComponent: minecraftManager.isInstalled ? (selectedVersion !== "" ? versionSelectedComponent : installedComponent) : emptyComponent
            }
        }

        Component {
            id: emptyComponent

            Item {
                width: parent ? parent.width : emptyColumn.implicitWidth
                implicitWidth: emptyColumn.implicitWidth
                implicitHeight: emptyColumn.implicitHeight

                Column {
                    id: emptyColumn
                    width: Math.min(parent.width - 40, 420)
                    spacing: 20
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter

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
            id: installedComponent

            Item {
                width: parent ? parent.width : 0
                implicitWidth: installedColumn.implicitWidth
                implicitHeight: installedColumn.implicitHeight

                ColumnLayout {
                    id: installedColumn
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 30
                    spacing: 20

                    Text {
                        text: "Welcome to Kon Launcher"
                        font.pixelSize: 32
                        font.bold: true
                        color: "#ffffff"
                        Layout.topMargin: 20
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Text.AlignHCenter
                    }

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

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 15

                        Button {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 60
                            text: "PLAY"
                            enabled: !minecraftManager.isRunning

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
                                var version = minecraftManager.installedVersion
                                console.log("[Home] Launching game with version:", version, "and profile:", profileManager.currentProfile)
                                minecraftManager.runGame(version, "", profileManager.currentProfile)
                            }
                        }

                        Button {
                            Layout.preferredWidth: 150
                            Layout.preferredHeight: 60
                            text: "STOP"
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
                                console.log("[Home] Stopping game")
                                minecraftManager.stopGame()
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        color: minecraftManager.isRunning ? "#1b5e20" : "#3d3d3d"
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
                                text: (typeof minecraftManager !== 'undefined') ? minecraftManager.status : ""
                                font.pixelSize: 16
                                color: minecraftManager.isRunning ? "#81C784" : "#b0b0b0"
                                font.bold: true
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }
                }
            }
        }

        Component {
            id: versionSelectedComponent

            Item {
                id: rootSelected
                width: parent ? parent.width : 0
                // Height grows based on content, with minimum of viewport height
                height: Math.max(homeScroll.availableHeight, contentColumn.implicitHeight)

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

                // Main content column to properly calculate implicitHeight
                ColumnLayout {
                    id: contentColumn
                    anchors.fill: parent
                    spacing: 0

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
                            anchors.verticalCenter: parent.verticalCenter
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
                                Layout.preferredWidth: 450
                                Layout.preferredHeight: 120
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
                                            text: "Minecraft " + selectedVersion
                                            color: "#4CAF50"
                                            font.bold: true
                                        }

                                        Text {
                                            text: "Current:"
                                            color: "#b0b0b0"
                                        }
                                        Text {
                                            text: minecraftManager.installedVersion || "Latest"
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
                                    
                                    // Custom drawn icon
                                    Canvas {
                                        width: 30
                                        height: 30
                                        anchors.verticalCenter: parent.verticalCenter
                                        
                                        onPaint: {
                                            var ctx = getContext("2d");
                                            ctx.reset();
                                            ctx.fillStyle = "#ffffff";
                                            
                                            if (actionButton.isGameRunning) {
                                                // Draw Square (Stop)
                                                ctx.fillRect(0, 0, width, height);
                                            } else {
                                                // Draw Triangle (Play)
                                                ctx.beginPath();
                                                ctx.moveTo(0, 0);
                                                ctx.lineTo(width, height / 2);
                                                ctx.lineTo(0, height);
                                                ctx.closePath();
                                                ctx.fill();
                                            }
                                        }
                                        // Repaint when running state changes
                                        onVisibleChanged: requestPaint()
                                        Connections {
                                            target: actionButton
                                            function onIsGameRunningChanged() { 
                                                var canvas = parent.children[0]
                                                canvas.requestPaint()
                                            }
                                        }
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
