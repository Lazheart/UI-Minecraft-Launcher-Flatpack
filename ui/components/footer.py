import customtkinter as ctk
from ui.theme.colors import COLORS

class Footer(ctk.CTkFrame):
    def __init__(self, parent):
        super().__init__(parent, fg_color=COLORS["footer_bg"])
        self.label = ctk.CTkLabel(
            self,
            text="Minecraft Bedrock Launcher © 2025 Lazheart",
            text_color=COLORS["text_secondary"],
            font=("Arial", 12)
        )
        self.label.pack(pady=5)
