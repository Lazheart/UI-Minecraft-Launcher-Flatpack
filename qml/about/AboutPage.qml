import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "cards"

Rectangle {
    color: themeManager.colors["background_primary"]
    
    ScrollView {
        id: scrollView
        anchors.fill: parent
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        Item {
            width: scrollView.availableWidth
            implicitHeight: contentLayout.implicitHeight + 80
            height: implicitHeight

            ColumnLayout {
                id: contentLayout
                width: Math.min(parent.width - 60, 950)
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 40
                spacing: 32

                // TÍTULO
                Text {
                    text: qsTr("About This Launcher")
                    font.pixelSize: 36
                    font.bold: true
                    color: themeManager.colors["text_primary"]
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                // TARJETA HERO
                AboutHeroCard {
                    Layout.fillWidth: true
                }

                // TARJETA AUTOR
                AboutAuthorCard {
                    Layout.fillWidth: true
                }

                // TARJETA CARACTERÍSTICAS
                AboutFeaturesCard {
                    Layout.fillWidth: true
                }

                // TARJETA DISCLAIMER
                AboutDisclaimerCard {
                    Layout.fillWidth: true
                }

                Item { Layout.preferredHeight: 60 }
            }
        }
    }
}
