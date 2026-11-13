#!/bin/bash
# Peripheral state as JSON for the DMS "peripherals" plugin (tools/dms-peripherals):
#   {"mouse": {...} | null, "pad": {...} | null}
# Razer mouse via OpenRazer sysfs; Wolverine V3 Pro via tools/wolverine-battery.

json_str() { printf '"%s"' "${1//\"/\\\"}"; }

# Mouse: OpenRazer charge_level is 0-255
mouse=null
dir=$(dirname "$(ls /sys/bus/hid/drivers/razermouse/*/charge_level 2>/dev/null | head -1)")
if [[ -r $dir/charge_level ]]; then
    raw=$(cat "$dir/charge_level" 2>/dev/null)
    pct=$(( ${raw:-0} * 100 / 255 ))
    charging=false; [[ $(cat "$dir/charge_status" 2>/dev/null) == 1 ]] && charging=true
    name=$(cat "$dir/device_type" 2>/dev/null); name=${name#Razer }; name=${name% (Receiver)}
    mouse="{\"name\":$(json_str "${name:-Mouse}"),\"pct\":$pct,\"charging\":$charging}"
fi

# Controller: the dongle's USB ID gives the mode. Battery and profile are only
# readable in PC mode (Fn+Menu+A); Xbox mode (Fn+Menu+X) has no HID interface.
pad=null
mode=""
for d in /sys/bus/usb/devices/*; do
    [[ $(cat "$d/idVendor" 2>/dev/null) == 1532 ]] || continue
    case $(cat "$d/idProduct" 2>/dev/null) in
        0a4c) mode=PC ;;
        0a3f) mode=Xbox ;;
    esac
done
if [[ -n $mode ]]; then
    pad="{\"name\":\"Wolverine V3 Pro\",\"mode\":\"$mode\",\"awake\":false}"
    wb="$HOME/.local/bin/wolverine-battery"
    if [[ $mode == PC ]] && c=$("$wb" 2>/dev/null); then
        pct=${c%%%*}
        charging=false; [[ $c == *charging* ]] && charging=true
        # Onboard profile 1-4, switched with Fn+A/B/X/Y on the pad
        case $("$wb" profile 2>/dev/null) in
            1) profile='"A"' ;; 2) profile='"B"' ;; 3) profile='"X"' ;; 4) profile='"Y"' ;; *) profile=null ;;
        esac
        pad="{\"name\":\"Wolverine V3 Pro\",\"mode\":\"PC\",\"awake\":true,\"pct\":$pct,\"charging\":$charging,\"profile\":$profile}"
    fi
fi

echo "{\"mouse\":$mouse,\"pad\":$pad}"
