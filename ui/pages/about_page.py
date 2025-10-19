import customtkinter as ctk
from ui.theme.colors import COLORS
from ui.theme.styles import LABEL_STYLE, FRAME_STYLE

class AboutPage(ctk.CTkFrame):
    """Página de información del launcher."""

    def __init__(self, parent, app):
        super().__init__(parent, **FRAME_STYLE)

        title_style = LABEL_STYLE.copy()
        title_style["font"] = ("Arial", 18, "bold")
        ctk.CTkLabel(self, text="Acerca del Launcher", **title_style).pack(pady=10)
        ctk.CTkLabel(
            self,
            text=(
                "Este lanzador fue desarrollado por Lazheart.\n"
                "Permite instalar, gestionar y ejecutar versiones de Minecraft Bedrock Edition en Linux.\n"
                "Basado en MCPEDL Extractor y mcpelauncher-client."
            ),
            **LABEL_STYLE,
            justify="center",
            wraplength=600,
        ).pack(pady=20)

        ctk.CTkLabel(
            self,
            text="Versión 1.0 — Proyecto en desarrollo",
            text_color=COLORS["text_secondary"],
            font=("Arial", 12, "italic"),
        ).pack(side="bottom", pady=10)
