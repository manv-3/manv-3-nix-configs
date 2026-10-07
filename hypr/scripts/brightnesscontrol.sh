#!/usr/bin/env bash
# Brightness controller for Hyprland and Lotus Shell
# Supports get, set <0-100>, or relative +5% / -5%

case "$1" in
    get)
        if command -v brightnessctl >/dev/null 2>&1; then
            pct=$(brightnessctl -m 2>/dev/null | cut -d, -f4 | tr -d '%')
            if [ -n "$pct" ]; then
                echo "$pct"
                exit 0
            fi
        fi
        # Fallback to sysfs directly
        for bl in /sys/class/backlight/*; do
            if [ -f "$bl/brightness" ] && [ -f "$bl/max_brightness" ]; then
                cur=$(cat "$bl/brightness" 2>/dev/null)
                max=$(cat "$bl/max_brightness" 2>/dev/null)
                if [ -n "$cur" ] && [ -n "$max" ] && [ "$max" -gt 0 ]; then
                    awk "BEGIN {printf \"%d\", ($cur * 100) / $max}"
                    echo ""
                    exit 0
                fi
            fi
        done
        echo "50"
        ;;
    set)
        val="$2"
        # Strip trailing % if supplied
        val="${val%\%}"
        if command -v brightnessctl >/dev/null 2>&1; then
            brightnessctl set "${val}%" >/dev/null 2>&1
        fi
        ;;
    *)
        echo "Usage: $0 {get|set <0-100>}"
        exit 1
        ;;
esac
