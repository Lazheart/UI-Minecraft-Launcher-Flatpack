import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: visualCard
    color: "#2d2d2d"
    radius: 8
    border.color: "#3d3d3d"
    border.width: 1
    Layout.fillWidth: true
    Layout.preferredHeight: 280

    property real scaleValue: 1.0
    property string currentTheme: "DARK"
    
    signal scaleChanged(real scale)
    signal themeChanged(string theme)

    ColumnLayout {
        anchors {
            fill: parent
            margins: 25
        }
        spacing: 25

        Text {
            text: "VISUAL"
            color: "#ffffff"
            font.pixelSize: 16
            font.bold: true
            font.capitalization: Font.AllUppercase
        }

        // Scale Adjustment Section
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 12

            Text {
                text: "Interface Scale"
                color: "#ffffff"
                font.pixelSize: 13
                font.bold: true
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 15
                Layout.topMargin: 5

                Slider {
                    id: scaleSlider
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    from: 0.5
                    to: 3.0
                    value: visualCard.scaleValue
                    stepSize: 0.1

                    background: Rectangle {
                        color: "#1e1e1e"
                        radius: 4
                        height: 8
                        y: parent.height / 2 - height / 2

                        Rectangle {
                            color: "#4CAF50"
                            height: parent.height
                            radius: 4
                            width: scaleSlider.visualPosition * parent.width
                        }
                    }

                    handle: Rectangle {
                        x: scaleSlider.leftPadding + scaleSlider.visualPosition * (scaleSlider.availableWidth - width)
                        y: (scaleSlider.height - height) / 2
                        width: 24
                        height: 24
                        radius: 12
                        color: "#4CAF50"
                        
                        Rectangle {
                            anchors.centerIn: parent
                            width: 12
                            height: 12
                            radius: 6
                            color: "#2d2d2d"
                        }
                    }

                    onValueChanged: {
                        visualCard.scaleValue = value
                        visualCard.scaleChanged(value)
                    }
                }

                Text {
                    text: scaleSlider.value.toFixed(2) + "x"
                    color: "#4CAF50"
                    font.pixelSize: 14
                    font.bold: true
                    Layout.minimumWidth: 50
                    Layout.alignment: Qt.AlignVCenter
                }
            }
        }

        // Theme Selection Section
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 12
            Layout.topMargin: 10

            Text {
                text: "THEME"
                color: "#ffffff"
                font.pixelSize: 13
                font.bold: true
            }

            RowLayout {
                Layout.fillWidth: false
                spacing: 12
                Layout.topMargin: 5

                Button {
                    text: "DARK"
                    Layout.preferredWidth: 130
                    Layout.preferredHeight: 45

                    background: Rectangle {
                        color: visualCard.currentTheme === "DARK" ? "#4CAF50" : "#1e1e1e"
                        radius: 6
                        border.color: visualCard.currentTheme === "DARK" ? "#4CAF50" : "#3d3d3d"
                        border.width: 2
                        
                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                    }

                    contentItem: Text {
                        text: parent.text
                        color: visualCard.currentTheme === "DARK" ? "#1e1e1e" : "#ffffff"
                        font.bold: true
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        visualCard.currentTheme = "DARK"
                        visualCard.themeChanged("DARK")
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onPressed: mouse.accepted = false
                    }
                }

                Button {
                    text: "LIGHT"
                    Layout.preferredWidth: 130
                    Layout.preferredHeight: 45

                    background: Rectangle {
                        color: visualCard.currentTheme === "LIGHT" ? "#4CAF50" : "#1e1e1e"
                        radius: 6
                        border.color: visualCard.currentTheme === "LIGHT" ? "#4CAF50" : "#3d3d3d"
                        border.width: 2
                        
                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                    }

                    contentItem: Text {
                        text: parent.text
                        color: visualCard.currentTheme === "LIGHT" ? "#1e1e1e" : "#ffffff"
                        font.bold: true
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        visualCard.currentTheme = "LIGHT"
                        visualCard.themeChanged("LIGHT")
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onPressed: mouse.accepted = false
                    }
                }

                Item { Layout.fillWidth: true }
            }
        }
    }
}
