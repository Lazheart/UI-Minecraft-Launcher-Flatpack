use eframe::{egui, App};
use std::{fs, process::Command, vec};
use std::path::{Path, PathBuf};
use rfd::FileDialog;
use directories::BaseDirs;

// ==== Helpers de rutas ====
fn base_dirs() -> BaseDirs {
    BaseDirs::new().expect("No se pudo obtener BaseDirs")
}

fn data_dir() -> PathBuf {
    base_dirs().data_dir().join("mcpelauncher")
}

fn versions_dir() -> PathBuf {
    data_dir().join("versions")
}

fn profiles_dir() -> PathBuf {
    data_dir().join("profiles")
}

fn apps_dir() -> PathBuf {
    data_dir().join("applications/minecraft_egui")
}

fn logo_path() -> PathBuf {
    data_dir().join("logo.png")
}

fn get_profile_path(version_path: &String) -> String {
    version_path.replace("versions", "profiles")
}

// ==== Funciones de ejecución y generación ====
fn generate_short(name: &String, nvidia: bool, args: Vec<String>, share: bool, zink: bool) {
    let logopath = logo_path().display().to_string();
    let mut nvidiastring = args.join(" ");
    let mut nombre = name.clone();
    let mut apodo = String::new();

    if nvidia {
        apodo += "N";
        nvidiastring = format!(
            "env __NV_PRIME_RENDER_OFFLOAD=1 __VK_LAYER_NV_optimus=NVIDIA_only __GLX_VENDOR_LIBRARY_NAME=nvidia {}",
            args.join(" ")
        );
    }
    if zink {
        apodo += "Z";
        nvidiastring = format!(
            "env MESA_LOADER_DRIVER_OVERRIDE=zink {}",
            args.join(" ")
        );
    }
    if share {
        apodo += "C";
    }

    if !apodo.is_empty() {
        nombre = format!("[{}] {} ", apodo, nombre);
    }

    let entry = format!(
        "[Desktop Entry]
Name={}
Comment=Explora el sistema de archivos con el administrador de archivos
Exec={}
Icon={}
Terminal=false
Type=Application
Categories=Utility;Application;
StartupNotify=true",
        nombre, nvidiastring, logopath
    );

    fs::create_dir_all(apps_dir()).ok();
    let _ = fs::write(apps_dir().join(format!("{}.desktop", nombre)), entry);
}

fn exec_nvidia(nvidia: bool, args: Vec<String>, zink: bool, mangohud: bool) {
    let mut cmd = "setsid";
    if mangohud {
        cmd = "mangohud";
    }

    let mut command = Command::new(cmd);

    if zink {
        command.env("MESA_LOADER_DRIVER_OVERRIDE", "zink");
    } else if nvidia {
        command
            .env("__NV_PRIME_RENDER_OFFLOAD", "1")
            .env("__VK_LAYER_NV_optimus", "NVIDIA_only")
            .env("__GLX_VENDOR_LIBRARY_NAME", "nvidia");
    }

    let _ = command.args(args).spawn().unwrap();
}

fn gen_cmd(version: &String, addons: Option<String>, share_path: bool) -> Vec<String> {
    let mut r = vec!["/app/bin/mcpelauncher-client".to_string(), "-dg".to_string(), version.clone()];
    if !share_path {
        r.push("-dd".to_string());
        r.push(get_profile_path(version));
    }
    if let Some(addon) = addons {
        r.push("-ifp".to_string());
        r.push(addon);
    }
    r
}

// ==== UI principal ====
struct MyApp {
    share_path: bool,
    versions: Vec<String>,
    paths: Vec<String>,
    selected: String,
    nvidia: bool,
    name: String,
    apk: String,
    log: String,
    erase: String,
    erase_path: bool,
    zink: bool,
    mangohud: bool,
}

fn get_versions() -> (Vec<String>, Vec<String>) {
    let mut paths = vec![];
    let mut versions = vec![];

    fs::create_dir_all(apps_dir()).ok();
    fs::create_dir_all(versions_dir()).ok();
    fs::create_dir_all(profiles_dir()).ok();

    if versions_dir().exists() {
        if let Ok(entries) = fs::read_dir(&versions_dir()) {
            for entry in entries.flatten() {
                if entry.file_type().map(|f| f.is_dir()).unwrap_or(false) {
                    paths.push(entry.path().display().to_string());
                    versions.push(entry.file_name().to_string_lossy().to_string());
                    fs::create_dir_all(profiles_dir().join(entry.file_name())).ok();
                }
            }
        }
    }

    (paths, versions)
}

impl Default for MyApp {
    fn default() -> Self {
        fs::create_dir_all(data_dir()).ok();

        let logo = logo_path();
        if !logo.exists() {
            let img_data: &[u8] = include_bytes!("../assets/logo.png");
            fs::write(&logo, img_data).unwrap_or_default();
        }

        let (paths, versions) = get_versions();

        Self {
            paths,
            versions,
            selected: String::new(),
            apk: String::new(),
            name: String::new(),
            nvidia: false,
            log: String::new(),
            share_path: false,
            erase: String::new(),
            erase_path: true,
            zink: false,
            mangohud: false,
        }
    }
}

