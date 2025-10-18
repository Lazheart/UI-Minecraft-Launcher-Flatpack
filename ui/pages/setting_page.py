import customtkinter as ctk
from ui.theme.colors import COLORS
from ui.theme.styles import LABEL_STYLE, FRAME_STYLE, BUTTON_STYLE

class SettingPage(ctk.CTkFrame):
    """Página de configuración general."""

    def __init__(self, parent, app):
        super().__init__(parent, **FRAME_STYLE)
        self.app = app

        ctk.CTkLabel(self, text="Configuraciones", **LABEL_STYLE, font=("Arial", 18, "bold")).pack(pady=10)

        # Tema manual
        ctk.CTkLabel(self, text="Tema de la interfaz:", **LABEL_STYLE).pack(pady=5)
        self.theme_option = ctk.CTkOptionMenu(self, values=["Dark", "Light"], command=self.change_theme)
        self.theme_option.pack(pady=5)

        # Escalado
        ctk.CTkLabel(self, text="Escala de la interfaz:", **LABEL_STYLE).pack(pady=5)
        self.scale_slider = ctk.CTkSlider(self, from_=1, to=2, number_of_steps=8, command=self.change_scale)
        self.scale_slider.set(1.0)
        self.scale_slider.pack(pady=5)

        # Botón de reset
        ctk.CTkButton(self, text="Restablecer Configuración", command=self.reset_settings, **BUTTON_STYLE).pack(pady=15)

    def change_theme(self, mode):
        ctk.set_appearance_mode(mode.lower())

    def change_scale(self, value):
        ctk.set_widget_scaling(float(value))

    def reset_settings(self):
        self.theme_option.set("Dark")
        self.scale_slider.set(1.0)
        ctk.set_appearance_mode("dark")
        ctk.set_widget_scaling(1.0)
