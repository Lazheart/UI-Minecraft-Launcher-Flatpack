import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    color: "#232323"
    radius: 16
    border.color: "#343434"
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
                color: "#2f2f2f"
                border.color: "#404040"
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
                text: "Información y Características"
                font.pixelSize: 20
                font.bold: true
                color: "#ffffff"
                wrapMode: Text.WordWrap
                Layout.alignment: Qt.AlignVCenter
            }
        }

        Text {
            Layout.fillWidth: true
            text: "• Interfaz diseñada con Qt para usabilidad\n• Gestión completa de perfiles y lenguaje \n• Registro en tiempo real para depuración y soporte\n• Integración seamless con Flatpak y app sandbox de Linux"
            color: "#b8b8b8"
            font.pixelSize: 13
            lineHeight: 1.6
            wrapMode: Text.WordWrap
        }
    }
}
