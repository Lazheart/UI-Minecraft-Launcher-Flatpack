import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: pathsCard
    color: themeManager.colors["surface_card"]
    radius: 8
    border.color: themeManager.colors["border"]
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
            text: qsTr("PATHS")
            color: themeManager.colors["text_primary"]
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
                    text: qsTr("Installed Versions")
                    color: themeManager.colors["text_primary"]
                    font.pixelSize: 12
                    Layout.preferredWidth: 160
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 35
                    color: themeManager.colors["background_primary"]
                    radius: 4
                    border.color: themeManager.colors["border_muted"]
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
                            height: 35
                            verticalAlignment: TextInput.AlignVCenter
                            color: themeManager.colors["text_secondary"]
                            font.pixelSize: 11
                            readOnly: true
                            selectByMouse: true
                            text: (typeof pathManager !== 'undefined' && pathManager.versionsDir && pathManager.versionsDir.length) ? pathManager.versionsDir : "/home/user/.minecraft/versions"
                        }
                    }
                }

                Button {
                    text: qsTr("Browse")
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 35

                    background: Rectangle {
                        color: parent.pressed ? themeManager.colors["border_muted"] : themeManager.colors["border"]
                        radius: 3
                    }

                    contentItem: Text {
                        text: parent.text
                        color: themeManager.colors["text_primary"]
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
                    color: themeManager.colors["text_primary"]
                    font.pixelSize: 12
                    Layout.preferredWidth: 160
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 35
                    color: themeManager.colors["background_primary"]
                    radius: 4
                    border.color: themeManager.colors["border_muted"]
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
                            height: 35
                            verticalAlignment: TextInput.AlignVCenter
                            color: themeManager.colors["text_secondary"]
                            font.pixelSize: 11
                            readOnly: true
                            selectByMouse: true
                            text: (typeof pathManager !== 'undefined' && pathManager.dataDir && pathManager.dataDir.length) ? pathManager.dataDir + "/backgrounds" : "/home/user/.minecraft/backgrounds"
                        }
                    }
                }

                Button {
                    text: qsTr("Browse")
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 35

                    background: Rectangle {
                        color: parent.pressed ? themeManager.colors["border_muted"] : themeManager.colors["border"]
                        radius: 3
                    }

                    contentItem: Text {
                        text: parent.text
                        color: themeManager.colors["text_primary"]
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
                    text: qsTr("Installed Icons")
                    color: themeManager.colors["text_primary"]
                    font.pixelSize: 12
                    Layout.preferredWidth: 160
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 35
                    color: themeManager.colors["background_primary"]
                    radius: 4
                    border.color: themeManager.colors["border_muted"]
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
                            height: 35
                            verticalAlignment: TextInput.AlignVCenter
                            color: themeManager.colors["text_secondary"]
                            font.pixelSize: 11
                            readOnly: true
                            selectByMouse: true
                            text: (typeof pathManager !== 'undefined' && pathManager.dataDir && pathManager.dataDir.length) ? pathManager.dataDir + "/icons" : "/home/user/.minecraft/icons"
                        }
                    }
                }

                Button {
                    text: qsTr("Browse")
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 35

                    background: Rectangle {
                        color: parent.pressed ? themeManager.colors["border_muted"] : themeManager.colors["border"]
                        radius: 3
                    }

                    contentItem: Text {
                        text: parent.text
                        color: themeManager.colors["text_primary"]
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
                    text: qsTr("Profile Config")
                    color: themeManager.colors["text_primary"]
                    font.pixelSize: 12
                    Layout.preferredWidth: 160
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 35
                    color: themeManager.colors["background_primary"]
                    radius: 4
                    border.color: themeManager.colors["border_muted"]
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
                            height: 35
                            verticalAlignment: TextInput.AlignVCenter
                            color: themeManager.colors["text_secondary"]
                            font.pixelSize: 11
                            readOnly: true
                            selectByMouse: true
                            text: (typeof pathManager !== 'undefined' && pathManager.profilesDir && pathManager.profilesDir.length) ? pathManager.profilesDir : "/home/user/.minecraft/profiles"
                        }
                    }
                }

                Button {
                    text: qsTr("Browse")
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 35

                    background: Rectangle {
                        color: parent.pressed ? themeManager.colors["border_muted"] : themeManager.colors["border"]
                        radius: 3
                    }

                    contentItem: Text {
                        text: parent.text
                        color: themeManager.colors["text_primary"]
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
