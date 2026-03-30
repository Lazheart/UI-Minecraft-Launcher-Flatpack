import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3 as QtDialogs

Rectangle {
    id: visualCard
    color: themeManager.colors["surface_card"]
    radius: 8
    border.color: themeManager.colors["border"]
    border.width: 1
    Layout.fillWidth: true
    Layout.preferredHeight: 420

    property real scaleValue: 1.0
    property string currentTheme: "DARK"
    property var customThemes: []

    signal scaleChanged(real scale)
    signal themeChanged(string theme)

    function refreshCustomThemes() {
        var profile = profileManager.getProfile(profileManager.currentProfile)
        if (profile && profile.customThemes)
            customThemes = profile.customThemes
        else
            customThemes = []
    }

    function activateCustomTheme(themeName, themePath) {
        if (!themePath || String(themePath).length === 0)
            return

        if (themeManager.loadFromFile(String(themePath))) {
            visualCard.currentTheme = String(themeName)
            profileManager.updateProfile(profileManager.currentProfile, {
                theme: String(themeName),
                customThemePath: String(themePath)
            })
            visualCard.themeChanged(String(themeName))
            profileManager.saveProfiles()
        }
    }

    function addThemeFromPopup() {
        var source = sourcePathField.text.trim()
        var name = themeNameField.text.trim()

        if (name.length === 0) {
            addThemeError.text = qsTr("Debes ingresar un nombre para el tema")
            return
        }
        if (source.length === 0) {
            addThemeError.text = qsTr("Debes seleccionar un archivo CSS")
            return
        }

        var savedPath = pathManager.saveThemeToProfile(
                    profileManager.currentProfile,
                    name,
                    source)
        if (!savedPath || String(savedPath).length === 0) {
            addThemeError.text = qsTr("No se pudo copiar el archivo al perfil")
            return
        }

        if (!themeManager.loadFromFile(String(savedPath))) {
            addThemeError.text = themeManager.lastError
            return
        }

        var profile = profileManager.getProfile(profileManager.currentProfile)
        var list = (profile && profile.customThemes) ? profile.customThemes.slice() : []
        var replaced = false
        for (var i = 0; i < list.length; ++i) {
            if (String(list[i].name).toLowerCase() === name.toLowerCase()) {
                list[i] = {"name": name, "path": String(savedPath)}
                replaced = true
                break
            }
        }
        if (!replaced)
            list.push({"name": name, "path": String(savedPath)})

        profileManager.updateProfile(profileManager.currentProfile, {
            customThemes: list,
            customThemePath: String(savedPath),
            theme: name
        })
        profileManager.saveProfiles()

        visualCard.currentTheme = name
        visualCard.themeChanged(name)
        refreshCustomThemes()
        addThemeDialog.close()
    }

    Component.onCompleted: refreshCustomThemes()

    Connections {
        target: profileManager
        function onProfilesChanged() {
            refreshCustomThemes()
        }
        function onCurrentProfileChanged() {
            refreshCustomThemes()
        }
    }

    QtDialogs.FileDialog {
        id: importThemeDialog
        title: qsTr("Seleccionar archivo de tema CSS")
        selectExisting: true
        nameFilters: [ qsTr("CSS (*.css)"), qsTr("Todos los archivos (*)") ]
        onAccepted: {
            sourcePathField.text = importThemeDialog.fileUrl.toString()
            addThemeError.text = ""
        }
    }

    Dialog {
        id: addThemeDialog
        modal: true
        focus: true
        width: Math.min(visualCard.width - 20, 460)
        x: (visualCard.width - width) / 2
        y: 18
        title: qsTr("Add Theme")
        standardButtons: Dialog.NoButton

        onOpened: {
            themeNameField.text = ""
            sourcePathField.text = ""
            addThemeError.text = ""
        }

        background: Rectangle {
            color: themeManager.colors["surface"]
            radius: 8
            border.color: themeManager.colors["border"]
            border.width: 1
        }

        contentItem: ColumnLayout {
            spacing: 10

            Text {
                text: qsTr("Nombre del estilo")
                color: themeManager.colors["text_primary"]
                font.pixelSize: 12
                font.bold: true
            }

            TextField {
                id: themeNameField
                Layout.fillWidth: true
                placeholderText: qsTr("Ejemplo: Gray Steel")
            }

            Text {
                text: qsTr("Archivo source (.css)")
                color: themeManager.colors["text_primary"]
                font.pixelSize: 12
                font.bold: true
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                TextField {
                    id: sourcePathField
                    Layout.fillWidth: true
                    placeholderText: qsTr("Selecciona un archivo CSS")
                    readOnly: true
                }

                Button {
                    text: qsTr("Browse")
                    Layout.preferredWidth: 90
                    onClicked: importThemeDialog.open()
                }
            }

            Text {
                id: addThemeError
                Layout.fillWidth: true
                color: themeManager.colors["error"]
                font.pixelSize: 11
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Item { Layout.fillWidth: true }

                Button {
                    text: qsTr("Cancelar")
                    onClicked: addThemeDialog.close()
                }

                Button {
                    text: qsTr("Add")
                    onClicked: addThemeFromPopup()
                }
            }
        }
    }

    QtDialogs.FileDialog {
        id: saveTemplateDialog
        title: qsTr("Seleccionar carpeta para guardar style.css")
        folder: shortcuts.home
        selectFolder: true
        selectExisting: true
        onAccepted: {
            var targetPath = saveTemplateDialog.fileUrl.toString()
            if (!targetPath.endsWith("/"))
                targetPath += "/"
            targetPath += "style.css"
            themeManager.saveBundledDarkTemplateTo(targetPath)
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

            // Fila principal de tema
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
                    id: addThemeBtn
                    hoverEnabled: true
                    Layout.preferredWidth: 122
                    Layout.minimumWidth: 98
                    Layout.preferredHeight: 45
                    Layout.minimumHeight: 45
                    Layout.alignment: Qt.AlignVCenter
                    ToolTip.visible: addThemeBtn.hovered
                    ToolTip.delay: 400
                    ToolTip.text: qsTr("Agregar tema personalizado")

                    background: Item {
                        Rectangle {
                            anchors.fill: parent
                            color: addThemeBtn.pressed ? themeManager.colors["background_primary"] : themeManager.colors["surface"]
                            radius: 6
                        }
                        Canvas {
                            anchors.fill: parent
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.clearRect(0, 0, width, height)
                                ctx.strokeStyle = themeManager.colors["border"]
                                ctx.lineWidth = 1
                                ctx.setLineDash([6, 4])
                                ctx.strokeRect(1, 1, width - 2, height - 2)
                            }
                            onWidthChanged: requestPaint()
                            onHeightChanged: requestPaint()
                        }
                    }
                    contentItem: Text {
                        text: qsTr("Add Theme")
                        color: themeManager.colors["text_muted"]
                        font.pixelSize: 12
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: addThemeDialog.open()
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
                    onClicked: {
                        saveTemplateDialog.open()
                    }
                }
            }

            Flow {
                id: customThemesFlow
                Layout.fillWidth: true
                spacing: 8
                visible: visualCard.customThemes.length > 0

                Repeater {
                    model: visualCard.customThemes

                    delegate: Button {
                        width: 118
                        height: 38
                        text: modelData.name

                        background: Rectangle {
                            color: (profileManager.getProfile(profileManager.currentProfile).customThemePath === modelData.path)
                                   ? themeManager.colors["accent"]
                                   : themeManager.colors["background_primary"]
                            radius: 6
                            border.color: (profileManager.getProfile(profileManager.currentProfile).customThemePath === modelData.path)
                                          ? themeManager.colors["accent"]
                                          : themeManager.colors["border"]
                            border.width: 1
                        }

                        contentItem: Text {
                            text: parent.text
                            color: (profileManager.getProfile(profileManager.currentProfile).customThemePath === modelData.path)
                                   ? themeManager.colors["text_on_accent"]
                                   : themeManager.colors["text_primary"]
                            font.pixelSize: 11
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }

                        onClicked: {
                            visualCard.activateCustomTheme(String(modelData.name), String(modelData.path))
                        }
                    }
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
