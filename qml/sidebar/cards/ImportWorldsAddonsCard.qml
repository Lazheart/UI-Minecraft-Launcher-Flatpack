import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3 as QtDialogs
import "../../Media.js" as Media

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

    // Versions model for selection
    ListModel { id: versionsListModel }
    property string selectedVersionPath: ""
    property string importError: ""

    anchors.centerIn: parent

    function rebuildVersions() {
        versionsListModel.clear();
        var versions = minecraftManager.getAvailableVersions();
        if (!versions) return;
        for (var i = 0; i < versions.length; ++i) {
            var v = versions[i];
            var name = (typeof v === 'string') ? v.split("/").pop() : (v.name ? v.name : (v.path ? v.path.split("/").pop() : ""));
            var path = (typeof v === 'string') ? v : (v.path ? v.path : "");
            versionsListModel.append({ text: name, path: path });
        }
        // reset selection
        selectedVersionPath = "";
    }

    Connections {
        target: minecraftManager
        function onAvailableVersionsChanged() { rebuildVersions(); }
    }

    Component.onCompleted: rebuildVersions()

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
                        color: "#111111"
                        border.color: filePathInputMouse.containsMouse ? "#4CAF50" : "#3d3d3d"
                        border.width: 1
                        radius: 6
                        
                        MouseArea {
                            id: filePathInputMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: fileDialog.open()
                        }
                    }

                    color: "#ffffff"
                    font.pixelSize: 13
                    padding: 12
                }

                Button {
                    id: browseButton
                    text: "Browse"
                    Layout.preferredWidth: 100

                    Layout.preferredHeight: 40
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

            // Version Selector (must pick a version before importing)
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    Text {
                        text: "Target Version"
                        color: "#b0b0b0"
                        font.pixelSize: 13
                    }
                    Text {
                        id: noVersionsLabel
                        visible: versionsListModel.count === 0
                        color: "#ff6b6b"
                        text: "No versions installed. Install a version first."
                        font.pixelSize: 12
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignRight
                    }
                }

                ComboBox {
                    id: versionCombo
                    Layout.fillWidth: true
                    model: versionsListModel
                    textRole: "text"
                    implicitHeight: 40
                    font.pixelSize: 13
                    enabled: versionsListModel.count > 0
                    opacity: enabled ? 1.0 : 0.5

                    onCurrentIndexChanged: {
                        if (currentIndex >= 0 && currentIndex < versionsListModel.count) {
                            selectedVersionPath = versionsListModel.get(currentIndex).path
                        } else {
                            selectedVersionPath = ""
                        }
                        importError = ""
                    }

                    background: Rectangle {
                        color: "#111111"
                        border.color: (versionCombo.activeFocus || versionComboMouse.containsMouse) ? "#4CAF50" : "#3d3d3d"
                        border.width: versionCombo.activeFocus ? 2 : 1
                        radius: 6
                        implicitHeight: 36
                        
                        MouseArea {
                            id: versionComboMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: if (versionCombo.enabled) versionCombo.popup.open()
                        }
                    }

                    contentItem: Text {
                        text: versionCombo.displayText
                        color: "#ffffff"
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignLeft
                        elide: Text.ElideRight
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: 13
                    }
                }
            }

            // Import error / hint
            Text {
                id: importErrorText
                visible: importError !== ""
                text: importError
                color: "#ff6b6b"
                font.pixelSize: 13
                Layout.fillWidth: true
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
                    Layout.preferredHeight: 45

                    background: Rectangle {
                        color: parent.pressed ? "#3d3d3d" : "#302C2C"
                        radius: 6
                        border.color: parent.hovered ? "#4CAF50" : "transparent"
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
                    id: importButton
                    text: "Import"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45
                    enabled: selectedVersionPath !== ""

                    background: Rectangle {
                        color: importButton.enabled ? (importButton.pressed ? "#45a049" : "#4CAF50") : "#555555"
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
                        importError = ""
                        var fp = filePathInput.text.trim()
                        if (fp === "") {
                            importError = "Please select a file to import."
                            return
                        }
                        if (selectedVersionPath === "") {
                            importError = "Please select a target version."
                            return
                        }

                        // Stage file to ensure accessibility and then call manager
                        var staged = pathManager.stageFileForExtraction(fp)
                        var fileToUse = (staged && staged.length) ? staged : fp
                        minecraftManager.importSelected(fileToUse, importCard.selectedType, selectedVersionPath)
                        // close and reset
                        importCard.close()
                        filePathInput.text = ""
                        mundoRadio.checked = true
                        selectedVersionPath = ""
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
