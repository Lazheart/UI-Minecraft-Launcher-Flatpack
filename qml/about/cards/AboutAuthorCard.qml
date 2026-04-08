import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    color: themeManager.colors["surface_card"]
    radius: 18
    border.color: themeManager.colors["border"]
    border.width: 1
    Layout.minimumHeight: 200
    Layout.fillWidth: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 28
        spacing: 18

        RowLayout {
            Layout.fillWidth: true
            spacing: 20

            Image {
                Layout.preferredWidth: 120
                Layout.preferredHeight: 120
                Layout.alignment: Qt.AlignTop
                source: "qrc:/assets/media/yo.png"
                fillMode: Image.PreserveAspectFit
                smooth: true
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                spacing: 8

                Text {
                    text: qsTr("Creado por Lazheart")
                    font.pixelSize: 18
                    font.bold: true
                    color: themeManager.colors["text_primary"]
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                Text {
                    Layout.fillWidth: true
                    textFormat: Text.RichText
                    text: "<a href='https://github.com/Lazheart'>https://github.com/Lazheart</a>"
                    color: themeManager.colors["accent"]
                    font.pixelSize: 18
                    font.bold: true
                    linkColor: themeManager.colors["accent"]
                    wrapMode: Text.WordWrap
                    onLinkActivated: Qt.openUrlExternally(link)
                }

                Text {
                    Layout.fillWidth: true
                    text: qsTr("Desarrollo abierto, comunidad activa y soporte continuo para disfrutar de Minecraft Bedrock en Linux.") 
                    wrapMode: Text.WordWrap
                    color: themeManager.colors["text_secondary"]
                    font.pixelSize: 13
                    lineHeight: 1.5
                }
            }
        }
    }
}
