import customtkinter as ctk
from ui.theme.colors import COLORS

class Navbar(ctk.CTkFrame):
    def __init__(self, parent, show_page_callback):
        super().__init__(parent, fg_color=COLORS["navbar_bg"])
        self.show_page_callback = show_page_callback

        # Layout flexible
        self.grid_columnconfigure((0, 1, 2, 3), weight=1)

        # Logo o título
        self.logo_label = ctk.CTkLabel(self, text="🪶 Lazheart Launcher", text_color=COLORS["accent"], font=("Arial", 16, "bold"))
        self.logo_label.grid(row=0, column=0, padx=20, pady=10, sticky="w")

        # Botones de navegación
        self.home_btn = ctk.CTkButton(self, text="Inicio", width=90, command=lambda: self.show_page_callback("home"))
        self.settings_btn = ctk.CTkButton(self, text="Configuración", width=120, command=lambda: self.show_page_callback("settings"))
        self.about_btn = ctk.CTkButton(self, text="Acerca de", width=100, command=lambda: self.show_page_callback("about"))

        self.home_btn.grid(row=0, column=1, padx=10)
        self.settings_btn.grid(row=0, column=2, padx=10)
        self.about_btn.grid(row=0, column=3, padx=10)