impl App for MyApp {
    fn update(&mut self, ctx: &egui::Context, _frame: &mut eframe::Frame) {
        egui::CentralPanel::default().show(ctx, |ui| {
            ui.heading("Instalar APK");
            ui.separator();

            ui.horizontal(|ui| {
                ui.label("Nombre de versión:");
                ui.text_edit_singleline(&mut self.name);
            });

            ui.horizontal(|ui| {
                if ui.button("Seleccionar APK").clicked() {
                    if let Some(path) = FileDialog::new()
                        .add_filter("Archivos APK", &["apk"])
                        .pick_file()
                    {
                        self.apk = path.display().to_string();
                    }
                }
                ui.label(&self.apk);
            });

            if !self.apk.is_empty() && !self.name.is_empty() {
                if ui.button(format!("Instalar \"{}\" APK", self.name)).clicked() {
                    self.log = format!("Instalando {}...", self.name);
                    let targetpath = versions_dir().join(&self.name);
                    let status = Command::new("/app/bin/mcpelauncher-extract")
                        .args([&self.apk, &targetpath.display().to_string()])
                        .output()
                        .map(|o| o.status.success())
                        .unwrap_or(false);

                    if status {
                        (self.paths, self.versions) = get_versions();
                        self.log = "Instalado correctamente".to_string();
                    } else {
                        self.log = "Error al instalar el APK".to_string();
                    }
                }
            }

            ui.separator();
            ui.heading("Borrar versión");

            egui::ComboBox::from_label("Versión a borrar")
                .selected_text(format!("{:?}", self.erase))
                .show_ui(ui, |ui| {
                    for (i, v) in self.versions.iter().enumerate() {
                        ui.selectable_value(&mut self.erase, self.paths[i].clone(), v.clone());
                    }
                });

            if !self.erase.is_empty() {
                ui.checkbox(&mut self.erase_path, "¿Borrar datos del perfil?");
                if ui.button("Borrar (no borra atajos)").clicked() {
                    if self.erase_path {
                        let _ = fs::remove_dir_all(get_profile_path(&self.erase));
                    }
                    let _ = fs::remove_dir_all(&self.erase);
                    (self.paths, self.versions) = get_versions();
                    self.log = format!("Se eliminó {}", self.erase);
                    self.erase.clear();
                }
            }

            ui.separator();
            ui.heading("Jugar Minecraft Bedrock");

            egui::ComboBox::from_label("Versión")
                .selected_text(format!("{:?}", self.selected))
                .show_ui(ui, |ui| {
                    for (i, v) in self.versions.iter().enumerate() {
                        ui.selectable_value(&mut self.selected, self.paths[i].clone(), v.clone());
                    }
                });

            if !self.selected.is_empty() {
                if ui.checkbox(&mut self.zink, "[Z] Usar Zink (Experimental)").changed() {
                    if self.zink {
                        self.nvidia = false;
                    }
                }

                if !self.zink {
                    ui.checkbox(&mut self.nvidia, "[N] Usar Nvidia");
                }

                ui.checkbox(&mut self.share_path, "[C] Carpeta compartida");
                ui.checkbox(&mut self.mangohud, "Usar Mangohud");

                if ui.button("Jugar").clicked() {
                    self.log = format!("Iniciando {}", self.selected);
                    exec_nvidia(
                        self.nvidia,
                        gen_cmd(&self.selected, None, self.share_path),
                        self.zink,
                        self.mangohud,
                    );
                }

                if ui.button("Crear acceso directo").clicked() {
                    let name_parts: Vec<String> =
                        self.selected.split('/').map(String::from).collect();
                    let nombre = name_parts.last().unwrap();
                    generate_short(
                        nombre,
                        self.nvidia,
                        gen_cmd(&self.selected, None, self.share_path),
                        self.share_path,
                        self.zink,
                    );
                    self.log = format!("Atajo '{}' creado", nombre);
                }

                if ui.button("Añadir addons/mapas").clicked() {
                    if let Some(path) = FileDialog::new()
                        .add_filter("Addons/Mapas", &["mcpack", "mcaddon", "mcworld"])
                        .pick_file()
                    {
                        let addon_path = path.display().to_string();
                        self.log = format!("Añadiendo {}", addon_path);
                        exec_nvidia(
                            self.nvidia,
                            gen_cmd(&self.selected, Some(addon_path), self.share_path),
                            self.zink,
                            self.mangohud,
                        );
                    }
                }

                if ui.button("Ver carpeta").clicked() {
                    let target = if self.share_path {
                        data_dir()
                    } else {
                        PathBuf::from(get_profile_path(&self.selected))
                    };
                    let _ = Command::new("xdg-open").arg(target).spawn();
                }
            }

            if ui.button("Ver carpeta de accesos").clicked() {
                let _ = Command::new("xdg-open").arg(apps_dir()).spawn();
            }

            ui.separator();
            ui.label(&self.log);
        });
    }
}

fn main() {
    let options = eframe::NativeOptions::default();
    let _ = eframe::run_native(
        "Minecraft Bedrock Launcher CC-MC",
        options,
        Box::new(|cc| {
            cc.egui_ctx.set_pixels_per_point(1.3);
            Ok(Box::<MyApp>::default())
        }),
    );
}
