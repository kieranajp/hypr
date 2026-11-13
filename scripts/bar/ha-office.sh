#!/bin/bash
# Office temperature/humidity from Home Assistant, as plain text for the DMS
# bar (Interval Command plugin, which shows the first line of stdout).
# Outside weather is DMS's own weather widget.
#
# Token lives outside this repo: ~/.config/dms/ha_token (mode 600).

HA_URL="https://homeassistant.kieranajp.uk"
HA_TOKEN="$(cat ~/.config/dms/ha_token 2>/dev/null)"

fetch() {
    curl -sf --max-time 5 -H "Authorization: Bearer $HA_TOKEN" "$HA_URL/api/states/$1" | jq -r '.state'
}

temp=$(fetch sensor.office_sensor_temperature)
hum=$(fetch sensor.office_sensor_humidity)

if [[ -z "$temp" || -z "$hum" || "$temp" == "null" || "$hum" == "null" ]]; then
    echo "—"
    exit 0
fi

printf '%.0f°C / %.0f%%\n' "$temp" "$hum"
