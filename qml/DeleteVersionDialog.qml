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
                                                if (deleteDialog.selectedVersions.indexOf(modelData) === -1) {
                                                    deleteDialog.selectedVersions.push(modelData)
                                                }
                                            } else {
                                                deleteDialog.selectedVersions.splice(
                                                    deleteDialog.selectedVersions.indexOf(modelData), 1
                                                )
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
                                        text: modelData
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
        color: "transparent"
        radius: 8

        layer.enabled: true
        layer.effect: DropShadow {
            id: shadow
            anchors.fill: parent
            source: parent
            horizontalOffset: 0
            verticalOffset: 4
            radius: 8
            samples: 17
            color: "#00000040"
            cached: true
        }
    }
}
