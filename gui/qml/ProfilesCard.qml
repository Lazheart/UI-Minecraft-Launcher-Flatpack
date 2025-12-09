import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: profilesCard
    color: "#2d2d2d"
    radius: 8
    border.color: "#3d3d3d"
    border.width: 1
    Layout.preferredWidth: 300
    Layout.preferredHeight: 200

    ColumnLayout {
        anchors {
            fill: parent
            margins: 20
        }
        spacing: 15

        Text {
            text: "PROFILES"
            color: "#ffffff"
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
                    color: modelData.name === profileManager.currentProfile ? "#4CAF50" : "#1e1e1e"
                    radius: 4
                    border.color: modelData.name === profileManager.currentProfile ? "#4CAF50" : "#555555"
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

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0

                                Text {
                                    text: modelData.name
                                    color: modelData.name === profileManager.currentProfile ? "#1e1e1e" : "#ffffff"
                                    font.pixelSize: 13
                                    font.bold: true
                                }

                                Text {
                                    text: "Version: " + (modelData.version || "latest")
                                    color: modelData.name === profileManager.currentProfile ? "#2d2d2d" : "#b0b0b0"
                                    font.pixelSize: 10
                                }
                            }

                            Button {
                                text: "✕"
                                visible: modelData.name !== "Default"
                                Layout.preferredWidth: 30
                                Layout.preferredHeight: 30

                                background: Rectangle {
                                    color: parent.pressed ? "#d32f2f" : "#f44336"
                                    radius: 3
                                }

                                contentItem: Text {
                                    text: parent.text
                                    color: "#ffffff"
                                    font.pixelSize: 14
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                onClicked: {
                                    if (modelData.name !== "Default") {
                                        profileManager.removeProfile(modelData.name)
                                    }
                                }
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: profileManager.currentProfile = modelData.name
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
                    placeholderText: "New profile"

                    background: Rectangle {
                        color: "#1e1e1e"
                        radius: 3
                        border.color: parent.activeFocus ? "#4CAF50" : "#555555"
                        border.width: 1
                    }

                    color: "#ffffff"
                    font.pixelSize: 11
                }

                Button {
                    text: "+"
                    Layout.preferredWidth: 35

                    background: Rectangle {
                        color: parent.pressed ? "#388E3C" : "#4CAF50"
                        radius: 3
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "#ffffff"
                        font.pixelSize: 14
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                    onClicked: {
                        if (newProfileInput.text.trim() !== "") {
                            profileManager.addProfile(newProfileInput.text.trim())
                            newProfileInput.text = ""
                        }
                    }
                }
            }
        }
    }
}
