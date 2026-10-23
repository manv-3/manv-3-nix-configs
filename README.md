# manv-3-nix-configs

A modern, highly customizable **Hyprland + Quickshell** desktop environment and dotfiles collection designed for seamless use across Linux distributions (NixOS, Arch, Fedora, etc.).

---

## Highlights

- **Compositor:** Hyprland with modular configs (general, keybinds, animations, windowrules, autostart)
- **Desktop Bar & Widgets:** [Quickshell](https://quickshell.outfoxxed.me/) featuring **Lotus Shell** (minimal dynamic island bar), plus 10+ switchable community shell presets
- **Terminal:** Kitty configured with clean dark palettes and JetBrains Mono Nerd Font
- **App Launcher:** Rofi with smooth floating dmenu and custom `.rasi` theme
- **Utilities & Monitoring:**
  - `btop` & `nvtop` configured for CPU/GPU monitoring
  - `cava` audio visualizer with custom GLSL shaders
  - `swappy` interactive screenshot annotator with `slurp` area selection
- **Wallpapers:** Integrated wallpaper switcher scripts with companion repository support

---

## Wallpaper Companion

Find the curated wallpapers at: **[manv-3-wallpapers](https://github.com/manv-3/manv-3-wallpapers)**

```bash
git clone https://github.com/manv-3/manv-3-wallpapers.git ~/Pictures/Wallpapers
ln -sf ~/Pictures/Wallpapers ~/.config/wallpapers
```

---

## Quick Installation

### Automated Install (Recommended)

Clone and run the automated installer:

```bash
git clone https://github.com/manv-3/manv-3-nix-configs.git ~/manv-3-nix-configs
cd ~/manv-3-nix-configs
chmod +x install.sh
./install.sh
```

*The installer automatically creates timestamped backups in `~/.config/dotfiles_backup_<timestamp>` before making changes.*

---

## Keybindings Reference

| Key Combination | Action | Description |
|---|---|---|
| `SUPER + Return` | Terminal | Launch Kitty terminal |
| `SUPER + D` | Application Launcher | Open Rofi launcher |
| `SUPER + B` | Quickshell Switcher | Open Rofi shell picker to change desktop bars |
| `SUPER + Q` | Close Window | Close the focused window |
| `SUPER + M` | Exit Hyprland | Gracefully log out |
| `SUPER + E` | File Manager | Launch default file manager |
| `SUPER + V` | Floating Toggle | Toggle floating window mode |
| `SUPER + SHIFT + S` | Area Screenshot | Interactive area selection with `slurp` and copy to clipboard |
| `Print` | Full Screenshot | Capture entire screen and save to `~/Pictures/Screenshots` |
| `SUPER + 1-9` | Workspaces | Switch to workspace 1 through 9 |
| `SUPER + SHIFT + 1-9` | Move Window | Move focused window to workspace 1 through 9 |

---

## Switching Quickshell Desktop Bars

Switch shells anytime with:

* **GUI Selector:** Press `SUPER + B`
* **CLI Switch:**
  ```bash
  ~/.config/hypr/scripts/toggle_qs_dots.sh <shell-name>
  ```
* **Test Directly:**
  ```bash
  quickshell -p ~/.config/quickshell/lotus-dotfiles/shell.qml
  ```

---

## Dependencies

- **Wayland / Compositor:** `hyprland`, `hypridle`, `hyprlock`, `quickshell`
- **Tools:** `kitty`, `rofi`, `btop`, `cava`, `swappy`, `grim`, `slurp`, `wl-clipboard`, `brightnessctl`, `playerctl`
- **Fonts:** `JetBrains Mono Nerd Font`, `Font Awesome`

---

## License & Credits

Dotfiles and custom scripts are licensed under MIT. Quickshell desktop themes and community contributions belong to their respective authors.
