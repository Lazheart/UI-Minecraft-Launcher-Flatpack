import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: settingsPage
    color: "#1e1e1e"
    
    // Define colores y estilos globales
    QtObject {
        id: colorScheme
        property color background: "#1e1e1e"
        property color cardBg: "#2d2d2d"
        property color cardBorder: "#3d3d3d"
        property color textPrimary: "#ffffff"
        property color textSecondary: "#b0b0b0"
        property color accentGreen: "#4CAF50"
        property color accentRed: "#f44336"
        property color inputBg: "#1e1e1e"
    }
    
    ScrollView {
        anchors.fill: parent
        clip: true
        
        ColumnLayout {
            width: parent.width
            spacing: 20
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 30
            }
            
            // Título principal
            Text {
                text: "Settings"
                font.pixelSize: 32
                font.bold: true
                color: colorScheme.textPrimary
                Layout.topMargin: 20
            }
            
            // SECTION: LANGUAGE
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                color: colorScheme.cardBg
                radius: 8
                border.color: colorScheme.cardBorder
                border.width: 1
                
                ColumnLayout {
                    anchors {
                        fill: parent
                        margins: 20
                    }
                    spacing: 15
                    
                    Text {
                        text: "LANGUAGE"
                        color: colorScheme.textPrimary
                        font.pixelSize: 14
                        font.bold: true
                        font.capitalization: Font.AllUppercase
                    }
                    
                    RowLayout {
                        spacing: 15
                        
                        LanguageButton {
                            text: "EN"
                            selected: true
                        }
                        
                        LanguageButton {
                            text: "ES"
                            selected: false
                        }
                        
                        Item { Layout.fillWidth: true }
                    }
                }
            }
            
            // SECTION: PATHS
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 250
                color: colorScheme.cardBg
                radius: 8
                border.color: colorScheme.cardBorder
                border.width: 1
                
                ColumnLayout {
                    anchors {
                        fill: parent
                        margins: 20
                    }
                    spacing: 15
                    
                    Text {
                        text: "PATHS"
                        color: colorScheme.textPrimary
                        font.pixelSize: 14
                        font.bold: true
                        font.capitalization: Font.AllUppercase
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        PathInputRow {
                            label: "Installed Versions"
                            value: "/home/user/.minecraft/versions"
                        }
                        
                        PathInputRow {
                            label: "Installed Backgrounds"
                            value: "/home/user/.minecraft/backgrounds"
                        }
                        
                        PathInputRow {
                            label: "Installed Icons"
                            value: "/home/user/.minecraft/icons"
                        }
                        
                        PathInputRow {
                            label: "Profile Config"
                            value: "/home/user/.minecraft/profiles"
                        }
                    }
                }
            }
            
            // SECTION: VISUAL
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 380
                color: colorScheme.cardBg
                radius: 8
                border.color: colorScheme.cardBorder
                border.width: 1
                
                ColumnLayout {
                    anchors {
                        fill: parent
                        margins: 20
                    }
                    spacing: 20
                    
                    Text {
                        text: "VISUAL"
                        color: colorScheme.textPrimary
                        font.pixelSize: 14
                        font.bold: true
                        font.capitalization: Font.AllUppercase
                    }
                    
                    // Scale Adjustment
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            text: "Adjust Scale"
                            color: colorScheme.textPrimary
                            font.pixelSize: 14
                            font.bold: true
                        }
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 15
                            
                            Slider {
                                id: scaleSlider
                                Layout.fillWidth: true
                                from: 0.5
                                to: 3.0
                                value: 1.0
                                stepSize: 0.1
                                
                                background: Rectangle {
                                    color: colorScheme.cardBg
                                    radius: 4
                                    height: 6
                                    
                                    Rectangle {
                                        color: colorScheme.accentGreen
                                        height: parent.height
                                        radius: 3
                                        width: scaleSlider.visualPosition * parent.width
                                    }
                                }
                                
                                handle: Rectangle {
                                    x: scaleSlider.leftPadding + scaleSlider.visualPosition * (scaleSlider.availableWidth - width)
                                    y: scaleSlider.topPadding + scaleSlider.availableHeight / 2 - height / 2
                                    width: 18
                                    height: 18
                                    radius: 9
                                    color: colorScheme.accentGreen
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.OpenHandCursor
                                    }
                                }
                            }
                            
                            Text {
                                text: scaleSlider.value.toFixed(2) + "x"
                                color: colorScheme.accentGreen
                                font.pixelSize: 12
                                font.bold: true
                                Layout.minimumWidth: 40
                            }
                        }
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            
                            ScaleButton {
                                text: "×0.5"
                                onClicked: scaleSlider.value = 0.5
                            }
                            
                            ScaleButton {
                                text: "×1"
                                onClicked: scaleSlider.value = 1.0
                            }
                            
                            ScaleButton {
                                text: "×1.5"
                                onClicked: scaleSlider.value = 1.5
                            }
                            
                            ScaleButton {
                                text: "×2"
                                onClicked: scaleSlider.value = 2.0
                            }
                            
                            ScaleButton {
                                text: "×3"
                                onClicked: scaleSlider.value = 3.0
                            }
                            
                            Item { Layout.fillWidth: true }
                        }
                    }
                    
                    // Theme Selection
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            text: "THEME"
                            color: colorScheme.textPrimary
                            font.pixelSize: 14
                            font.bold: true
                        }
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            
                            ThemeButton {
                                text: "DARK"
                                selected: true
                            }
                            
                            ThemeButton {
                                text: "LIGHT"
                                selected: false
                            }
                            
                            Item { Layout.fillWidth: true }
                        }
                    }
                }
            }
            
            // SECTION: DEBUG
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 350
                spacing: 15
                
                // Console Output
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height
                    color: colorScheme.cardBg
                    radius: 8
                    border.color: colorScheme.cardBorder
                    border.width: 1
                    
                    ColumnLayout {
                        anchors {
                            fill: parent
                            margins: 20
                        }
                        spacing: 15
                        
                        Text {
                            text: "DEBUG - Console Output"
                            color: colorScheme.textPrimary
                            font.pixelSize: 14
                            font.bold: true
                            font.capitalization: Font.AllUppercase
                        }
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "#0d0d0d"
                            radius: 4
                            border.color: colorScheme.cardBorder
                            
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 0
                                
                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 1
                                    color: colorScheme.cardBorder
                                }
                                
                                TextEdit {
                                    id: consoleOutput
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    readOnly: true
                                    text: "[INFO] Launcher started\n[INFO] Profiles loaded\n[DEBUG] Backend initialized\n[WARNING] Update available"
                                    color: colorScheme.textSecondary
                                    font.pixelSize: 10
                                    font.family: "Courier"
                                    wrapMode: TextEdit.Wrap
                                    topPadding: 10
                                    leftPadding: 10
                                    rightPadding: 10
                                    
                                    Rectangle {
                                        anchors.fill: parent
                                        z: -1
                                        color: "transparent"
                                    }
                                }
                                
                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 1
                                    color: colorScheme.cardBorder
                                }
                                
                                RowLayout {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 30
                                    spacing: 5
                                    
                                    Button {
                                        text: "Clear"
                                        Layout.preferredWidth: 60
                                        
                                        background: Rectangle {
                                            color: parent.pressed ? "#505050" : "#3d3d3d"
                                            radius: 3
                                        }
                                        
                                        contentItem: Text {
                                            text: parent.text
                                            color: colorScheme.textPrimary
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
                                            color: colorScheme.textPrimary
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
                
                // Profiles Panel
                Rectangle {
                    Layout.preferredWidth: 280
                    Layout.preferredHeight: parent.height
                    color: colorScheme.cardBg
                    radius: 8
                    border.color: colorScheme.cardBorder
                    border.width: 1
                    
                    ColumnLayout {
                        anchors {
                            fill: parent
                            margins: 20
                        }
                        spacing: 15
                        
                        Text {
                            text: "PROFILES"
                            color: colorScheme.textPrimary
                            font.pixelSize: 14
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
                                
                                delegate: ProfileCard {
                                    width: parent.width
                                    profileName: modelData.name
                                    version: modelData.version || "latest"
                                    isSelected: modelData.name === profileManager.currentProfile
                                    onSelectProfile: profileManager.currentProfile = modelData.name
                                    onDeleteProfile: {
                                        if (modelData.name !== "Default") {
                                            profileManager.removeProfile(modelData.name)
                                        }
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
                                        color: colorScheme.inputBg
                                        radius: 3
                                        border.color: parent.activeFocus ? colorScheme.accentGreen : colorScheme.cardBorder
                                        border.width: 1
                                    }
                                    
                                    color: colorScheme.textPrimary
                                    font.pixelSize: 11
                                }
                                
                                Button {
                                    text: "+"
                                    Layout.preferredWidth: 35
                                    
                                    background: Rectangle {
                                        color: parent.pressed ? "#388E3C" : colorScheme.accentGreen
                                        radius: 3
                                    }
                                    
                                    contentItem: Text {
                                        text: parent.text
                                        color: "#ffffff"
                                        font.pixelSize: 14
                                        font.bold: true
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
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
            }
            
            // SECTION: Actions (Save, Apply, Reset)
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                Layout.topMargin: 20
                
                Button {
                    text: "SAVE"
                    Layout.preferredWidth: 150
                    Layout.preferredHeight: 45
                    
                    background: Rectangle {
                        color: parent.pressed ? "#388E3C" : colorScheme.accentGreen
                        radius: 4
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: "#ffffff"
                        font.pixelSize: 13
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                    
                    onClicked: {
                        // Save settings logic
                        console.log("Settings saved")
                    }
                }
                
                Button {
                    text: "APPLY"
                    Layout.preferredWidth: 150
                    Layout.preferredHeight: 45
                    
                    background: Rectangle {
                        color: parent.pressed ? "#1976D2" : "#2196F3"
                        radius: 4
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: "#ffffff"
                        font.pixelSize: 13
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                    
                    onClicked: {
                        // Apply settings logic
                        console.log("Settings applied")
                    }
                }
                
                Button {
                    text: "RESET TO DEFAULT"
                    Layout.preferredWidth: 180
                    Layout.preferredHeight: 45
                    
                    background: Rectangle {
                        color: parent.pressed ? "#d32f2f" : colorScheme.accentRed
                        radius: 4
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: "#ffffff"
                        font.pixelSize: 13
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                    
                    onClicked: {
                        // Reset settings logic
                        console.log("Settings reset to default")
                        scaleSlider.value = 1.0
                    }
                }
                
                Item { Layout.fillWidth: true }
            }
            
            Item { Layout.fillHeight: true; Layout.minimumHeight: 20 }
        }
    }
    
    // ===================== CUSTOM COMPONENTS =====================
    
    // Language Button Component
    component LanguageButton: Button {
        property bool selected: false
        
        Layout.preferredWidth: 100
        Layout.preferredHeight: 40
        
        background: Rectangle {
            color: parent.selected ? colorScheme.cardBg : colorScheme.inputBg
            radius: 4
            border.color: parent.selected ? colorScheme.accentGreen : colorScheme.cardBorder
            border.width: 2
        }
        
        contentItem: Text {
            text: parent.text
            color: colorScheme.textPrimary
            font.pixelSize: 12
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        
        onClicked: {
            if (!selected) {
                // Toggle selection
                console.log("Language changed to: " + text)
            }
        }
    }
    
    // Path Input Row Component
    component PathInputRow: RowLayout {
        property string label: ""
        property string value: ""
        
        Layout.fillWidth: true
        spacing: 10
        
        Text {
            text: label
            color: colorScheme.textPrimary
            font.pixelSize: 12
            Layout.preferredWidth: 180
        }
        
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 35
            color: colorScheme.inputBg
            radius: 4
            border.color: colorScheme.cardBorder
            border.width: 1
            
            TextInput {
                anchors {
                    fill: parent
                    leftMargin: 10
                    rightMargin: 10
                }
                verticalAlignment: TextInput.AlignVCenter
                text: value
                color: colorScheme.textSecondary
                font.pixelSize: 11
                readOnly: true
                selectByMouse: true
            }
        }
        
        Button {
            text: "Browse"
            Layout.preferredWidth: 80
            Layout.preferredHeight: 35
            
            background: Rectangle {
                color: parent.pressed ? "#505050" : "#3d3d3d"
                radius: 3
            }
            
            contentItem: Text {
                text: parent.text
                color: colorScheme.textPrimary
                font.pixelSize: 11
                horizontalAlignment: Text.AlignHCenter
            }
            
            onClicked: {
                console.log("Browse directory for: " + label)
            }
        }
    }
    
    // Scale Button Component
    component ScaleButton: Button {
        Layout.preferredWidth: 70
        Layout.preferredHeight: 35
        
        background: Rectangle {
            color: parent.pressed ? "#505050" : "#3d3d3d"
            radius: 3
            border.color: colorScheme.cardBorder
            border.width: 1
        }
        
        contentItem: Text {
            text: parent.text
            color: colorScheme.textPrimary
            font.pixelSize: 11
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
    
    // Theme Button Component
    component ThemeButton: Button {
        property bool selected: false
        
        Layout.preferredWidth: 120
        Layout.preferredHeight: 40
        
        background: Rectangle {
            color: parent.selected ? colorScheme.cardBg : colorScheme.inputBg
            radius: 4
            border.color: parent.selected ? colorScheme.accentGreen : colorScheme.cardBorder
            border.width: 2
        }
        
        contentItem: Text {
            text: parent.text
            color: colorScheme.textPrimary
            font.pixelSize: 12
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        
        onClicked: {
            if (!selected) {
                console.log("Theme changed to: " + text)
            }
        }
    }
    
    // Profile Card Component
    component ProfileCard: Rectangle {
        property string profileName: ""
        property string version: "latest"
        property bool isSelected: false
        signal selectProfile()
        signal deleteProfile()
        
        Layout.fillWidth: true
        Layout.preferredHeight: 70
        color: isSelected ? colorScheme.accentGreen : colorScheme.inputBg
        radius: 4
        border.color: isSelected ? colorScheme.accentGreen : colorScheme.cardBorder
        border.width: 1
        
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
                        text: profileName
                        color: isSelected ? "#1e1e1e" : colorScheme.textPrimary
                        font.pixelSize: 13
                        font.bold: true
                    }
                    
                    Text {
                        text: "Version: " + version
                        color: isSelected ? "#2d2d2d" : colorScheme.textSecondary
                        font.pixelSize: 10
                    }
                }
                
                Button {
                    text: "✕"
                    visible: profileName !== "Default"
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    
                    background: Rectangle {
                        color: parent.pressed ? "#d32f2f" : colorScheme.accentRed
                        radius: 3
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: "#ffffff"
                        font.pixelSize: 14
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                    
                    onClicked: deleteProfile()
                }
            }
        }
        
        MouseArea {
            anchors.fill: parent
            onClicked: selectProfile()
        }
    }
}
