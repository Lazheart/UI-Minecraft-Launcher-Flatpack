import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    color: "#252525"
    radius: 16
    border.color: "#363636"
    border.width: 1
    clip: true
    Layout.preferredHeight: 220
    Layout.fillWidth: true

    Image {
        anchors.fill: parent
        source: "qrc:/assets/backgrounds/Minecraft_village.jpg"
        fillMode: Image.PreserveAspectCrop
        opacity: 0.35
        smooth: true
    }

    Rectangle {
        anchors.fill: parent
        color: "#121212"
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
            color: "#1f1f1f"
            border.color: "#3a3a3a"
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
                color: "#ffffff"
            }

            Text {
                text: "Versión: " + minecraftManager.getLauncherVersion()
                color: "#d4d4d4"
                font.pixelSize: 14
            }

            Text {
                Layout.fillWidth: true
                text: "Launcher de Minecraft Bedrock Edition en Linux mediante flatpak con integración de perfiles, customización y registros en tiempo real."
                color: "#c0c0c0"
                font.pixelSize: 13
                wrapMode: Text.WordWrap
            }
        }
    }
}
