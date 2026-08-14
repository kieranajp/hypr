#!/bin/bash
conf="$HOME/.config/hypr/monitors.conf"

choice=$(printf "Work\nPlay\nHDR On\nHDR Off\nFix HDMI" | wofi --dmenu --prompt "Session" --config ~/.config/wofi/config/config --style ~/.config/wofi/src/macchiato/style.css --width 200)

case "$choice" in
    Work)
        vivaldi-stable & mailspring --password-store="gnome-libsecret" --ozone-platform=x11 & slack & obsidian &
        kitty --title "AWS Login" -e bash -c 'aws sso login --profile lifesum/sandbox && aws sso login --profile lifesum/prod' &
        ;;
    Play) steam & discord & ;;
    "HDR On")
        sed -i -E 's/^(\s*)#+\s*cm\s*=\s*hdr/\1cm = hdr/' "$conf"
        hyprctl reload >/dev/null
        ;;
    "HDR Off")
        sed -i -E 's/^(\s*)#*\s*cm\s*=\s*hdr/\1#cm = hdr/' "$conf"
        hyprctl reload >/dev/null
        ;;
    "Fix HDMI")
        ~/.config/hypr/scripts/fix-hdmi.sh
        ;;
esac
