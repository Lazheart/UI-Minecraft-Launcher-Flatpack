import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    color: themeManager.colors["surface"]
    opacity: 0.95
    radius: 8
    
    ScrollView {
        anchors.fill: parent
        anchors.margins: 20
        clip: true
        
        ColumnLayout {
            width: parent.width
            spacing: 25
            
            // Sección de perfiles
            GroupBox {
                Layout.fillWidth: true
                
                background: Rectangle {
                    color: themeManager.colors["border"]
                    radius: 8
                    border.color: themeManager.colors["border_strong"]
                }
                
                label: Text {
                    text: qsTr("Profiles")
                    color: themeManager.colors["text_primary"]
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
                            placeholderText: qsTr("Name of new profile")
                            
                            background: Rectangle {
                                color: themeManager.colors["surface"]
                                radius: 4
                                border.color: parent.activeFocus ? themeManager.colors["accent"] : themeManager.colors["border_muted"]
                            }
                            
                            color: themeManager.colors["text_primary"]
                        }
                        
                        Button {
                            text: qsTr("Add Profile")
                            
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
                            color: themeManager.colors["surface"]
                            radius: 4
                            border.color: modelData.name === profileManager.currentProfile ? themeManager.colors["accent"] : themeManager.colors["border_muted"]
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
                                        color: themeManager.colors["text_primary"]
                                        font.pixelSize: 14
                                        font.bold: true
                                    }
                                    
                                    Text {
                                        text: qsTr("Version: ") + (modelData.version || qsTr("latest"))
                                        color: themeManager.colors["text_secondary"]
                                        font.pixelSize: 11
                                    }
                                }
                                
                                Button {
                                    text: qsTr("Delete")
                                    visible: modelData.name !== "Default"
                                    
                                    background: Rectangle {
                                        color: parent.pressed ? themeManager.colors["error_dark"] : themeManager.colors["error"]
                                        radius: 4
                                    }
                                    
                                    contentItem: Text {
                                        text: parent.text
                                        color: themeManager.colors["text_primary"]
                                        font.pixelSize: 11
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    
                                    onClicked: {
                                        profileManager.removeProfile(modelData.name)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Sección de gráficos
            GroupBox {
                Layout.fillWidth: true
                
                background: Rectangle {
                    color: themeManager.colors["border"]
                    radius: 8
                    border.color: themeManager.colors["border_strong"]
                }
                
                label: Text {
                    text: qsTr("Graphics")
                    color: themeManager.colors["text_primary"]
                    font.pixelSize: 16
                    font.bold: true
                    padding: 10
                }
                
                ColumnLayout {
                    width: parent.width
                    spacing: 15
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: qsTr("Window Resolution   :")
                            color: themeManager.colors["text_secondary"]
                            font.pixelSize: 13
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        ComboBox {
                            model: ["1920x1080", "1600x900", "1366x768", "1280x720"]
                            
                            background: Rectangle {
                                color: themeManager.colors["surface"]
                                radius: 4
                                border.color: parent.activeFocus ? themeManager.colors["accent"] : themeManager.colors["border_muted"]
                            }
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: qsTr("Fullscreen:")
                            color: themeManager.colors["text_secondary"]
                            font.pixelSize: 13
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Switch {
                            checked: false
                        }
                    }
                }
            }
            
            // Sección de información
            GroupBox {
                Layout.fillWidth: true
                
                background: Rectangle {
                    color: themeManager.colors["border"]
                    radius: 8
                    border.color: themeManager.colors["border_strong"]
                }
                
                label: Text {
                    text: qsTr("Information")
                    color: themeManager.colors["text_primary"]
                    font.pixelSize: 16
                    font.bold: true
                    padding: 10
                }
                
                GridLayout {
                    width: parent.width
                    columns: 2
                    columnSpacing: 15
                    rowSpacing: 10
                    
                    Text {
                        text: qsTr("Version of the Launcher:")
                        color: themeManager.colors["text_secondary"]
                        font.pixelSize: 13
                    }
                    Text {
                        text: minecraftManager.getLauncherVersion()
                        color: themeManager.colors["text_primary"]
                        font.pixelSize: 13
                    }
                    
                    Text {
                        text: qsTr("Data Directory:")
                        color: themeManager.colors["text_secondary"]
                        font.pixelSize: 13
                    }
                    Text {
                        text: (typeof pathManager !== 'undefined' && pathManager.dataDir) ? pathManager.dataDir : ""
                        color: themeManager.colors["text_primary"]
                        font.pixelSize: 11
                        elide: Text.ElideMiddle
                        Layout.fillWidth: true
                    }
                    
                    Text {
                        text: qsTr("Application Directory:")
                        color: themeManager.colors["text_secondary"]
                        font.pixelSize: 13
                    }
                    Text {
                        text: (typeof pathManager !== 'undefined' && pathManager.launcherDir) ? pathManager.launcherDir : ""
                        color: themeManager.colors["text_primary"]
                        font.pixelSize: 11
                        elide: Text.ElideMiddle
                        Layout.fillWidth: true
                    }
                }
            }
            
            Item { Layout.fillHeight: true }
        }
    }
}
