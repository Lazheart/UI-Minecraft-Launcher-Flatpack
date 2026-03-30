import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3

Rectangle {
    id: visualCard
    color: themeManager.colors["surface_card"]
    radius: 8
    border.color: themeManager.colors["border"]
    border.width: 1
    Layout.fillWidth: true
    Layout.preferredHeight: 340

    property real scaleValue: 1.0
    property string currentTheme: "DARK"

    signal scaleChanged(real scale)
    signal themeChanged(string theme)

    FileDialog {
        id: importThemeDialog
        title: qsTr("Importar archivo de tema CSS")
        selectExisting: true
        nameFilters: [ qsTr("CSS (*.css)"), qsTr("Todos los archivos (*)") ]
        onAccepted: {
            var urlStr = importThemeDialog.fileUrl.toString()
            if (themeManager.loadFromFile(urlStr)) {
                profileManager.updateProfile(profileManager.currentProfile, {
                    customThemePath: themeManager.currentSource,
                    theme: visualCard.currentTheme
                })
                profileManager.saveProfiles()
            }
        }
    }

    FileDialog {
        id: saveTemplateDialog
        title: qsTr("Guardar plantilla del tema oscuro")
        selectExisting: false
        defaultSuffix: "css"
        nameFilters: [ qsTr("CSS (*.css)") ]
        onAccepted: {
            themeManager.saveBundledDarkTemplateTo(saveTemplateDialog.fileUrl.toString())
        }
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: 25
        }
        spacing: 22

        Text {
            text: "VISUAL"
            color: themeManager.colors["text_primary"]
            font.pixelSize: 16
            font.bold: true
            font.capitalization: Font.AllUppercase
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 12

            Text {
                text: "Interface Scale"
                color: themeManager.colors["text_primary"]
                font.pixelSize: 13
                font.bold: true
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 15
                Layout.topMargin: 5

                Slider {
                    id: scaleSlider
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    from: 0.5
                    to: 3.0
                    value: visualCard.scaleValue
                    stepSize: 0.1

                    background: Rectangle {
                        color: themeManager.colors["slider_track"]
                        radius: 4
                        height: 8
                        y: parent.height / 2 - height / 2

                        Rectangle {
                            color: themeManager.colors["accent"]
                            height: parent.height
                            radius: 4
                            width: scaleSlider.visualPosition * parent.width
                        }
                    }

                    handle: Rectangle {
                        x: scaleSlider.leftPadding + scaleSlider.visualPosition * (scaleSlider.availableWidth - width)
                        y: (scaleSlider.height - height) / 2
                        width: 24
                        height: 24
                        radius: 12
                        color: themeManager.colors["accent"]

                        Rectangle {
                            anchors.centerIn: parent
                            width: 12
                            height: 12
                            radius: 6
                            color: themeManager.colors["slider_handle_inner"]
                        }
                    }

                    onValueChanged: {
                        visualCard.scaleValue = value
                        visualCard.scaleChanged(value)
                    }
                }

                Text {
                    text: scaleSlider.value.toFixed(2) + "x"
                    color: themeManager.colors["accent"]
                    font.pixelSize: 14
                    font.bold: true
                    Layout.minimumWidth: 50
                    Layout.alignment: Qt.AlignVCenter
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 12
            Layout.topMargin: 6

            Text {
                text: "THEME"
                color: themeManager.colors["text_primary"]
                font.pixelSize: 13
                font.bold: true
            }

            // Una sola fila: DARK / LIGHT / importar / plantilla (misma altura que DARK·LIGHT)
            RowLayout {
                id: themeButtonsRow
                Layout.fillWidth: true
                spacing: 10
                Layout.topMargin: 4

                Button {
                    id: darkBtn
                    text: "DARK"
                    Layout.preferredWidth: 108
                    Layout.preferredHeight: 45
                    Layout.minimumHeight: 45
                    Layout.minimumWidth: 88
                    Layout.alignment: Qt.AlignVCenter

                    background: Rectangle {
                        color: visualCard.currentTheme === "DARK" ? themeManager.colors["accent"] : themeManager.colors["background_primary"]
                        radius: 6
                        border.color: visualCard.currentTheme === "DARK" ? themeManager.colors["accent"] : themeManager.colors["border"]
                        border.width: 2
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                    contentItem: Text {
                        text: parent.text
                        color: visualCard.currentTheme === "DARK" ? themeManager.colors["text_on_accent"] : themeManager.colors["text_primary"]
                        font.bold: true
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        visualCard.currentTheme = "DARK"
                        profileManager.updateProfile(profileManager.currentProfile, {
                            theme: "DARK",
                            customThemePath: ""
                        })
                        themeManager.loadBundledTheme("DARK")
                        visualCard.themeChanged("DARK")
                        profileManager.saveProfiles()
                    }
                }

                Button {
                    id: lightBtn
                    text: "LIGHT"
                    Layout.preferredWidth: 108
                    Layout.preferredHeight: 45
                    Layout.minimumHeight: 45
                    Layout.minimumWidth: 88
                    Layout.alignment: Qt.AlignVCenter

                    background: Rectangle {
                        color: visualCard.currentTheme === "LIGHT" ? themeManager.colors["accent"] : themeManager.colors["background_primary"]
                        radius: 6
                        border.color: visualCard.currentTheme === "LIGHT" ? themeManager.colors["accent"] : themeManager.colors["border"]
                        border.width: 2
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                    contentItem: Text {
                        text: parent.text
                        color: visualCard.currentTheme === "LIGHT" ? themeManager.colors["text_on_accent"] : themeManager.colors["text_primary"]
                        font.bold: true
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        visualCard.currentTheme = "LIGHT"
                        profileManager.updateProfile(profileManager.currentProfile, {
                            theme: "LIGHT",
                            customThemePath: ""
                        })
                        themeManager.loadBundledTheme("LIGHT")
                        visualCard.themeChanged("LIGHT")
                        profileManager.saveProfiles()
                    }
                }

                Button {
                    id: importCssBtn
                    hoverEnabled: true
                    Layout.preferredWidth: 44
                    Layout.minimumWidth: 38
                    Layout.maximumWidth: 46
                    Layout.preferredHeight: 44
                    Layout.minimumHeight: 38
                    Layout.maximumHeight: 46
                    Layout.alignment: Qt.AlignVCenter
                    ToolTip.visible: importCssBtn.hovered
                    ToolTip.delay: 400
                    ToolTip.text: qsTr("Importar un archivo .css de tema personalizado")

                    background: Rectangle {
                        color: parent.pressed ? themeManager.colors["border"] : themeManager.colors["surface"]
                        radius: 6
                        border.color: themeManager.colors["border"]
                        border.width: 1
                    }
                    contentItem: Text {
                        text: "+"
                        color: themeManager.colors["text_primary"]
                        font.pixelSize: 19
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: importThemeDialog.open()
                }

                Button {
                    id: templateBtn
                    hoverEnabled: true
                    Layout.preferredWidth: 44
                    Layout.minimumWidth: 38
                    Layout.maximumWidth: 46
                    Layout.preferredHeight: 44
                    Layout.minimumHeight: 38
                    Layout.maximumHeight: 46
                    Layout.alignment: Qt.AlignVCenter
                    ToolTip.visible: templateBtn.hovered
                    ToolTip.delay: 400
                    ToolTip.text: qsTr("Guardar la plantilla del tema oscuro (dark.css)")

                    background: Rectangle {
                        color: parent.pressed ? themeManager.colors["border"] : themeManager.colors["surface"]
                        radius: 6
                        border.color: themeManager.colors["border"]
                        border.width: 1
                    }
                    contentItem: Text {
                        text: "\u2193"
                        color: themeManager.colors["text_primary"]
                        font.pixelSize: 17
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: saveTemplateDialog.open()
                }
            }

            Text {
                visible: themeManager.lastError.length > 0
                text: themeManager.lastError
                color: themeManager.colors["error"]
                font.pixelSize: 11
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }
    }
}
