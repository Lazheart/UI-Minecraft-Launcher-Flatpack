import customtkinter as ctk
from ui.theme.colors import COLORS
from ui.theme.styles import BUTTON_STYLE, LABEL_STYLE, FRAME_STYLE
from ui.utils.backend import extract_apk, get_versions, run_game, delete_version
from ui.utils.paths import MCPELAUNCHER_EXTRACT, MCPELAUNCHER_CLIENT
import os

class HomePage(ctk.CTkFrame):
    """Página principal: instalación y lanzamiento del juego."""

    def __init__(self, parent, app):
        super().__init__(parent, **FRAME_STYLE)
        self.app = app

        # 📦 Estado
        self.selected_version = ctk.StringVar(value="")
        self.apk_path = ctk.StringVar(value="")
        self.version_name = ctk.StringVar(value="")

        # 🧱 Layout principal
        self.grid_rowconfigure(0, weight=1)
        self.grid_columnconfigure(0, weight=1)
        
        # Título principal
        title_style = LABEL_STYLE.copy()
        title_style["font"] = ("Arial", 20, "bold")
        title_label = ctk.CTkLabel(self, text="Minecraft Bedrock Launcher", **title_style)
        title_label.pack(pady=(20, 10))

        # Frame contenedor principal
        main_frame = ctk.CTkFrame(self, **FRAME_STYLE)
        main_frame.pack(pady=10, padx=20, fill="both", expand=True)
        main_frame.grid_rowconfigure(0, weight=1)
        main_frame.grid_columnconfigure((0, 1), weight=1)

        # --- Panel izquierdo: Instalación APK ---
        install_frame = ctk.CTkFrame(main_frame, **FRAME_STYLE)
        install_frame.grid(row=0, column=0, padx=10, pady=10, sticky="nsew")
        
        install_title_style = LABEL_STYLE.copy()
        install_title_style["font"] = ("Arial", 16, "bold")
        install_title = ctk.CTkLabel(install_frame, text="📦 Instalar Nueva Versión", **install_title_style)
        install_title.pack(pady=10)

        # Campo nombre de versión
        ctk.CTkLabel(install_frame, text="Nombre de la versión:", **LABEL_STYLE).pack(pady=(10, 5))
        self.version_entry = ctk.CTkEntry(install_frame, textvariable=self.version_name, placeholder_text="Ej: 1.20.15")
        self.version_entry.pack(pady=5, padx=20, fill="x")

        # Seleccionar APK
        ctk.CTkButton(install_frame, text="📁 Seleccionar APK", command=self.select_apk, **BUTTON_STYLE).pack(pady=10)
        
        # Ruta del APK seleccionado
        self.apk_label = ctk.CTkLabel(install_frame, textvariable=self.apk_path, **LABEL_STYLE, wraplength=200)
        self.apk_label.pack(pady=5)

        # Botón instalar
        self.install_btn = ctk.CTkButton(install_frame, text="⬇️ Instalar APK", command=self.install_selected_apk, **BUTTON_STYLE)
        self.install_btn.pack(pady=15)

        # --- Panel derecho: Lanzamiento ---
        play_frame = ctk.CTkFrame(main_frame, **FRAME_STYLE)
        play_frame.grid(row=0, column=1, padx=10, pady=10, sticky="nsew")
        
        play_title_style = LABEL_STYLE.copy()
        play_title_style["font"] = ("Arial", 16, "bold")
        play_title = ctk.CTkLabel(play_frame, text="🎮 Lanzar Juego", **play_title_style)
        play_title.pack(pady=10)

        # Lista de versiones
        ctk.CTkLabel(play_frame, text="Versiones instaladas:", **LABEL_STYLE).pack(pady=(10, 5))
        self.version_combo = ctk.CTkComboBox(play_frame, variable=self.selected_version, width=200)
        self.version_combo.pack(pady=5, padx=20, fill="x")

        # Botones de acción
        button_frame = ctk.CTkFrame(play_frame, fg_color="transparent")
        button_frame.pack(pady=15)

        self.play_btn = ctk.CTkButton(button_frame, text="▶️ Jugar", command=self.play_selected, **BUTTON_STYLE)
        self.play_btn.pack(side="left", padx=5)

        self.delete_btn = ctk.CTkButton(button_frame, text="🗑️ Eliminar", command=self.delete_selected, 
                                      fg_color=COLORS["error"], hover_color="#DC2626")
        self.delete_btn.pack(side="left", padx=5)

        # Estado del backend
        self.status_label = ctk.CTkLabel(self, text="", **LABEL_STYLE)
        self.status_label.pack(pady=10)

        # Actualiza lista inicial y estado
        self.refresh_versions()
        self.update_backend_status()

    def select_apk(self):
        from tkinter import filedialog
        path = filedialog.askopenfilename(filetypes=[("Archivos APK", "*.apk")])
        if path:
            self.apk_path.set(path)
            # Mostrar solo el nombre del archivo
            filename = os.path.basename(path)
            self.apk_label.configure(text=f"📄 {filename}")

    def install_selected_apk(self):
        apk = self.apk_path.get()
        name = self.version_name.get()
        if not apk or not name:
            from tkinter import messagebox
            messagebox.showwarning("Campos vacíos", "Debes seleccionar un APK y asignar un nombre.")
            return
        
        # Deshabilitar botón durante instalación
        self.install_btn.configure(text="⏳ Instalando...", state="disabled")
        self.app.update()
        
        try:
            ok = extract_apk(apk, name)
            if ok:
                from tkinter import messagebox
                messagebox.showinfo("Instalado", f"Versión '{name}' instalada correctamente.")
                self.refresh_versions()
                # Limpiar campos
                self.apk_path.set("")
                self.version_name.set("")
                self.apk_label.configure(text="")
            else:
                from tkinter import messagebox
                messagebox.showerror("Error", "No se pudo instalar el APK.")
        finally:
            # Rehabilitar botón
            self.install_btn.configure(text="⬇️ Instalar APK", state="normal")

    def refresh_versions(self):
        versions = get_versions()
        if versions:
            # Mostrar solo los nombres de las versiones
            version_names = [os.path.basename(v) for v in versions]
            self.version_combo.configure(values=version_names)
        else:
            self.version_combo.configure(values=["<Sin versiones instaladas>"])

    def play_selected(self):
        version = self.selected_version.get()
        if version and version != "<Sin versiones instaladas>":
            # Encontrar la ruta completa de la versión
            versions = get_versions()
            version_path = None
            for v in versions:
                if os.path.basename(v) == version:
                    version_path = v
                    break
            
            if version_path:
                run_game(version_path)
            else:
                from tkinter import messagebox
                messagebox.showerror("Error", "No se pudo encontrar la versión seleccionada.")

    def delete_selected(self):
        version = self.selected_version.get()
        if version and version != "<Sin versiones instaladas>":
            from tkinter import messagebox
            result = messagebox.askyesno("Confirmar eliminación", 
                                      f"¿Estás seguro de que quieres eliminar la versión '{version}'?")
            if result:
                # Encontrar la ruta completa de la versión
                versions = get_versions()
                version_path = None
                for v in versions:
                    if os.path.basename(v) == version:
                        version_path = v
                        break
                
                if version_path:
                    delete_version(version_path)
                    from tkinter import messagebox
                    messagebox.showinfo("Eliminado", f"Versión '{version}' eliminada correctamente.")
                    self.refresh_versions()
                else:
                    from tkinter import messagebox
                    messagebox.showerror("Error", "No se pudo encontrar la versión seleccionada.")

    def update_backend_status(self):
        """Actualiza el estado del backend en la interfaz."""
        extract_exists = os.path.exists(MCPELAUNCHER_EXTRACT)
        client_exists = os.path.exists(MCPELAUNCHER_CLIENT)
        
        if extract_exists and client_exists:
            self.status_label.configure(text="✅ Backend disponible", text_color=COLORS["success"])
        elif extract_exists or client_exists:
            self.status_label.configure(text="⚠️ Backend parcialmente disponible", text_color=COLORS["warning"])
        else:
            self.status_label.configure(text="❌ Backend no disponible", text_color=COLORS["error"])
