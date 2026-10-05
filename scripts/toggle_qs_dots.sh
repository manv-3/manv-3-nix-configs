#!/usr/bin/env bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  toggle_qs_dots.sh — Switch Quickshell Dots via Rofi / Cycle
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

QS_BASE="$HOME/.config/quickshell"
HYPR_QS="$HOME/.config/hypr/scripts/quickshell"

# ─── 1. Detect Currently Active Dot ───────────────────────
get_active_dot() {
    if pgrep -f "ryoku/shell/ipc/ryoku-shell" >/dev/null 2>&1; then
        echo "ryoku"
    elif pgrep -f "(quickshell|qs)[[:space:]].*/macos(/|[[:space:]]|$)" >/dev/null 2>&1; then
        echo "macos"
    elif pgrep -f "(quickshell|qs)[[:space:]].*/ii(/|[[:space:]]|$)" >/dev/null 2>&1; then
        echo "ii"
    elif pgrep -f "(quickshell|qs)[[:space:]].*/k4(/|[[:space:]]|$)" >/dev/null 2>&1; then
        echo "k4"
    else
        for dir in "$QS_BASE"/*/; do
            [[ -d "$dir" && -f "$dir/shell.qml" ]] || continue
            local dot_name
            dot_name=$(basename "$dir")
            if pgrep -f "(quickshell|qs)[[:space:]].*/$dot_name(/|[[:space:]]|$)" >/dev/null 2>&1; then
                echo "$dot_name"
                return
            fi
        done
        if pgrep -f "(quickshell|qs)[[:space:]].*(Main|TopBar)\.qml" >/dev/null 2>&1; then
            echo "default"
        else
            echo "none"
        fi
    fi
}

# ─── 2. Stop All Quickshell Instances ─────────────────────
stop_all_quickshell() {
    pkill -9 -f "ryoku/shell/ipc/ryoku-shell" 2>/dev/null || true
    pkill -9 -f "k4/arrancar" 2>/dev/null || true
    pkill -9 -f "k4/tools" 2>/dev/null || true
    pkill -9 -f "quickshell -p" 2>/dev/null || true
    pkill -9 -f "quickshell -c" 2>/dev/null || true
    pkill -9 -f "qs -p" 2>/dev/null || true
    pkill -9 -f "qs -c" 2>/dev/null || true
    pkill -9 -x "quickshell" 2>/dev/null || true

    for _ in $(seq 1 10); do
        pgrep -x "quickshell" >/dev/null 2>&1 || break
        sleep 0.1
    done
}

# ─── 3. Start Specific Dot ────────────────────────────────
start_dot() {
    local target="$1"
    stop_all_quickshell

    local QT_EXTRA_QML="/run/current-system/sw/lib/qt-6/qml:/nix/store/dacgzrsxd134ypb0yk6pbhm6y3p0z6i9-qt5compat-6.11.1/lib/qt-6/qml:/nix/store/g6c6y99aq0fvcfbshcvfkngxy8fzv6y7-qtpositioning-6.11.1/lib/qt-6/qml:/nix/store/7k8r8fg48qhkv1ifg2s80jv6s3bw58kh-qtmultimedia-6.11.1/lib/qt-6/qml:/nix/store/l0rvyx8ih3bx5iyj7459y234nvq9qqf1-syntax-highlighting-6.26.0/lib/qt-6/qml:/nix/store/fpzffzmvbr6xwdsgwk3nmykf41ah8ahv-kirigami-6.26.0/lib/qt-6/qml"

    if [[ "$target" == "default" ]]; then
        if [[ -f "$HYPR_QS/Main.qml" ]]; then
            setsid -f quickshell -p "$HYPR_QS/Main.qml" >/dev/null 2>&1
        fi
        if [[ -f "$HYPR_QS/TopBar.qml" ]]; then
            setsid -f quickshell -p "$HYPR_QS/TopBar.qml" >/dev/null 2>&1
        fi
    elif [[ "$target" == "macos" ]]; then
        setsid -f bash -c "QML2_IMPORT_PATH=\"$QT_EXTRA_QML:\$QML2_IMPORT_PATH\" quickshell -p $QS_BASE/macos/shell.qml" >"$HOME/macos.log" 2>&1
        setsid -f "$QS_BASE/k4/arrancar" >/tmp/k4.log 2>&1
    elif [[ "$target" == "ii" ]]; then
        setsid -f bash -c "QML2_IMPORT_PATH=\"$QT_EXTRA_QML:\$QML2_IMPORT_PATH\" qs -p $QS_BASE/ii" >/tmp/ii.log 2>&1
    elif [[ "$target" == "k4" ]]; then
        setsid -f "$QS_BASE/k4/arrancar" >/tmp/k4.log 2>&1
    elif [[ "$target" == "ryoku" ]]; then
        setsid -f bash -c "$QS_BASE/ryoku/launch.sh" >/dev/null 2>&1
    elif [[ -d "$QS_BASE/$target" ]]; then
        if [[ -f "$QS_BASE/$target/shell.qml" ]]; then
            local import_path="$QT_EXTRA_QML"
            if [[ -d "$QS_BASE/$target/build/qml" ]]; then
                import_path="$QS_BASE/$target/build/qml:$import_path"
            elif [[ -d "$QS_BASE/$target/api" ]]; then
                import_path="$QS_BASE/$target/api:$import_path"
            fi
            setsid -f bash -c "LOTUS_NOTIFICATION_SERVER=1 QML2_IMPORT_PATH=\"$import_path:\$QML2_IMPORT_PATH\" quickshell -p $QS_BASE/$target/shell.qml" >"$HOME/${target}.log" 2>&1
        fi
    fi
}

