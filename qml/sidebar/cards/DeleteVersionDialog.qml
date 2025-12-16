import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

Dialog {
    id: deleteDialog
    modal: true
    focus: true
    dim: true
    closePolicy: Popup.CloseOnEscape
    padding: 0
    implicitWidth: 500
    implicitHeight: 400

    // Item that defines the visual area where the dialog should be centered.
    property Item anchorItem: null

    property color backgroundColor: '#292929'
    property color surfaceColor: "#2d2d2d"
    property color accentColor: "#4CAF50"
    property color textColor: "#ffffff"
    property color secondaryTextColor: "#c7c7c7"
    property color borderColor: "#3d3d3d"
    property color deleteColor: "#f44336"

    // Lista de versiones seleccionadas para eliminar
    property var selectedVersions: []
    // Cached list of versions shown in the dialog; refreshed on open and when manager notifies
    property var versions: []

    signal deleteRequested(var versions)

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

    onVisibleChanged: {
        // Clear any previous selections when the dialog opens or closes
        if (visible) {
            deleteDialog.selectedVersions = []
            // refresh the list each time the dialog opens
            deleteDialog.versions = minecraftManager.getAvailableVersions()
        }
    }

    // Listen for changes from the C++ side and refresh the local cache
    Connections {
        target: minecraftManager
        onAvailableVersionsChanged: {
            deleteDialog.versions = minecraftManager.getAvailableVersions()
        }
    }

    contentItem: Rectangle {
        color: backgroundColor
        radius: 8

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            // Título
            Text {
                text: "Delete Versions"
                font.pixelSize: 20
                font.bold: true
                color: textColor
                Layout.fillWidth: true
            }

            // Descripción
            Text {
                text: "Select the versions you want to delete:"
                font.pixelSize: 12
                color: secondaryTextColor
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }

            // Lista de versiones
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: surfaceColor
                radius: 0
                clip: true
                border.color: borderColor
                border.width: 1

                ScrollView {
                    anchors.fill: parent
                    clip: true

                    Column {
                        width: parent.width
                        spacing: 0

                        // Mensaje si no hay versiones
                        Rectangle {
                            width: parent.width
                            height: 100
                            color: "transparent"
                            visible: deleteDialog.versions.length === 0

                            Text {
                                anchors.centerIn: parent
                                text: "No versions installed"
                                color: secondaryTextColor
                                font.pixelSize: 13
                            }
                        }

                        // Lista de versiones disponibles
                        Repeater {
                            model: deleteDialog.versions

                            Rectangle {
                                id: versionItemDelegate
                                width: parent.width
                                height: 48
                                radius: 0
                                clip: true
                                property string versionPath: (typeof modelData === 'string') ? modelData : (modelData && modelData.path ? modelData.path : "")
                                property string versionName: (typeof modelData === 'string') ? (modelData.split("/").pop()) : (modelData && modelData.name ? modelData.name : (versionPath.split("/").pop()))
                                // use delegate 'checked' state for coloring (we'll implement a custom checkbox below)
                                property bool checked: false
                                color: checked ? "#2e1f1f" : (itemMouse.containsMouse ? "#3d3d3d" : "transparent")

                                MouseArea {
                                    id: itemMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        // Toggle the delegate checked state (same behavior as clicking the custom checkbox)
                                        versionItemDelegate.checked = !versionItemDelegate.checked
                                        if (versionItemDelegate.checked) {
                                            deleteDialog.selectedVersions = deleteDialog.selectedVersions.concat([versionPath])
                                        } else {
                                            var newArr = []
                                            for (var i = 0; i < deleteDialog.selectedVersions.length; ++i) {
                                                if (deleteDialog.selectedVersions[i] !== versionPath)
                                                    newArr.push(deleteDialog.selectedVersions[i])
                                            }
                                            deleteDialog.selectedVersions = newArr
                                        }
                                    }
                                }

                                // background and hover overlays
                                Rectangle {
                                    id: itemBackground
                                    anchors.fill: parent
                                    // selected uses UI gray (borderColor), non-rounded
                                    color: checked ? deleteDialog.borderColor : "transparent"
                                    radius: 0
                                    z: -1
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    // subtle gray hover using existing borderColor with alpha
                                    color: itemMouse.containsMouse ? "#3d3d3d22" : "transparent"
                                    radius: 0
                                    z: 0
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 12
                                    // ensure children are laid out inside the delegate bounds
                                    clip: true

                                    // Custom checkbox visual (thin, compact, green accent when checked)
                                    Rectangle {
                                        id: customCheck
                                        width: 20
                                        height: 20
                                        radius: 4
                                        // keep visible on hover: faint bg and lighter border when not checked
                                        color: checked ? deleteDialog.accentColor : (itemMouse.containsMouse ? '#151515' : "transparent")
                                        border.color: checked ? deleteDialog.accentColor : (itemMouse.containsMouse ? "#e0e0e0" : deleteDialog.borderColor)
                                        border.width: 1
                                        Layout.preferredWidth: 20
                                        Layout.preferredHeight: 20
                                        z: 2

                                        Behavior on color { ColorAnimation { duration: 120 } }
                                        Behavior on border.color { ColorAnimation { duration: 120 } }

                                        Text {
                                            id: checkMark
                                            anchors.centerIn: parent
                                            text: "✓"
                                            color: checked ? "#ffffff" : "transparent"
                                            font.pixelSize: 12
                                            font.bold: true
                                            opacity: checked ? 1 : 0
                                            Behavior on opacity { NumberAnimation { duration: 120 } }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                // toggle delegate checked state and update selection list
                                                versionItemDelegate.checked = !versionItemDelegate.checked
                                                if (versionItemDelegate.checked) {
                                                    deleteDialog.selectedVersions = deleteDialog.selectedVersions.concat([versionPath])
                                                } else {
                                                    var newArr = []
                                                    for (var i = 0; i < deleteDialog.selectedVersions.length; ++i) {
                                                        if (deleteDialog.selectedVersions[i] !== versionPath)
                                                            newArr.push(deleteDialog.selectedVersions[i])
                                                    }
                                                    deleteDialog.selectedVersions = newArr
                                                }
                                            }
                                        }
                                    }

                                    Text {
                                        text: versionName
                                        color: textColor
                                        font.pixelSize: 13
                                        verticalAlignment: Text.AlignVCenter
                                        Layout.fillWidth: true
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Botones
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    text: "Cancel"
                    Layout.fillWidth: true

                    background: Rectangle {
                        color: parent.pressed ? "#3d3d3d" : surfaceColor
                        radius: 4
                        border.color: borderColor
                        border.width: 1
                    }

                    contentItem: Text {
                        text: parent.text
                        color: textColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 12
                    }

                    onClicked: {
                        deleteDialog.selectedVersions = []
                        deleteDialog.close()
                    }
                }

                Button {
                    text: "Delete Selected"
                    Layout.fillWidth: true
                    enabled: deleteDialog.selectedVersions.length > 0

                    background: Rectangle {
                        color: parent.enabled ? (parent.pressed ? "#d32f2f" : deleteColor) : "#888888"
                        radius: 4
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
                        if (deleteDialog.selectedVersions.length > 0) {
                            deleteDialog.deleteRequested(deleteDialog.selectedVersions)
                            deleteDialog.selectedVersions = []
                            deleteDialog.close()
                        }
                    }
                }
            }
        }
    }

    background: Rectangle {
        color: surfaceColor
        radius: 8
        border.color: borderColor
        border.width: 1
    }
}
