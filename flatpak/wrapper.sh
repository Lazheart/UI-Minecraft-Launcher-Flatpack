#!/usr/bin/env bash
set -e

# Directorio del lanzador dentro del sandbox Flatpak
APP_DIR="/app"
BIN_DIR="$APP_DIR/bin"
QT_GUI_LAUNCHER="$BIN_DIR/minecraft-launcher-gui"
CLIENT_BIN="$BIN_DIR/mcpelauncher-client"

# Configurar variables de entorno para el sandbox Flatpak
export PATH="$BIN_DIR:$PATH"
export LD_LIBRARY_PATH="$APP_DIR/lib:$LD_LIBRARY_PATH"
export PYTHONPATH="$APP_DIR:$PYTHONPATH"

# Variables para GUI (importante para que la UI se muestre)
export QT_QPA_PLATFORM="wayland;xcb"
export QTWEBENGINE_CHROMIUM_FLAGS="--no-sandbox"
export DISPLAY="${DISPLAY:-:0}"

# 🧩 Añadido: Variables de teclado y EGLUT para evitar "UNKNOWN KEY"
export XKB_DEFAULT_LAYOUT=${XKB_DEFAULT_LAYOUT:-us}
export XKB_DEFAULT_MODEL=${XKB_DEFAULT_MODEL:-pc105}
export XKB_DEFAULT_OPTIONS=${XKB_DEFAULT_OPTIONS:-grp:alt_shift_toggle}
export EGL_PLATFORM=${EGL_PLATFORM:-x11}  # fuerza EGLUT a usar X11

# 🧩 Añadido: fallback por si no hay variables X11 / Wayland
export XAUTHORITY="${XAUTHORITY:-${HOME}/.Xauthority}"
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"

# Logs para depuración (útil para debuggear problemas)
LOG_FILE="$HOME/.minecraft-launcher-flatpak.log"
echo "[$(date)] Wrapper iniciado - FLATPAK_ID: $FLATPAK_ID" >> "$LOG_FILE"

echo "[Wrapper] Iniciando Minecraft Bedrock Launcher..."
echo "[Wrapper] APP_DIR: $APP_DIR"
echo "[Wrapper] BIN_DIR: $BIN_DIR"
echo "[Wrapper] Teclado configurado: layout=$XKB_DEFAULT_LAYOUT, model=$XKB_DEFAULT_MODEL"

# Verificar si existe la GUI Qt Quick
if [ -x "$QT_GUI_LAUNCHER" ]; then
    echo "[Wrapper] Ejecutando interfaz Qt Quick/QML..."
    echo "[Wrapper] Archivo encontrado: $QT_GUI_LAUNCHER"
    
    # Ejecutar el launcher Qt Quick con la UI
    exec "$QT_GUI_LAUNCHER" "$@"

# Si no existe la UI Qt, usar directamente el cliente nativo
elif [ -x "$CLIENT_BIN" ]; then
    echo "[Wrapper] Ejecutando cliente nativo sin GUI..."
    exec "$CLIENT_BIN" "$@"

else
    echo "[Error] No se encontró ningún binario ejecutable"
    echo "[Error] QT_GUI_LAUNCHER: $QT_GUI_LAUNCHER (existe: $([ -x "$QT_GUI_LAUNCHER" ] && echo "SÍ" || echo "NO"))"
    echo "[Error] CLIENT_BIN: $CLIENT_BIN (existe: $([ -x "$CLIENT_BIN" ] && echo "SÍ" || echo "NO"))"
    echo "[Error] Contenido de $BIN_DIR:"
    ls -la "$BIN_DIR" 2>/dev/null || echo "No se puede listar $BIN_DIR"
    echo "[Error] Contenido de $APP_DIR:"
    ls -la "$APP_DIR" 2>/dev/null || echo "No se puede listar $APP_DIR"
    exit 1
fi