# ─── 4. List All Available Dots ───────────────────────────
get_available_dots() {
    local dots=("default")
    for d in "$QS_BASE"/*/; do
        if [[ -d "$d" && -f "$d/shell.qml" ]]; then
            local bname
            bname=$(basename "$d")
            # Exclude shells incompatible with Hyprland or missing required C++ plugins
            if [[ "$bname" != "imported-1789667132" && "$bname" != "vast-shell" && "$bname" != "ryoku" ]]; then
                dots+=("$bname")
            fi
        fi
    done
    echo "${dots[@]}"
}

# ─── 5. Cycle Mode (--next) ───────────────────────────────
cycle_next() {
    local active
    active=$(get_active_dot)
    read -ra dots_list <<< "$(get_available_dots)"

    local current_idx=-1
    for i in "${!dots_list[@]}"; do
        if [[ "${dots_list[$i]}" == "$active" ]]; then
            current_idx=$i
            break
        fi
    done

    local next_idx=$(( (current_idx + 1) % ${#dots_list[@]} ))
    local next_dot="${dots_list[$next_idx]}"
    start_dot "$next_dot"
}

# ─── 6. Rofi Selector Mode ────────────────────────────────
show_rofi_menu() {
    if pgrep -x "rofi" > /dev/null; then
        pkill rofi
        exit 0
    fi

    local active
    active=$(get_active_dot)
    read -ra dots_list <<< "$(get_available_dots)"

    local options=""
    for dot in "${dots_list[@]}"; do
        local label=""
        case "$dot" in
            default)            label="default            │ ⚙️ Default (System Shell)" ;;
            macos)              label="macos              │ 🍎 macOS + 🏝️ k4 Dynamic Island" ;;
            ii)                 label="ii                 │ 🪟 ii (Windows 11 Waffle)" ;;
            k4)                 label="k4                 │ 🏝️ k4 (Dynamic Island)" ;;
            end4-pc)            label="end4-pc            │ 💎 End4 Dots (Hyprland Shell)" ;;
            lotus-dotfiles)     label="lotus-dotfiles     │ 🪷 Lotus Minimal Shell" ;;
            lucid)              label="lucid              │ 🫧 Lucid Glass Shell" ;;
            cartoon-shell)      label="cartoon-shell      │ 🎨 Cartoon Cyber Shell" ;;
            synoptik)           label="synoptik           │ 📊 Synoptik Dashboard Shell" ;;
            nibrasshell)        label="nibrasshell        │ 🌌 Nibras Futuristic Shell" ;;
            11)                 label="11                 │ 🖥️ Windows 11 Shell" ;;
            macduo)             label="macduo             │ 🍏 macOS Duo Shell" ;;
            hyprland-minions)   label="hyprland-minions   │ 👾 Minions Dynamic Island" ;;
            zesis)              label="zesis              │ 🪐 Zesis Celestial Shell" ;;
            Q1)                 label="Q1                 │ ⚡ Q1 Quick Bar" ;;
            persona-quickshell) label="persona-quickshell │ 🎭 Persona 5 Shell" ;;
            *)                  label="$dot              │ 🎨 $dot" ;;
        esac

        if [[ "$dot" == "$active" ]]; then
            options+="$label  ✔ [Active]\n"
        else
            options+="$label\n"
        fi
    done
    options+="stop     │ ❌ Stop Quickshell"

    local selected
    selected=$(echo -e "$options" | rofi -dmenu \
        -p "Quickshell Dots" \
        -config "$HOME/.config/rofi/config.rasi" \
        -theme-str 'listview { columns: 1; lines: 10; spacing: 4px; }' \
        -theme-str 'element { orientation: horizontal; padding: 8px 12px; }' \
        -theme-str 'element-text { enabled: true; vertical-align: 0.5; font: "Inter DemiBold 12"; }' \
        -theme-str 'element-icon { enabled: false; }' \
        || true)

    if [[ -z "$selected" ]]; then
        exit 0
    fi

    local chosen_key
    chosen_key=$(echo "$selected" | awk '{print $1}')

    if [[ "$chosen_key" == "stop" ]]; then
        stop_all_quickshell
        exit 0
    fi

    if [[ -n "$chosen_key" ]]; then
        start_dot "$chosen_key"
    fi
}

# ─── Main Switcher ────────────────────────────────────────
case "${1:-menu}" in
    --active|-a|status) get_active_dot ;;
    --list|-l|list) get_available_dots ;;
    --next|-n) cycle_next ;;
    --menu|-m|menu) show_rofi_menu ;;
    *) start_dot "$1" ;;
esac
