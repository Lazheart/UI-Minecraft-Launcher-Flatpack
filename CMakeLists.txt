cmake_minimum_required(VERSION 3.16)
project(minecraft-launcher-gui VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Buscar Qt5 en el entorno (evitar rutas absolutas)
# Si el usuario no provee `CMAKE_PREFIX_PATH`, usar prefijos sensatos
if(NOT CMAKE_PREFIX_PATH)
    # Usar `/app` (Flatpak runtime) y `/usr` (sistema) por defecto.
    # Los usuarios pueden sobreescribir con -DCMAKE_PREFIX_PATH="..."
    set(CMAKE_PREFIX_PATH "/app" "/usr" CACHE STRING "Paths to search for packages (Qt etc.)" FORCE)
endif()

find_package(Qt5 REQUIRED COMPONENTS
    Core
    Quick
    Qml
    Widgets
    Network
    DBus
)

# Buscar libzip
find_package(PkgConfig REQUIRED)
pkg_check_modules(LIBZIP REQUIRED libzip)

# Incluir directorios
include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CMAKE_CURRENT_SOURCE_DIR}/qml
    ${LIBZIP_INCLUDE_DIRS}
)

# Archivos fuente
set(SOURCES
    src/main.cpp
    src/launcherbackend.cpp
    src/minecraftmanager.cpp
    src/profilemanager.cpp
    src/packagemanager.cpp
    src/workers.cpp
    src/packageinspector.cpp
)

# Archivos de cabecera
set(HEADERS
    include/launcherbackend.h
    include/minecraftmanager.h
    include/profilemanager.h
    include/packagemanager.h
    include/workers.h
    include/packageinspector.h
)

# Archivos QML y recursos
set(QML_RESOURCES
    qml/qml.qrc
)

# Crear el ejecutable
add_executable(${PROJECT_NAME}
    ${SOURCES}
    ${HEADERS}
    ${QML_RESOURCES}
)

# Enlazar con Qt5
target_link_libraries(${PROJECT_NAME}
    Qt5::Core
    Qt5::Quick
    Qt5::Qml
    Qt5::Widgets
    Qt5::Network
    Qt5::DBus
    ${LIBZIP_LIBRARIES}
)

# Opciones de compilación
target_compile_options(${PROJECT_NAME} PRIVATE
    -Wall
    -Wextra
    -Wpedantic
)

# Instalar el ejecutable en /app/bin (Flatpak)
install(TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION bin
)

# Definir rutas para los archivos de instalación
set(DESKTOP_FILE "${CMAKE_SOURCE_DIR}/flatpak/org.lazheart.minecraft-launcher.desktop")
set(METAINFO_FILE "${CMAKE_SOURCE_DIR}/flatpak/org.lazheart.minecraft-launcher.metainfo.xml")
set(ICON_DIR "${CMAKE_SOURCE_DIR}/assets/icons")

# Directorio de assets completo (fondos, media, etc.)
set(ASSETS_DIR "${CMAKE_SOURCE_DIR}/assets")

# Opción para permitir saltarse la instalación de archivos de escritorio
option(INSTALL_DESKTOP_FILES "Instalar archivos de escritorio y metainfo" ON)

# Instalar archivos de escritorio y metainfo (si existen)
if(INSTALL_DESKTOP_FILES)
    if(EXISTS "${DESKTOP_FILE}")
        install(FILES "${DESKTOP_FILE}"
            DESTINATION share/applications
        )
    else()
        message(WARNING "Desktop file no encontrado: ${DESKTOP_FILE}")
    endif()

    if(EXISTS "${METAINFO_FILE}")
        install(FILES "${METAINFO_FILE}"
            DESTINATION share/metainfo
        )
    else()
        message(WARNING "Metainfo file no encontrado: ${METAINFO_FILE}")
    endif()
endif()

# Instalar iconos (si existen)
if(EXISTS "${ICON_DIR}")
    # Instalar icono SVG en la ruta estándar de hicolor para AppStream
    if(EXISTS "${ICON_DIR}/logo.svg")
        install(FILES "${ICON_DIR}/logo.svg"
            DESTINATION share/icons/hicolor/scalable/apps
            RENAME org.lazheart.minecraft-launcher.svg
        )
    endif()
    
    # Instalar otros iconos en share/icons
    install(DIRECTORY "${ICON_DIR}/"
        DESTINATION share/icons
        PATTERN "logo.svg" EXCLUDE
    )
else()
    message(WARNING "Icon directory no encontrado: ${ICON_DIR}")
endif()

# Instalar el resto de assets (backgrounds, media, etc.) evitando la carpeta de icons
if(EXISTS "${ASSETS_DIR}")
    install(DIRECTORY "${ASSETS_DIR}/"
        DESTINATION share/${PROJECT_NAME}/assets
        PATTERN "icons" EXCLUDE
    )
else()
    message(WARNING "Assets directory no encontrado: ${ASSETS_DIR}")
endif()
