import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    color: "#252525"
    radius: 18
    border.color: "#363636"
    border.width: 1

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
                    text: "Creado por Lazheart"
                    font.pixelSize: 18
                    font.bold: true
                    color: "#ffffff"
                }

                Text {
                    Layout.fillWidth: true
                    textFormat: Text.RichText
                    text: "<a href='https://github.com/Lazheart'>https://github.com/Lazheart</a>"
                    color: "#4CAF50"
                    font.pixelSize: 18
                    font.bold: true
                    linkColor: "#4CAF50"
                    wrapMode: Text.WordWrap
                    onLinkActivated: Qt.openUrlExternally(link)
                }

                Text {
                    Layout.fillWidth: true
                    text: "Desarrollo abierto, comunidad activa y soporte continuo para disfrutar de tu biblioteca de Minecraft Bedrock en Linux."
                    wrapMode: Text.WordWrap
                    color: "#bcbcbc"
                    font.pixelSize: 13
                    lineHeight: 1.5
                }
            }
        }
    }
}
