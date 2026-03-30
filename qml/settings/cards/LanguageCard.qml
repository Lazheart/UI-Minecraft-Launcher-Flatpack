import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: languageCard
    color: themeManager.colors["surface_card"]
    radius: 8
    border.color: themeManager.colors["border"]
    border.width: 1
    Layout.fillWidth: true
    Layout.preferredHeight: 200

    property string currentLanguage: "EN"
    signal languageChanged(string language)

    ColumnLayout {
        anchors {
            fill: parent
            margins: 20
        }
        spacing: 20

        Text {
            text: "LANGUAGE"
            color: themeManager.colors["text_primary"]
            font.pixelSize: 16
            font.bold: true
            font.capitalization: Font.AllUppercase
        }

        RowLayout {
            spacing: 15
            Layout.fillWidth: true
            Layout.fillHeight: true

            Button {
                text: "ENGLISH"
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                
                background: Rectangle {
                    color: languageCard.currentLanguage === "EN" ? themeManager.colors["accent"] : themeManager.colors["background_primary"]
                    radius: 4
                    border.color: languageCard.currentLanguage === "EN" ? themeManager.colors["accent"] : themeManager.colors["border_muted"]
                    border.width: 2
                }
                
                contentItem: Text {
                    text: parent.text
                    color: languageCard.currentLanguage === "EN" ? themeManager.colors["text_on_accent"] : themeManager.colors["text_primary"]
                    font.bold: true
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: {
                    languageCard.currentLanguage = "EN"
                    languageChanged("EN")
                }
            }

            Button {
                text: "ESPAÑOL"
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                
                background: Rectangle {
                    color: languageCard.currentLanguage === "ES" ? themeManager.colors["accent"] : themeManager.colors["background_primary"]
                    radius: 4
                    border.color: languageCard.currentLanguage === "ES" ? themeManager.colors["accent"] : themeManager.colors["border_muted"]
                    border.width: 2
                }
                
                contentItem: Text {
                    text: parent.text
                    color: languageCard.currentLanguage === "ES" ? themeManager.colors["text_on_accent"] : themeManager.colors["text_primary"]
                    font.bold: true
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: {
                    languageCard.currentLanguage = "ES"
                    languageChanged("ES")
                }
            }

            Item { Layout.fillWidth: true }
        }
    }
}
