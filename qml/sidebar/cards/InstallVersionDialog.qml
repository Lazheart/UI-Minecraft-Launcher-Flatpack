import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3 as QtDialogs

Dialog {
    id: installDialog
    modal: true
    focus: true
    dim: true
    closePolicy: Popup.CloseOnEscape
    padding: 0
    implicitWidth: 480
    implicitHeight: 560

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
        iconPath = ""
        backgroundPath = ""
        useDefaultIcon = true
        useDefaultBackground = true
        iconDefault.checked = true
        backgroundDefault.checked = true
        iconUploadButton.enabled = false
        backgroundUploadButton.enabled = false
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

            // APK route
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                Text {
                    text: "APK ROUTE"
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

            // Icon section
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 12

                Text {
                    text: "ICON"
                    color: textColor
                    font.pixelSize: 16
                    font.bold: true
                }

                ButtonGroup { id: iconGroup }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 20

                    RadioButton {
                        id: iconDefault
                        text: "Default"
                        checked: true
                        ButtonGroup.group: iconGroup
                        contentItem: Text {
                            text: iconDefault.text
                            font: iconDefault.font
                            color: iconDefault.enabled ? textColor : secondaryTextColor
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            leftPadding: iconDefault.indicator ? iconDefault.indicator.width + iconDefault.spacing : 0
                            rightPadding: iconDefault.rightPadding
                        }
                        onToggled: if (checked) {
                            installDialog.useDefaultIcon = true
                            iconUploadButton.enabled = false
                            installDialog.iconPath = ""
                        }
                    }

                    RadioButton {
                        id: iconOther
                        text: "Other"
                        ButtonGroup.group: iconGroup
                        contentItem: Text {
                            text: iconOther.text
                            font: iconOther.font
                            color: iconOther.enabled ? textColor : secondaryTextColor
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            leftPadding: iconOther.indicator ? iconOther.indicator.width + iconOther.spacing : 0
                            rightPadding: iconOther.rightPadding
                        }
                        onToggled: if (checked) {
                            installDialog.useDefaultIcon = false
                            iconUploadButton.enabled = true
                        }
                    }

                    Button {
                        id: iconUploadButton
                        Layout.preferredWidth: 140
                        enabled: false
                        text: installDialog.iconPath === "" ? "Upload Here" : "Change"
                        background: Rectangle {
                            radius: 6
                            color: enabled ? (iconUploadButton.pressed ? Qt.darker(accentColor, 1.3) : accentColor) : "#555555"
                        }
                        contentItem: Text {
                            text: parent.text
                            color: enabled ? textColor : "#999999"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: iconDialog.open()
                    }
                }
            }

            // Background section
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 12

                Text {
                    text: "BACKGROUND"
                    color: textColor
                    font.pixelSize: 16
                    font.bold: true
                }

                ButtonGroup { id: backgroundGroup }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 20

                    RadioButton {
                        id: backgroundDefault
                        text: "Default"
                        checked: true
                        ButtonGroup.group: backgroundGroup
                        contentItem: Text {
                            text: backgroundDefault.text
                            font: backgroundDefault.font
                            color: backgroundDefault.enabled ? textColor : secondaryTextColor
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            leftPadding: backgroundDefault.indicator ? backgroundDefault.indicator.width + backgroundDefault.spacing : 0
                            rightPadding: backgroundDefault.rightPadding
                        }
                        onToggled: if (checked) {
                            installDialog.useDefaultBackground = true
                            backgroundUploadButton.enabled = false
                            installDialog.backgroundPath = ""
                        }
                    }

                    RadioButton {
                        id: backgroundOther
                        text: "Add"
                        ButtonGroup.group: backgroundGroup
                        contentItem: Text {
                            text: backgroundOther.text
                            font: backgroundOther.font
                            color: backgroundOther.enabled ? textColor : secondaryTextColor
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            leftPadding: backgroundOther.indicator ? backgroundOther.indicator.width + backgroundOther.spacing : 0
                            rightPadding: backgroundOther.rightPadding
                        }
                        onToggled: if (checked) {
                            installDialog.useDefaultBackground = false
                            backgroundUploadButton.enabled = true
                        }
                    }

                    Button {
                        id: backgroundUploadButton
                        Layout.preferredWidth: 140
                        enabled: false
                        text: installDialog.backgroundPath === "" ? "Upload Here" : "Change"
                        background: Rectangle {
                            radius: 6
                            color: enabled ? (backgroundUploadButton.pressed ? Qt.darker(accentColor, 1.3) : accentColor) : "#555555"
                        }
                        contentItem: Text {
                            text: parent.text
                            color: enabled ? textColor : "#999999"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: backgroundDialog.open()
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

            Button {
                id: installButton
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 160
                text: "INSTALL"
                enabled: nameField.text.trim().length > 0 && apkField.text.trim().length > 0 && (installDialog.useDefaultIcon || installDialog.iconPath !== "") && (installDialog.useDefaultBackground || installDialog.backgroundPath !== "")
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
                        errorLabel.text = "Complete todos los campos requeridos"
                        return
                    }
                    errorLabel.text = ""
                    // Ensure files are staged (if not already staged on select)
                    var apkPath = apkField.text.trim()
                    var stagedApk = pathManager.stageFileForExtraction(apkPath)
                    var stagedIcon = ""
                    var stagedBg = ""
                    if (!installDialog.useDefaultIcon && installDialog.iconPath) {
                        stagedIcon = pathManager.stageFileForExtraction(installDialog.iconPath)
                    }
                    if (!installDialog.useDefaultBackground && installDialog.backgroundPath) {
                        stagedBg = pathManager.stageFileForExtraction(installDialog.backgroundPath)
                    }

                    // Fallback a las rutas originales si stage falla
                    var apkToUse = stagedApk && stagedApk.length ? stagedApk : apkPath
                    var iconToUse = stagedIcon && stagedIcon.length ? stagedIcon : installDialog.iconPath
                    var bgToUse = stagedBg && stagedBg.length ? stagedBg : installDialog.backgroundPath

                    // Indicate installing state and disable UI
                    installDialog.installing = true
                    installButton.enabled = false
                    apkButton.enabled = false
                    iconUploadButton.enabled = false
                    backgroundUploadButton.enabled = false
                    installButton.text = "Installing..."

                    installDialog.installRequested(
                                nameField.text.trim(),
                                apkToUse,
                                installDialog.useDefaultIcon,
                                iconToUse,
                                installDialog.useDefaultBackground,
                                bgToUse
                            )
                    // Do not close the dialog immediately; wait for signals
                }
            }
        }
    }

    QtDialogs.FileDialog {
        id: apkDialog
        title: "Select APK file"
        selectExisting: true
        nameFilters: ["Android Package (*.apk)", "All files (*)"]
        // Note: keep default dialog behavior; staging logic will handle portal paths.
        onAccepted: {
            var picked = installDialog.cleanFileUrl(apkDialog.fileUrl.toString())
            // Try to stage immediately so the file remains available for install
            var staged = pathManager.stageFileForExtraction(picked)
            if (staged && staged.length) {
                apkField.text = staged
                console.log("[InstallVersionDialog] staged APK:", staged)
            } else {
                apkField.text = picked
                console.log("[InstallVersionDialog] using original APK path:", picked)
            }
        }
    }

    QtDialogs.FileDialog {
        id: iconDialog
        title: "Select Icon"
        selectExisting: true
        nameFilters: ["Images (*.png *.jpg *.jpeg *.svg)", "All files (*)"]
        onAccepted: installDialog.iconPath = installDialog.cleanFileUrl(iconDialog.fileUrl.toString())
    }

    QtDialogs.FileDialog {
        id: backgroundDialog
        title: "Select Background"
        selectExisting: true
        nameFilters: ["Images (*.png *.jpg *.jpeg)", "All files (*)"]
        onAccepted: installDialog.backgroundPath = installDialog.cleanFileUrl(backgroundDialog.fileUrl.toString())
    }

    Connections {
        target: minecraftManager
        function onInstallSucceeded(versionPath) {
            // Reset installing UI, show success and close
            installDialog.installing = false
            installButton.enabled = true
            apkButton.enabled = true
            iconUploadButton.enabled = true
            backgroundUploadButton.enabled = true
            installButton.text = "INSTALL"
            installDialog.close()
        }

        function onInstallFailed(versionPath, reason) {
            // Show error and allow retry
            installDialog.installing = false
            installButton.enabled = true
            apkButton.enabled = true
            iconUploadButton.enabled = !installDialog.useDefaultIcon
            backgroundUploadButton.enabled = !installDialog.useDefaultBackground
            installButton.text = "INSTALL"
            var msg = reason && reason.length ? reason : ("Failed to install " + versionPath)
            errorLabel.text = msg
            console.log("[InstallVersionDialog] install failed:", versionPath, reason)
        }
    }
}
