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
    implicitWidth: 550
    implicitHeight: 450

    // Item that defines the visual area where the dialog should be centered.
    property Item anchorItem: null

    property color backgroundColor: '#1a1a1a'
    property color surfaceColor: "#1a1a1a"
    property color accentColor: "#4CAF50"
    property color textColor: "#ffffff"
    property color secondaryTextColor: "#b0b0b0"
    property color borderColor: "#4CAF50"
    // Rojo aún más grisáceo/suave para las versiones a eliminar
    
    property color deleteColor: '#521d1d'

    // Lista de versiones seleccionadas para eliminar
    property var selectedVersions: []
    // Cached list of versions shown in the dialog; refreshed on open and when manager notifies
    property var versions: []

    signal deleteRequested(var versions)

    anchors.centerIn: parent

    background: Rectangle {
        color: "#1a1a1a"
        radius: 16
        clip: true
    }

    contentItem: Rectangle {
        color: "#1a1a1a"
        radius: 16
        clip: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 25
            spacing: 20

            // Título
            Text {
                text: "Delete Versions"
                color: "#ffffff"
                font.pixelSize: 20
                font.bold: true
                Layout.fillWidth: true
            }

            // Descripción
            Text {
                text: "Select the versions you want to delete:"
                font.pixelSize: 13
                color: "#b0b0b0"
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }

            // Lista de versiones
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#111111"
                radius: 6
                clip: true
                border.color: listMouse.containsMouse ? accentColor : "transparent"
                border.width: 1
                
                MouseArea {
                    id: listMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    // Propagate clicks to the list components
                    onPressed: mouse.accepted = false
                }

                ScrollView {
                    id: versionsScrollView
                    anchors.fill: parent
                    clip: true

                    // Sólo scroll vertical; nunca horizontal
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                    // Asegura que el contenido no sea más ancho que el área visible
                    contentWidth: availableWidth

                    Column {
                        width: versionsScrollView.availableWidth
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
                                width: versionsScrollView.availableWidth
                                height: 48
                                radius: 6
                                clip: true
                                property string versionPath: (typeof modelData === 'string') ? modelData : (modelData && modelData.path ? modelData.path : "")
                                property string versionName: (typeof modelData === 'string') ? (modelData.split("/").pop()) : (modelData && modelData.name ? modelData.name : (versionPath.split("/").pop()))
                                readonly property bool checked: deleteDialog.selectedVersions.indexOf(versionPath) !== -1
                                color: "transparent"

                                MouseArea {
                                    id: itemMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        var path = versionPath
                                        var index = deleteDialog.selectedVersions.indexOf(path)
                                        if (index === -1) {
                                            deleteDialog.selectedVersions = deleteDialog.selectedVersions.concat([path])
                                        } else {
                                            var newArr = deleteDialog.selectedVersions.slice()
                                            newArr.splice(index, 1)
                                            deleteDialog.selectedVersions = newArr
                                        }
                                    }
                                }

                                // background overlay (contenido siempre dentro del recuadro)
                                Rectangle {
                                    id: itemBackground
                                    anchors.fill: parent
                                    // Margen muy pequeño para que casi no se note el espacio negro entre tarjetas
                                    anchors.margins: 1
                                    // Hover gris cuando no está seleccionado, rojo suave cuando sí
                                    color: versionItemDelegate.checked ? deleteDialog.deleteColor : (itemMouse.containsMouse ? "#2a2a2a" : "transparent")
                                    radius: 6
                                    z: 0
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 12
                                    clip: true

                                    Rectangle {
                                        id: customCheck
                                        width: 20
                                        height: 20
                                        radius: 4
                                        // Usamos el rojo fuerte del botón principal para que resalte sobre el fondo suave de la fila
                                        color: versionItemDelegate.checked ? '#17cd0a' : "transparent"
                                        border.color: versionItemDelegate.checked ? '#17cd0a' : deleteDialog.borderColor
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
                                            color: versionItemDelegate.checked ? "#ffffff" : "transparent"
                                            font.pixelSize: 12
                                            font.bold: true
                                            opacity: versionItemDelegate.checked ? 1 : 0
                                            Behavior on opacity { NumberAnimation { duration: 120 } }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                var path = versionPath
                                                var index = deleteDialog.selectedVersions.indexOf(path)
                                                if (index === -1) {
                                                    deleteDialog.selectedVersions = deleteDialog.selectedVersions.concat([path])
                                                } else {
                                                    var newArr = deleteDialog.selectedVersions.slice()
                                                    newArr.splice(index, 1)
                                                    deleteDialog.selectedVersions = newArr
                                                }
                                            }
                                        }
                                    }

                                    Text {
                                        text: versionName
                                        color: "#ffffff"
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
                        deleteDialog.selectedVersions = []
                        deleteDialog.close()
                    }
                }

                Button {
                    text: "Delete Selected"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45
                    enabled: deleteDialog.selectedVersions.length > 0

                    background: Rectangle {
                        color: parent.enabled ? (parent.pressed ? "#d32f2f" : "#f44336") : "#555555"
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

    onVisibleChanged: {
        // Clear any previous selections when the dialog opens or closes
        deleteDialog.selectedVersions = []
        if (visible) {
            // refresh the list each time the dialog opens
            deleteDialog.versions = minecraftManager.getAvailableVersions()
        }
    }

    // Listen for changes from the C++ side and refresh the local cache
    Connections {
        target: minecraftManager
        function onAvailableVersionsChanged() {
            deleteDialog.versions = minecraftManager.getAvailableVersions()
        }
    }
}
