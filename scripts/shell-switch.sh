#!/bin/bash

# Swap the running desktop shell between hyprpanel and dms (dux-shell).
#
#   shell-switch.sh            toggle
#   shell-switch.sh dms        switch to dms
#   shell-switch.sh hyprpanel  switch to hyprpanel
#
# Writes the choice to ~/.config/hypr/shell (read by shell.lua), stops the old
# shell's processes, reloads Hyprland so the shell-specific binds swap, then
# starts the new shell. Keep stop_* in sync with the `start` lists in shell.lua.

set -u

state="$HOME/.config/hypr/shell"
current=$(awk 'NR==1{print $1}' "$state" 2>/dev/null)
current=${current:-hyprpanel}

case "${1:-toggle}" in
    toggle) [ "$current" = dms ] && target=hyprpanel || target=dms ;;
    dms|hyprpanel) target=$1 ;;
    *) echo "usage: $0 [dms|hyprpanel|toggle]" >&2; exit 2 ;;
esac

if [ "$target" = dms ] && ! command -v dms >/dev/null; then
    notify-send -u critical "Shell" "dms not installed (pacman -S dux-shell)"
    exit 1
fi

stop_hyprpanel() {
    pkill -f hyprpanel-lua-ags.js
    pkill -f /usr/share/hyprpanel/scripts/   # bluetooth.py etc; outlive the panel otherwise
    pkill -x swaybg
    pkill -f polkit-gnome-authentication-agent-1
}

stop_dms() {
    pkill -f 'dms run'
    pkill -x quickshell
    pkill -x qs
}

# Stop both: cheap, and cleans up after a half-finished previous switch.
stop_hyprpanel
stop_dms

# Wait for the notification daemon / tray D-Bus names to be released,
# otherwise the new shell can lose the race and start without them.
for _ in $(seq 20); do
    pgrep -f 'hyprpanel-lua-ags.js|dms run' >/dev/null || pgrep -x quickshell >/dev/null || break
    sleep 0.1
done

echo "$target" > "$state"
hyprctl reload >/dev/null

# kitty colours follow the shell: Macchiato under hyprpanel, DMS's generated
# theme under dms. SIGUSR1 makes running kitties reload their config.
case "$target" in
    hyprpanel) ln -sfn current-theme.conf "$HOME/.config/kitty/shell-theme.conf" ;;
    dms)       ln -sfn dms-theme.conf     "$HOME/.config/kitty/shell-theme.conf" ;;
esac
pkill -USR1 -x kitty

# Start via Hyprland so the shell isn't a child of whatever ran this script.
# Mirrors the `start` lists in shell.lua.
case "$target" in
    hyprpanel)
        hyprctl eval 'hl.exec_cmd("~/.config/hypr/scripts/hyprpanel.sh")
                      hl.exec_cmd("~/.config/hypr/wallpaper.sh ~/Pictures/Walls/veil-nebula-purple.jpg")
                      hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")' >/dev/null
        ;;
    dms)
        hyprctl eval 'hl.exec_cmd("dms run")' >/dev/null
        ;;
esac

# Notify once the new shell has claimed the notifications D-Bus name.
(
    for _ in $(seq 50); do
        busctl --user status org.freedesktop.Notifications >/dev/null 2>&1 && break
        sleep 0.2
    done
    notify-send -h boolean:suppress-sound:true -t 1500 "Shell" "Switched to $target"
) &
