import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: settingsPage
    color: "#1e1e1e"

    ScrollView {
        id: scrollView
        anchors.fill: parent
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        contentHeight: contentLayout.implicitHeight + 80

        Item {
            width: scrollView.width
            height: Math.max(scrollView.height, contentLayout.implicitHeight + 80)

            ColumnLayout {
                id: contentLayout
                width: Math.min(parent.width - 60, 1200)
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 40
                spacing: 32

                // Título
                Text {
                    text: "Settings"
                    font.pixelSize: 36
                    font.bold: true
                    color: "#ffffff"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                // Primera fila: Language y Profiles lado a lado
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 20

                    LanguageCard {
                        id: languageCard
                        Layout.fillWidth: true
                        onLanguageChanged: (language) => {
                            launcherBackend.setLanguage(language)
                        }
                    }

                    ProfilesCard {
                        id: profilesCard
                        Layout.preferredWidth: 300
                    }
                }

                // Paths Card
                PathsCard {
                    Layout.fillWidth: true
                }

                // Visual Card
                VisualCard {
                    id: visualCard
                    Layout.fillWidth: true
                    onScaleChanged: (scale) => {
                        settingsPage.scale = scale
                    }
                    onThemeChanged: (theme) => {
                        launcherBackend.setTheme(theme)
                    }
                }

                // Debug Card - Full width with more space
                DebugCard {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 500
                }

                // Action Buttons Row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15
                    Layout.topMargin: 20

                    Button {
                        text: "SAVE"
                        Layout.preferredWidth: 150
                        Layout.preferredHeight: 45

                        background: Rectangle {
                            color: parent.pressed ? "#388E3C" : "#4CAF50"
                            radius: 4
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "#ffffff"
                            font.pixelSize: 13
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            launcherBackend.saveSettings()
                            console.log("[Settings] Settings saved")
                        }
                    }

                    Button {
                        text: "APPLY"
                        Layout.preferredWidth: 150
                        Layout.preferredHeight: 45

                        background: Rectangle {
                            color: parent.pressed ? "#1976D2" : "#2196F3"
                            radius: 4
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "#ffffff"
                            font.pixelSize: 13
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            launcherBackend.applySettings()
                            console.log("[Settings] Settings applied")
                        }
                    }

                    Button {
                        text: "RESET TO DEFAULT"
                        Layout.preferredWidth: 180
                        Layout.preferredHeight: 45

                        background: Rectangle {
                            color: parent.pressed ? "#d32f2f" : "#f44336"
                            radius: 4
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "#ffffff"
                            font.pixelSize: 13
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            launcherBackend.resetSettings()
                            languageCard.currentLanguage = "EN"
                            visualCard.scaleValue = 1.0
                            visualCard.currentTheme = "DARK"
                            settingsPage.scale = 1.0
                            console.log("[Settings] Settings reset to default")
                        }
                    }

                    Item { Layout.fillWidth: true }
                }

                Item { Layout.fillHeight: true; Layout.minimumHeight: 20 }
            }
        }
    }
}
