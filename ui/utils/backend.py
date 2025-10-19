import os
import subprocess
import shutil
from tkinter import messagebox
from .paths import VERSIONS_DIR, MCPELAUNCHER_EXTRACT, MCPELAUNCHER_CLIENT, IS_FLATPAK

# Directorios para perfiles y shortcuts
PROFILES_DIR = os.path.join(os.path.dirname(VERSIONS_DIR), "profiles")
SHORTCUTS_DIR = os.path.join(os.path.dirname(VERSIONS_DIR), "shortcuts")

os.makedirs(VERSIONS_DIR, exist_ok=True)
os.makedirs(PROFILES_DIR, exist_ok=True)
os.makedirs(SHORTCUTS_DIR, exist_ok=True)


def get_versions():
    """Devuelve lista de versiones disponibles."""
    versions = []
    if os.path.exists(VERSIONS_DIR):
        for v in os.listdir(VERSIONS_DIR):
            path = os.path.join(VERSIONS_DIR, v)
            if os.path.isdir(path):
                versions.append(path)
    return versions


def extract_apk(apk_path, name):
    """Extrae el APK en una carpeta de versión."""
    if not apk_path or not name:
        messagebox.showwarning("Error", "Faltan campos requeridos.")
        return False

    target = os.path.join(VERSIONS_DIR, name)
    os.makedirs(target, exist_ok=True)
    
    # Usar la ruta correcta del ejecutable
    result = subprocess.run([MCPELAUNCHER_EXTRACT, apk_path, target])

    if result.returncode == 0:
        messagebox.showinfo("Éxito", f"Versión '{name}' instalada.")
        return True
    else:
        messagebox.showerror("Error", "No se pudo instalar el APK.")
        return False


def delete_version(version_path, delete_profile=True):
    """Elimina una versión y su perfil asociado."""
    if not version_path:
        return
    shutil.rmtree(version_path, ignore_errors=True)
    if delete_profile:
        profile_path = version_path.replace("/versions/", "/profiles/")
        shutil.rmtree(profile_path, ignore_errors=True)


def run_game(version_path, use_nvidia=False, use_zink=False, use_shared=False, use_mangohud=False):
    """Ejecuta el cliente con las opciones seleccionadas."""
    cmd = [MCPELAUNCHER_CLIENT, "-dg", version_path]
    if not use_shared:
        cmd += ["-dd", version_path.replace("/versions/", "/profiles/")]

    env = os.environ.copy()
    if use_zink:
        env["MESA_LOADER_DRIVER_OVERRIDE"] = "zink"
    elif use_nvidia:
        env.update({
            "__NV_PRIME_RENDER_OFFLOAD": "1",
            "__VK_LAYER_NV_optimus": "NVIDIA_only",
            "__GLX_VENDOR_LIBRARY_NAME": "nvidia"
        })

    final_cmd = ["setsid"] + cmd
    if use_mangohud:
        final_cmd = ["mangohud"] + cmd

    subprocess.Popen(final_cmd, env=env)
