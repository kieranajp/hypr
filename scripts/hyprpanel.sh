#!/bin/sh

# Launch hyprpanel with its workspace buttons patched for the lua config.
#
# hyprpanel's workspace buttons send the legacy IPC call `dispatch workspace N`.
# On a lua config Hyprland wraps dispatch payloads as `return hl.dispatch(...)`
# and evaluates them, so that string dies as a syntax error and clicking a
# workspace in the bar silently does nothing. Same trap as layout-toggle.sh and
# fix-hdmi.sh, just buried in a vendored bundle instead of our own scripts.
#
# hyprpanel ships as a base64 blob inside a shell launcher, so: extract it,
# rewrite the two call sites to the lua form, hand the result to gjs.
#
# Delete this once hyprpanel or Hyprland grows lua-aware dispatch.

APP=/usr/share/hyprpanel/hyprpanel-app

# Mirror /usr/bin/hyprpanel: with args we're the astal client, not the panel.
if [ "$#" -gt 0 ]; then
    exec astal -i hyprpanel "$*"
fi

out="${XDG_RUNTIME_DIR:-/tmp}/hyprpanel-lua-ags.js"

awk '/^\/bin\/cat <<EOF/{f=1;next} /^EOF$/{f=0} f' "$APP" | base64 --decode > "$out" || exit 1

before=$(grep -c 'dispatch("workspace"' "$out")
sed -i 's/\.dispatch("workspace", \([A-Za-z_][A-Za-z0-9_]*\)\.toString())/.dispatch("hl.dsp.focus({ workspace = " + \1 + " })", "")/g' "$out"
after=$(grep -c 'dispatch("workspace"' "$out")

# Shout if an upstream update reshapes the call sites, rather than silently
# regressing to dead workspace buttons.
[ "$after" -eq 0 ] || echo "hyprpanel.sh: patched $((before - after))/$before dispatch sites, $after left" >&2

exec env LD_PRELOAD="" gjs -m "$out"
