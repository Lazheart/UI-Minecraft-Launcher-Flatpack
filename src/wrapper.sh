#!/usr/bin/env bash
set -e

# Directorio del lanzador dentro del sandbox Flatpak
APP_DIR="/app"
BIN_DIR="$APP_DIR/bin"
PYTHON_LAUNCHER="$BIN_DIR/minecraft-launcher-ui"
CLIENT_BIN="$BIN_DIR/mcpelauncher-client"

# Configurar variables de entorno para el sandbox Flatpak
export PATH="$BIN_DIR:$PATH"
export LD_LIBRARY_PATH="$APP_DIR/lib:$LD_LIBRARY_PATH"
export PYTHONPATH="$APP_DIR:$PYTHONPATH"

# Variables para GUI (importante para que la UI se muestre)
export QT_QPA_PLATFORM="wayland;xcb"
export QTWEBENGINE_CHROMIUM_FLAGS="--no-sandbox"
export DISPLAY="${DISPLAY:-:0}"

# Logs para depuración (útil para debuggear problemas)
LOG_FILE="$HOME/.minecraft-launcher-flatpak.log"
echo "[$(date)] Wrapper iniciado - FLATPAK_ID: $FLATPAK_ID" >> "$LOG_FILE"

echo "[Wrapper] Iniciando Minecraft Bedrock Launcher..."
echo "[Wrapper] APP_DIR: $APP_DIR"
echo "[Wrapper] BIN_DIR: $BIN_DIR"

# Verificar si el launcher Python existe
if [ -f "$PYTHON_LAUNCHER" ]; then
    echo "[Wrapper] Ejecutando interfaz Python..."
    echo "[Wrapper] Archivo encontrado: $PYTHON_LAUNCHER"
    
    # Cambiar al directorio de la app para que Python encuentre los módulos
    cd "$APP_DIR"
    
    # Ejecutar el launcher Python con la UI
    exec python3 "$PYTHON_LAUNCHER" "$@"

# Si no existe la UI, usar directamente el cliente nativo
elif [ -x "$CLIENT_BIN" ]; then
    echo "[Wrapper] Ejecutando cliente nativo..."
    exec "$CLIENT_BIN" "$@"

else
    echo "[Error] No se encontró ningún binario ejecutable"
    echo "[Error] PYTHON_LAUNCHER: $PYTHON_LAUNCHER (existe: $([ -f "$PYTHON_LAUNCHER" ] && echo "SÍ" || echo "NO"))"
    echo "[Error] CLIENT_BIN: $CLIENT_BIN (existe: $([ -x "$CLIENT_BIN" ] && echo "SÍ" || echo "NO"))"
    echo "[Error] Contenido de $BIN_DIR:"
    ls -la "$BIN_DIR" 2>/dev/null || echo "No se puede listar $BIN_DIR"
    echo "[Error] Contenido de $APP_DIR:"
    ls -la "$APP_DIR" 2>/dev/null || echo "No se puede listar $APP_DIR"
    exit 1
fi
