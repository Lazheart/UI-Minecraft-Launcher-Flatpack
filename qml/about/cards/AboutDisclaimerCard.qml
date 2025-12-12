import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    color: "#2f2f2f"
    radius: 16
    border.color: "#404040"
    border.width: 1
    Layout.fillWidth: true
    Layout.minimumHeight: Math.max(implicitHeight, 400)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 12

        Text {
            text: "DISCLAIMER"
            font.pixelSize: 18
            font.bold: true
            color: "#ffffff"
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Text {
            Layout.fillWidth: true
            text: "Este launcher de Minecraft Bedrock no incluye ni proporciona archivos del juego, ni sirve como método para obtener copias no autorizadas. Su función es permitir que los usuarios ejecuten contenido que ya poseen legítimamente, incluyendo betas y builds obtenidas oficialmente de Mojang/Microsoft.\n\nA diferencia de otros lanzadores que dependen exclusivamente de Google Play, este proyecto no impone un método de distribución específico, permitiendo a los compradores del juego acceder a las versiones a las que tienen derecho.\n\nEl uso de este software requiere ser propietario legal de Minecraft Bedrock Edition. Cualquier uso con archivos obtenidos por medios no autorizados está estrictamente prohibido y no es apoyado por este proyecto."
            color: "#d0d0d0"
            font.pixelSize: 13
            lineHeight: 1.6
            wrapMode: Text.WordWrap
        }
    }
}
