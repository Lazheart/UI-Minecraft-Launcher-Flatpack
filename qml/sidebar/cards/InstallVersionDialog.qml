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
    closePolicy: installing ? Popup.NoAutoClose : Popup.CloseOnEscape
    padding: 0
    implicitWidth: 550
    implicitHeight: 650

    // Item that defines the visual area where the dialog should be centered.
    property Item anchorItem: null

    property color backgroundColor: '#1a1a1a'
    property color surfaceColor: "#1a1a1a"
    property color accentColor: "#4CAF50"
    property color textColor: "#ffffff"
    property color secondaryTextColor: "#b0b0b0"
    property color borderColor: "#4CAF50"

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

    function stripExtension(filename) {
        if (!filename) return ""
        var lastDot = filename.lastIndexOf('.')
        return (lastDot > 0) ? filename.substring(0, lastDot) : filename
    }

    property bool installing: false

    onInstallingChanged: {
        console.log("[InstallVersionDialog] installing changed ->", installing)
    }

    function cleanFileUrl(url) {
        if (!url)
            return ""
        var path = url
        if (path.startsWith("file://"))
            path = decodeURIComponent(path.substring(7))
        return path
    }

    anchors.centerIn: parent

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
        color: "#1a1a1a"
        radius: 16
        clip: true
    }

    contentItem: Item {
        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 25
            spacing: 20

            Text {
                text: "Install Version"
                color: "#ffffff"
                font.pixelSize: 20
                font.bold: true
                Layout.fillWidth: true
            }

            // Name field
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                Text {
                    text: "NAME"
                    color: textColor
                    font.pixelSize: 16
                    font.bold: true
                }

                TextField {
                    id: nameField
                    Layout.fillWidth: true
                    placeholderText: "Enter version name"
                    enabled: !installDialog.installing
                    color: "#ffffff"
                    selectByMouse: true
                    padding: 12
                    font.pixelSize: 13
                    background: Rectangle {
                        color: "#111111"
                        border.color: nameField.activeFocus ? accentColor : "#3d3d3d"
                        border.width: nameField.activeFocus ? 2 : 1
                        radius: 6
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
                        Layout.preferredHeight: 40
                        placeholderText: "Select APK file..."
                        color: "#ffffff"
                        readOnly: true
                        padding: 12
                        font.pixelSize: 13
                        background: Rectangle {
                            color: "#111111"
                            border.color: apkMouse.containsMouse ? accentColor : "#3d3d3d"
                            border.width: 1
                            radius: 6
                            
                            MouseArea {
                                id: apkMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                enabled: !installDialog.installing
                                onClicked: apkDialog.open()
                            }
                        }
                    }

                    Button {
                        id: apkButton
                        text: "Browse"
                        enabled: !installDialog.installing
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 40
                        background: Rectangle {
                            color: apkButton.enabled ? (apkButton.pressed ? "#45a049" : "#4CAF50") : "#555555"
                            radius: 6
                        }
                        contentItem: Text {
                            text: apkButton.text
                            color: "#ffffff"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 12
                            font.bold: true
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
                        text: "TAG"
                        color: tagCheckBox.checked ? textColor : secondaryTextColor
                        font.pixelSize: 16
                        font.bold: true
                        Layout.alignment: Qt.AlignVCenter
                    }
                    CheckBox {
                        id: tagCheckBox
                        checked: false
                        enabled: !installDialog.installing
                        padding: 0
                        Layout.alignment: Qt.AlignVCenter
                        indicator: Rectangle {
                            implicitWidth: 16
                            implicitHeight: 16
                            radius: 3
                            color: "#111111"
                            border.color: tagCheckBox.checked ? accentColor : (tagCheckBoxMouse.containsMouse ? accentColor : "#3d3d3d")
                            Rectangle {
                                width: 9
                                height: 9
                                x: 3.5
                                y: 3.5
                                radius: 1.5
                                color: accentColor
                                visible: tagCheckBox.checked
                            }
                            MouseArea {
                                id: tagCheckBoxMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: tagCheckBox.checked = !tagCheckBox.checked
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
                    implicitHeight: 40
                    model: (typeof versionsApiHandler !== 'undefined' && versionsApiHandler) ? versionsApiHandler.versions : []
                    currentIndex: -1
                    enabled: tagCheckBox.checked && !installDialog.installing
                    displayText: currentIndex === -1 ? "Select a version" : currentText
                    
                    background: Rectangle {
                        radius: 6
                        color: "#111111"
                        border.color: tagComboBox.activeFocus || tagComboBoxMouse.containsMouse ? accentColor : "#3d3d3d"
                        border.width: 1
                        
                        MouseArea {
                            id: tagComboBoxMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: if (tagComboBox.enabled) tagComboBox.popup.open()
                        }
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
                        implicitHeight: 40
                        font.pixelSize: 13
                        enabled: !installDialog.installing
                        
                        onActivated: {
                            if (currentText === "Other...") {
                                iconDialog.open()
                            } else {
                                installDialog.iconPath = iconModel.get(currentIndex).path
                                installDialog.useDefaultIcon = (currentText === "Default")
                            }
                        }

                        background: Rectangle {
                            color: "#111111"
                            border.color: (iconComboBox.activeFocus || iconComboBoxMouse.containsMouse) ? accentColor : "#3d3d3d"
                            border.width: 1
                            radius: 6
                            
                            MouseArea {
                                id: iconComboBoxMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                enabled: !installDialog.installing
                                onClicked: iconComboBox.popup.open()
                            }
                        }
                        
                        contentItem: Text {
                            text: iconComboBox.displayText
                            color: "#ffffff"
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 10
                        }
                    }

                    Rectangle {
                        width: 40
                        height: 40
                        radius: 6
                        color: '#ef121212'
                        clip: true
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
                        implicitHeight: 40
                        font.pixelSize: 13
                        enabled: !installDialog.installing
                        
                        onActivated: {
                            if (currentText === "Other...") {
                                backgroundDialog.open()
                            } else {
                                installDialog.backgroundPath = backgroundModel.get(currentIndex).path
                                installDialog.useDefaultBackground = (currentText === "Default")
                            }
                        }

                        background: Rectangle {
                            color: "#111111"
                            border.color: (backgroundComboBox.activeFocus || backgroundComboBoxMouse.containsMouse) ? accentColor : "#3d3d3d"
                            border.width: 1
                            radius: 6
                            
                            MouseArea {
                                id: backgroundComboBoxMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                enabled: !installDialog.installing
                                onClicked: backgroundComboBox.popup.open()
                            }
                        }
                        
                        contentItem: Text {
                            text: backgroundComboBox.displayText
                            color: "#ffffff"
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 10
                        }
                    }

                    Rectangle {
                        width: 60
                        height: 40
                        radius: 10
                        color: '#1e1e1e'
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
                Layout.fillWidth: true
                spacing: 10

                Button {
                    text: "Cancel"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45

                    background: Rectangle {
                        color: parent.pressed ? "#3d3d3d" : "#302C2C"
                        radius: 6
                        border.color: parent.hovered ? accentColor : "transparent"
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
                        if (installDialog.installing) {
                            console.log("[InstallVersionDialog] Installation cancelled by user")
                            installDialog.installing = false
                            errorLabel.text = "Installation cancelled by user"
                        }
                        installDialog.close()
                    }
                }

                Button {
                    id: installButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45
                    text: installDialog.installing ? "Installing..." : "Install"
                    enabled: !installDialog.installing && nameField.text.trim().length > 0 && apkField.text.trim().length > 0 && (!tagCheckBox.checked || tagComboBox.currentIndex !== -1)
                    
                    background: Rectangle {
                        color: installButton.enabled ? (installButton.pressed ? "#45a049" : "#4CAF50") : "#555555"
                        radius: 6
                    }

                    contentItem: Text {
                        text: installButton.text
                        color: "#ffffff"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 12
                        font.bold: true
                    }
                    
                    onClicked: {
                        console.log("[InstallVersionDialog] installButton clicked. enabled=", installButton.enabled,
                                    " installing=", installDialog.installing,
                                    " name=", nameField.text,
                                    " apk=", apkField.text)
                        if (!installButton.enabled) {
                            return
                        }
                        errorLabel.text = ""

                        // Ensure APK file is staged and actually accessible
                        var apkPath = apkField.text.trim()
                        var stagedApk = pathManager.stageFileForExtraction(apkPath)
                        var finalApk = (stagedApk && stagedApk.length) ? stagedApk : apkPath

                        if (!finalApk || finalApk.length === 0) {
                            console.log("[InstallVersionDialog] No valid APK path after staging, aborting install")
                            errorLabel.text = "APK file not accessible. Please re-select the APK and try again."
                            installDialog.installing = false
                            return
                        }

                        var iconToUse = installDialog.iconPath
                        var bgToUse = installDialog.backgroundPath

                        // Indicate installing state and disable UI
                        installDialog.installing = true

                        console.log("[InstallVersionDialog] emitting installRequested with:",
                                    "name=", nameField.text.trim(),
                                    "apk=", finalApk,
                                    "useDefaultIcon=", installDialog.useDefaultIcon,
                                    "iconPath=", iconToUse,
                                    "useDefaultBackground=", installDialog.useDefaultBackground,
                                    "backgroundPath=", bgToUse,
                                    "tag=", tagCheckBox.checked ? tagComboBox.currentText : "")

                        installDialog.installRequested(
                                    nameField.text.trim(),
                                    finalApk,
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
            iconModel.append({ "name": stripExtension(customIcons[i]), "path": pathManager.dataDir + "/icons/" + customIcons[i] })
        }
        iconModel.append({ "name": "Other...", "path": "" })

        backgroundModel.clear()
        for (var k = 0; k < Media.StandardBackgrounds.length; k++) {
            backgroundModel.append(Media.StandardBackgrounds[k])
        }
        var customBgs = pathManager.listCustomBackgrounds()
        for (var j = 0; j < customBgs.length; j++) {
            backgroundModel.append({ "name": stripExtension(customBgs[j]), "path": pathManager.dataDir + "/backgrounds/" + customBgs[j] })
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
                var nameNoExt = stripExtension(fileName)
                for (var i = 0; i < iconModel.count; i++) {
                    if (iconModel.get(i).name === nameNoExt) {
                        iconComboBox.currentIndex = i
                        break
                    }
                }
            } else {
                var fileNameBg = sourcePath.substring(sourcePath.lastIndexOf('/') + 1)
                var nameBgNoExt = stripExtension(fileNameBg)
                for (var j = 0; j < backgroundModel.count; j++) {
                    if (backgroundModel.get(j).name === nameBgNoExt) {
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
            console.log("[InstallVersionDialog] onInstallSucceeded for", versionPath)
            installDialog.installing = false
            installDialog.close()
        }

        function onInstallFailed(versionPath, reason) {
            console.log("[InstallVersionDialog] onInstallFailed for", versionPath, "reason=", reason)
            installDialog.installing = false
            errorLabel.text = reason && reason.length ? reason : ("Failed to install " + versionPath)
        }
    }
}
