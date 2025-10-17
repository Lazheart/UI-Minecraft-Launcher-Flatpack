#!/usr/bin/env bash
set -e

# Directorio del lanzador dentro del sandbox
APP_DIR="/app"
BIN_DIR="$APP_DIR/bin"
ASSETS_DIR="$APP_DIR/share/icons/hicolor/256x256/apps"
PYTHON_LAUNCHER="$BIN_DIR/minecraft-launcher-ui"
CLIENT_BIN="$BIN_DIR/mcpelauncher-client"

# Asegurar que variables esenciales estén definidas
export PATH="$BIN_DIR:$PATH"
export LD_LIBRARY_PATH="$APP_DIR/lib:$LD_LIBRARY_PATH"
export QT_QPA_PLATFORM="wayland;xcb"
export QTWEBENGINE_CHROMIUM_FLAGS="--no-sandbox"

# Logs (útiles para depuración dentro del sandbox)
LOG_FILE="$HOME/.minecraft-launcher-flatpak.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "[Wrapper] Iniciando org.lazheart.minecraft-launcher..."

# Detectar si el launcher Python existe (modo UI)
if [ -x "$PYTHON_LAUNCHER" ]; then
    echo "[Wrapper] Ejecutando interfaz Python..."
    exec python3 "$PYTHON_LAUNCHER" "$@"

# Si no existe la UI, usar directamente el cliente nativo
elif [ -x "$CLIENT_BIN" ]; then
    echo "[Wrapper] Ejecutando cliente nativo..."
    exec "$CLIENT_BIN" "$@"

else
    echo "[Error] No se encontró ningún binario ejecutable en $BIN_DIR"
    exit 1
fi
