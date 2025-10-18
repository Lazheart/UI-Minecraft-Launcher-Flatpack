# ui/utils/paths.py
import os

# Directorio HOME del usuario dentro o fuera del sandbox
HOME_DIR = os.path.expanduser("~")

# Carpeta de datos del launcher (compatible con Flatpak)
DATA_DIR = os.environ.get("XDG_DATA_HOME", os.path.join(HOME_DIR, ".var", "app", "org.lazheart.minecraft-launcher", "data"))

# Rutas específicas del launcher
LAUNCHER_DIR = os.path.join(DATA_DIR, "minecraft-bedrock")
VERSIONS_DIR = os.path.join(LAUNCHER_DIR, "versions")
LOGS_DIR = os.path.join(LAUNCHER_DIR, "logs")
CONFIG_FILE = os.path.join(LAUNCHER_DIR, "config.json")

# Ruta del ejecutable backend (extrae o lanza el juego)
BACKEND_EXECUTABLE = "/app/bin/minecraft-backend"  # ajusta si el binario tiene otro nombre

# Crear carpetas si no existen
for path in [LAUNCHER_DIR, VERSIONS_DIR, LOGS_DIR]:
    os.makedirs(path, exist_ok=True)
