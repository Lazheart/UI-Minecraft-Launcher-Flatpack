import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: pathsCard
    color: "#2d2d2d"
    radius: 8
    border.color: "#3d3d3d"
    border.width: 1
    Layout.fillWidth: true
    Layout.preferredHeight: 280

    property string currentField: ""

    ColumnLayout {
        anchors {
            fill: parent
            margins: 20
        }
        spacing: 15

        Text {
            text: "PATHS"
            color: "#ffffff"
            font.pixelSize: 14
            font.bold: true
            font.capitalization: Font.AllUppercase
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 12

            // Versiones
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Text {
                    text: "Installed Versions"
                    color: "#ffffff"
                    font.pixelSize: 12
                    Layout.preferredWidth: 160
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 35
                    color: "#1e1e1e"
                    radius: 4
                    border.color: "#555555"
                    border.width: 1

                    ScrollView {
                        anchors {
                            fill: parent
                            leftMargin: 10
                            rightMargin: 10
                        }
                        clip: true
                        ScrollBar.horizontal.policy: ScrollBar.AsNeeded
                        ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                        
                        TextInput {
                            id: versionsInput
                            width: Math.max(parent.width, contentWidth)
                            height: parent.height
                            verticalAlignment: TextInput.AlignVCenter
                            color: "#b0b0b0"
                            font.pixelSize: 11
                            readOnly: true
                            selectByMouse: true
                            text: (typeof pathManager !== 'undefined' && pathManager.versionsDir && pathManager.versionsDir.length) ? pathManager.versionsDir : "/home/user/.minecraft/versions"
                        }
                    }
                }

                Button {
                    text: "Browse"
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 35

                    background: Rectangle {
                        color: parent.pressed ? "#505050" : "#3d3d3d"
                        radius: 3
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "#ffffff"
                        font.pixelSize: 11
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        console.log("Browse versions directory")
                        if (typeof pathManager !== 'undefined') pathManager.ensurePathsExist()
                        var p = (typeof pathManager !== 'undefined' && pathManager.versionsDir && pathManager.versionsDir.length) ? pathManager.versionsDir : "/home/user/.minecraft/versions"
                        var uri = p.indexOf("file://") === 0 ? p : ("file://" + p)
                        Qt.openUrlExternally(uri)
                    }
                }
            }

            // Backgrounds
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Text {
                    text: "Installed Backgrounds"
                    color: "#ffffff"
                    font.pixelSize: 12
                    Layout.preferredWidth: 160
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 35
                    color: "#1e1e1e"
                    radius: 4
                    border.color: "#555555"
                    border.width: 1

                    ScrollView {
                        anchors {
                            fill: parent
                            leftMargin: 10
                            rightMargin: 10
                        }
                        clip: true
                        ScrollBar.horizontal.policy: ScrollBar.AsNeeded
                        ScrollBar.vertical.policy: ScrollBar.AlwaysOff

                        TextInput {
                            id: backgroundsInput
                            width: Math.max(parent.width, contentWidth)
                            height: parent.height
                            verticalAlignment: TextInput.AlignVCenter
                            color: "#b0b0b0"
                            font.pixelSize: 11
                            readOnly: true
                            selectByMouse: true
                            text: (typeof pathManager !== 'undefined' && pathManager.dataDir && pathManager.dataDir.length) ? pathManager.dataDir + "/backgrounds" : "/home/user/.minecraft/backgrounds"
                        }
                    }
                }

                Button {
                    text: "Browse"
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 35

                    background: Rectangle {
                        color: parent.pressed ? "#505050" : "#3d3d3d"
                        radius: 3
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "#ffffff"
                        font.pixelSize: 11
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        console.log("Browse backgrounds directory")
                        if (typeof pathManager !== 'undefined') pathManager.ensurePathsExist()
                        var bp = (typeof pathManager !== 'undefined' && pathManager.dataDir && pathManager.dataDir.length) ? pathManager.dataDir + "/backgrounds" : "/home/user/.minecraft/backgrounds"
                        var uri = bp.indexOf("file://") === 0 ? bp : ("file://" + bp)
                        Qt.openUrlExternally(uri)
                    }
                }
            }

            // Icons
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Text {
                    text: "Installed Icons"
                    color: "#ffffff"
                    font.pixelSize: 12
                    Layout.preferredWidth: 160
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 35
                    color: "#1e1e1e"
                    radius: 4
                    border.color: "#555555"
                    border.width: 1

                    ScrollView {
                        anchors {
                            fill: parent
                            leftMargin: 10
                            rightMargin: 10
                        }
                        clip: true
                        ScrollBar.horizontal.policy: ScrollBar.AsNeeded
                        ScrollBar.vertical.policy: ScrollBar.AlwaysOff

                        TextInput {
                            id: iconsInput
                            width: Math.max(parent.width, contentWidth)
                            height: parent.height
                            verticalAlignment: TextInput.AlignVCenter
                            color: "#b0b0b0"
                            font.pixelSize: 11
                            readOnly: true
                            selectByMouse: true
                            text: (typeof pathManager !== 'undefined' && pathManager.dataDir && pathManager.dataDir.length) ? pathManager.dataDir + "/icons" : "/home/user/.minecraft/icons"
                        }
                    }
                }

                Button {
                    text: "Browse"
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 35

                    background: Rectangle {
                        color: parent.pressed ? "#505050" : "#3d3d3d"
                        radius: 3
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "#ffffff"
                        font.pixelSize: 11
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        console.log("Browse icons directory")
                        if (typeof pathManager !== 'undefined') pathManager.ensurePathsExist()
                        var ip = (typeof pathManager !== 'undefined' && pathManager.dataDir && pathManager.dataDir.length) ? pathManager.dataDir + "/icons" : "/home/user/.minecraft/icons"
                        var uri = ip.indexOf("file://") === 0 ? ip : ("file://" + ip)
                        Qt.openUrlExternally(uri)
                    }
                }
            }

            // Profile Config
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Text {
                    text: "Profile Config"
                    color: "#ffffff"
                    font.pixelSize: 12
                    Layout.preferredWidth: 160
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 35
                    color: "#1e1e1e"
                    radius: 4
                    border.color: "#555555"
                    border.width: 1

                    ScrollView {
                        anchors {
                            fill: parent
                            leftMargin: 10
                            rightMargin: 10
                        }
                        clip: true
                        ScrollBar.horizontal.policy: ScrollBar.AsNeeded
                        ScrollBar.vertical.policy: ScrollBar.AlwaysOff

                        TextInput {
                            id: profilesInput
                            width: Math.max(parent.width, contentWidth)
                            height: parent.height
                            verticalAlignment: TextInput.AlignVCenter
                            color: "#b0b0b0"
                            font.pixelSize: 11
                            readOnly: true
                            selectByMouse: true
                            text: (typeof pathManager !== 'undefined' && pathManager.profilesDir && pathManager.profilesDir.length) ? pathManager.profilesDir : "/home/user/.minecraft/profiles"
                        }
                    }
                }

                Button {
                    text: "Browse"
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 35

                    background: Rectangle {
                        color: parent.pressed ? "#505050" : "#3d3d3d"
                        radius: 3
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "#ffffff"
                        font.pixelSize: 11
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        console.log("Browse profiles directory")
                        if (typeof pathManager !== 'undefined') pathManager.ensurePathsExist()
                        var pp = (typeof pathManager !== 'undefined' && pathManager.profilesDir && pathManager.profilesDir.length) ? pathManager.profilesDir : "/home/user/.minecraft/profiles"
                        var uri = pp.indexOf("file://") === 0 ? pp : ("file://" + pp)
                        Qt.openUrlExternally(uri)
                    }
                }
            }
        }
    }
}
