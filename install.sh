#!/usr/bin/env bash
# ==============================================================================
# manv-3-nix-configs Automated Installer
# Installs Hyprland, Quickshell, Kitty, Rofi, and auxiliary dotfiles.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

echo "=== manv-3 Dotfiles Installer ==="

# 1. Backup existing configurations
echo ">> Checking existing configurations..."
mkdir -p "$BACKUP_DIR"
for dir in hypr quickshell kitty rofi btop cava swappy nvtop gtk-3.0 gtk-4.0; do
    if [ -d "$HOME/.config/$dir" ]; then
        echo "   Backing up ~/.config/$dir to $BACKUP_DIR/"
        cp -r "$HOME/.config/$dir" "$BACKUP_DIR/"
    fi
done

# 2. Deploy configurations to ~/.config
echo ">> Deploying dotfiles to ~/.config..."
mkdir -p "$HOME/.config"
for dir in hypr quickshell kitty rofi btop cava swappy nvtop gtk-3.0 gtk-4.0; do
    if [ -d "$SCRIPT_DIR/$dir" ]; then
        echo "   Installing $dir -> ~/.config/$dir"
        mkdir -p "$HOME/.config/$dir"
        cp -r "$SCRIPT_DIR/$dir"/* "$HOME/.config/$dir/"
    fi
done

# 3. Deploy scripts
echo ">> Setting up helper scripts..."
mkdir -p "$HOME/.config/hypr/scripts"
if [ -d "$SCRIPT_DIR/scripts" ]; then
    cp -r "$SCRIPT_DIR/scripts"/* "$HOME/.config/hypr/scripts/"
fi
chmod +x "$HOME/.config/hypr/scripts"/*.sh 2>/dev/null || true
if [ -d "$HOME/.config/hypr/scripts/wallpapers" ]; then
    chmod +x "$HOME/.config/hypr/scripts/wallpapers"/*.sh 2>/dev/null || true
fi

# 4. Optional shell profiles
read -rp ">> Install shell profiles (~/.bashrc, ~/.zshrc)? [y/N]: " install_shell
if [[ "$install_shell" =~ ^[Yy]$ ]]; then
    [ -f "$SCRIPT_DIR/shell/.bashrc" ] && cp "$SCRIPT_DIR/shell/.bashrc" "$HOME/.bashrc.manv3" && echo "   Saved ~/.bashrc.manv3"
    [ -f "$SCRIPT_DIR/shell/.zshrc" ] && cp "$SCRIPT_DIR/shell/.zshrc" "$HOME/.zshrc.manv3" && echo "   Saved ~/.zshrc.manv3"
    echo "   (Review .bashrc.manv3 / .zshrc.manv3 and merge with your shell)"
fi

echo ""
echo "=== Installation Completed Successfully! ==="
echo "Restart Hyprland or log in again to experience your new desktop environment."
