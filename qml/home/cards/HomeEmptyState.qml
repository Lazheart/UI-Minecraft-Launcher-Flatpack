import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../../Media.js" as Media

Item {
    id: emptyRoot

    // Señal que el padre conectará para abrir el diálogo de instalación
    signal installRequested()

    // Estas propiedades permiten al padre controlar el tamaño
    property real availableWidth: width
    property real availableHeight: height

    width: parent ? parent.width : emptyColumn.implicitWidth
    height: Math.max(availableHeight, emptyColumn.implicitHeight + 80)

    Column {
        id: emptyColumn
        width: Math.min(parent.width - 40, 420)
        spacing: 20
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Math.max(40, (parent.height - implicitHeight) / 2)

        Text {
            text: "Welcome to Kon Launcher"
            font.pixelSize: 32
            font.bold: true
            color: "#ffffff"
            horizontalAlignment: Text.AlignHCenter
            width: parent.width
        }

        Column {
            spacing: 20
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                text: "Install new version clicking on icon of"
                font.pixelSize: 16
                color: "#b0b0b0"
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
            }

            Item {
                width: 80
                height: 80

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: emptyRoot.installRequested()

                    Image {
                        id: installIcon
                        anchors.fill: parent
                        source: Media.BedrockLogo
                        fillMode: Image.PreserveAspectFit
                        cache: true
                        opacity: parent.containsMouse ? 0.8 : 1.0
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: "#4CAF50"
                        radius: 8
                        visible: installIcon.status !== Image.Ready
                        opacity: parent.containsMouse ? 0.8 : 1.0
                        Behavior on opacity { NumberAnimation { duration: 200 } }

                        Text {
                            anchors.centerIn: parent
                            text: "B"
                            font.pixelSize: 48
                            font.bold: true
                            color: "#ffffff"
                        }
                    }
                }
            }

            Text {
                text: "Install new version"
                font.pixelSize: 14
                color: "#ffffff"
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
            }
        }
    }
}
