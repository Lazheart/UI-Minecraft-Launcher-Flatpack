import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    color: "#1e1e1e"
    
    ScrollView {
        anchors.fill: parent
        clip: true
        
        ColumnLayout {
            width: parent.width
            spacing: 20
            anchors.margins: 30
            
            Text {
                text: "Settings"
                font.pixelSize: 32
                font.bold: true
                color: "#ffffff"
                Layout.topMargin: 20
            }
            
            // Sección de perfiles
            GroupBox {
                Layout.fillWidth: true
                
                background: Rectangle {
                    color: "#2d2d2d"
                    radius: 8
                    border.color: "#3d3d3d"
                }
                
                label: Text {
                    text: "Profiles"
                    color: "#ffffff"
                    font.pixelSize: 16
                    font.bold: true
                    padding: 10
                }
                
                ColumnLayout {
                    width: parent.width
                    spacing: 15
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        TextField {
                            id: newProfileName
                            Layout.fillWidth: true
                            placeholderText: "Profile name"
                            
                            background: Rectangle {
                                color: "#1e1e1e"
                                radius: 4
                                border.color: parent.activeFocus ? "#4CAF50" : "#555555"
                                border.width: 1
                            }
                            
                            color: "#ffffff"
                        }
                        
                        Button {
                            text: "Add Profile"
                            
                            background: Rectangle {
                                color: parent.pressed ? "#388E3C" : "#4CAF50"
                                radius: 4
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                color: "#ffffff"
                                font.pixelSize: 12
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            onClicked: {
                                if (newProfileName.text.trim() !== "") {
                                    profileManager.addProfile(newProfileName.text.trim())
                                    newProfileName.text = ""
                                }
                            }
                        }
                    }
                    
                    ListView {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 200
                        model: profileManager.profiles
                        spacing: 5
                        clip: true
                        
                        delegate: Rectangle {
                            width: ListView.view.width
                            height: 50
                            color: "#1e1e1e"
                            radius: 4
                            border.color: modelData.name === profileManager.currentProfile ? "#4CAF50" : "#555555"
                            border.width: 2
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 10
                                
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    
                                    Text {
                                        text: modelData.name
                                        color: "#ffffff"
                                        font.pixelSize: 14
                                        font.bold: true
                                    }
                                    
                                    Text {
                                        text: "Version: " + (modelData.version || "latest")
                                        color: "#b0b0b0"
                                        font.pixelSize: 11
                                    }
                                }
                                
                                Button {
                                    text: "Delete"
                                    visible: modelData.name !== "Default"
                                    
                                    background: Rectangle {
                                        color: parent.pressed ? "#d32f2f" : "#f44336"
                                        radius: 4
                                    }
                                    
                                    contentItem: Text {
                                        text: parent.text
                                        color: "#ffffff"
                                        font.pixelSize: 11
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                    
                                    onClicked: profileManager.removeProfile(modelData.name)
                                }
                            }
                        }
                    }
                }
            }
            
            Item { Layout.fillHeight: true }
        }
    }
}
