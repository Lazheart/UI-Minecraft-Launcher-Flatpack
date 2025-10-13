use eframe::{egui};
use eframe::App;
use std::{env, vec};
use std::path::PathBuf;
use std::fs;
use std::process::Command;
use rfd::FileDialog;
use std::path::Path;

fn get_profile_path(path: &String) -> String {
    return path.clone().replace(".local/share/mcpelauncher/versions/", ".local/share/mcpelauncher/profiles/")
}

fn generate_short(name: &String, nvidia: bool, args: Vec<String>, share: bool, zink: bool) {
    let home = env::var("HOME").unwrap();
    let logopath =format!("{}/.local/share/mcpelauncher/logo.png", home.to_string());
    let mut nvidiastring= args.join(" ");
    let mut nombre = name.clone();
    let mut apodo = "".to_string();
    if nvidia {
        apodo += "N";
        nvidiastring = format!("env __NV_PRIME_RENDER_OFFLOAD=1 __VK_LAYER_NV_optimus=NVIDIA_only __GLX_VENDOR_LIBRARY_NAME=nvidia {}", args.join(" "));
    }
    if zink {
        apodo += "Z";
        nvidiastring = format!("env MESA_LOADER_DRIVER_OVERRIDE=zink {}", args.join(" "));
    }
    if share {
        apodo += "C";
    }
    if apodo != "" {
        nombre = format!("[{}] {} ",apodo, nombre);
    } else {
        nombre = nombre
    }

    let r = format!("[Desktop Entry]
Name={}
Comment=Explore el sistema de archivos con el administrador de archivos
Exec={}
Icon={}
Terminal=false
Type=Application
Categories=Utility;Application;
StartupNotify=true", nombre, nvidiastring , logopath);
    let _ = fs::write(format!("{}/.local/share/applications/minecraft_egui/{}.desktop", home, nombre), r);
    println!("{}/.local/share/applications/minecraft_egui/{}.desktop", home, nombre)
}

fn exec_nvidia(nvidia: bool, args : Vec<String>, zink: bool, mangohud: bool) {
    let mut cmd = "setsid";
    if mangohud {
        cmd = "mangohud";
    }
    if zink {
        let _ = Command::new(cmd)
            .env("MESA_LOADER_DRIVER_OVERRIDE", "zink")
            .args(args).spawn().unwrap();
    } else {
        if nvidia {
            let _ = Command::new(cmd)
                .env("__NV_PRIME_RENDER_OFFLOAD", "1")
                .env("__VK_LAYER_NV_optimus","NVIDIA_only" )
                .env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
                .args(args).spawn().unwrap();
        } else {
            let _ = Command::new(cmd).args(args).spawn().unwrap();   
        }
    }
}

fn gen_cmd(version: &String, addons: Option<String>, share_path: bool) -> Vec<String> {
    // Cambiado para usar ruta absoluta dentro del flatpak
    let mut r = vec!["/app/bin/mcpelauncher-client".to_string(), "-dg".to_string(), version.clone()];
    if !share_path {
        r.push("-dd".to_string());
        r.push(get_profile_path(version));
    }
    if let Some(addon) = addons {
        r.push("-ifp".to_string());
        r.push(addon);
    }
    return r
}

struct MyApp {
    share_path: bool,
    versions: Vec<String>,
    paths: Vec<String>,
    selected: String,
    nvidia: bool, 
    name: String, 
    apk: String,
    log: String,
    home: String,
    erase: String,
    erase_path: bool,
    zink: bool,
    mangohud: bool
}

fn get_versions() -> (Vec<String>, Vec<String>) {
    let mut paths = vec![];
    let mut versions = vec![];
    let home = env::var("HOME").unwrap();
    let mut path = PathBuf::from(&home);
    path.push(".local/share/mcpelauncher/versions/");
    if !PathBuf::from(format!("{}/.local/share/applications/minecraft_egui/", &home)).exists() {
        fs::create_dir_all(format!("{}/.local/share/applications/minecraft_egui/", &home)).unwrap();
    };
    if path.exists() {
        match fs::read_dir(&path) {
            Ok(carpetas) => {
                for i in carpetas {
                    let car = i.unwrap();
                    if car.file_type().unwrap().is_dir() {
                        paths.push(car.path().display().to_string());
                        versions.push(car.file_name().display().to_string());        
                        let _ = fs::create_dir_all(format!("{}/.local/share/mcpelauncher/profiles/{}", home.clone(), car.file_name().display().to_string()));            
                    }
                }
            },
            Err(_) => { 
            } 
        }
    };
    return (paths, versions);
}


impl Default for MyApp {
    fn default() -> Self {
        let home = env::var("HOME").unwrap();
        let logopath =format!("{}/.local/share/mcpelauncher/logo.png", home.to_string());
        if !Path::new(&logopath).exists() {
            let img_data: &[u8] = include_bytes!("../assets/logo.png");
            let _ = fs::write(logopath, img_data).unwrap();
        }
        let (paths, versions) = get_versions();
        Self {
            paths: paths,
            versions: versions,
            selected: "".to_string(),
            apk:"".to_string(),
            name:"".to_string(),
            nvidia:false,
            log: "".to_string(),
            share_path: false,
            home: env::var("HOME").unwrap(),
            erase: "".to_string(),
            erase_path: true,
            zink: false,
            mangohud: false,
        }
    }
}

impl App for MyApp {
    fn update(&mut self, ctx: &eframe::egui::Context, _frame : &mut eframe::Frame) {
        egui::CentralPanel::default().show(ctx, |ui| {

            ui.separator();
            ui.heading("Instalar apk");
            ui.horizontal(|ui|{
                ui.label("Nombre de version:");
                ui.text_edit_singleline(&mut self.name);
            });
            ui.horizontal(|ui| {
                if ui.button("Selecionar apk").clicked() {
                    if let Some(path) = FileDialog::new().add_filter("Archivos apk", &["apk"]).pick_file() {
                        self.apk = path.as_path().display().to_string()
                    };
                };
                ui.label(&self.apk);
            });
            if &self.apk != &"".to_string() && &self.name != &"".to_string() {
                if ui.button(format!("Instalar \"{}\" apk", self.name)).clicked() {
                    self.log = format!("Instalando {} version {}", self.apk, self.name);
                    let targetpath =format!("{}/.local/share/mcpelauncher/versions/{}", &self.home, &self.name);
                    // Cambiado comando a ruta absoluta dentro del flatpak
                    if Command::new("/app/bin/mcpelauncher-extract").args([&self.apk, &targetpath]).output().unwrap().status.success() {
                        (self.paths, self.versions) = get_versions();
                        self.log = "Instalado".to_string();
                    } else { self.log = "No se pudo instalar".to_string() }
                };
            };

            ui.separator();
            ui.heading("Borrar version");
            egui::ComboBox::from_label("Version a borrar")
                .selected_text(format!("{:?}", self.erase))
                .show_ui(ui, |ui|{
                    for (i, v) in self.versions.iter().enumerate() {
                        ui.selectable_value(&mut self.erase,self.paths[i].clone(), v.clone());
                    }
                }
            );
            if self.erase != "" {
                ui.checkbox(&mut self.erase_path, "Borrar datos del perfil?");
                if ui.button("Borrar (No borra atajos)").clicked() {
                    if self.erase_path {
                        let _ = fs::remove_dir_all(&get_profile_path(&self.erase));
                    }
                    let _ = fs::remove_dir_all(&self.erase);
                    (self.paths, self.versions) = get_versions();
                    self.log = format!("Se elimino {}", self.erase);
                    self.erase = "".to_string();
                };
            }
            ui.separator();
            ui.heading("Jugar minecraft bedrock");
            egui::ComboBox::from_label("Version").selected_text(format!("{:?}", self.selected)).show_ui(ui, |ui|{
                for (i, v) in self.versions.iter().enumerate() {
                    ui.selectable_value(&mut self.selected,self.paths[i].clone(), v.clone());
                }
            });
            if &self.selected != &"".to_string() {
                if ui.checkbox(&mut self.zink, "[Z] Usar zink (Experimental)").changed() {
                    if self.zink {
                        self.nvidia = false;
                    } 
                };
                if !self.zink {
                    ui.checkbox(&mut self.nvidia, "[N] Usar nvidia");
                };
                ui.checkbox(&mut self.share_path, "[C] Usar carpeta compartida");
                ui.checkbox(&mut self.mangohud, "Usar mangohud");
                if ui.button("Jugar").clicked() {
                    println!("Iniciar {}", self.selected);
                    self.log = format!("Iniciando {}", self.selected);
                    exec_nvidia(self.nvidia, gen_cmd(&self.selected, None, self.share_path), self.zink, self.mangohud)
                }
                if ui.button("Crear atajo").clicked() {
                    let names: Vec<String> = self.selected.split("/").map(String::from).collect();
                    let nombre = names.last().unwrap();
                    generate_short(&nombre, self.nvidia, gen_cmd(&self.selected, None, self.share_path), self.share_path, self.zink);
                    if self.nvidia { self.log = format!("Atajo 'nvidia {}' creado", nombre) }
                    else { self.log = format!("Atajo '{}' creado", nombre) }
                };
                if ui.button("Añadir addons/mapas").clicked() {
                    if let Some(path) = FileDialog::new().add_filter("Archivos addons/mapas", &["mcpack", "mcaddon", "mcworld"]).pick_file() {
                        let fileselect = path.as_path().display().to_string();
                        println!("Iniciar {}", self.selected);
                        println!("{}", &self.selected);
                        self.log = format!("Iniciando {}", self.selected);
                        exec_nvidia(self.nvidia, gen_cmd(&self.selected, Some(fileselect), self.share_path), self.zink, self.mangohud);
                    };
                }
                if ui.button("Ver carpeta").clicked() {
                    if self.share_path {
                        let _ = Command::new("xdg-open").arg(format!("{}/.local/share/mcpelauncher/", self.home)).spawn().unwrap();
                    } else {
                        let _ = Command::new("xdg-open").arg(get_profile_path(&self.selected).as_str()).spawn().unwrap();
                    }
                }
            };
            if ui.button("Ver carpeta de atajos").clicked() {
                let _ = Command::new("xdg-open").arg(format!("{}/.local/share/applications/minecraft_egui/", self.home)).spawn().unwrap();
            };
            ui.label(&self.log)
        });
    }
}

fn main() {
    let options = eframe::NativeOptions::default();
    let _ = eframe::run_native(
        "Minecraft bedrock launcher CC-MC",
        options,
        Box::new(|_cc| {
            _cc.egui_ctx.set_pixels_per_point(1.3);
            Ok(Box::<MyApp>::default())
            }),
    );
}
