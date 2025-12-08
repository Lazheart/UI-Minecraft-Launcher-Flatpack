import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    color: "#1e1e1e"
    
    ScrollView {
        anchors.fill: parent
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        Item {
            width: Math.max(parent.width, 950 + 60)
            height: contentLayout.height

            ColumnLayout {
                id: contentLayout
                width: Math.min(parent.width - 60, 950)
                x: Math.max((parent.width - width) / 2, 30)
                y: 40
                spacing: 32

                // TÍTULO
                Text {
                    text: "About Enkidu Launcher"
                    font.pixelSize: 36
                    font.bold: true
                    color: "#ffffff"
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

                Item { Layout.fillHeight: true; height: 60 }
            }
        }
    }
}
