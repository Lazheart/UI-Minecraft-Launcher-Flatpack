import customtkinter as ctk
# from ui.theme.colors import COLORS
from ui.theme.styles import BUTTON_STYLE, LABEL_STYLE, FRAME_STYLE
from ui.utils.backend import extract_apk, get_versions, run_game

class HomePage(ctk.CTkFrame):
    """Página principal: instalación y lanzamiento del juego."""

    def __init__(self, parent, app):
        super().__init__(parent, **FRAME_STYLE)
        self.app = app

        # 📦 Estado
        self.selected_version = ctk.StringVar(value="")
        self.apk_path = ctk.StringVar(value="")
        self.version_name = ctk.StringVar(value="")

        # 🧱 Layout
        ctk.CTkLabel(self, text="Minecraft Bedrock Launcher", **LABEL_STYLE, font=("Arial", 18, "bold")).pack(pady=10)

        # --- Instalación APK ---
        install_frame = ctk.CTkFrame(self, **FRAME_STYLE)
        install_frame.pack(pady=15, padx=15, fill="x")

        ctk.CTkLabel(install_frame, text="Instalar nueva versión APK:", **LABEL_STYLE).pack(pady=5)
        ctk.CTkEntry(install_frame, textvariable=self.version_name, placeholder_text="Nombre de versión").pack(pady=5)
        ctk.CTkButton(install_frame, text="Seleccionar APK", command=self.select_apk, **BUTTON_STYLE).pack(pady=5)
        ctk.CTkLabel(install_frame, textvariable=self.apk_path, **LABEL_STYLE).pack(pady=5)
        ctk.CTkButton(install_frame, text="Instalar APK", command=self.install_selected_apk, **BUTTON_STYLE).pack(pady=5)

        # --- Lanzamiento ---
        play_frame = ctk.CTkFrame(self, **FRAME_STYLE)
        play_frame.pack(pady=15, padx=15, fill="x")

        ctk.CTkLabel(play_frame, text="Seleccionar versión instalada:", **LABEL_STYLE).pack(pady=5)
        self.version_combo = ctk.CTkComboBox(play_frame, variable=self.selected_version)
        self.version_combo.pack(pady=5)
        ctk.CTkButton(play_frame, text="Jugar", command=self.play_selected, **BUTTON_STYLE).pack(pady=5)

        # Actualiza lista inicial
        self.refresh_versions()

    def select_apk(self):
        from tkinter import filedialog
        path = filedialog.askopenfilename(filetypes=[("Archivos APK", "*.apk")])
        if path:
            self.apk_path.set(path)

    def install_selected_apk(self):
        apk = self.apk_path.get()
        name = self.version_name.get()
        if not apk or not name:
            from tkinter import messagebox
            messagebox.showwarning("Campos vacíos", "Debes seleccionar un APK y asignar un nombre.")
            return
        ok = extract_apk(apk, name)
        if ok:
            from tkinter import messagebox
            messagebox.showinfo("Instalado", f"Versión '{name}' instalada correctamente.")
            self.refresh_versions()
        else:
            from tkinter import messagebox
            messagebox.showerror("Error", "No se pudo instalar el APK.")

    def refresh_versions(self):
        versions = get_versions()
        self.version_combo.configure(values=versions or ["<Sin versiones>"])

    def play_selected(self):
        version = self.selected_version.get()
        if version and version != "<Sin versiones>":
            run_game(version)
