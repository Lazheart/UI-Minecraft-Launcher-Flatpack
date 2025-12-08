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
            width: parent.width
            height: contentLayout.implicitHeight + 80

            ColumnLayout {
                id: contentLayout
                width: Math.min(parent.width - 60, 950)
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 40
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

                Item { Layout.preferredHeight: 60 }
            }
        }
    }
}
