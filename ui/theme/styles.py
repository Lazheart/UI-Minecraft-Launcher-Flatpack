import customtkinter as ctk
from ui.theme.colors import COLORS

def apply_global_theme():
    """Configura el tema global de CustomTkinter."""
    ctk.set_appearance_mode("dark")
    ctk.set_default_color_theme("blue")  # Tema base de CustomTkinter
    ctk.set_widget_scaling(1.0)
    ctk.set_window_scaling(1.0)


# 🎨 Estilos predefinidos (para uso directo en componentes)
BUTTON_STYLE = {
    "fg_color": COLORS["accent"],
    "hover_color": COLORS["accent_hover"],
    "text_color": COLORS["text_primary"],
    "corner_radius": 10,
    "font": ("Arial", 13, "bold"),
}

FRAME_STYLE = {
    "fg_color": COLORS["bg_secondary"],
    "corner_radius": 12,
    "border_width": 1,
    "border_color": COLORS.get("border", "#333333"),
}

LABEL_STYLE = {
    "text_color": COLORS["text_primary"],
    "font": ("Arial", 13),
}

# 🔧 Función para aplicar estilos globales
def set_styles():
    """Configura los estilos globales para los widgets."""
    ctk.set_widget_scaling(1.0)  # Escala de widgets
    ctk.set_window_scaling(1.0)  # Escala de ventana
    
    # Los estilos se aplican individualmente a cada widget
    # No se pueden configurar globalmente en CustomTkinter