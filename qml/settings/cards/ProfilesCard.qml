import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: profilesCard
    color: themeManager.colors["surface_card"]
    radius: 8
    border.color: themeManager.colors["border"]
    border.width: 1
    Layout.preferredWidth: 300
    Layout.preferredHeight: 200

    property var settingsPageRef: null

    ColumnLayout {
        anchors {
            fill: parent
            margins: 20
        }
        spacing: 15

        Text {
            text: qsTr("PROFILES")
            color: themeManager.colors["text_primary"]
            font.pixelSize: 16
            font.bold: true
            font.capitalization: Font.AllUppercase
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: profileManager.profiles
                spacing: 8
                clip: true

                delegate: Rectangle {
                    width: parent.width
                    height: 70
                    color: modelData.name === profileManager.currentProfile ? themeManager.colors["accent"] : themeManager.colors["background_primary"]
                    radius: 4
                    border.color: modelData.name === profileManager.currentProfile ? themeManager.colors["accent"] : themeManager.colors["border_muted"]
                    border.width: 2

                    ColumnLayout {
                        anchors {
                            fill: parent
                            margins: 10
                        }
                        spacing: 4

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            MouseArea {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                onClicked: {
                                    profileManager.currentProfile = modelData.name

                                    var language = modelData.language || "EN"
                                    var theme = modelData.theme || "DARK"
                                    var scale = modelData.scale || 1.0

                                    profileManager.updateProfile(modelData.name, { language: language, theme: theme, scale: scale })

                                    if (settingsPageRef) {
                                        settingsPageRef.currentLanguage = language
                                        settingsPageRef.currentTheme = theme
                                        settingsPageRef.currentScale = scale
                                    }
                                }

                                ColumnLayout {
                                    anchors {
                                        fill: parent
                                        margins: 0
                                    }
                                    spacing: 0

                                    Text {
                                        text: modelData.name
                                        color: modelData.name === profileManager.currentProfile ? themeManager.colors["text_on_accent"] : themeManager.colors["text_primary"]
                                        font.pixelSize: 13
                                        font.bold: true
                                    }

                                    Text {
                                        text: {
                                            var info = []
                                            if (modelData.language) info.push(modelData.language)
                                            if (modelData.theme) info.push(modelData.theme)
                                            if (modelData.scale) info.push(modelData.scale + "x")
                                            return info.length > 0 ? info.join(" | ") : "Version: " + (modelData.version || "latest")
                                        }
                                        color: modelData.name === profileManager.currentProfile ? themeManager.colors["text_on_accent"] : themeManager.colors["text_secondary"]
                                        font.pixelSize: 10
                                    }
                                }
                            }

                            Button {
                                text: "✕"
                                visible: modelData.name !== "Default"
                                Layout.preferredWidth: 30
                                Layout.preferredHeight: 30

                                background: Rectangle {
                                    color: parent.pressed ? themeManager.colors["error_dark"] : themeManager.colors["error"]
                                    radius: 3
                                }

                                contentItem: Text {
                                    text: parent.text
                                    color: themeManager.colors["text_primary"]
                                    font.pixelSize: 14
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                onClicked: {
                                    if (modelData.name !== "Default") {
                                        profileManager.removeProfile(modelData.name)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                spacing: 5

                TextField {
                    id: newProfileInput
                    Layout.fillWidth: true
                    placeholderText: qsTr("New profile")

                    background: Rectangle {
                        color: themeManager.colors["background_primary"]
                        radius: 3
                        border.color: parent.activeFocus ? themeManager.colors["accent"] : themeManager.colors["border_muted"]
                        border.width: 1
                    }

                    color: themeManager.colors["text_primary"]
                    font.pixelSize: 11
                }

                Button {
                    text: "+"
                    Layout.preferredWidth: 35

                    background: Rectangle {
                        color: parent.pressed ? themeManager.colors["accent_pressed"] : themeManager.colors["accent"]
                        radius: 3
                    }

                    contentItem: Text {
                        text: parent.text
                        color: themeManager.colors["text_primary"]
                        font.pixelSize: 14
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                    onClicked: {
                        if (newProfileInput.text.trim() !== "") {
                            var language = settingsPageRef ? settingsPageRef.currentLanguage : "EN"
                            var theme = settingsPageRef ? settingsPageRef.currentTheme : "DARK"
                            var scale = settingsPageRef ? settingsPageRef.currentScale : 1.0

                            profileManager.addProfileWithSettings(
                                newProfileInput.text.trim(),
                                language,
                                theme,
                                scale
                            )
                            newProfileInput.text = ""
                        }
                    }
                }
            }
        }
    }
}
