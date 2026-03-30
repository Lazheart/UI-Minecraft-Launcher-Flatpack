import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

Rectangle {
    id: cardRoot
    color: themeManager.colors["surface_card"]
    radius: 16
    border.color: themeManager.colors["border"]
    border.width: 1
    clip: true
    Layout.preferredHeight: 220
    Layout.fillWidth: true

    Image {
        id: bgImage
        anchors.fill: parent
        source: "qrc:/assets/backgrounds/Minecraft_village.jpg"
        fillMode: Image.PreserveAspectCrop
        opacity: 0.35
        smooth: true
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: mask
        }
    }

    Rectangle {
        id: mask
        anchors.fill: parent
        radius: 16
        visible: false
    }

    Rectangle {
        anchors.fill: parent
        color: themeManager.colors["background_secondary"]
        opacity: 0.55
        radius: 16
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 28
        spacing: 24

        Rectangle {
            Layout.preferredWidth: 120
            Layout.preferredHeight: 120
            Layout.alignment: Qt.AlignVCenter
            radius: 14
            color: themeManager.colors["surface"]
            border.color: themeManager.colors["border"]
            border.width: 1

            Image {
                anchors.fill: parent
                anchors.margins: 12
                source: "qrc:/assets/media/bedrockLogo.png"
                fillMode: Image.PreserveAspectFit
                smooth: true
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 10

            Text {
                text: "Minecraft Bedrock Launcher"
                font.pixelSize: 24
                font.bold: true
                color: themeManager.colors["text_primary"]
            }

            Text {
                text: "Versión: " + minecraftManager.getLauncherVersion()
                color: themeManager.colors["text_secondary"]
                font.pixelSize: 14
            }

            Text {
                Layout.fillWidth: true
                text: "Launcher de Minecraft Bedrock Edition en Linux mediante flatpak con integración de perfiles, customización y registros en tiempo real."
                color: themeManager.colors["text_muted"]
                font.pixelSize: 13
                wrapMode: Text.WordWrap
            }
        }
    }
}
