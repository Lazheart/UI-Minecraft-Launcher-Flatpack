import QtQuick 2.15
import QtQuick.Controls 2.15

Button {
    id: button
    
    property bool isActive: false
    
    implicitWidth: 100
    implicitHeight: 50
    
    background: Rectangle {
        color: button.isActive ? themeManager.colors["accent"] : (button.hovered ? themeManager.colors["border"] : themeManager.colors["surface"])
        border.color: button.isActive ? themeManager.colors["accent_bright"] : "transparent"
        border.width: 2
        radius: 6
        
        Behavior on color {
            ColorAnimation { duration: 200 }
        }
    }
    
    contentItem: Text {
        text: button.text
        font.pixelSize: 14
        font.bold: button.isActive
        color: button.isActive ? themeManager.colors["text_primary"] : themeManager.colors["text_secondary"]
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
