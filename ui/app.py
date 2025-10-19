import customtkinter as ctk
import darkdetect
from ui.components.navbar import Navbar
from ui.components.footer import Footer
from ui.pages.home_page import HomePage
from ui.pages.about_page import AboutPage
from ui.pages.setting_page import SettingPage
from ui.theme.colors import COLORS
from ui.theme.styles import set_styles

class LauncherApp(ctk.CTk):
    def __init__(self):
        super().__init__()

        # 🖥 Configuración general de la ventana
        self.title("Minecraft Bedrock Launcher")
        self.geometry("950x600")
        self.minsize(900, 550)
        self.resizable(True, True)
        self.iconbitmap("assets/logo.png") if not self._is_linux() else None

        # 🎨 Tema dinámico (auto dark/light)
        appearance = "dark" if darkdetect.isDark() else "light"
        ctk.set_appearance_mode(appearance)
        ctk.set_default_color_theme("blue")
        set_styles()

        # 🧱 Layout base
        self.grid_rowconfigure(1, weight=1)
        self.grid_columnconfigure(0, weight=1)

        # 🧭 Navbar (arriba)
        self.navbar = Navbar(self, self.show_page)
        self.navbar.grid(row=0, column=0, sticky="ew")

        # 📄 Frame central (contenido)
        self.container = ctk.CTkFrame(self, fg_color=COLORS["bg_primary"])
        self.container.grid(row=1, column=0, sticky="nsew")

        # 📜 Footer (abajo)
        self.footer = Footer(self)
        self.footer.grid(row=2, column=0, sticky="ew")

        # Diccionario de páginas cargadas
        self.pages = {}
        self.current_page = None

        # 🏠 Página inicial
        self.show_page("home")

    # 🔄 Cambiar página
    def show_page(self, page_name: str):
        if self.current_page:
            self.current_page.grid_forget()

        if page_name not in self.pages:
            if page_name == "home":
                page = HomePage(self.container, self)
            elif page_name == "settings":
                page = SettingPage(self.container, self)
            elif page_name == "about":
                page = AboutPage(self.container, self)
            else:
                raise ValueError(f"Página desconocida: {page_name}")
            self.pages[page_name] = page

        self.current_page = self.pages[page_name]
        self.current_page.grid(row=0, column=0, sticky="nsew")

    @staticmethod
    def _is_linux():
        import platform
        return platform.system() == "Linux"

    def run(self):
        self.mainloop()
