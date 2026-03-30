import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    color: themeManager.colors["surface_card"]
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
                color: themeManager.colors["text_primary"]
            }
            
            Item { Layout.fillWidth: true }
            
            Button {
                text: "Limpiar"
                
                background: Rectangle {
                    color: parent.pressed ? themeManager.colors["logs_button_neutral_pressed"] : themeManager.colors["logs_button_neutral"]
                    radius: 4
                }
                
                contentItem: Text {
                    text: parent.text
                    color: themeManager.colors["text_primary"]
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
                    color: parent.pressed ? themeManager.colors["accent_pressed"] : themeManager.colors["accent"]
                    radius: 4
                }
                
                contentItem: Text {
                    text: parent.text
                    color: themeManager.colors["text_primary"]
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
                color: themeManager.colors["text_primary"]
                
                background: Rectangle {
                    color: themeManager.colors["background_primary"]
                    radius: 4
                    border.color: themeManager.colors["border"]
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
            color: themeManager.colors["border"]
            radius: 8
            
            GridLayout {
                anchors.fill: parent
                anchors.margins: 15
                columns: 4
                columnSpacing: 20
                rowSpacing: 5
                
                Text {
                    text: "Sistema:"
                    color: themeManager.colors["text_secondary"]
                    font.pixelSize: 11
                }
                Text {
                    text: Qt.platform.os
                    color: themeManager.colors["text_primary"]
                    font.pixelSize: 11
                }
                
                Text {
                    text: "Qt Version:"
                    color: themeManager.colors["text_secondary"]
                    font.pixelSize: 11
                }
                Text {
                    text: "5.15"
                    color: themeManager.colors["text_primary"]
                    font.pixelSize: 11
                }
                
                Text {
                    text: "Plataforma gráfica:"
                    color: themeManager.colors["text_secondary"]
                    font.pixelSize: 11
                }
                Text {
                    text: "Wayland/X11"
                    color: themeManager.colors["text_primary"]
                    font.pixelSize: 11
                }
                
                Text {
                    text: "Estado:"
                    color: themeManager.colors["text_secondary"]
                    font.pixelSize: 11
                }
                Text {
                    text: (typeof minecraftManager !== 'undefined') ? minecraftManager.status : ""
                    color: themeManager.colors["accent"]
                    font.pixelSize: 11
                    font.bold: true
                }
            }
        }
    }
}
