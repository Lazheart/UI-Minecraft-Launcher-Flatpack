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
    
    ScrollView {
        id: homeScroll
        anchors.fill: parent
        clip: true

        Item {
            id: contentRoot
            width: homeScroll.availableWidth
            height: Math.max(homeScroll.availableHeight, contentLoader.implicitHeight)

            Loader {
                id: contentLoader
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: minecraftManager.isInstalled ? parent.top : undefined
                anchors.topMargin: minecraftManager.isInstalled ? 30 : 0
                anchors.verticalCenter: minecraftManager.isInstalled ? undefined : parent.verticalCenter
                width: minecraftManager.isInstalled ? parent.width : Math.min(parent.width, 420)
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
                        text: "Welcome to Enkidu Launcher"
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
                        text: "Welcome to Enkidu Launcher"
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
                width: parent ? parent.width : 0
                implicitWidth: selectedLayout.implicitWidth
                implicitHeight: selectedLayout.implicitHeight

                ColumnLayout {
                    id: selectedLayout
                    anchors.fill: parent
                    spacing: 0

                    // Background Image
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 350
                        color: "#1e1e1e"

                        Image {
                            id: backgroundImage
                            anchors.fill: parent
                            source: Media.VersionBackgrounds[selectedVersion] || Media.VersionBackgrounds["1.21.0"]
                            fillMode: Image.PreserveAspectCrop
                            cache: true

                            Rectangle {
                                anchors.fill: parent
                                color: "black"
                                opacity: 0.3
                            }
                        }

                        // Header with title and import button
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 30
                            spacing: 20

                            ColumnLayout {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                spacing: 10

                                Text {
                                    text: "Welcome to Enkidu Launcher"
                                    font.pixelSize: 32
                                    font.bold: true
                                    color: "#ffffff"
                                    Layout.alignment: Qt.AlignBottom
                                }

                                Text {
                                    text: "Minecraft " + selectedVersion
                                    font.pixelSize: 24
                                    color: "#4CAF50"
                                    font.bold: true
                                }
                            }

                            Item {
                                Layout.fillHeight: true
                            }
                        }
                    }

                    // Content area
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 30
                            spacing: 20

                            // Status rectangle
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
                                        text: "Version Information"
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

                            Item { Layout.fillHeight: true }

                            // Action buttons at bottom
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 15

                                // Play button
                                Button {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 70
                                    enabled: !minecraftManager.isRunning

                                    background: Rectangle {
                                        color: parent.enabled ? (parent.pressed ? "#388E3C" : "#4CAF50") : "#555555"
                                        radius: 8
                                    }

                                    contentItem: RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        spacing: 15

                                        Image {
                                            Layout.preferredWidth: 40
                                            Layout.preferredHeight: 40
                                            source: Media.PlayIcon
                                            fillMode: Image.PreserveAspectFit
                                        }

                                        Text {
                                            text: "PLAY"
                                            font.pixelSize: 20
                                            font.bold: true
                                            color: parent.parent.enabled ? "#ffffff" : "#888888"
                                            Layout.fillWidth: true
                                        }
                                    }

                                    onClicked: {
                                        console.log("[Home] Launching game with version:", selectedVersion, "and profile:", profileManager.currentProfile)
                                        minecraftManager.runGame(selectedVersion, "", profileManager.currentProfile)
                                    }
                                }

                                // Graphic options button
                                Button {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 70

                                    background: Rectangle {
                                        color: pressed ? "#3d3d3d" : "#2d2d2d"
                                        radius: 8
                                        border.color: hovered ? "#4CAF50" : "#555555"
                                        border.width: 2
                                    }

                                    contentItem: RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        spacing: 15

                                        Image {
                                            Layout.preferredWidth: 40
                                            Layout.preferredHeight: 40
                                            source: Media.DropperIcon
                                            fillMode: Image.PreserveAspectFit
                                        }

                                        Text {
                                            text: "Graphic Options"
                                            font.pixelSize: 18
                                            color: "#ffffff"
                                            font.bold: true
                                            Layout.fillWidth: true
                                        }
                                    }

                                    onClicked: {
                                        console.log("[Home] Opening graphic options for version:", selectedVersion)
                                    }
                                }
                            }
                        }
                    }

                    // Back button area
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 60
                        color: "#2d2d2d"
                        radius: 8

                        Button {
                            anchors.fill: parent
                            anchors.margins: 10
                            text: "← Back to Home"

                            background: Rectangle {
                                color: parent.pressed ? "#3d3d3d" : "#1e1e1e"
                                radius: 4
                                border.color: parent.hovered ? "#4CAF50" : "#555555"
                                border.width: 1
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
                    }
                }
            }
        }
    }
}
