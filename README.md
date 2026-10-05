# manv-3-nix-configs

A clean, modular collection of Quickshell desktop shells for Hyprland and Wayland environments.

---

## Quick Setup

To use these shells on a new machine or installation:

```bash
# Clone the repository
git clone https://github.com/manv-3/manv-3-nix-configs.git ~/manv-3-nix-configs

# Link or copy the quickshell configurations
mkdir -p ~/.config/quickshell
cp -r ~/manv-3-nix-configs/quickshell/* ~/.config/quickshell/

# Install the switcher script
mkdir -p ~/.config/hypr/scripts
cp ~/manv-3-nix-configs/scripts/toggle_qs_dots.sh ~/.config/hypr/scripts/
chmod +x ~/.config/hypr/scripts/toggle_qs_dots.sh
```

### Switching Shells

* **GUI Menu (Rofi):** Press `SUPER + B` or run:
  ```bash
  ~/.config/hypr/scripts/toggle_qs_dots.sh
  ```
* **CLI Switch:**
  ```bash
  ~/.config/hypr/scripts/toggle_qs_dots.sh <shell-name>
  ```
* **Direct Test / Launch:**
  ```bash
  quickshell -p ~/.config/quickshell/<shell-name>/shell.qml
  ```

---

## Included Shells

| Shell | Style / Theme | Upstream / Author | Key Features & Entry Point |
| :--- | :--- | :--- | :--- |
| **lotus-dotfiles** *(Default)* | Lotus Paper | [JesusP2/lotus-dotfiles](https://github.com/JesusP2/lotus-dotfiles) | Minimalist tactile paper theme, 3 top islands, native notification center, and island dashboard. (`lotus-dotfiles/shell.qml`) |
| **lucid** | Frosted Glass | [Sn3akyy1/lucid-shell](https://github.com/Sn3akyy1/lucid-shell) | Frosted glass look, swipe workspace overview, interactive media controls, screenshot OCR. (`lucid/shell.qml`) |
| **end4-pc** | Modern Material | [pctrade/end4-pC](https://github.com/pctrade/end4-pC) | Standalone fork of end-4 dots with custom wallpaper-driven color switcher. (`end4-pc/shell.qml`) |
| **ii** | Windows 11 (Waffle) | [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland) | Original Illogical Impulse shell with Windows 11 style start menu, taskbar, and notification tray. (`ii/shell.qml`) |
| **k4** | Cyber Dynamic Island | [k4ditano/k4](https://github.com/k4ditano/k4) | Dynamic Island system bar, clipboard history manager, token monitors, and plugin runtime. (`k4/arrancar`) |
| **zesis** | Celestial Wayland | [zesis-shell/zesis](https://github.com/zesis-shell/zesis) | Matugen live dynamic theming, audio/network widgets, and multi-monitor status bars. (`zesis/shell.qml`) |
| **nibrasshell** | Futuristic AI Shell | [AhmedSaadi0/NibrasShell](https://github.com/AhmedSaadi0/NibrasShell) | Smart Capsule island, AI system monitoring daemon, Material 3 coloring, and visual control hub. (`nibrasshell/shell.qml`) |
| **persona-quickshell** | Persona 5 UI | [Yujonpradhananga/Persona-Quickshell-](https://github.com/Yujonpradhananga/Persona-Quickshell-) | Persona 5 game aesthetic with comic cut-in popups, animated background menus, and CAVA visualizer. (`persona-quickshell/shell.qml`) |
| **synoptik** | Telemetry Dashboard | [natepayn3/Synoptik](https://github.com/natepayn3/Synoptik) | System telemetry dashboard, real-time hardware gauges (CPU, RAM, Temp), and quick settings panel. (`synoptik/shell.qml`) |
| **cartoon-shell** | Cyber Cartoon | [mailong2401/cartoon-shell](https://github.com/mailong2401/cartoon-shell) | Vibrant cartoon aesthetic with custom floating desktop widgets and animations. (`cartoon-shell/shell.qml`) |
| **macos** | macOS Tahoe | [lestercorderomurillo/macos-tahoe-liquid-kde](https://github.com/lestercorderomurillo/macos-tahoe-liquid-kde) | macOS layout with top menubar, Spotlight search, Launchpad overlay, Dock, and genie animations. (`macos/shell.qml`) |
| **Q1** | Anime & Media Hub | [dhrruvsharma/shell](https://github.com/dhrruvsharma/shell) | Slide-out anime/manga/novel reader, synced Spotify lyrics, and AI assistant chat interface. (`Q1/shell.qml`) |
| **11** | Windows 11 Overlay | [Ronin-CK/HyprQuickFrame](https://github.com/Ronin-CK/HyprQuickFrame) | Windows 11 style screen-capture overlay and region selector. (`11/shell.qml`) |
| **ryoku** | Japanese Minimal | [Ryoku-dev/ryoku](https://github.com/Ryoku-dev/ryoku) | Japanese aesthetic frame bars and wallpaper clock ("力と美") driven by modular IPC. (`ryoku/shell.qml`) |
| **imported-1789667132** | Clavis Shell | [StatIndet/clavis-shell](https://github.com/StatIndet/picture/tree/main/clavis-shell) | High-performance QML & C++ shell built for scrollable tiling Wayland compositors (Niri). (`imported-1789667132/shell.qml`) |
| **vast-shell** | Dynamic Island | Caelestia Ecosystem | Dynamic island widgets with Caelestia elevation styling and calendar integrations. (`vast-shell/shell.qml`) |
| **macduo** | Perspective Blur | Local Integration | ACPI lid-switch listener that triggers macOS-style perspective distortion and screen dimming on sleep. (`macduo/shell.qml`) |
| **hyprland-minions** | Plasticbar (iMac G3) | Community Theme | Fruity pastel color schemes (`blueberry`, `grape`, `lemon`, `tangerine`) with glossy retro widgets. (`hyprland-minions/shell.qml`) |
