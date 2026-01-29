import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3 as QtDialogs
import "../../Media.js" as Media

Dialog {
    id: installDialog
    modal: true
    focus: true
    dim: true
    closePolicy: Popup.CloseOnEscape
    padding: 0
    implicitWidth: 480
    implicitHeight: 640

    // Item that defines the visual area where the dialog should be centered.
    property Item anchorItem: null

    property color backgroundColor: '#292929'
    property color surfaceColor: "#2d2d2d"
    property color accentColor: "#4CAF50"
    property color textColor: "#ffffff"
    property color secondaryTextColor: "#c7c7c7"
    property color borderColor: "#3d3d3d"

    property string iconPath: ""
    property string backgroundPath: ""
    property bool useDefaultIcon: true
    property bool useDefaultBackground: true

    signal installRequested(string name,
                            string apkRoute,
                            bool useDefaultIcon,
                            string iconPath,
                            bool useDefaultBackground,
                            string backgroundPath)

    function resetForm() {
        nameField.text = ""
        apkField.text = ""
        refreshModels()
        iconPath = Media.DefaultVersionIcon
        backgroundPath = Media.DefaultVersionBackground || ""
        useDefaultIcon = true
        useDefaultBackground = true
        iconComboBox.currentIndex = 0
        backgroundComboBox.currentIndex = 0
        tagCheckBox.checked = false
        tagComboBox.currentIndex = -1
        errorLabel.text = ""
    }

    property bool installing: false

    function cleanFileUrl(url) {
        if (!url)
            return ""
        var path = url
        if (path.startsWith("file://"))
            path = decodeURIComponent(path.substring(7))
        return path
    }

    function centeredPosition() {
        if (!parent)
            return Qt.point(0, 0)
        if (!anchorItem)
            return Qt.point((parent.width - width) / 2, (parent.height - height) / 2)
        return anchorItem.mapToItem(parent,
                                    (anchorItem.width - width) / 2,
                                    (anchorItem.height - height) / 2)
    }

    x: centeredPosition().x
    y: centeredPosition().y

    onOpened: resetForm()

    onClosed: {
        // If dialog closed without installing, clean any staged files we created
        if (!installing) {
            try {
                var apk = apkField.text && apkField.text.length ? apkField.text : ""
                if (apk && apk.indexOf(pathManager.dataDir + "/imports/") === 0) {
                    pathManager.removeStagedFile(apk)
                    console.log("[InstallVersionDialog] removed staged apk on close:", apk)
                }
                // icons/backgrounds may also be staged separately; attempt removal similarly
                if (installDialog.iconPath && installDialog.iconPath.indexOf(pathManager.dataDir + "/imports/") === 0) {
                    pathManager.removeStagedFile(installDialog.iconPath)
                }
                if (installDialog.backgroundPath && installDialog.backgroundPath.indexOf(pathManager.dataDir + "/imports/") === 0) {
                    pathManager.removeStagedFile(installDialog.backgroundPath)
                }
            } catch (e) {
                console.log("[InstallVersionDialog] cleanup error:", e)
            }
        }
    }

    background: Rectangle {
        radius: 8
        color: surfaceColor
        border.color: borderColor
        border.width: 1
        clip: true
    }

    contentItem: Item {
        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 26
            spacing: 18

            Text {
                text: "Install Version"
                font.pixelSize: 28
                font.bold: true
                color: textColor
                Layout.alignment: Qt.AlignHCenter
            }

            // Name field
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                Text {
                    text: "Name"
                    color: textColor
                    font.pixelSize: 16
                    font.bold: true
                }

                TextField {
                    id: nameField
                    Layout.fillWidth: true
                    placeholderText: "Enter version name"
                    color: textColor
                    selectByMouse: true
                    background: Rectangle {
                        radius: 6
                        color: "#1a1a1a"
                        border.color: nameField.activeFocus ? accentColor : borderColor
                        border.width: nameField.activeFocus ? 2 : 1
                    }
                }
            }

            // APK section
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                Text {
                    text: "APK"
                    color: textColor
                    font.pixelSize: 16
                    font.bold: true
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    TextField {
                        id: apkField
                        Layout.fillWidth: true
                        placeholderText: "Select APK file"
                        color: textColor
                        readOnly: true
                        background: Rectangle {
                            radius: 6
                            color: '#232222'
                            border.color: borderColor
                            border.width: 1
                        }
                    }

                    Button {
                        id: apkButton
                        text: "Browse"
                        Layout.preferredWidth: 100
                        background: Rectangle {
                            radius: 6
                            color: apkButton.pressed ? Qt.darker(accentColor, 1.5) : accentColor
                        }
                        contentItem: Text {
                            text: parent.text
                            color: textColor
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: apkDialog.open()
                    }
                }
            }

            // Tag section
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                RowLayout {
                    spacing: 8
                    Text {
                        text: "Tag"
                        color: textColor
                        font.pixelSize: 16
                        font.bold: true
                        Layout.alignment: Qt.AlignVCenter
                    }
                    CheckBox {
                        id: tagCheckBox
                        checked: false
                        padding: 0
                        Layout.alignment: Qt.AlignVCenter
                        indicator: Rectangle {
                            implicitWidth: 20
                            implicitHeight: 20
                            radius: 4
                            color: "#1a1a1a"
                            border.color: tagCheckBox.checked ? accentColor : borderColor
                            Rectangle {
                                width: 12
                                height: 12
                                x: 4
                                y: 4
                                radius: 2
                                color: accentColor
                                visible: tagCheckBox.checked
                            }
                        }
                        onCheckedChanged: {
                            if (checked) versionsApiHandler.fetchVersions()
                        }
                    }
                }

                ComboBox {
                    id: tagComboBox
                    Layout.fillWidth: true
                    model: versionsApiHandler.versions
                    currentIndex: -1
                    enabled: tagCheckBox.checked
                    displayText: currentIndex === -1 ? "Select a version" : currentText
                    
                    background: Rectangle {
                        radius: 6
                        color: tagCheckBox.checked ? "#1a1a1a" : "#111111"
                        border.color: borderColor
                        border.width: 1
                    }
                    
                    contentItem: Text {
                        text: tagComboBox.displayText
                        color: tagCheckBox.checked ? textColor : secondaryTextColor
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 10
                    }
                }
            }

            // Icon section
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                Text {
                    text: "ICON"
                    color: textColor
                    font.pixelSize: 16
                    font.bold: true
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    ComboBox {
                        id: iconComboBox
                        Layout.fillWidth: true
                        model: ListModel { id: iconModel }
                        textRole: "name"
                        currentIndex: 0
                        onActivated: {
                            if (currentText === "Other...") {
                                iconDialog.open()
                            } else {
                                installDialog.iconPath = iconModel.get(currentIndex).path
                                installDialog.useDefaultIcon = (currentText === "Default")
                            }
                        }

                        background: Rectangle {
                            radius: 6
                            color: "#1a1a1a"
                            border.color: borderColor
                        }
                        contentItem: Text {
                            text: iconComboBox.displayText
                            color: textColor
                            leftPadding: 10
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Rectangle {
                        width: 40
                        height: 40
                        radius: 10
                        color: "#1a1a1a"
                        Image {
                            anchors.fill: parent
                            anchors.margins: 4
                            source: installDialog.iconPath.startsWith("/") ? "file://" + installDialog.iconPath : installDialog.iconPath
                            fillMode: Image.PreserveAspectFit
                        }
                    }
                }
            }

            // Background section
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                Text {
                    text: "BACKGROUND"
                    color: textColor
                    font.pixelSize: 16
                    font.bold: true
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    ComboBox {
                        id: backgroundComboBox
                        Layout.fillWidth: true
                        model: ListModel { id: backgroundModel }
                        textRole: "name"
                        currentIndex: 0
                        onActivated: {
                            if (currentText === "Other...") {
                                backgroundDialog.open()
                            } else {
                                installDialog.backgroundPath = backgroundModel.get(currentIndex).path
                                installDialog.useDefaultBackground = (currentText === "Default")
                            }
                        }

                        background: Rectangle {
                            radius: 6
                            color: "#1a1a1a"
                            border.color: borderColor
                        }
                        contentItem: Text {
                            text: backgroundComboBox.displayText
                            color: textColor
                            leftPadding: 10
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Rectangle {
                        width: 80
                        height: 45
                        radius: 10
                        color: "#1a1a1a"
                        clip: true
                        Image {
                            anchors.fill: parent
                            source: installDialog.backgroundPath.startsWith("/") ? "file://" + installDialog.backgroundPath : installDialog.backgroundPath
                            fillMode: Image.PreserveAspectCrop
                        }
                    }
                }
            }

            Text {
                id: errorLabel
                text: ""
                color: "#ff7070"
                font.pixelSize: 14
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 12

                Button {
                    id: installButton
                    Layout.preferredWidth: 160
                    text: "INSTALL"
                    enabled: nameField.text.trim().length > 0 && apkField.text.trim().length > 0 && (!tagCheckBox.checked || tagComboBox.currentIndex !== -1)
                    background: Rectangle {
                        radius: 6
                        color: installButton.enabled ? (installButton.pressed ? Qt.darker(accentColor, 1.3) : accentColor) : "#555555"
                    }
                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 16
                        font.bold: true
                        color: installButton.enabled ? textColor : "#999999"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        if (!installButton.enabled) {
                            errorLabel.text = "Complete all required fields before installing."
                            return
                        }
                        errorLabel.text = ""
                        // Ensure files are staged
                        var apkPath = apkField.text.trim()
                        var stagedApk = pathManager.stageFileForExtraction(apkPath)
                        
                        var iconToUse = installDialog.iconPath
                        var bgToUse = installDialog.backgroundPath

                        // Indicate installing state and disable UI
                        installDialog.installing = true
                        installButton.enabled = false
                        apkButton.enabled = false
                        installButton.text = "Installing..."

                        installDialog.installRequested(
                                    nameField.text.trim(),
                                    stagedApk && stagedApk.length ? stagedApk : apkPath,
                                    installDialog.useDefaultIcon,
                                    iconToUse,
                                    installDialog.useDefaultBackground,
                                    bgToUse,
                                    tagCheckBox.checked ? tagComboBox.currentText : ""
                                )
                    }
                }
            }
        }
    }

    function refreshModels() {
        iconModel.clear()
        iconModel.append({ "name": "Default", "path": Media.DefaultVersionIcon })
        iconModel.append({ "name": "Bedrock", "path": Media.BedrockLogo })
        iconModel.append({ "name": "Java", "path": "qrc:/assets/media/logo.svg" })
        
        var customIcons = pathManager.listCustomIcons()
        for (var i = 0; i < customIcons.length; i++) {
            iconModel.append({ "name": customIcons[i], "path": pathManager.dataDir + "/icons/" + customIcons[i] })
        }
        iconModel.append({ "name": "Other...", "path": "" })

        backgroundModel.clear()
        for (var k = 0; k < Media.StandardBackgrounds.length; k++) {
            backgroundModel.append(Media.StandardBackgrounds[k])
        }
        var customBgs = pathManager.listCustomBackgrounds()
        for (var j = 0; j < customBgs.length; j++) {
            backgroundModel.append({ "name": customBgs[j], "path": pathManager.dataDir + "/backgrounds/" + customBgs[j] })
        }
        backgroundModel.append({ "name": "Other...", "path": "" })
    }

    QtDialogs.FileDialog {
        id: apkDialog
        title: "Select APK file"
        selectExisting: true
        nameFilters: ["Android Package (*.apk)", "All files (*)"]
        onAccepted: {
            var picked = installDialog.cleanFileUrl(apkDialog.fileUrl.toString())
            var staged = pathManager.stageFileForExtraction(picked)
            apkField.text = staged && staged.length ? staged : picked
        }
    }

    QtDialogs.FileDialog {
        id: iconDialog
        title: "Select Icon"
        selectExisting: true
        nameFilters: ["Images (*.png *.jpg *.jpeg *.svg)", "All files (*)"]
        onAccepted: {
            var picked = installDialog.cleanFileUrl(iconDialog.fileUrl.toString())
            installDialog.iconPath = picked
            installDialog.useDefaultIcon = false
            saveAssetDialog.targetType = "icon"
            saveAssetDialog.sourcePath = picked
            saveAssetDialog.open()
        }
    }

    QtDialogs.FileDialog {
        id: backgroundDialog
        title: "Select Background"
        selectExisting: true
        nameFilters: ["Images (*.png *.jpg *.jpeg)", "All files (*)"]
        onAccepted: {
            var picked = installDialog.cleanFileUrl(backgroundDialog.fileUrl.toString())
            installDialog.backgroundPath = picked
            installDialog.useDefaultBackground = false
            saveAssetDialog.targetType = "background"
            saveAssetDialog.sourcePath = picked
            saveAssetDialog.open()
        }
    }

    Dialog {
        id: saveAssetDialog
        title: "Save Asset?"
        standardButtons: Dialog.Yes | Dialog.No
        modal: true
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        property string targetType: ""
        property string sourcePath: ""

        Text {
            text: "Do you want to save this " + saveAssetDialog.targetType + " for future versions?"
            color: textColor
        }

        onAccepted: {
            if (targetType === "icon") {
                pathManager.saveCustomIcon(sourcePath)
            } else {
                pathManager.saveCustomBackground(sourcePath)
            }
            refreshModels()
            // Select the newly added item
            if (targetType === "icon") {
                var fileName = sourcePath.substring(sourcePath.lastIndexOf('/') + 1)
                for (var i = 0; i < iconModel.count; i++) {
                    if (iconModel.get(i).name === fileName) {
                        iconComboBox.currentIndex = i
                        break
                    }
                }
            } else {
                var fileNameBg = sourcePath.substring(sourcePath.lastIndexOf('/') + 1)
                for (var j = 0; j < backgroundModel.count; j++) {
                    if (backgroundModel.get(j).name === fileNameBg) {
                        backgroundComboBox.currentIndex = j
                        break
                    }
                }
            }
        }
    }

    Connections {
        target: minecraftManager
        function onInstallSucceeded(versionPath) {
            installDialog.installing = false
            installButton.enabled = true
            apkButton.enabled = true
            installButton.text = "INSTALL"
            installDialog.close()
        }

        function onInstallFailed(versionPath, reason) {
            installDialog.installing = false
            installButton.enabled = true
            apkButton.enabled = true
            installButton.text = "INSTALL"
            errorLabel.text = reason && reason.length ? reason : ("Failed to install " + versionPath)
        }
    }
}
