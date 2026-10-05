# manv-3-nix-configs

A clean, modular collection of Quickshell desktop shells for Hyprland and Wayland environments.

---

##For Wallpapers visit -

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

## Disclaimer : Not all work here is mine. These dotfiles and configurations are inspired by and adapted from various open-source ricing projects across the community. This repository serves as a personal backup of my favorite shells.
  ──────# manv-3-nix-configs
