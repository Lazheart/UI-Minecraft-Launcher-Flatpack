import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import "../../Media.js" as Media

Item {
    id: rootSelected

    // Altura disponible del viewport para evitar huecos negros
    property real availableHeight: 0

    // Versión seleccionada a mostrar (nombre)
    property string versionName: ""

    // Señal para pedir al padre volver al dashboard
    signal backRequested()

    // Datos completos de la versión seleccionada
    property var selectedVersionData: {
        if (versionName === "") return null;
        var versions = minecraftManager.availableVersions;
        for (var i = 0; i < versions.length; i++) {
            if (versions[i].name === versionName) return versions[i];
        }
        return null;
    }

    width: parent ? parent.width : 0
    height: Math.max(availableHeight, contentColumn.implicitHeight)
    implicitHeight: contentColumn.implicitHeight

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

    onVisibleChanged: {
        console.log("[HomeVersionSelected] visible =", visible, "versionName =", versionName)
    }

    // Background Image
    Rectangle {
        anchors.fill: parent
        color: themeManager.colors["background_primary"]
        z: 0

        Image {
            id: backgroundImage
            anchors.fill: parent
            source: getVersionBackground(versionName)
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
                text: "\u2190 Back to Home"

                background: Rectangle {
                    color: parent.pressed ? themeManager.colors["border"] : themeManager.colors["background_primary"]
                    radius: 8
                    border.color: parent.hovered ? themeManager.colors["accent"] : themeManager.colors["border_muted"]
                    border.width: 1
                    opacity: 0.9
                }

                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 14
                    color: themeManager.colors["text_primary"]
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: rootSelected.backRequested()
            }

            // Graphic Options Button (Right)
            Button {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 30
                width: 200
                height: 40

                background: Rectangle {
                    color: parent.pressed ? themeManager.colors["border"] : themeManager.colors["surface"]
                    radius: 8
                    border.color: parent.hovered ? themeManager.colors["accent"] : themeManager.colors["border_muted"]
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
                            color: themeManager.colors["text_primary"]
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
                    color: themeManager.colors["text_primary"]
                }

                Text {
                    text: "Hola " + (profileManager ? profileManager.currentProfile : "Usuario")
                    font.pixelSize: 24
                    color: themeManager.colors["accent"]
                    font.bold: true
                }

                // Version Info Box
                Rectangle {
                    Layout.preferredWidth: 500
                    Layout.preferredHeight: 160
                    color: themeManager.colors["surface"]
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
                            color: themeManager.colors["text_primary"]
                        }

                        GridLayout {
                            columns: 2
                            columnSpacing: 15
                            rowSpacing: 8
                            Layout.fillWidth: true

                            Text {
                                text: "Selected:"
                                color: themeManager.colors["text_secondary"]
                            }
                            Text {
                                text: versionName
                                color: themeManager.colors["accent"]
                                font.bold: true
                            }

                            Text {
                                text: "Tag:"
                                color: themeManager.colors["text_secondary"]
                            }
                            Text {
                                text: (selectedVersionData && selectedVersionData.tag) ? selectedVersionData.tag : "None"
                                color: themeManager.colors["text_primary"]
                            }

                            Text {
                                text: "Created:"
                                color: themeManager.colors["text_secondary"]
                            }
                            Text {
                                text: (selectedVersionData && selectedVersionData.installDate) ? selectedVersionData.installDate : "Unknown"
                                color: themeManager.colors["text_primary"]
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
                           (parent.pressed ? themeManager.colors["error_dark"] : themeManager.colors["error"]) :
                           (parent.pressed ? themeManager.colors["accent_pressed"] : themeManager.colors["accent"])
                    radius: 8
                }

                contentItem: Item {
                    anchors.fill: parent

                    Row {
                        anchors.centerIn: parent
                        spacing: 15

                        Text {
                            text: actionButton.isGameRunning ? "\u25A0" : "\u25B6"
                            font.pixelSize: 24
                            color: themeManager.colors["text_primary"]
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: actionButton.text
                            font.pixelSize: 24
                            font.bold: true
                            font.letterSpacing: 5
                            color: themeManager.colors["text_primary"]
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                onClicked: {
                    if (isGameRunning) {
                        console.log("[Home] Stopping game")
                        minecraftManager.stopGame()
                    } else {
                        console.log("[Home] Launching game version:", versionName)
                        minecraftManager.runGame(versionName, "", profileManager.currentProfile)
                    }
                }
            }
        }
    }
}
