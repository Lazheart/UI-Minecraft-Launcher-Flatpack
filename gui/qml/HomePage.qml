import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "Media.js" as Media

Rectangle {
    color: "#1e1e1e"
    
    ScrollView {
        id: homeScroll
        anchors.fill: parent
        clip: true

        Item {
            id: contentRoot
            width: homeScroll.availableWidth
            implicitHeight: contentLoader.implicitHeight

            Loader {
                id: contentLoader
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: minecraftManager.isInstalled ? parent.top : undefined
                anchors.topMargin: minecraftManager.isInstalled ? 30 : 0
                anchors.verticalCenter: minecraftManager.isInstalled ? undefined : parent.verticalCenter
                width: minecraftManager.isInstalled ? parent.width : Math.min(parent.width, 420)
                sourceComponent: minecraftManager.isInstalled ? installedComponent : emptyComponent
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
                    width: parent.width
                    spacing: 20
                    anchors.horizontalCenter: parent.horizontalCenter

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

                            Image {
                                id: installIcon
                                anchors.fill: parent
                                source: Media.BedrockLogo
                                fillMode: Image.PreserveAspectFit
                                cache: true
                            }

                            Rectangle {
                                anchors.fill: parent
                                color: "#4CAF50"
                                radius: 8
                                visible: installIcon.status !== Image.Ready

                                Text {
                                    anchors.centerIn: parent
                                    text: "B"
                                    font.pixelSize: 48
                                    font.bold: true
                                    color: "#ffffff"
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
                            enabled: !launcherBackend.isRunning

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
                                console.log("[Home] Launching game with profile:", profileManager.currentProfile)
                                launcherBackend.launchGame(profileManager.currentProfile)
                            }
                        }

                        Button {
                            Layout.preferredWidth: 150
                            Layout.preferredHeight: 60
                            text: "STOP"
                            enabled: launcherBackend.isRunning

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
                                launcherBackend.stopGame()
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        color: launcherBackend.isRunning ? "#1b5e20" : "#3d3d3d"
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
                                text: launcherBackend.status
                                font.pixelSize: 16
                                color: launcherBackend.isRunning ? "#81C784" : "#b0b0b0"
                                font.bold: true
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }
                }
            }
        }
    }
}
