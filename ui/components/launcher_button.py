import customtkinter as ctk
from ui.theme.styles import BUTTON_STYLE

class LauncherButton(ctk.CTkButton):
    """
    Botón principal reutilizable del launcher.
    Puede mostrar ícono, texto y ejecutar una acción al hacer clic.
    """
    def __init__(self, parent, text="Jugar", icon_path=None, command=None, **kwargs):
        # Mezcla los estilos base con cualquier argumento adicional
        style = BUTTON_STYLE.copy()
        style.update(kwargs)

        super().__init__(parent, text=text, command=command, **style)

        # Si se pasa un ícono, lo configuramos
        if icon_path:
            try:
                from PIL import Image, ImageTk
                image = ctk.CTkImage(light_image=Image.open(icon_path), size=(24, 24))
                self.configure(image=image, compound="left")
            except Exception as e:
                print(f"[LauncherButton] No se pudo cargar el icono: {e}")
