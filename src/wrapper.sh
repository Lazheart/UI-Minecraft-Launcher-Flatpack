#!/usr/bin/env bash
set -e

# === Minecraft Bedrock Launcher - Flatpak Wrapper ===

# 📦 Directorios base dentro del sandbox Flatpak
APP_DIR="/app"
BIN_DIR="$APP_DIR/bin"
PYTHON_LAUNCHER="$BIN_DIR/minecraft-launcher-ui"
CLIENT_BIN="$BIN_DIR/mcpelauncher-client"

# 📁 Directorio de datos del usuario (XDG)
DATA_DIR="${XDG_DATA_HOME:-$HOME/.var/app/org.lazheart.minecraft-launcher/data}"

# 🧠 Variables de entorno mínimas necesarias
export PATH="$BIN_DIR:$PATH"
export PYTHONPATH="$APP_DIR/share/minecraft-launcher:$APP_DIR:$PYTHONPATH"

# 🧰 Archivo de log para depuración persistente
LOG_FILE="$HOME/.minecraft-launcher-flatpak.log"
{
    echo "[$(date)] ======================================="
    echo "[Wrapper] Iniciando Minecraft Bedrock Launcher..."
    echo "[Wrapper] APP_DIR: $APP_DIR"
    echo "[Wrapper] BIN_DIR: $BIN_DIR"
    echo "[Wrapper] DATA_DIR: $DATA_DIR"
    echo "[Wrapper] FLATPAK_ID: ${FLATPAK_ID:-no definido}"
    echo "[Wrapper] DISPLAY: ${DISPLAY:-no definido}"
    echo "-----------------------------------------------"
} >> "$LOG_FILE"

# 🧩 Verificar existencia del lanzador Python (UI)
if [ -f "$PYTHON_LAUNCHER" ]; then
    echo "[Wrapper] Ejecutando interfaz Python..."
    echo "[Wrapper] Archivo encontrado: $PYTHON_LAUNCHER"
    echo "[Wrapper] Cambiando a directorio de aplicación: $APP_DIR"
    cd "$APP_DIR"

    # 🧩 Añadir librerías internas solo para la UI (Tkinter necesita Tcl/Tk)
    export LD_LIBRARY_PATH="$APP_DIR/lib:$LD_LIBRARY_PATH"

    {
        echo "[Wrapper] LD_LIBRARY_PATH temporal: $LD_LIBRARY_PATH"
        echo "[Wrapper] Iniciando interfaz gráfica con Python..."
    } >> "$LOG_FILE"

    # 🪶 Ejecutar la UI del launcher
    exec python3 "$PYTHON_LAUNCHER" "$@"

# 🧩 Si no hay UI, intentar usar el cliente nativo
elif [ -x "$CLIENT_BIN" ]; then
    echo "[Wrapper] Ejecutando cliente nativo..."
    {
        echo "[Wrapper] Ejecutando cliente nativo..."
        echo "[Wrapper] LD_LIBRARY_PATH actual: ${LD_LIBRARY_PATH:-no definido}"
    } >> "$LOG_FILE"

    exec "$CLIENT_BIN" "$@"

# ❌ Si no hay ningún ejecutable disponible, mostrar diagnóstico completo
else
    echo "[Error] ❌ No se encontró ningún binario ejecutable"
    echo "[Error] PYTHON_LAUNCHER: $PYTHON_LAUNCHER (existe: $([ -f "$PYTHON_LAUNCHER" ] && echo 'SÍ' || echo 'NO'))"
    echo "[Error] CLIENT_BIN: $CLIENT_BIN (existe: $([ -x "$CLIENT_BIN" ] && echo 'SÍ' || echo 'NO'))"

    echo "[Error] Contenido de $BIN_DIR:"
    ls -la "$BIN_DIR" 2>/dev/null || echo "No se puede listar $BIN_DIR"

    echo "[Error] Contenido de $APP_DIR:"
    ls -la "$APP_DIR" 2>/dev/null || echo "No se puede listar $APP_DIR"

    {
        echo "[Error] ❌ No se encontró ningún binario ejecutable"
        echo "[Error] PYTHON_LAUNCHER: $PYTHON_LAUNCHER"
        echo "[Error] CLIENT_BIN: $CLIENT_BIN"
        echo "[Error] Contenido de $BIN_DIR:"
        ls -la "$BIN_DIR" 2>/dev/null
        echo "[Error] Contenido de $APP_DIR:"
        ls -la "$APP_DIR" 2>/dev/null
    } >> "$LOG_FILE"

    exit 1
fi
