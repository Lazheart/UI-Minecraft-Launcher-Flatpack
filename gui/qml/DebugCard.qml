import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: debugCard
    color: "#2d2d2d"
    radius: 8
    border.color: "#3d3d3d"
    border.width: 1
    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.minimumHeight: 400

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

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 0

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#3d3d3d"
                }

                TextEdit {
                    id: consoleOutput
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    readOnly: true
                    text: "[INFO] Launcher started\n[INFO] Profiles loaded\n[DEBUG] Backend initialized\n[WARNING] Update available"
                    color: "#b0b0b0"
                    font.pixelSize: 10
                    font.family: "Courier"
                    wrapMode: TextEdit.Wrap
                    topPadding: 10
                    leftPadding: 10
                    rightPadding: 10
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#3d3d3d"
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 35
                    spacing: 5
                    Layout.topMargin: 5
                    Layout.bottomMargin: 5

                    Button {
                        text: "Clear"
                        Layout.preferredWidth: 60

                        background: Rectangle {
                            color: parent.pressed ? "#505050" : "#3d3d3d"
                            radius: 3
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "#ffffff"
                            font.pixelSize: 11
                            horizontalAlignment: Text.AlignHCenter
                        }

                        onClicked: consoleOutput.text = ""
                    }

                    Button {
                        text: "Copy"
                        Layout.preferredWidth: 60

                        background: Rectangle {
                            color: parent.pressed ? "#505050" : "#3d3d3d"
                            radius: 3
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "#ffffff"
                            font.pixelSize: 11
                            horizontalAlignment: Text.AlignHCenter
                        }

                        onClicked: {
                            consoleOutput.selectAll()
                            consoleOutput.copy()
                        }
                    }

                    Item { Layout.fillWidth: true }
                }
            }
        }
    }
}
