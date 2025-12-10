import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3 as QtDialogs
import "Media.js" as Media

Dialog {
    id: importCard
    modal: true
    focus: true
    dim: true
    closePolicy: Popup.CloseOnEscape
    padding: 0
    implicitWidth: 550
    implicitHeight: 400
    
    background: Rectangle {
        color: "#1a1a1a"
        radius: 16
        clip: true
    }
    
    // Item that defines the visual area where the dialog should be centered
    property Item anchorItem: null
    property string selectedType: "World"

    signal importRequested(string path, string type)
    signal closed()

    contentItem: Rectangle {
        color: "#1a1a1a"
        radius: 16
        clip: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 25
            spacing: 20

            // Title
            Text {
                text: "Import Worlds / Addons"
                color: "#ffffff"
                font.pixelSize: 20
                font.bold: true
                Layout.fillWidth: true
            }

            // Type Selector with RadioButtons
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 12

                ButtonGroup {
                    id: typeGroup
                }

                Text {
                    text: "Type:"
                    color: "#b0b0b0"
                    font.pixelSize: 14
                    font.bold: true
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 30

                    RowLayout {
                        spacing: 10

                        Rectangle {
                            width: 24
                            height: 24
                            radius: 12
                            color: "transparent"
                            border.color: "#4CAF50"
                            border.width: mundoRadio.checked ? 3 : 1
                            clip: true

                            Rectangle {
                                anchors.centerIn: parent
                                width: 12
                                height: 12
                                radius: 6
                                color: "#4CAF50"
                                visible: mundoRadio.checked
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    mundoRadio.checked = true
                                }
                            }
                        }

                        RadioButton {
                            id: mundoRadio
                            checked: true
                            ButtonGroup.group: typeGroup
                            indicator: Rectangle { visible: false }
                            background: Rectangle { visible: false }
                            
                            onCheckedChanged: {
                                if (checked) {
                                    importCard.selectedType = "World"
                                }
                            }
                        }

                        Text {
                            text: "World"
                            color: "#ffffff"
                            font.pixelSize: 14

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    addonRadio.checked = true
                                }
                            }
                        }
                    }

                    RowLayout {
                        spacing: 10

                        Rectangle {
                            width: 24
                            height: 24
                            radius: 12
                            color: "transparent"
                            border.color: "#4CAF50"
                            border.width: addonRadio.checked ? 3 : 1
                            clip: true

                            Rectangle {
                                anchors.centerIn: parent
                                width: 12
                                height: 12
                                radius: 6
                                color: "#4CAF50"
                                visible: addonRadio.checked
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    addonRadio.checked = true
                                }
                            }
                        }

                        RadioButton {
                            id: addonRadio
                            ButtonGroup.group: typeGroup
                            indicator: Rectangle { visible: false }
                            background: Rectangle { visible: false }
                            
                            onCheckedChanged: {
                                if (checked) {
                                    importCard.selectedType = "Addon"
                                }
                            }
                        }

                        Text {
                            text: "Addon"
                            color: "#ffffff"
                            font.pixelSize: 14

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    mundoRadio.checked = true
                                }
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }
                }
            }

            // File Path Input with Browse Button
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                TextField {
                    id: filePathInput
                    Layout.fillWidth: true
                    placeholderText: "Select a file..."
                    readOnly: true
                    
                    background: Rectangle {
                        color: "#231f1f"
                        border.color: "#4CAF50"
                        border.width: 1
                        radius: 6
                    }

                    color: "#ffffff"
                    font.pixelSize: 13
                    padding: 12
                }

                Button {
                    id: browseButton
                    text: "Browse"
                    Layout.preferredWidth: 100

                    background: Rectangle {
                        color: browseButton.pressed ? "#45a049" : "#4CAF50"
                        radius: 6
                    }

                    contentItem: Text {
                        text: browseButton.text
                        color: "#ffffff"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 12
                        font.bold: true
                    }

                    onClicked: fileDialog.open()
                }
            }

            // Spacer
            Item {
                Layout.fillHeight: true
            }

            // Buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    text: "Cancel"
                    Layout.fillWidth: true

                    background: Rectangle {
                        color: parent.pressed ? "#3d3d3d" : "#302C2C"
                        radius: 6
                        border.color: "#4CAF50"
                        border.width: 1
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "#ffffff"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 12
                    }

                    onClicked: {
                        importCard.close()
                        filePathInput.text = ""
                        mundoRadio.checked = true
                        importCard.closed()
                    }
                }

                Button {
                    text: "Import"
                    Layout.fillWidth: true

                    background: Rectangle {
                        color: parent.pressed ? "#45a049" : "#4CAF50"
                        radius: 6
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "#ffffff"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 12
                        font.bold: true
                    }

                    onClicked: {
                        if (filePathInput.text.trim() !== "") {
                            importCard.importRequested(filePathInput.text, importCard.selectedType)
                            importCard.close()
                            filePathInput.text = ""
                            mundoRadio.checked = true
                        }
                    }
                }
            }
        }
    }

    QtDialogs.FileDialog {
        id: fileDialog
        title: "Select " + importCard.selectedType + " File"
        selectExisting: true
        nameFilters: {
            if (importCard.selectedType === "World") {
                return ["Minecraft World (*.mcworld)", "All files (*)"]
            } else {
                return ["Minecraft Addon (*.mcpack)", "All files (*)"]
            }
        }
        onAccepted: {
            filePathInput.text = fileDialog.fileUrl.toString().replace("file://", "")
        }
    }

    function show() {
        open()
    }

    function hide() {
        close()
        filePathInput.text = ""
        mundoRadio.checked = true
    }
}
