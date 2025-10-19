import customtkinter as ctk
import json
import os
from ui.theme.colors import COLORS
from ui.theme.styles import LABEL_STYLE, FRAME_STYLE, BUTTON_STYLE
from ui.utils.paths import CONFIG_FILE

class SettingPage(ctk.CTkFrame):
    """Página de configuración general."""

    def __init__(self, parent, app):
        super().__init__(parent, **FRAME_STYLE)
        self.app = app
        
        # Variables de configuración
        self.theme_var = ctk.StringVar(value="dark")
        self.scale_var = ctk.DoubleVar(value=1.0)
        self.language_var = ctk.StringVar(value="es")

        # Cargar configuración existente
        self.load_config()

        # Layout principal
        title_style = LABEL_STYLE.copy()
        title_style["font"] = ("Arial", 20, "bold")
        title_label = ctk.CTkLabel(self, text="⚙️ Configuraciones", **title_style)
        title_label.pack(pady=(20, 10))

        # Frame contenedor
        main_frame = ctk.CTkFrame(self, **FRAME_STYLE)
        main_frame.pack(pady=10, padx=20, fill="both", expand=True)

        # --- Sección de Apariencia ---
        appearance_frame = ctk.CTkFrame(main_frame, **FRAME_STYLE)
        appearance_frame.pack(pady=10, padx=10, fill="x")
        
        appearance_title_style = LABEL_STYLE.copy()
        appearance_title_style["font"] = ("Arial", 16, "bold")
        appearance_title = ctk.CTkLabel(appearance_frame, text="🎨 Apariencia", **appearance_title_style)
        appearance_title.pack(pady=10)

        # Tema
        ctk.CTkLabel(appearance_frame, text="Tema de la interfaz:", **LABEL_STYLE).pack(pady=(10, 5))
        self.theme_option = ctk.CTkOptionMenu(appearance_frame, variable=self.theme_var, 
                                              values=["dark", "light", "system"], command=self.change_theme)
        self.theme_option.pack(pady=5, padx=20, fill="x")

        # Escalado
        ctk.CTkLabel(appearance_frame, text="Escala de la interfaz:", **LABEL_STYLE).pack(pady=(10, 5))
        scale_frame = ctk.CTkFrame(appearance_frame, fg_color="transparent")
        scale_frame.pack(pady=5, padx=20, fill="x")
        
        self.scale_slider = ctk.CTkSlider(scale_frame, from_=0.8, to=1.5, number_of_steps=7, 
                                        variable=self.scale_var, command=self.change_scale)
        self.scale_slider.pack(side="left", fill="x", expand=True)
        
        self.scale_label = ctk.CTkLabel(scale_frame, text="1.0x", **LABEL_STYLE)
        self.scale_label.pack(side="right", padx=(10, 0))

        # --- Sección de Idioma ---
        language_frame = ctk.CTkFrame(main_frame, **FRAME_STYLE)
        language_frame.pack(pady=10, padx=10, fill="x")
        
        language_title_style = LABEL_STYLE.copy()
        language_title_style["font"] = ("Arial", 16, "bold")
        language_title = ctk.CTkLabel(language_frame, text="🌐 Idioma", **language_title_style)
        language_title.pack(pady=10)

        ctk.CTkLabel(language_frame, text="Idioma de la interfaz:", **LABEL_STYLE).pack(pady=(10, 5))
        self.language_option = ctk.CTkOptionMenu(language_frame, variable=self.language_var,
                                                values=["es", "en"], command=self.change_language)
        self.language_option.pack(pady=5, padx=20, fill="x")

        # --- Sección de Acciones ---
        actions_frame = ctk.CTkFrame(main_frame, **FRAME_STYLE)
        actions_frame.pack(pady=10, padx=10, fill="x")
        
        actions_title_style = LABEL_STYLE.copy()
        actions_title_style["font"] = ("Arial", 16, "bold")
        actions_title = ctk.CTkLabel(actions_frame, text="🔧 Acciones", **actions_title_style)
        actions_title.pack(pady=10)

        # Botones de acción
        button_frame = ctk.CTkFrame(actions_frame, fg_color="transparent")
        button_frame.pack(pady=10)

        ctk.CTkButton(button_frame, text="💾 Guardar", command=self.save_config, **BUTTON_STYLE).pack(side="left", padx=5)
        ctk.CTkButton(button_frame, text="🔄 Restablecer", command=self.reset_settings, **BUTTON_STYLE).pack(side="left", padx=5)
        ctk.CTkButton(button_frame, text="📁 Abrir Carpeta de Datos", command=self.open_data_folder, **BUTTON_STYLE).pack(side="left", padx=5)

    def load_config(self):
        """Carga la configuración desde el archivo."""
        if os.path.exists(CONFIG_FILE):
            try:
                with open(CONFIG_FILE, 'r') as f:
                    config = json.load(f)
                    self.theme_var.set(config.get("theme", "dark"))
                    self.scale_var.set(config.get("scale", 1.0))
                    self.language_var.set(config.get("language", "es"))
            except Exception as e:
                print(f"Error cargando configuración: {e}")

    def save_config(self):
        """Guarda la configuración actual."""
        config = {
            "theme": self.theme_var.get(),
            "scale": self.scale_var.get(),
            "language": self.language_var.get()
        }
        
        try:
            with open(CONFIG_FILE, 'w') as f:
                json.dump(config, f, indent=4)
            from tkinter import messagebox
            messagebox.showinfo("Configuración", "Configuración guardada correctamente.")
        except Exception as e:
            from tkinter import messagebox
            messagebox.showerror("Error", f"No se pudo guardar la configuración: {e}")

    def change_theme(self, mode):
        if mode == "system":
            import darkdetect
            mode = "dark" if darkdetect.isDark() else "light"
        ctk.set_appearance_mode(mode)

    def change_scale(self, value):
        scale = float(value)
        ctk.set_widget_scaling(scale)
        self.scale_label.configure(text=f"{scale:.1f}x")

    def change_language(self, language):
        # Por ahora solo actualizamos la variable, en el futuro se puede implementar i18n
        pass

    def reset_settings(self):
        self.theme_var.set("dark")
        self.scale_var.set(1.0)
        self.language_var.set("es")
        self.change_theme("dark")
        self.change_scale(1.0)
        from tkinter import messagebox
        messagebox.showinfo("Configuración", "Configuración restablecida a valores por defecto.")

    def open_data_folder(self):
        """Abre la carpeta de datos del launcher."""
        import subprocess
        import platform
        
        data_dir = os.path.dirname(CONFIG_FILE)
        try:
            if platform.system() == "Linux":
                subprocess.run(["xdg-open", data_dir])
            elif platform.system() == "Darwin":  # macOS
                subprocess.run(["open", data_dir])
            elif platform.system() == "Windows":
                subprocess.run(["explorer", data_dir])
        except Exception as e:
            from tkinter import messagebox
            messagebox.showerror("Error", f"No se pudo abrir la carpeta: {e}")
