cmake_minimum_required(VERSION 3.16)
project(minecraft-launcher-gui VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Buscar Qt5 en el entorno Flatpak
set(CMAKE_PREFIX_PATH "/usr/lib/sdk/qt5/lib/cmake:/usr/lib/sdk/qt5/lib/cmake/Qt5")

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
    src/zipvalidator.cpp
    src/packageinspector.cpp
)

# Archivos de cabecera
set(HEADERS
    include/launcherbackend.h
    include/minecraftmanager.h
    include/profilemanager.h
    include/packagemanager.h
    include/workers.h
    include/zipvalidator.h
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

# Instalar archivos adicionales
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/../src/org.lazheart.minecraft-launcher.desktop
    DESTINATION share/applications
)

install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/../src/org.lazheart.minecraft-launcher.metainfo.xml
    DESTINATION share/metainfo
)
