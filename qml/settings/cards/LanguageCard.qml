import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3 as QtDialogs

Rectangle {
    id: languageCard
    color: themeManager.colors["surface_card"]
    radius: 8
    border.color: themeManager.colors["border"]
    border.width: 1
    Layout.fillWidth: true
    Layout.preferredHeight: 250

    property string currentLanguage: "EN"
    property var availableLanguages: ["EN", "ES"]
    property bool deleteMode: false
    property string selectedDeleteLanguage: ""
    property bool hasCustomLanguages: false
    property string statusText: ""

    signal languageChanged(string language)

    function normalizeLanguageCode(languageCode) {
        var raw = String(languageCode || "").trim()
        if (raw.length === 0)
            return ""

        var upper = raw.toUpperCase()
        if (upper.indexOf("_") >= 0)
            upper = upper.split("_")[0]
        if (upper.indexOf("-") >= 0)
            upper = upper.split("-")[0]
        return upper
    }

    function isDefaultLanguage(languageCode) {
        var normalized = normalizeLanguageCode(languageCode)
        return normalized === "EN" || normalized === "ES"
    }

    function refreshLanguages() {
        var langs = translator.availableLanguages()
        var normalized = []
        var map = {}

        for (var i = 0; i < langs.length; ++i) {
            var code = normalizeLanguageCode(langs[i])
            if (code.length === 0)
                continue
            if (!map[code]) {
                map[code] = true
                normalized.push(code)
            }
        }

        if (!map["EN"])
            normalized.push("EN")
        if (!map["ES"])
            normalized.push("ES")

        normalized.sort()
        availableLanguages = normalized

        var foundCurrent = false
        var hasCustom = false
        for (var j = 0; j < normalized.length; ++j) {
            if (normalized[j] === currentLanguage)
                foundCurrent = true
            if (!isDefaultLanguage(normalized[j]))
                hasCustom = true
        }
        hasCustomLanguages = hasCustom

        if (!foundCurrent)
            currentLanguage = "EN"

        if (selectedDeleteLanguage.length > 0 && normalized.indexOf(selectedDeleteLanguage) < 0)
            selectedDeleteLanguage = ""
    }

    function addLanguageFromPopup() {
        var code = normalizeLanguageCode(languageCodeField.text)
        var source = sourceJsonPathField.text.trim()

        if (code.length === 0) {
            addLanguageError.text = qsTr("Should enter language code")
            return
        }
        if (source.length === 0) {
            addLanguageError.text = qsTr("Should select a JSON file as source")
            return
        }

        if (!translator.importFromJson(code, source)) {
            addLanguageError.text = translator.lastError.length > 0
                                  ? translator.lastError
                                  : qsTr("Can not import language from JSON")
            return
        }

        refreshLanguages()
        deleteMode = false
        selectedDeleteLanguage = ""
        addLanguageDialog.close()
        statusText = qsTr("Language imported successfully")
        languageCard.currentLanguage = code
        languageChanged(code)
    }

    function deleteSelectedLanguageCode() {
        var code = normalizeLanguageCode(selectedDeleteLanguage)
        if (code.length === 0)
            return

        if (!translator.deleteLanguage(code)) {
            statusText = translator.lastError.length > 0
                       ? translator.lastError
                       : qsTr("Can not delete selected language")
            return
        }

        var removedCurrent = normalizeLanguageCode(currentLanguage) === code
        refreshLanguages()
        deleteMode = false
        selectedDeleteLanguage = ""
        statusText = qsTr("Language deleted successfully")

        if (removedCurrent) {
            languageCard.currentLanguage = "EN"
            languageChanged("EN")
        }
    }

    Component.onCompleted: {
        currentLanguage = normalizeLanguageCode(currentLanguage)
        refreshLanguages()
    }

    onCurrentLanguageChanged: {
        currentLanguage = normalizeLanguageCode(currentLanguage)
    }

    Connections {
        target: profileManager
        function onProfilesChanged() {
            refreshLanguages()
        }
    }

    QtDialogs.FileDialog {
        id: importLanguageDialog
        title: qsTr("Select JSON file for the language")
        selectExisting: true
        nameFilters: [ qsTr("JSON (*.json)"), qsTr("All Files (*)") ]
        onAccepted: {
            sourceJsonPathField.text = importLanguageDialog.fileUrl.toString()
            addLanguageError.text = ""
        }
    }

    QtDialogs.FileDialog {
        id: saveTemplateDialog
        title: qsTr("Save translation template")
        folder: shortcuts.home
        selectFolder: false
        selectExisting: false
        nameFilters: [ qsTr("JSON (*.json)") ]
        onAccepted: {
            var targetPath = saveTemplateDialog.fileUrl.toString()
            if (!targetPath || targetPath.length === 0)
                targetPath = "file://" + shortcuts.home + "/translation_template.json"

            if (!targetPath.toLowerCase().endsWith(".json"))
                targetPath += ".json"

            if (!translator.exportToJson(targetPath)) {
                statusText = translator.lastError.length > 0
                           ? translator.lastError
                           : qsTr("Can not export language template")
                return
            }
            statusText = qsTr("Template exported successfully")
        }
    }

    Dialog {
        id: addLanguageDialog
        modal: true
        focus: true
        width: Math.min(languageCard.width - 20, 460)
        x: (languageCard.width - width) / 2
        y: 18
        title: qsTr("Add Language")
        standardButtons: Dialog.NoButton

        onOpened: {
            languageCodeField.text = ""
            sourceJsonPathField.text = ""
            addLanguageError.text = ""
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
                text: qsTr("Language Code")
                color: themeManager.colors["text_primary"]
                font.pixelSize: 12
                font.bold: true
            }

            TextField {
                id: languageCodeField
                Layout.fillWidth: true
                placeholderText: qsTr("Example: FR")
            }

            Text {
                text: qsTr("Source File (.json)")
                color: themeManager.colors["text_primary"]
                font.pixelSize: 12
                font.bold: true
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                TextField {
                    id: sourceJsonPathField
                    Layout.fillWidth: true
                    placeholderText: qsTr("Select a JSON file")
                    readOnly: true
                }

                Button {
                    text: qsTr("Browse")
                    Layout.preferredWidth: 90
                    onClicked: importLanguageDialog.open()
                }
            }

            Text {
                id: addLanguageError
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
                    onClicked: addLanguageDialog.close()
                }

                Button {
                    text: qsTr("Add")
                    onClicked: addLanguageFromPopup()
                }
            }
        }
    }

    Menu {
        id: languageOptionsMenu

        MenuItem {
            text: qsTr("Get Template")
            onTriggered: saveTemplateDialog.open()
        }

        MenuItem {
            text: deleteMode ? qsTr("Cancel Delete Mode") : qsTr("Select Language to Delete")
            enabled: hasCustomLanguages
            onTriggered: {
                deleteMode = !deleteMode
                selectedDeleteLanguage = ""
            }
        }

        MenuItem {
            text: qsTr("Delete Selected Language")
            enabled: deleteMode && selectedDeleteLanguage.length > 0
            onTriggered: deleteSelectedLanguageCode()
        }
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: 25
        }
        spacing: 22

        Text {
            text: qsTr("LANGUAGE")
            color: themeManager.colors["text_primary"]
            font.pixelSize: 16
            font.bold: true
            font.capitalization: Font.AllUppercase
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 54
                Layout.topMargin: 2

                Flickable {
                    id: languageButtonsFlick
                    anchors.fill: parent
                    clip: true
                    contentWidth: languageButtonsRow.width
                    contentHeight: height
                    interactive: contentWidth > width

                    ScrollBar.horizontal: ScrollBar {
                        policy: languageButtonsFlick.contentWidth > languageButtonsFlick.width ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
                    }

                    Row {
                        id: languageButtonsRow
                        spacing: 10
                        height: parent.height

                        Repeater {
                            model: languageCard.availableLanguages

                            delegate: Button {
                                property string langCode: String(modelData)
                                property bool isCurrent: languageCard.currentLanguage === langCode
                                property bool isDeleteSelected: deleteMode && selectedDeleteLanguage === langCode

                                width: 108
                                height: 45
                                text: langCode
                                anchors.verticalCenter: parent.verticalCenter

                                background: Rectangle {
                                    color: isCurrent
                                           ? themeManager.colors["accent"]
                                           : (isDeleteSelected
                                              ? themeManager.colors["error"]
                                              : themeManager.colors["background_primary"])
                                    radius: 6
                                    border.color: isCurrent
                                                 ? themeManager.colors["accent"]
                                                 : (isDeleteSelected
                                                    ? themeManager.colors["error"]
                                                    : themeManager.colors["border"])
                                    border.width: 2
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                }

                                contentItem: Text {
                                    text: parent.text
                                    color: isCurrent ? themeManager.colors["text_on_accent"] : themeManager.colors["text_primary"]
                                    font.pixelSize: 13
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                }

                                onClicked: {
                                    if (deleteMode) {
                                        if (isDefaultLanguage(langCode)) {
                                            statusText = qsTr("Default languages can not be deleted")
                                            return
                                        }
                                        selectedDeleteLanguage = langCode
                                    } else {
                                        languageCard.currentLanguage = langCode
                                        languageChanged(langCode)
                                        statusText = ""
                                    }
                                }
                            }
                        }

                        Button {
                            id: addLanguageBtn
                            hoverEnabled: true
                            width: 122
                            height: 45
                            anchors.verticalCenter: parent.verticalCenter
                            ToolTip.visible: addLanguageBtn.hovered
                            ToolTip.delay: 400
                            ToolTip.text: qsTr("Add a new language")

                            background: Item {
                                Rectangle {
                                    anchors.fill: parent
                                    color: addLanguageBtn.pressed ? themeManager.colors["background_primary"] : themeManager.colors["surface"]
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
                                text: qsTr("Add Language")
                                color: themeManager.colors["text_muted"]
                                font.pixelSize: 12
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: addLanguageDialog.open()
                        }

                        Button {
                            id: languageOptionsBtn
                            hoverEnabled: true
                            width: 44
                            height: 44
                            anchors.verticalCenter: parent.verticalCenter
                            ToolTip.visible: languageOptionsBtn.hovered
                            ToolTip.delay: 400
                            ToolTip.text: qsTr("Language Options")

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

                            onClicked: languageOptionsMenu.popup()
                        }
                    }
                }
            }

            Text {
                visible: statusText.length > 0
                text: statusText
                color: themeManager.colors["error"]
                font.pixelSize: 11
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            Text {
                visible: deleteMode
                text: qsTr("Delete Mode: select a custom language in the row and then use 'Delete Selected Language' in the 3-dot menu.")
                color: themeManager.colors["text_muted"]
                font.pixelSize: 11
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }
    }
}
