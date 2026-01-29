import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: languageCard
    color: "#2d2d2d"
    radius: 8
    border.color: "#3d3d3d"
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
            color: "#ffffff"
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
                    color: languageCard.currentLanguage === "EN" ? "#4CAF50" : "#1e1e1e"
                    radius: 4
                    border.color: languageCard.currentLanguage === "EN" ? "#4CAF50" : "#555555"
                    border.width: 2
                }
                
                contentItem: Text {
                    text: parent.text
                    color: languageCard.currentLanguage === "EN" ? "#1e1e1e" : "#ffffff"
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
                    color: languageCard.currentLanguage === "ES" ? "#4CAF50" : "#1e1e1e"
                    radius: 4
                    border.color: languageCard.currentLanguage === "ES" ? "#4CAF50" : "#555555"
                    border.width: 2
                }
                
                contentItem: Text {
                    text: parent.text
                    color: languageCard.currentLanguage === "ES" ? "#1e1e1e" : "#ffffff"
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
