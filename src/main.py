#!/usr/bin/env python3
import os
import sys
from pathlib import Path
from PyQt6.QtCore import Qt
from PyQt6.QtGui import QPixmap, QIcon
from PyQt6.QtWidgets import (
    QApplication, QWidget, QLabel, QPushButton, QVBoxLayout,
    QMessageBox
)

APP_ID = "org.lazheart.minecraft-launcher"
APP_NAME = "Minecraft Bedrock Launcher"
ICON_PATH = os.path.join(os.path.dirname(__file__), "..", "assets", "logo.png")


class LauncherUI(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle(APP_NAME)
        self.setWindowIcon(QIcon(ICON_PATH))
        self.setFixedSize(400, 500)

        layout = QVBoxLayout()
        layout.setAlignment(Qt.AlignmentFlag.AlignCenter)

        # Logo
        logo = QLabel()
        pixmap = QPixmap(ICON_PATH)
        logo.setPixmap(pixmap.scaled(200, 200, Qt.AspectRatioMode.KeepAspectRatio, Qt.TransformationMode.SmoothTransformation))
        logo.setAlignment(Qt.AlignmentFlag.AlignCenter)
        layout.addWidget(logo)

        # Botones
        self.launch_button = QPushButton("Iniciar Minecraft")
        self.launch_button.clicked.connect(self.launch_game)

        self.shortcut_button = QPushButton("Crear acceso directo")
        self.shortcut_button.clicked.connect(self.create_shortcut)

        self.exit_button = QPushButton("Salir")
        self.exit_button.clicked.connect(self.close)

        for btn in (self.launch_button, self.shortcut_button, self.exit_button):
            btn.setFixedHeight(40)
            layout.addWidget(btn)

        self.setLayout(layout)

    def launch_game(self):
        QMessageBox.information(self, "Minecraft", "Ejecutando Minecraft Bedrock (modo Flatpak)...")
        # Aquí podrías ejecutar el binario real dentro del sandbox:
        # os.system("flatpak-spawn --host minecraft-launcher")

    def create_shortcut(self):
        """Crea un acceso directo .desktop en ~/.local/share/applications"""
        shortcut_dir = Path.home() / ".local/share/applications"
        shortcut_dir.mkdir(parents=True, exist_ok=True)
        shortcut_path = shortcut_dir / f"{APP_ID}.desktop"

        desktop_entry = f"""[Desktop Entry]
Version=1.0
Type=Application
Name={APP_NAME}
Comment=Lanzador de Minecraft Bedrock Edition
Exec=flatpak run {APP_ID}
Icon={APP_ID}
Terminal=false
Categories=Game;
StartupNotify=true
"""

        with open(shortcut_path, "w") as f:
            f.write(desktop_entry)
        os.chmod(shortcut_path, 0o755)

        QMessageBox.information(self, "Acceso directo", f"Acceso directo creado:\n{shortcut_path}")


def main():
    app = QApplication(sys.argv)
    window = LauncherUI()
    window.show()
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
