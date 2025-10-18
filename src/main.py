#!/usr/bin/env python3
import os
import sys
import json
import subprocess

# Detectar si estamos dentro de Flatpak
IS_FLATPAK = os.environ.get("FLATPAK_ID") is not None

# Ajustar sys.path para importar el módulo de UI desde /app o desde desarrollo
BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
if BASE_DIR not in sys.path:
    sys.path.insert(0, BASE_DIR)

from ui.app import LauncherApp
from ui.utils import paths


def ensure_environment():
    """
    Asegura que los directorios y configuraciones básicas existan.
    """
    print("[Launcher] Verificando entorno de datos...")
    os.makedirs(paths.LAUNCHER_DIR, exist_ok=True)
    os.makedirs(paths.VERSIONS_DIR, exist_ok=True)
    os.makedirs(paths.LOGS_DIR, exist_ok=True)

    if not os.path.exists(paths.CONFIG_FILE):
        print("[Launcher] Creando archivo de configuración inicial.")
        default_config = {
            "theme": "system",
            "language": "es",
            "last_version": None
        }
        with open(paths.CONFIG_FILE, "w") as f:
            json.dump(default_config, f, indent=4)


def check_backend():
    """
    Comprueba si el ejecutable backend existe y es ejecutable.
    Si no, muestra una advertencia en consola.
    """
    backend = paths.BACKEND_EXECUTABLE
    if not os.path.exists(backend):
        print(f"[ADVERTENCIA] No se encontró el backend: {backend}")
        print("El juego no podrá lanzarse hasta que se instale correctamente.")
        return False
    if not os.access(backend, os.X_OK):
        print(f"[ADVERTENCIA] El backend existe pero no es ejecutable: {backend}")
        return False
    print("[OK] Backend detectado:", backend)
    return True


def main():
    print("=== Minecraft Bedrock Launcher ===")
    ensure_environment()
    check_backend()

    # Inicializa la aplicación de la UI
    app = LauncherApp()
    app.mainloop()


if __name__ == "__main__":
    main()
