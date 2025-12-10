# Configuración Correcta para Flatpak - Minecraft Launcher

## Archivo de Manifiesto (módulo en flatpak-builder.json)

```yaml
  # GUI del launcher
  - name: mcpelauncher-gui
    buildsystem: cmake
    builddir: true
    make-args: [ -j4 ]
    build-options:
      env:
        PATH: /usr/lib/sdk/qt5/bin:/app/bin:/usr/bin
        CMAKE_PREFIX_PATH: /usr/lib/sdk/qt5/lib/cmake
      prepend-pkg-config-path: /usr/lib/sdk/qt5/lib/pkgconfig
    sources:
      - type: git
        url: https://github.com/Lazheart/UI-Minecraft-Launcher-Flatpack.git
        branch: c++
    build-commands:
      # Crear directorio de instalación
      - mkdir -p /app/bin /app/share/applications /app/share/metainfo /app/share/icons/hicolor/256x256/apps
      
      # Compilar con CMake
      - cmake -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/app .
      - cmake --build build -j4
      
      # Instalar binario
      - install -Dm755 build/minecraft-launcher-gui /app/bin/minecraft-launcher
      
      # Instalar archivos de escritorio
      - install -Dm644 flatpak/org.lazheart.minecraft-launcher.desktop /app/share/applications/org.lazheart.minecraft-launcher.desktop
      
      # Instalar metainfo (para AppCenter/Gnome Software)
      - install -Dm644 flatpak/org.lazheart.minecraft-launcher.metainfo.xml /app/share/metainfo/org.lazheart.minecraft-launcher.metainfo.xml
      
      # Instalar icono (SVG se escala automáticamente)
      - install -Dm644 assets/icons/logo.svg /app/share/icons/hicolor/scalable/apps/org.lazheart.minecraft-launcher.svg
```

---

## Actualización del Archivo .desktop

Tu archivo `.desktop` actual tiene `Exec=wrapper.sh`, pero en Flatpak debe ser:

```ini
[Desktop Entry]
Version=1.0
Type=Application
Name=Minecraft Bedrock Launcher
Comment=Lanzador no oficial de Minecraft Bedrock Edition para Linux
Exec=minecraft-launcher
Icon=org.lazheart.minecraft-launcher
Terminal=false
Categories=Game;Utility;
StartupNotify=true
Keywords=Minecraft;Bedrock;Launcher;Linux;
```

**Cambios:**
- `Exec=wrapper.sh` → `Exec=minecraft-launcher` (Flatpak maneja esto automáticamente)
- El icono ya debe estar en el path correcto

---

## Verificación de Estructura

Tu estructura debe tener:
```
UI-Minecraft-Launcher-Flatpack/
├── CMakeLists.txt              ✅ (ya existe)
├── src/                         ✅ (ya existe)
├── include/                     ✅ (ya existe)
├── qml/                         ✅ (ya existe)
├── flatpak/
│   ├── org.lazheart.minecraft-launcher.desktop        ✅ (ya existe)
│   ├── org.lazheart.minecraft-launcher.metainfo.xml   ✅ (ya existe)
│   └── wrapper.sh               (Opcional en Flatpak)
└── assets/
    └── icons/
        └── launcher.png         ⚠️ (necesitas renombrar o crear)
```

---

## Paso a Paso para Actualizar tu Flatpak

### 1. Actualiza el archivo .desktop
Reemplaza `Exec=wrapper.sh` por `Exec=minecraft-launcher`

### 2. Icono (logo.svg)
El icono SVG se encuentra en `assets/icons/logo.svg` y se escala automáticamente en todas las resoluciones.

✅ **Ya está configurado correctamente**

### 3. Actualiza tu manifiesto flatpak-builder.json

Reemplaza la sección del módulo con la configuración anterior.

### 4. Compila tu Flatpak

```bash
flatpak-builder --user --install --force-clean _build org.lazheart.minecraft-launcher.json
```

---

## Variables de Entorno Importantes

Si tu aplicación necesita variables especiales en Flatpak, agrega esto en `build-options`:

```yaml
build-options:
  env:
    PATH: /usr/lib/sdk/qt5/bin:/app/bin:/usr/bin
    CMAKE_PREFIX_PATH: /usr/lib/sdk/qt5/lib/cmake
    CFLAGS: -I/usr/lib/sdk/qt5/include
    LDFLAGS: -L/usr/lib/sdk/qt5/lib
  prepend-pkg-config-path: /usr/lib/sdk/qt5/lib/pkgconfig
```

---

## Archivo Manifesto Flatpak Completo (Ejemplo)

Si necesitas ver cómo se integra en el archivo principal, aquí está la estructura:

