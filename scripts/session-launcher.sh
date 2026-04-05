#!/bin/bash
choice=$(printf "Work\nPlay" | wofi --dmenu --prompt "Session" --config ~/.config/wofi/config/config --style ~/.config/wofi/src/macchiato/style.css --width 200)

case "$choice" in
    Work)
        vivaldi-stable & mailspring --password-store="gnome-libsecret" --ozone-platform=x11 & slack &
        kitty --title "AWS Login" -e bash -c 'aws sso login --profile lifesum/sandbox && aws sso login --profile lifesum/prod' &
        ;;
    Play) steam & discord & ;;
esac
