#!/usr/bin/env python3
import os
import subprocess
import shutil
import tkinter as tk
import customtkinter as ctk
from tkinter import filedialog, messagebox


# --- CONFIGURACIÓN ---
HOME = os.path.expanduser("~")
VERSIONS_DIR = os.path.join(HOME, ".local/share/mcpelauncher/versions")
PROFILES_DIR = os.path.join(HOME, ".local/share/mcpelauncher/profiles")
SHORTCUTS_DIR = os.path.join(HOME, ".local/share/applications/minecraft_egui")

os.makedirs(VERSIONS_DIR, exist_ok=True)
os.makedirs(PROFILES_DIR, exist_ok=True)
os.makedirs(SHORTCUTS_DIR, exist_ok=True)


def get_profile_path(version_path):
    """Devuelve el path del perfil asociado a una versión."""
    return version_path.replace("/versions/", "/profiles/")


def exec_nvidia(use_nvidia, args, use_zink, use_mangohud):
    """Ejecuta mcpelauncher-client con las variables correctas."""
    cmd = ["setsid"]
    if use_mangohud:
        cmd = ["mangohud"]

    env = os.environ.copy()
    if use_zink:
        env["MESA_LOADER_DRIVER_OVERRIDE"] = "zink"
    elif use_nvidia:
        env.update({
            "__NV_PRIME_RENDER_OFFLOAD": "1",
            "__VK_LAYER_NV_optimus": "NVIDIA_only",
            "__GLX_VENDOR_LIBRARY_NAME": "nvidia"
        })

    subprocess.Popen(cmd + args, env=env)


def gen_cmd(version_path, addon_path=None, shared=False):
    """Genera el comando de ejecución base."""
    args = ["mcpelauncher-client", "-dg", version_path]
    if not shared:
        args += ["-dd", get_profile_path(version_path)]
    if addon_path:
        args += ["-ifp", addon_path]
    return args


def get_versions():
    """Escanea las versiones disponibles."""
    versions, paths = [], []
    if os.path.exists(VERSIONS_DIR):
        for name in os.listdir(VERSIONS_DIR):
            path = os.path.join(VERSIONS_DIR, name)
            if os.path.isdir(path):
                versions.append(name)
                paths.append(path)
                os.makedirs(os.path.join(PROFILES_DIR, name), exist_ok=True)
    return versions, paths


def generate_shortcut(name, use_nvidia, args, shared, use_zink):
    """Crea un archivo .desktop personalizado."""
    apodo = ""
    cmd_str = " ".join(args)
    if use_nvidia:
        apodo += "N"
        cmd_str = f"env __NV_PRIME_RENDER_OFFLOAD=1 __VK_LAYER_NV_optimus=NVIDIA_only __GLX_VENDOR_LIBRARY_NAME=nvidia {cmd_str}"
    if use_zink:
        apodo += "Z"
        cmd_str = f"env MESA_LOADER_DRIVER_OVERRIDE=zink {cmd_str}"
    if shared:
        apodo += "C"

    nombre_final = f"[{apodo}] {name}" if apodo else name
    logo_path = os.path.join(HOME, ".local/share/mcpelauncher/logo.png")

    desktop_entry = f"""[Desktop Entry]
Name={nombre_final}
Exec={cmd_str}
Icon={logo_path}
Terminal=false
Type=Application
Categories=Utility;Application;
StartupNotify=true
"""
    dest = os.path.join(SHORTCUTS_DIR, f"{nombre_final}.desktop")
    with open(dest, "w") as f:
        f.write(desktop_entry)
    os.chmod(dest, 0o755)
    messagebox.showinfo("Atajo creado", f"Atajo creado en:\n{dest}")