```json
{
  "app-id": "org.lazheart.minecraft-launcher",
  "runtime": "org.freedesktop.Platform",
  "runtime-version": "23.08",
  "sdk": "org.freedesktop.Sdk",
  "sdk-extensions": [
    "org.freedesktop.Sdk.Extension.llvm15",
    "org.freedesktop.Sdk.Extension.toolchain-x86_64"
  ],
  "command": "minecraft-launcher",
  "finish-args": [
    "--share=network",
    "--share=ipc",
    "--socket=x11",
    "--socket=wayland",
    "--device=dri",
    "--filesystem=home"
  ],
  "modules": [
    {
      "name": "libzip",
      "buildsystem": "cmake",
      "sources": [
        {
          "type": "archive",
          "url": "https://libzip.org/download/libzip-1.9.2.tar.gz",
          "sha256": "c0ab5487771d76c7892dd0d064755b9037bab2302524e93d9ce10db1e9e4f1f6"
        }
      ]
    },
    {
      "name": "mcpelauncher-gui",
      "buildsystem": "cmake",
      "builddir": true,
      "make-args": [ "-j4" ],
      "build-options": {
        "env": {
          "PATH": "/usr/lib/sdk/qt5/bin:/app/bin:/usr/bin",
          "CMAKE_PREFIX_PATH": "/usr/lib/sdk/qt5/lib/cmake"
        },
        "prepend-pkg-config-path": "/usr/lib/sdk/qt5/lib/pkgconfig"
      },
      "sources": [
        {
          "type": "git",
          "url": "https://github.com/Lazheart/UI-Minecraft-Launcher-Flatpack.git",
          "branch": "c++"
        }
      ],
      "build-commands": [
        "mkdir -p /app/bin /app/share/applications /app/share/metainfo /app/share/icons/hicolor/256x256/apps",
        "cmake -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/app .",
        "cmake --build build -j4",
        "install -Dm755 build/minecraft-launcher-gui /app/bin/minecraft-launcher",
        "install -Dm644 flatpak/org.lazheart.minecraft-launcher.desktop /app/share/applications/org.lazheart.minecraft-launcher.desktop",
        "install -Dm644 flatpak/org.lazheart.minecraft-launcher.metainfo.xml /app/share/metainfo/org.lazheart.minecraft-launcher.metainfo.xml",
        "install -Dm644 assets/icons/logo.svg /app/share/icons/hicolor/scalable/apps/org.lazheart.minecraft-launcher.svg"
      ]
    }
  ]
}
```

---

## Resumen de Cambios Necesarios

| Elemento | Estado | Acción |
|----------|--------|--------|
| CMakeLists.txt | ✅ OK | No requiere cambios |
| src/ | ✅ OK | No requiere cambios |
| include/ | ✅ OK | No requiere cambios |
| qml/ | ✅ OK | No requiere cambios |
| Elemento | Estado | Acción |
|----------|--------|--------|
| CMakeLists.txt | ✅ OK | No requiere cambios |
| src/ | ✅ OK | No requiere cambios |
| include/ | ✅ OK | No requiere cambios |
| qml/ | ✅ OK | No requiere cambios |
| .desktop | ✅ OK | Cambiar `Exec` (ver abajo) |
| metainfo.xml | ✅ OK | No requiere cambios |
| assets/icons/logo.svg | ✅ OK | Ya existe y está configurado |
| flatpak/wrapper.sh | 🗑️ ELIMINADO | No necesario en Flatpak |
| build-commands | ✅ OK | Usar configuración con logo.svg |
| build-options | ✅ OK | Agregar variables de entorno |

```bash
cd /path/to/UI-Minecraft-Launcher-Flatpack
flatpak-builder --user --install --force-clean _build org.lazheart.minecraft-launcher.json
flatpak run org.lazheart.minecraft-launcher
```

---
## Notas Importantes

1. **La ruta del binario**: El CMakeLists.txt genera `minecraft-launcher-gui`, pero en Flatpak lo renombramos a `minecraft-launcher`

2. **Icono SVG**: Se usa `assets/icons/logo.svg` instalado en `scalable/apps/` para que se escale automáticamente en todas las resoluciones. SVG es el formato ideal para Flatpak.

3. **wrapper.sh eliminado**: No es necesario en Flatpak, ya que Flatpak maneja automáticamente el entorno.

4. **Permisos de red**: Si tu aplicación necesita descargar archivos, los permisos ya están configurados (`--share=network`)

5. **Rutas en Flatpak**: 
   - Datos de usuario: `~/.var/app/org.lazheart.minecraft-launcher/`
   - Config: `~/.var/app/org.lazheart.minecraft-launcher/.config/`
   - Data: `~/.var/app/org.lazheart.minecraft-launcher/.local/share/`
   - Data: `~/.var/app/org.lazheart.minecraft-launcher/.local/share/`
