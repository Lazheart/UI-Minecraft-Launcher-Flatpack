import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3

Rectangle {
    id: debugCard
    color: "#2d2d2d"
    radius: 8
    border.color: "#3d3d3d"
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
            color: "#ffffff"
            font.pixelSize: 14
            font.bold: true
            font.capitalization: Font.AllUppercase
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#0d0d0d"
            radius: 4
            border.color: "#3d3d3d"
            clip: true

            ListView {
                id: consoleListView
                anchors.fill: parent
                model: logHandler
                clip: true
                spacing: 2
                boundsBehavior: Flickable.StopAtBounds
                
                ScrollBar.vertical: ScrollBar {
                    active: true
                    policy: ScrollBar.AsNeeded
                }

                delegate: Rectangle {
                    width: consoleListView.width
                    height: logText.paintedHeight + 4
                    color: "transparent"

                    Text {
                        id: logText
                        width: parent.width - 10
                        x: 5
                        anchors.verticalCenter: parent.verticalCenter
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
            Layout.preferredHeight: 35
            spacing: 10

            Button {
                text: "Clear Console"
                Layout.preferredWidth: 120
                background: Rectangle {
                    color: parent.pressed ? "#505050" : "#3d3d3d"
                    radius: 3
                }
                contentItem: Text {
                    text: parent.text
                    color: "#ffffff"
                    font.pixelSize: 11
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: logHandler.clear()
            }

            Button {
                text: "Copy Logs"
                Layout.preferredWidth: 120
                background: Rectangle {
                    color: parent.pressed ? "#505050" : "#3d3d3d"
                    radius: 3
                }
                contentItem: Text {
                    text: parent.text
                    color: "#ffffff"
                    font.pixelSize: 11
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: logHandler.copyToClipboard()
            }

            Button {
                text: "Export Logs"
                Layout.preferredWidth: 120
                background: Rectangle {
                    color: parent.pressed ? "#505050" : "#3d3d3d"
                    radius: 3
                }
                contentItem: Text {
                    text: parent.text
                    color: "#ffffff"
                    font.pixelSize: 11
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: fileDialog.open()
            }

            Item { Layout.fillWidth: true }
            
            CheckBox {
                id: autoScrollCheck
                text: "Auto-scroll"
                checked: debugCard.autoScroll
                onCheckedChanged: debugCard.autoScroll = checked

                indicator: Rectangle {
                    implicitWidth: 18
                    implicitHeight: 18
                    x: autoScrollCheck.leftPadding
                    y: parent.height / 2 - height / 2
                    radius: 3
                    color: "#3d3d3d"
                    border.color: autoScrollCheck.checked ? "#4CAF50" : "#505050"
                    border.width: 1

                    Rectangle {
                        width: 10
                        height: 10
                        anchors.centerIn: parent
                        radius: 2
                        color: "#4CAF50"
                        visible: autoScrollCheck.checked
                    }
                }

                contentItem: Text {
                    text: parent.text
                    color: "#ffffff"
                    font.pixelSize: 12
                    verticalAlignment: Text.AlignVCenter
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