class LauncherUI(ctk.CTk):
    def __init__(self):
        super().__init__()
        self.title("Minecraft Bedrock Launcher - Lazheart")
        self.geometry("720x600")
        self.resizable(False, False)

        # Estado
        self.apk_path = tk.StringVar()
        self.version_name = tk.StringVar()
        self.selected_version = tk.StringVar()
        self.erase_target = tk.StringVar()
        self.use_nvidia = tk.BooleanVar()
        self.use_zink = tk.BooleanVar()
        self.use_shared = tk.BooleanVar()
        self.use_mangohud = tk.BooleanVar()
        self.erase_profiles = tk.BooleanVar(value=True)

        # --- Secciones ---
        self.build_install_section()
        self.build_delete_section()
        self.build_play_section()

        self.refresh_versions()

    def build_install_section(self):
        frame = ctk.CTkFrame(self)
        frame.pack(pady=10, fill="x", padx=10)

        ctk.CTkLabel(frame, text="Instalar APK").pack(pady=5)
        ctk.CTkEntry(frame, textvariable=self.version_name, placeholder_text="Nombre de versión").pack(pady=5)
        ctk.CTkButton(frame, text="Seleccionar APK", command=self.select_apk).pack(pady=5)
        ctk.CTkLabel(frame, textvariable=self.apk_path).pack(pady=5)
        ctk.CTkButton(frame, text="Instalar APK", command=self.install_apk).pack(pady=5)

    def select_apk(self):
        file = filedialog.askopenfilename(filetypes=[("Archivos APK", "*.apk")])
        if file:
            self.apk_path.set(file)

    def install_apk(self):
        apk = self.apk_path.get()
        name = self.version_name.get()
        if not apk or not name:
            messagebox.showwarning("Campos vacíos", "Debes seleccionar un APK y poner un nombre.")
            return

        target = os.path.join(VERSIONS_DIR, name)
        os.makedirs(target, exist_ok=True)
        result = subprocess.run(["mcpelauncher-extract", apk, target])
        if result.returncode == 0:
            messagebox.showinfo("Instalado", f"Versión '{name}' instalada.")
            self.refresh_versions()
        else:
            messagebox.showerror("Error", "No se pudo instalar el APK.")

    def build_delete_section(self):
        frame = ctk.CTkFrame(self)
        frame.pack(pady=10, fill="x", padx=10)

        ctk.CTkLabel(frame, text="Borrar versión").pack(pady=5)
        self.erase_box = ctk.CTkComboBox(frame, variable=self.erase_target)
        self.erase_box.pack(pady=5)
        ctk.CTkCheckBox(frame, text="Borrar datos del perfil", variable=self.erase_profiles).pack(pady=5)
        ctk.CTkButton(frame, text="Borrar versión", command=self.erase_version).pack(pady=5)

    def erase_version(self):
        path = self.erase_target.get()
        if not path:
            return
        if messagebox.askyesno("Confirmar", f"¿Borrar versión en {path}?"):
            shutil.rmtree(path, ignore_errors=True)
            if self.erase_profiles.get():
                shutil.rmtree(get_profile_path(path), ignore_errors=True)
            self.refresh_versions()

    def build_play_section(self):
        frame = ctk.CTkFrame(self)
        frame.pack(pady=10, fill="x", padx=10)

        ctk.CTkLabel(frame, text="Jugar Minecraft Bedrock").pack(pady=5)
        self.combo = ctk.CTkComboBox(frame, variable=self.selected_version)
        self.combo.pack(pady=5)

        for label, var in [
            ("Usar NVIDIA [N]", self.use_nvidia),
            ("Usar Zink [Z]", self.use_zink),
            ("Usar carpeta compartida [C]", self.use_shared),
            ("Usar MangoHud", self.use_mangohud)
        ]:
            ctk.CTkCheckBox(frame, text=label, variable=var).pack(pady=3)

        ctk.CTkButton(frame, text="Jugar", command=self.launch_game).pack(pady=5)
        ctk.CTkButton(frame, text="Crear atajo", command=self.create_shortcut).pack(pady=5)

    def refresh_versions(self):
        versions, paths = get_versions()
        options = paths if paths else ["<No hay versiones>"]
        self.combo.configure(values=options)
        self.erase_box.configure(values=options)

    def launch_game(self):
        version = self.selected_version.get()
        if not version:
            return
        exec_nvidia(self.use_nvidia.get(), gen_cmd(version, None, self.use_shared.get()),
                    self.use_zink.get(), self.use_mangohud.get())

    def create_shortcut(self):
        version = self.selected_version.get()
        if not version:
            return
        name = os.path.basename(version)
        generate_shortcut(name, self.use_nvidia.get(),
                          gen_cmd(version, None, self.use_shared.get()),
                          self.use_shared.get(), self.use_zink.get())


if __name__ == "__main__":
    ctk.set_appearance_mode("system")
    ctk.set_default_color_theme("dark-blue")
    app = LauncherUI()
    app.mainloop()
