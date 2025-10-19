# ui/utils/paths.py
import os

# Detectar si estamos en Flatpak
IS_FLATPAK = os.environ.get("FLATPAK_ID") is not None

# Directorio HOME del usuario dentro o fuera del sandbox
HOME_DIR = os.path.expanduser("~")

# Carpeta de datos del launcher (compatible con Flatpak)
if IS_FLATPAK:
    DATA_DIR = os.environ.get("XDG_DATA_HOME", os.path.join(HOME_DIR, ".var", "app", "org.lazheart.minecraft-launcher", "data"))
else:
    # Para desarrollo local
    DATA_DIR = os.path.join(HOME_DIR, ".local", "share", "minecraft-launcher")

# Rutas específicas del launcher
LAUNCHER_DIR = os.path.join(DATA_DIR, "minecraft-bedrock")
VERSIONS_DIR = os.path.join(LAUNCHER_DIR, "versions")
LOGS_DIR = os.path.join(LAUNCHER_DIR, "logs")
CONFIG_FILE = os.path.join(LAUNCHER_DIR, "config.json")

# Rutas de los ejecutables backend (mcpelauncher)
if IS_FLATPAK:
    MCPELAUNCHER_EXTRACT = "/app/bin/mcpelauncher-extract"
    MCPELAUNCHER_CLIENT = "/app/bin/mcpelauncher-client"
else:
    # Para desarrollo, asumir que están en PATH
    MCPELAUNCHER_EXTRACT = "mcpelauncher-extract"
    MCPELAUNCHER_CLIENT = "mcpelauncher-client"

# Crear carpetas si no existen
for path in [LAUNCHER_DIR, VERSIONS_DIR, LOGS_DIR]:
    os.makedirs(path, exist_ok=True)
