import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import "../../Media.js" as Media

Item {
    id: dashboardRoot

    signal versionSelected(string versionName)

    // Tamaño controlado por el padre
    anchors.fill: parent

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
                text: qsTr("Hello, ") + (profileManager ? profileManager.currentProfile : "User")
                font.pixelSize: 32
                font.bold: true
                color: themeManager.colors["text_primary"]
            }

            Text {
                text: qsTr("Welcome back to Kon Launcher. What do you want to play today?")
                font.pixelSize: 16
                color: themeManager.colors["text_secondary"]
            }
        }

        // 2. Quick Launch & Stats Row
        RowLayout {
            Layout.fillWidth: true
            spacing: 20

            // Quick Launch Card
            Rectangle {
                id: quickLaunchCard
                Layout.fillWidth: true
                Layout.preferredHeight: 180
                color: themeManager.colors["surface"]
                radius: 12
                clip: true

                property string versionName: minecraftManager.lastActiveVersion || "Latest"
                property string fullTitle: "Minecraft " + versionName
                property int titleMaxChars: 22
                property string displayTitle: fullTitle.length > titleMaxChars ? versionName : fullTitle

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 25
                    spacing: 15

                    RowLayout {
                        id: quickLaunchHeader
                        Layout.fillWidth: true

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            Text {
                                text: qsTr("READY TO PLAY")
                                font.pixelSize: 12
                                font.bold: true
                                color: themeManager.colors["accent"]
                                font.letterSpacing: 1.5
                            }
                            Text {
                                text: quickLaunchCard.displayTitle
                                font.pixelSize: 24
                                font.bold: true
                                color: themeManager.colors["text_primary"]
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                wrapMode: Text.NoWrap
                                clip: true
                            }
                        }

                        Item { Layout.fillWidth: true }

                        // Status Badge
                        Rectangle {
                            id: statusBadge
                            Layout.preferredWidth: 100
                            Layout.preferredHeight: 30
                            color: minecraftManager.isRunning ? themeManager.colors["accent_pressed"] : themeManager.colors["border"]
                            radius: 15

                            Text {
                                anchors.centerIn: parent
                                text: minecraftManager.isRunning ? "RUNNING" : "STOPPED"
                                font.pixelSize: 10
                                font.bold: true
                                color: minecraftManager.isRunning ? themeManager.colors["accent_bright"] : themeManager.colors["text_secondary"]
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
                            text: qsTr("START GAME")
                            enabled: !minecraftManager.isRunning

                            background: Rectangle {
                                color: parent.enabled ? (parent.pressed ? themeManager.colors["accent_pressed"] : themeManager.colors["accent"]) : themeManager.colors["button_disabled"]
                                radius: 8
                            }

                            contentItem: Item {
                                Row {
                                    anchors.centerIn: parent
                                    spacing: 10
                                    Text {
                                        text: "\u25B6" // ▶
                                        font.pixelSize: 16
                                        color: themeManager.colors["text_primary"]
                                        visible: !minecraftManager.isRunning
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    Text {
                                        text: actionButtonHome.text
                                        font.pixelSize: 16
                                        font.bold: true
                                        color: actionButtonHome.enabled ? themeManager.colors["text_primary"] : themeManager.colors["text_muted"]
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
                                color: parent.pressed ? themeManager.colors["error_dark"] : themeManager.colors["error"]
                                radius: 8
                            }

                            contentItem: Text {
                                text: "\u25A0" // ■
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
                color: themeManager.colors["background_primary"]
                radius: 12
                border.color: themeManager.colors["border"]
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15

                    Text {
                        text: "INSTALLED VERSIONS"
                        font.pixelSize: 12
                        font.bold: true
                        color: themeManager.colors["text_muted"]
                    }

                    Text {
                        text: minecraftManager.availableVersions.length
                        font.pixelSize: 48
                        font.bold: true
                        color: themeManager.colors["text_primary"]
                    }

                    Text {
                        text: qsTr("Versions loaded")
                        font.pixelSize: 14
                        color: themeManager.colors["text_muted"]
                    }
                }
            }
        }

        // 3. Installed Versions Gallery
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 20

            Text {
                text: qsTr("Your Versions")
                font.pixelSize: 20
                font.bold: true
                color: themeManager.colors["text_primary"]
            }

            Flow {
                id: galleryFlow
                Layout.fillWidth: true
                Layout.preferredHeight: implicitHeight
                spacing: 15
                width: parent.width

                Repeater {
                    model: minecraftManager.availableVersions

                    delegate: Item {
                        width: 160
                        height: 220

                        Rectangle {
                            id: cardBackground
                            anchors.fill: parent
                            color: themeManager.colors["surface"]
                            radius: 10
                            border.color: mouseArea.containsMouse ? themeManager.colors["accent"] : "transparent"
                            border.width: 2
                            visible: false
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

                        Item {
                            id: contentLayer
                            anchors.fill: parent
                            visible: false

                            Rectangle {
                                anchors.fill: parent
                                color: themeManager.colors["surface"]
                                radius: 10
                            }

                            Column {
                                anchors.fill: parent
                                spacing: 0

                                Rectangle {
                                    width: parent.width
                                    height: 120
                                    color: themeManager.colors["border"]

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
                                        color: themeManager.colors["surface_input"]
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

                                Column {
                                    width: parent.width
                                    padding: 12
                                    spacing: 4

                                    Text {
                                        text: modelData.name
                                        font.pixelSize: 16
                                        font.bold: true
                                        color: themeManager.colors["text_primary"]
                                        elide: Text.ElideRight
                                        width: parent.width - 24
                                    }

                                    Text {
                                        text: modelData.tag || modelData.name
                                        font.pixelSize: 12
                                        color: themeManager.colors["text_muted"]
                                    }

                                    Text {
                                        text: modelData.installDate || ""
                                        font.pixelSize: 10
                                        color: themeManager.colors["text_muted"]
                                        font.italic: true
                                    }
                                }
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            radius: 10
                            border.color: mouseArea.containsMouse ? themeManager.colors["accent"] : "transparent"
                            border.width: 2
                            z: 5
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                dashboardRoot.versionSelected(modelData.name)
                            }
                        }

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

    onVisibleChanged: {
        console.log("[HomeDashboard] visible =", visible)
    }
}
