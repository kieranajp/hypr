#!/bin/bash
# Peripheral batteries as one line of plain text for the DMS bar (Interval
# Command plugin): Razer mouse via OpenRazer sysfs, Wolverine V3 Pro via
# tools/wolverine-battery when its dongle is in PC mode and the pad is awake.
# Anything absent is left out; prints "–" if nothing is found.

parts=()

# Mouse: OpenRazer charge_level is 0-255
dir=$(dirname "$(ls /sys/bus/hid/drivers/razermouse/*/charge_level 2>/dev/null | head -1)")
if [[ -r $dir/charge_level ]]; then
    raw=$(cat "$dir/charge_level" 2>/dev/null)
    m="󰍽 $(( ${raw:-0} * 100 / 255 ))%"
    [[ $(cat "$dir/charge_status" 2>/dev/null) == 1 ]] && m+=" 󱐋"
    parts+=("$m")
fi

# Controller: the dongle's USB ID gives the mode. Battery is only readable in
# PC mode (Function+Menu+A); Xbox mode (Function+Menu+X) has no HID interface.
mode=""
for d in /sys/bus/usb/devices/*; do
    [[ $(cat "$d/idVendor" 2>/dev/null) == 1532 ]] || continue
    case $(cat "$d/idProduct" 2>/dev/null) in
        0a4c) mode=PC ;;
        0a3f) mode=Xbox ;;
    esac
done
if [[ $mode == PC ]]; then
    if c=$("$HOME/.local/bin/wolverine-battery" 2>/dev/null); then
        parts+=("󰊴 PC ${c/ charging/ 󱐋}")
    else
        parts+=("󰊴 PC")   # dongle present, pad asleep/off or no permission
    fi
elif [[ $mode == Xbox ]]; then
    parts+=("󰊴 Xbox")
fi

if (( ${#parts[@]} )); then
    out="${parts[0]}"; for p in "${parts[@]:1}"; do out+="   $p"; done; echo "$out"
else
    echo "–"
fi
