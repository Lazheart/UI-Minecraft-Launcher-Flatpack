# ui/utils/shortcuts.py
import os
from ui.utils.paths import LAUNCHER_DIR

def create_shortcut(version_name: str, exec_path: str, icon_path: str = None): # type: ignore
#  Se puede fixear usando Optional[str] pero verificar compatibilidad con flatpak
    """
    Crea un acceso directo .desktop para una versión específica del juego.
    """
    desktop_dir = os.path.join(LAUNCHER_DIR, "shortcuts")
    os.makedirs(desktop_dir, exist_ok=True)

    if icon_path is None:
        icon_path = "/app/share/icons/hicolor/256x256/apps/org.lazheart.minecraft-launcher.png"

    desktop_file_path = os.path.join(desktop_dir, f"minecraft-{version_name}.desktop")

    content = f"""[Desktop Entry]
Version=1.0
Type=Application
Name=Minecraft Bedrock ({version_name})
Comment=Versión personalizada de Minecraft Bedrock
Exec={exec_path}
Icon={icon_path}
Terminal=false
Categories=Game;
StartupNotify=true
"""

    with open(desktop_file_path, "w") as f:
        f.write(content)

    os.chmod(desktop_file_path, 0o755)
    return desktop_file_path
