#!/usr/bin/env bash
set -e

# === Minecraft Bedrock Launcher - Flatpak Wrapper ===

# 📦 Directorios base dentro del sandbox Flatpak
APP_DIR="/app"
BIN_DIR="$APP_DIR/bin"
PYTHON_LAUNCHER="$BIN_DIR/minecraft-launcher-ui"
CLIENT_BIN="$BIN_DIR/mcpelauncher-client"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.var/app/org.lazheart.minecraft-launcher/data}"

# 🧠 Variables de entorno necesarias
export PATH="$BIN_DIR:$PATH"
export PYTHONPATH="$APP_DIR/share/minecraft-launcher:$APP_DIR:$PYTHONPATH"
export LD_LIBRARY_PATH="$APP_DIR/lib:$LD_LIBRARY_PATH"

# 🧩 Engaño para EGLUT y teclado (evita el popup “Unknown Key”)
export XKB_CONFIG_ROOT="/app/share/X11/xkb"
mkdir -p "$XKB_CONFIG_ROOT/rules"
touch "$XKB_CONFIG_ROOT/rules/evdev"
export EGLUT_NO_WARNINGS=1

# 🧰 Log persistente
LOG_FILE="$HOME/.minecraft-launcher-flatpak.log"
{
    echo "[$(date)] ======================================="
    echo "[Wrapper] Iniciando Minecraft Bedrock Launcher..."
    echo "[Wrapper] APP_DIR: $APP_DIR"
    echo "[Wrapper] BIN_DIR: $BIN_DIR"
    echo "[Wrapper] DATA_DIR: $DATA_DIR"
    echo "[Wrapper] DISPLAY: ${DISPLAY:-no definido}"
    echo "-----------------------------------------------"
} >> "$LOG_FILE"

# 🧩 Ejecutar interfaz Python (UI)
if [ -f "$PYTHON_LAUNCHER" ]; then
    echo "[Wrapper] Ejecutando interfaz Python..."
    cd "$APP_DIR"
    exec python3 "$PYTHON_LAUNCHER" "$@" 2>>"$LOG_FILE"

# 🧩 Fallback: ejecutar cliente nativo
elif [ -x "$CLIENT_BIN" ]; then
    echo "[Wrapper] Ejecutando cliente nativo (silenciado)..."
    exec "$CLIENT_BIN" "$@" 2>>"$LOG_FILE" >/dev/null

# ❌ Diagnóstico
else
    echo "[Error] ❌ No se encontró ningún binario ejecutable"
    echo "[Error] Contenido de $BIN_DIR:"
    ls -la "$BIN_DIR" 2>/dev/null
    echo "[Error] Contenido de $APP_DIR:"
    ls -la "$APP_DIR" 2>/dev/null
    exit 1
fi
