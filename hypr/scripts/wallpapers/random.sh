#!/usr/bin/env bash

WALLPAPERS_DIR="$HOME/Pictures/Wallpapers"
NEW_WALL=$(find $WALLPAPERS_DIR -type f | shuf -n 1)


~/.config/hypr/scripts/wallpapers/set.sh "$NEW_WALL"
