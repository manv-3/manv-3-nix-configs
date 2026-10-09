#!/usr/bin/env bash
set -eu

WALL="$1"

if [ -f "$WALL" ]; then
    awww img --transition-type center --transition-step 90 "$WALL" 2>/dev/null || true
    echo "$WALL" > ~/.cache/current_wallpaper 2>/dev/null || true

    if command -v matugen >/dev/null 2>&1; then
        matugen image "$WALL" 2>/dev/null || true
    fi

    if command -v wal >/dev/null 2>&1; then
        wal -i "$WALL" -n -q 2>/dev/null || true
        [ -x "$HOME/.config/mako/update-colors.sh" ] && "$HOME/.config/mako/update-colors.sh" &
        [ -x "$HOME/.config/keyboard/set-color-keyboard.sh" ] && "$HOME/.config/keyboard/set-color-keyboard.sh" &
    fi
fi
