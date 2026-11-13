#!/bin/bash
# Razer mouse battery via OpenRazer sysfs, as plain text for the DMS bar
# (Interval Command plugin). charge_level is 0-255.
dir=$(dirname "$(ls /sys/bus/hid/drivers/razermouse/*/charge_level 2>/dev/null | head -1)")
if [[ ! -r $dir/charge_level ]]; then
    echo "–"
    exit 0
fi
raw=$(cat "$dir/charge_level" 2>/dev/null)
charging=$(cat "$dir/charge_status" 2>/dev/null)
pct=$(( ${raw:-0} * 100 / 255 ))
bolt=""
[[ $charging == 1 ]] && bolt=" 󱐋"
echo "${pct}%${bolt}"
