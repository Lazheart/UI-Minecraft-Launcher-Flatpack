import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    color: "#2d2d2d"
    opacity: 0.95
    radius: 8
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15
        
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            
            Text {
                text: "Registro de eventos"
                font.pixelSize: 16
                font.bold: true
                color: "#ffffff"
            }
            
            Item { Layout.fillWidth: true }
            
            Button {
                text: "Limpiar"
                
                background: Rectangle {
                    color: parent.pressed ? "#616161" : "#757575"
                    radius: 4
                }
                
                contentItem: Text {
                    text: parent.text
                    color: "#ffffff"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: {
                    logArea.clear()
                }
            }
            
            Button {
                text: "Exportar"
                
                background: Rectangle {
                    color: parent.pressed ? "#388E3C" : "#4CAF50"
                    radius: 4
                }
                
                contentItem: Text {
                    text: parent.text
                    color: "#ffffff"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: {
                    // TODO: Implementar exportación de logs
                    console.log("[QML] Exportar logs")
                }
            }
        }
        
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            
            TextArea {
                id: logArea
                readOnly: true
                wrapMode: TextArea.Wrap
                selectByMouse: true
                font.family: "Monospace"
                font.pixelSize: 11
                color: "#ffffff"
                
                background: Rectangle {
                    color: "#1e1e1e"
                    radius: 4
                    border.color: "#3d3d3d"
                }
                
                // Función para agregar líneas al log
                function append(message) {
                    var timestamp = Qt.formatDateTime(new Date(), "hh:mm:ss")
                    logArea.text += "[" + timestamp + "] " + message + "\n"
                    
                    // Auto-scroll al final
                    logArea.cursorPosition = logArea.length
                }
            }
        }
        
        // Información del sistema
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            color: "#3d3d3d"
            radius: 8
            
            GridLayout {
                anchors.fill: parent
                anchors.margins: 15
                columns: 4
                columnSpacing: 20
                rowSpacing: 5
                
                Text {
                    text: "Sistema:"
                    color: "#b0b0b0"
                    font.pixelSize: 11
                }
                Text {
                    text: Qt.platform.os
                    color: "#ffffff"
                    font.pixelSize: 11
                }
                
                Text {
                    text: "Qt Version:"
                    color: "#b0b0b0"
                    font.pixelSize: 11
                }
                Text {
                    text: "5.15"
                    color: "#ffffff"
                    font.pixelSize: 11
                }
                
                Text {
                    text: "Plataforma gráfica:"
                    color: "#b0b0b0"
                    font.pixelSize: 11
                }
                Text {
                    text: "Wayland/X11"
                    color: "#ffffff"
                    font.pixelSize: 11
                }
                
                Text {
                    text: "Estado:"
                    color: "#b0b0b0"
                    font.pixelSize: 11
                }
                Text {
                    text: launcherBackend.status
                    color: "#4CAF50"
                    font.pixelSize: 11
                    font.bold: true
                }
            }
        }
    }
}
