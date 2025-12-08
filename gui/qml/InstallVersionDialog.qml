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

    property color backgroundColor: "#1b1a1a"
    property color surfaceColor: "#0f0f0f"
    property color accentColor: "#4CAF50"
    property color textColor: "#ffffff"
    property color secondaryTextColor: "#c7c7c7"

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

    background: Rectangle {
        radius: 26
        color: surfaceColor
        border.color: "transparent"
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
                        radius: 14
                        color: "#111111"
                        border.color: nameField.activeFocus ? accentColor : "#3a3a3a"
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
                            radius: 14
                            color: "#d0d0d0"
                            border.color: "transparent"
                        }
                    }

                    Button {
                        id: apkButton
                        text: "Browse"
                        Layout.preferredWidth: 100
                        background: Rectangle {
                            radius: 12
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
                            radius: 12
                            color: enabled ? (iconUploadButton.pressed ? "#bbbbbb" : "#d9d9d9") : "#6f6f6f"
                        }
                        contentItem: Text {
                            text: parent.text
                            color: enabled ? "#2b2b2b" : "#1f1f1f"
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
                            radius: 12
                            color: enabled ? (backgroundUploadButton.pressed ? "#bbbbbb" : "#d9d9d9") : "#6f6f6f"
                        }
                        contentItem: Text {
                            text: parent.text
                            color: enabled ? "#2b2b2b" : "#1f1f1f"
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
                    radius: 16
                    color: installButton.enabled ? (installButton.pressed ? Qt.darker(accentColor, 1.3) : accentColor) : "#555555"
                }
                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 16
                    font.bold: true
                    color: installButton.enabled ? textColor : "#cccccc"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    if (!installButton.enabled) {
                        errorLabel.text = "Complete todos los campos requeridos"
                        return
                    }
                    errorLabel.text = ""
                    installDialog.installRequested(
                                nameField.text.trim(),
                                apkField.text.trim(),
                                installDialog.useDefaultIcon,
                                installDialog.iconPath,
                                installDialog.useDefaultBackground,
                                installDialog.backgroundPath
                            )
                    installDialog.close()
                }
            }
        }
    }

    QtDialogs.FileDialog {
        id: apkDialog
        title: "Select APK file"
        selectExisting: true
        nameFilters: ["Android Package (*.apk)", "All files (*)"]
        onAccepted: apkField.text = installDialog.cleanFileUrl(apkDialog.fileUrl.toString())
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
}
