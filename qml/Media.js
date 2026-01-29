// Centralized assets references
var LogoImage = "qrc:/assets/media/logo.svg"
var BedrockLogo = "qrc:/assets/media/bedrockLogo.png"
var TrashIcon = "qrc:/assets/icons/trash.ico"
// Default icon used next to installed versions (located in `assets/media/directAccess.png`)
var DefaultVersionIcon = "qrc:/assets/media/directAccess.png"
// Fallback icon in case `directAccess.png` is not available
var DefaultVersionIconFallback = BedrockLogo
var DropperIcon = "qrc:/assets/media/dropper.jpg"
var LibreriaIcon = "qrc:/assets/media/libreria.jpg"

// Background images for versions
var VersionBackgrounds = {
    "1.14": "qrc:/assets/backgrounds/Minecraft_1.14.jpg",
    "1.14.2": "qrc:/assets/backgrounds/Minecraf_1.14.2.jpg",
    "1.14.3": "qrc:/assets/backgrounds/Minecraft_1.14.3.jpg",
    "1.16.0": "qrc:/assets/backgrounds/Minecraft_village.jpg",
    "1.21.0": "qrc:/assets/backgrounds/Minecraft_bee.jpg",
    "caveandcliffs": "qrc:/assets/backgrounds/Minecraf_caveandcliffs.jpg"
}

var StandardBackgrounds = [
    { name: "Default", path: "qrc:/assets/backgrounds/Minecraf_1.14.2.jpg" },
    { name: "Cave and Clifs", path: "qrc:/assets/backgrounds/Minecraf_caveandcliffs.jpg" },
    { name: "Clasic Windows", path: "qrc:/assets/backgrounds/Minecraft_1.14.3.jpg" },
    { name: "Clasic Xbox", path: "qrc:/assets/backgrounds/Minecraft_1.14.jpg" },
    { name: "Buzzy Bees", path: "qrc:/assets/backgrounds/Minecraft_bee.jpg" },
    { name: "The Original", path: "qrc:/assets/backgrounds/Minecraft_village.jpg" }
]

// Default background to use when no specific version background is selected.
var DefaultVersionBackground = VersionBackgrounds["1.14.2"] 
