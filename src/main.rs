use iced::{
    button, scrollable, Align, Application, Button, Column, Command, Container, Element,
    Length, Row, Scrollable, Settings, Text,
};
use std::{fs, path::PathBuf, process::Command as SysCommand};
use rfd::FileDialog;
use directories::BaseDirs;

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
    data_dir().join("applications/minecraft_iced")
}

fn logo_path() -> PathBuf {
    data_dir().join("logo.png")
}

#[derive(Debug, Clone)]
enum Message {
    SelectApk,
    InstallApk,
    DeleteVersion(String),
    LaunchVersion(String),
    None,
}

struct MyApp {
    apk_path: String,
    name: String,
    versions: Vec<String>,
    scroll: scrollable::State,
    install_button: button::State,
}

impl Application for MyApp {
    type Message = Message;
    type Executor = iced::executor::Default;
    type Flags = ();
    type Theme = iced::Theme;

    fn new(_flags: ()) -> (Self, Command<Self::Message>) {
        fs::create_dir_all(data_dir()).ok();
        fs::create_dir_all(versions_dir()).ok();
        fs::create_dir_all(profiles_dir()).ok();
        fs::create_dir_all(apps_dir()).ok();

        let versions = fs::read_dir(versions_dir())
            .unwrap_or_default()
            .filter_map(|e| e.ok())
            .filter(|e| e.path().is_dir())
            .map(|e| e.file_name().to_string_lossy().to_string())
            .collect();

        (Self {
            apk_path: String::new(),
            name: String::new(),
            versions,
            scroll: scrollable::State::new(),
            install_button: button::State::new(),
        }, Command::none())
    }

    fn title(&self) -> String {
        "Minecraft Bedrock Launcher - Iced".into()
    }

    fn update(&mut self, message: Self::Message) -> Command<Self::Message> {
        match message {
            Message::SelectApk => {
                if let Some(path) = FileDialog::new().add_filter("APK", &["apk"]).pick_file() {
                    self.apk_path = path.display().to_string();
                }
            }
            Message::InstallApk => {
                if !self.apk_path.is_empty() && !self.name.is_empty() {
                    let target = versions_dir().join(&self.name);
                    let _ = SysCommand::new("/app/bin/mcpelauncher-extract")
                        .args([&self.apk_path, &target.display().to_string()])
                        .output();
                    self.versions.push(self.name.clone());
                }
            }
            Message::DeleteVersion(version) => {
                let _ = fs::remove_dir_all(versions_dir().join(&version));
                self.versions.retain(|v| v != &version);
            }
            Message::LaunchVersion(version) => {
                let _ = SysCommand::new("/app/bin/mcpelauncher-client")
                    .args([version])
                    .spawn();
            }
            Message::None => {}
        }
        Command::none()
    }

    fn view(&self) -> Element<'_, Self::Message> {
        let mut scroll = Scrollable::new(&self.scroll).padding(10).spacing(10);

        scroll = scroll.push(
            Column::new()
                .spacing(10)
                .push(Text::new("Instalar APK"))
                .push(
                    Row::new()
                        .spacing(10)
                        .push(Button::new(&mut self.install_button, Text::new("Seleccionar APK"))
                            .on_press(Message::SelectApk))
                        .push(Text::new(&self.apk_path)),
                )
                .push(
                    Row::new()
                        .spacing(10)
                        .push(iced::TextInput::new(
                            &mut iced::text_input::State::new(),
                            "Nombre de la versión",
                            &self.name,
                            |v| { Message::None } // aquí podrías manejar input real
                        ))
                        .push(Button::new(&mut self.install_button, Text::new("Instalar"))
                            .on_press(Message::InstallApk)),
                )
                .push(Text::new("Versiones instaladas:"))
        );

        for version in &self.versions {
            scroll = scroll.push(
                Row::new()
                    .spacing(10)
                    .push(Text::new(version))
                    .push(Button::new(&mut button::State::new(), Text::new("Jugar"))
                        .on_press(Message::LaunchVersion(version.clone())))
                    .push(Button::new(&mut button::State::new(), Text::new("Borrar"))
                        .on_press(Message::DeleteVersion(version.clone()))),
            );
        }

        Container::new(scroll).padding(20).center_x().center_y().into()
    }

    fn theme(&self) -> Self::Theme { iced::Theme::Light }
}

fn main() -> iced::Result {
    MyApp::run(Settings {
        window: iced::window::Settings {
            size: (600, 600),
            ..Default::default()
        },
        ..Settings::default()
    })
}
