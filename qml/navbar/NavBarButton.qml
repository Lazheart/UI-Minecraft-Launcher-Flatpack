import QtQuick 2.15
import QtQuick.Controls 2.15

Button {
    id: button
    
    property bool isActive: false
    
    implicitWidth: 100
    implicitHeight: 50
    
    background: Rectangle {
        color: button.isActive ? "#4CAF50" : (button.hovered ? "#3d3d3d" : "#2d2d2d")
        border.color: button.isActive ? "#66BB6A" : "transparent"
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
        color: button.isActive ? "#ffffff" : "#b0b0b0"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
