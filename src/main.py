#!/usr/bin/env python3
import os
import sys
import json
import subprocess

# Detectar si estamos dentro de Flatpak
IS_FLATPAK = os.environ.get("FLATPAK_ID") is not None

# Ajustar sys.path para importar el módulo de UI desde /app o desde desarrollo
if IS_FLATPAK:
    # En Flatpak, el código está en /app
    BASE_DIR = "/app"
    sys.path.insert(0, BASE_DIR)
else:
    # En desarrollo, usar el directorio padre
    BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    if BASE_DIR not in sys.path:
        sys.path.insert(0, BASE_DIR)

# Solo mostrar debug en desarrollo
if not IS_FLATPAK:
    print(f"[Launcher] BASE_DIR: {BASE_DIR}")
    print(f"[Launcher] IS_FLATPAK: {IS_FLATPAK}")
    print(f"[Launcher] sys.path: {sys.path[:3]}...")  # Solo mostrar los primeros 3

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
    Comprueba si los ejecutables backend existen y son ejecutables.
    Si no, muestra una advertencia en consola.
    """
    from ui.utils.paths import MCPELAUNCHER_EXTRACT, MCPELAUNCHER_CLIENT
    
    extract_ok = os.path.exists(MCPELAUNCHER_EXTRACT) and os.access(MCPELAUNCHER_EXTRACT, os.X_OK)
    client_ok = os.path.exists(MCPELAUNCHER_CLIENT) and os.access(MCPELAUNCHER_CLIENT, os.X_OK)
    
    if not extract_ok:
        print(f"[ADVERTENCIA] No se encontró mcpelauncher-extract: {MCPELAUNCHER_EXTRACT}")
    if not client_ok:
        print(f"[ADVERTENCIA] No se encontró mcpelauncher-client: {MCPELAUNCHER_CLIENT}")
    
    if not extract_ok or not client_ok:
        print("El juego no podrá lanzarse hasta que se instalen correctamente los backends.")
        return False
    
    print("[OK] Backends detectados:")
    print(f"  - mcpelauncher-extract: {MCPELAUNCHER_EXTRACT}")
    print(f"  - mcpelauncher-client: {MCPELAUNCHER_CLIENT}")
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
