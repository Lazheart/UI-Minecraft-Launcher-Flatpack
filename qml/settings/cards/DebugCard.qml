import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3

Rectangle {
    id: debugCard
    color: themeManager.colors["surface_card"]
    radius: 8
    border.color: themeManager.colors["border"]
    border.width: 1
    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.minimumHeight: 400

    property bool autoScroll: true

    ColumnLayout {
        anchors {
            fill: parent
            margins: 20
        }
        spacing: 15

        Text {
            text: "DEBUG - Console Output"
            color: themeManager.colors["text_primary"]
            font.pixelSize: 14
            font.bold: true
            font.capitalization: Font.AllUppercase
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: themeManager.colors["debug_console_bg"]
            radius: 4
            border.color: themeManager.colors["border"]
            clip: true

            ListView {
                id: consoleListView
                anchors.fill: parent
                anchors.margins: 5
                model: logHandler
                clip: true
                spacing: 2
                boundsBehavior: Flickable.StopAtBounds
                
                ScrollBar.vertical: ScrollBar {
                    active: true
                    policy: ScrollBar.AsNeeded
                }

                delegate: Item {
                    width: consoleListView.width - 10 
                    height: logText.implicitHeight + 4
                    
                    Text {
                        id: logText
                        anchors.fill: parent
                        anchors.leftMargin: 5
                        text: "[" + timestamp + "] " + message
                        color: logColor
                        font.family: "Courier" // Monospaced
                        font.pixelSize: 12
                        wrapMode: Text.Wrap
                        textFormat: Text.PlainText
                    }
                }

                onCountChanged: {
                    if (debugCard.autoScroll) {
                        consoleListView.positionViewAtEnd()
                    }
                }
                
                // Disable autoscroll if user manually scrolls
                onFlickStarted: {
                    debugCard.autoScroll = false
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Button {
                text: "Clear Console"
                Layout.fillWidth: true
                Layout.minimumWidth: 80
                Layout.maximumWidth: 160
                Layout.preferredHeight: 35 
                background: Rectangle {
                    color: parent.pressed ? themeManager.colors["border_muted"] : themeManager.colors["border"]
                    radius: 3
                }
                contentItem: Text {
                    text: parent.text
                    color: themeManager.colors["text_primary"]
                    font.pixelSize: 11
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    fontSizeMode: Text.Fit
                    minimumPixelSize: 8
                    elide: Text.ElideRight
                }
                onClicked: logHandler.clear()
            }

            Button {
                text: "Copy Logs"
                Layout.fillWidth: true
                Layout.minimumWidth: 60
                Layout.maximumWidth: 160
                Layout.preferredHeight: 35
                background: Rectangle {
                    color: parent.pressed ? themeManager.colors["border_muted"] : themeManager.colors["border"]
                    radius: 3
                }
                contentItem: Text {
                    text: parent.text
                    color: themeManager.colors["text_primary"]
                    font.pixelSize: 11
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    fontSizeMode: Text.Fit
                    minimumPixelSize: 8
                    elide: Text.ElideRight
                }
                onClicked: logHandler.copyToClipboard()
            }

            Button {
                text: "Export Logs"
                Layout.fillWidth: true
                Layout.minimumWidth: 80
                Layout.maximumWidth: 160
                Layout.preferredHeight: 35
                background: Rectangle {
                    color: parent.pressed ? themeManager.colors["border_muted"] : themeManager.colors["border"]
                    radius: 3
                }
                contentItem: Text {
                    text: parent.text
                    color: themeManager.colors["text_primary"]
                    font.pixelSize: 11
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    fontSizeMode: Text.Fit
                    minimumPixelSize: 8
                    elide: Text.ElideRight
                }
                onClicked: fileDialog.open()
            }

            Item { Layout.fillWidth: true }
            
            CheckBox {
                id: autoScrollCheck
                text: "Auto-scroll"
                checked: debugCard.autoScroll
                onCheckedChanged: debugCard.autoScroll = checked
                
                Layout.preferredHeight: 35
                Layout.alignment: Qt.AlignVCenter

                indicator: Rectangle {
                    implicitWidth: 18
                    implicitHeight: 18
                    anchors.verticalCenter: parent.verticalCenter
                    x: autoScrollCheck.leftPadding
                    radius: 3
                    color: themeManager.colors["border"]
                    border.color: autoScrollCheck.checked ? themeManager.colors["accent"] : themeManager.colors["border_muted"]
                    border.width: 1

                    Rectangle {
                        width: 10
                        height: 10
                        anchors.centerIn: parent
                        radius: 2
                        color: themeManager.colors["accent"]
                        visible: autoScrollCheck.checked
                    }
                }

                contentItem: Text {
                    text: parent.text
                    color: themeManager.colors["text_primary"]
                    font.pixelSize: 12
                    verticalAlignment: Text.AlignVCenter
                    anchors.verticalCenter: parent.verticalCenter
                    leftPadding: parent.indicator.width + 10
                }
            }
        }
    }

    FileDialog {
        id: fileDialog
        title: "Export Log File"
        folder: shortcuts.home
        selectExisting: false
        nameFilters: ["Log files (*.log)", "All files (*)"]
        onAccepted: {
            logHandler.saveLog(fileUrl)
        }
    }
}
