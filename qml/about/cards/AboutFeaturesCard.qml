import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    color: themeManager.colors["background_primary"]
    radius: 16
    border.color: themeManager.colors["border"]
    border.width: 1
    Layout.fillWidth: true
    Layout.minimumHeight: Math.max(implicitHeight, 210)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            Rectangle {
                Layout.preferredWidth: 56
                Layout.preferredHeight: 56
                Layout.alignment: Qt.AlignTop
                radius: 12
                color: themeManager.colors["surface"]
                border.color: themeManager.colors["border"]
                border.width: 1

                Image {
                    anchors.fill: parent
                    anchors.margins: 8
                    source: "qrc:/assets/media/directAccess.png"
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }
            }

            Text {
                Layout.fillWidth: true
                text: qsTr("Information and Features")
                font.pixelSize: 20
                font.bold: true
                color: themeManager.colors["text_primary"]
                wrapMode: Text.WordWrap
                Layout.alignment: Qt.AlignVCenter
            }
        }

        Text {
            Layout.fillWidth: true
            text: qsTr("• Complete profile management and language support\n• Real-time logging for debugging and support\n• Seamless integration with Flatpak")    
            color: themeManager.colors["text_secondary"]
            font.pixelSize: 13
            lineHeight: 1.6
            wrapMode: Text.WordWrap
        }
    }
}
