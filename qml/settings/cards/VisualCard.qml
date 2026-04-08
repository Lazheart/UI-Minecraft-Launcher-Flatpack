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
    property string currentTheme: qsTr("DARK")
    property var customThemes: []
    property bool deleteMode: false
    property string selectedDeleteThemePath: ""

    signal scaleChanged(real scale)
    signal themeChanged(string theme)

    function refreshCustomThemes() {
        var profile = profileManager.getProfile(profileManager.currentProfile)
        if (profile && profile.customThemes)
            customThemes = profile.customThemes
        else
            customThemes = []

        if (selectedDeleteThemePath.length > 0) {
            var stillExists = false
            for (var i = 0; i < customThemes.length; ++i) {
                if (String(customThemes[i].path) === selectedDeleteThemePath) {
                    stillExists = true
                    break
                }
            }
            if (!stillExists)
                selectedDeleteThemePath = ""
        }
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
            addThemeError.text = qsTr("Should enter name for the theme")
            return
        }
        if (source.length === 0) {
            addThemeError.text = qsTr("Should select a CSS file as source")
            return
        }

        var savedPath = pathManager.saveThemeToProfile(
                    profileManager.currentProfile,
                    name,
                    source)
        if (!savedPath || String(savedPath).length === 0) {
            addThemeError.text = qsTr("Can not copy the theme file to profile folder")
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

    function deleteThemeByPath(pathToDelete) {
        var profile = profileManager.getProfile(profileManager.currentProfile)
        var targetPath = String(pathToDelete)
        if (targetPath.length === 0)
            return
        var list = (profile && profile.customThemes) ? profile.customThemes.slice() : []
        var filtered = []
        for (var i = 0; i < list.length; ++i) {
            if (String(list[i].path) !== targetPath)
                filtered.push(list[i])
        }

        var removedCurrent = (profile && profile.customThemePath)
                           ? (String(profile.customThemePath) === targetPath)
                           : false
        var nextTheme = removedCurrent ? qsTr("DARK")
                                       : ((profile && profile.theme) ? String(profile.theme) : qsTr("DARK"))
        var nextCustomThemePath = removedCurrent ? ""
                                                 : ((profile && profile.customThemePath) ? String(profile.customThemePath) : "")

        profileManager.updateProfile(profileManager.currentProfile, {
            customThemes: filtered,
            customThemePath: nextCustomThemePath,
            theme: nextTheme
        })
        profileManager.saveProfiles()

        if (removedCurrent) {
            visualCard.currentTheme = "DARK"
            themeManager.loadBundledTheme("DARK")
            visualCard.themeChanged("DARK")
        }

        deleteMode = false
        selectedDeleteThemePath = ""
        refreshCustomThemes()
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
        title: qsTr("Select CSS file for the theme")
        selectExisting: true
        nameFilters: [ qsTr("CSS (*.css)"), qsTr("All Files (*)") ]
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
                text: qsTr("Theme Name")
                color: themeManager.colors["text_primary"]
                font.pixelSize: 12
                font.bold: true
            }

            TextField {
                id: themeNameField
                Layout.fillWidth: true
                placeholderText: qsTr("Example: Gray Steel")
            }

            Text {
                text: qsTr("Source File (.css)")
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
                    placeholderText: qsTr("Select a CSS file")
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
                    text: qsTr("Cancel")
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
        title: qsTr("Select folder to save style.css")
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

    Menu {
        id: themeOptionsMenu

        MenuItem {
            text: qsTr("Get Template")
            onTriggered: saveTemplateDialog.open()
        }

        MenuItem {
            text: deleteMode ? qsTr("Cancel Delete Mode") : qsTr("Select Theme to Delete")
            enabled: visualCard.customThemes.length > 0
            onTriggered: {
                deleteMode = !deleteMode
                selectedDeleteThemePath = ""
            }
        }

        MenuItem {
            text: qsTr("Delete Selected Theme")
            enabled: deleteMode && selectedDeleteThemePath.length > 0
            onTriggered: visualCard.deleteThemeByPath(selectedDeleteThemePath)
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
                text: qsTr("Interface Scale")
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
                text: qsTr("THEME")
                color: themeManager.colors["text_primary"]
                font.pixelSize: 13
                font.bold: true
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 54
                Layout.topMargin: 4

                Flickable {
                    id: themeButtonsFlick
                    anchors.fill: parent
                    clip: true
                    contentWidth: themeButtonsRow.width
                    contentHeight: height
                    interactive: contentWidth > width

                    ScrollBar.horizontal: ScrollBar {
                        policy: themeButtonsFlick.contentWidth > themeButtonsFlick.width ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
                    }

                    Row {
                        id: themeButtonsRow
                        spacing: 10
                        height: parent.height

                        Button {
                            id: darkBtn
                            text: qsTr("DARK")
                            width: 108
                            height: 45
                            anchors.verticalCenter: parent.verticalCenter

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
                            text: qsTr("LIGHT")
                            width: 108
                            height: 45
                            anchors.verticalCenter: parent.verticalCenter

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
                                visualCard.currentTheme = qsTr("LIGHT")
                                profileManager.updateProfile(profileManager.currentProfile, {
                                    theme: qsTr("LIGHT"),
                                    customThemePath: ""
                                })
                                themeManager.loadBundledTheme(qsTr("LIGHT"))
                                visualCard.themeChanged(qsTr("LIGHT"))
                                profileManager.saveProfiles()
                            }
                        }

                        Repeater {
                            model: visualCard.customThemes

                            delegate: Button {
                                width: 108
                                height: 45
                                text: modelData.name
                                anchors.verticalCenter: parent.verticalCenter

                                background: Rectangle {
                                    color: (visualCard.currentTheme === String(modelData.name))
                                           ? themeManager.colors["accent"]
                                           : (deleteMode && selectedDeleteThemePath === String(modelData.path)
                                              ? themeManager.colors["error"]
                                              : themeManager.colors["background_primary"])
                                    radius: 6
                                        border.color: (visualCard.currentTheme === String(modelData.name))
                                                     ? themeManager.colors["accent"]
                                                     : (deleteMode && selectedDeleteThemePath === String(modelData.path)
                                                        ? themeManager.colors["error"]
                                                        : themeManager.colors["border"])
                                    border.width: 2
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                }

                                contentItem: Text {
                                    text: parent.text
                                    color: (visualCard.currentTheme === String(modelData.name))
                                           ? themeManager.colors["text_on_accent"]
                                           : themeManager.colors["text_primary"]
                                    font.pixelSize: 13
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                }

                                onClicked: {
                                    if (deleteMode)
                                        selectedDeleteThemePath = String(modelData.path)
                                    else
                                        visualCard.activateCustomTheme(String(modelData.name), String(modelData.path))
                                }
                            }
                        }

                        Button {
                            id: addThemeBtn
                            hoverEnabled: true
                            width: 122
                            height: 45
                            anchors.verticalCenter: parent.verticalCenter
                            ToolTip.visible: addThemeBtn.hovered
                            ToolTip.delay: 400
                            ToolTip.text: qsTr("Add a new custom theme")

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
                            id: themeOptionsBtn
                            hoverEnabled: true
                            width: 44
                            height: 44
                            anchors.verticalCenter: parent.verticalCenter
                            ToolTip.visible: themeOptionsBtn.hovered
                            ToolTip.delay: 400
                            ToolTip.text: qsTr("Theme Options")

                            background: Rectangle {
                                color: (deleteMode || parent.pressed) ? themeManager.colors["border"] : themeManager.colors["surface"]
                                radius: 6
                                border.color: themeManager.colors["border"]
                                border.width: 1
                            }
                            contentItem: Text {
                                text: "\u22EF"
                                color: themeManager.colors["text_primary"]
                                font.pixelSize: 20
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                themeOptionsMenu.popup()
                            }
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

            Text {
                visible: deleteMode
                text: qsTr("Delete Mode: select a theme in the row and then use 'Delete Selected Theme' in the 3-dot menu.")
                color: themeManager.colors["text_muted"]
                font.pixelSize: 11
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }
    }
}
