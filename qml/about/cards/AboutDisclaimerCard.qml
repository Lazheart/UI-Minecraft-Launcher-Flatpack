import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    color: themeManager.colors["surface"]
    radius: 16
    border.color: themeManager.colors["border"]
    border.width: 1
    Layout.fillWidth: true
    Layout.minimumHeight: Math.max(implicitHeight, 400)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 12

        Text {
            text: qsTr("DISCLAIMER")
            font.pixelSize: 18
            font.bold: true
            color: themeManager.colors["text_primary"]
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Text {
            Layout.fillWidth: true
            text: qsTr("This launcher of Minecraft Bedrock does not include or provide game files, nor does it serve as a method to obtain unauthorized copies. Its function is to allow users to run content they legitimately own, including betas and builds obtained officially from Mojang/Microsoft.\n\nUnlike other launchers that depend exclusively on Google Play, this project does not impose a specific distribution method, allowing game buyers to access the versions they are entitled to.\n\nUsing this software requires being a legal owner of Minecraft Bedrock Edition. Any use with files obtained through unauthorized means is strictly prohibited and not supported by this project.")
            color: themeManager.colors["text_secondary"]
            font.pixelSize: 13
            lineHeight: 1.6
            wrapMode: Text.WordWrap
        }
    }
}
