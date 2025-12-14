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
                radius: 6
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
                            visible: minecraftManager.getAvailableVersions().length === 0

                            Text {
                                anchors.centerIn: parent
                                text: "No versions installed"
                                color: secondaryTextColor
                                font.pixelSize: 13
                            }
                        }

                        // Lista de versiones disponibles
                        Repeater {
                            model: minecraftManager.getAvailableVersions()

                            Rectangle {
                                id: versionItemDelegate
                                width: parent.width
                                height: 45
                                color: itemMouse.containsMouse ? "#3d3d3d" : "transparent"

                                // Soportar modelos que devuelvan una ruta (string)
                                // o un objeto { name: "1.21.0", path: "/abs/path/to/versions/1.21.0" }
                                property string versionPath: (typeof modelData === 'string') ? modelData : (modelData && modelData.path ? modelData.path : "")
                                property string versionName: (typeof modelData === 'string') ? (modelData.split("/").pop()) : (modelData && modelData.name ? modelData.name : (versionPath.split("/").pop()))

                                MouseArea {
                                    id: itemMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        versionCheckBox.checked = !versionCheckBox.checked
                                    }
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 10

                                    CheckBox {
                                        id: versionCheckBox
                                        Layout.preferredWidth: 20
                                        Layout.preferredHeight: 20

                                        onCheckedChanged: {
                                            if (checked) {
                                                if (deleteDialog.selectedVersions.indexOf(versionPath) === -1) {
                                                    deleteDialog.selectedVersions.push(versionPath)
                                                }
                                            } else {
                                                var idx = deleteDialog.selectedVersions.indexOf(versionPath)
                                                if (idx !== -1) deleteDialog.selectedVersions.splice(idx, 1)
                                            }
                                        }

                                        contentItem: Rectangle {
                                            width: parent.width
                                            height: parent.height
                                            color: parent.checked ? deleteDialog.deleteColor : deleteDialog.surfaceColor
                                            radius: 3
                                            border.color: deleteDialog.deleteColor
                                            border.width: 1

                                            Text {
                                                visible: parent.color === deleteDialog.deleteColor
                                                anchors.centerIn: parent
                                                text: "✓"
                                                color: "#ffffff"
                                                font.bold: true
                                                font.pixelSize: 12
                                            }
                                        }

                                        background: Rectangle {
                                            color: "transparent"
                                        }
                                    }

                                    Text {
                                        text: versionName
                                        color: textColor
                                        font.pixelSize: 13
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
