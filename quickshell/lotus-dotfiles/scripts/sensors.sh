#!/usr/bin/env bash
# Hardware temperature reader for Lotus Shell
# Outputs standard key-value format for SystemHealth.qml

cpu=0
gpu=0
drive=0

# 1. CPU temperature from /sys/class/hwmon
for h in /sys/class/hwmon/hwmon*; do
    [ -d "$h" ] || continue
    name=$(cat "$h/name" 2>/dev/null)
    case "$name" in
        coretemp|k10temp|zenpower|cpu_thermal)
            for t in "$h"/temp*_input; do
                [ -f "$t" ] || continue
                label=$(cat "${t%_input}_label" 2>/dev/null)
                v=$(cat "$t" 2>/dev/null)
                if [ -n "$v" ] && [ "$v" -gt 0 ] 2>/dev/null; then
                    if [ "$label" = "Package id 0" ] || [ "$label" = "Tctl" ] || [ "$cpu" = "0" ]; then
                        cpu=$(awk "BEGIN {printf \"%.1f\", $v/1000}")
                        [ "$label" = "Package id 0" ] || [ "$label" = "Tctl" ] && break
                    fi
                fi
            done
            [ "$cpu" != "0" ] && break
            ;;
    esac
done

# Fallback: CPU temperature from thermal zones
if [ "$cpu" = "0" ]; then
    for z in /sys/class/thermal/thermal_zone*; do
        [ -d "$z" ] || continue
        type=$(cat "$z/type" 2>/dev/null)
        case "$type" in
            *pkg_temp*|*cpu*|*x86_pkg_temp*|acpitz)
                v=$(cat "$z/temp" 2>/dev/null)
                if [ -n "$v" ] && [ "$v" -gt 0 ] 2>/dev/null; then
                    cpu=$(awk "BEGIN {printf \"%.1f\", $v/1000}")
                    break
                fi
                ;;
        esac
    done
fi

# 2. GPU temperature: NVIDIA -> AMD/Intel -> thermal zones
if command -v nvidia-smi >/dev/null 2>&1; then
    nv_temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null | head -n 1 | tr -d " \r\n")
    if [ -n "$nv_temp" ] && [ "$nv_temp" -gt 0 ] 2>/dev/null; then
        gpu="$nv_temp"
    fi
fi

if [ "$gpu" = "0" ]; then
    for h in /sys/class/hwmon/hwmon*; do
        [ -d "$h" ] || continue
        name=$(cat "$h/name" 2>/dev/null)
        case "$name" in
            amdgpu|nouveau|i915)
                for t in "$h"/temp*_input; do
                    [ -f "$t" ] || continue
                    v=$(cat "$t" 2>/dev/null)
                    if [ -n "$v" ] && [ "$v" -gt 0 ] 2>/dev/null; then
                        gpu=$(awk "BEGIN {printf \"%.1f\", $v/1000}")
                        break
                    fi
                done
                ;;
        esac
        [ "$gpu" != "0" ] && break
    done
fi

# 3. NVMe / Drive temperature
for h in /sys/class/hwmon/hwmon*; do
    [ -d "$h" ] || continue
    name=$(cat "$h/name" 2>/dev/null)
    if [ "$name" = "nvme" ] || [ "$name" = "drivetemp" ]; then
        for t in "$h"/temp*_input; do
            [ -f "$t" ] || continue
            label=$(cat "${t%_input}_label" 2>/dev/null)
            v=$(cat "$t" 2>/dev/null)
            if [ -n "$v" ] && [ "$v" -gt 0 ] 2>/dev/null; then
                if [ "$label" = "Composite" ] || [ "$label" = "Sensor 1" ] || [ "$drive" = "0" ]; then
                    drive=$(awk "BEGIN {printf \"%.1f\", $v/1000}")
                    [ "$label" = "Composite" ] && break 2
                fi
            fi
        done
    fi
done

echo "Tctl: +${cpu}°C"
echo "edge: +${gpu}°C"
echo "Composite: +${drive}°C"
