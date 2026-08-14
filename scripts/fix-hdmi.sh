#!/bin/bash
# `hyprctl keyword monitor ...` is hyprlang-flavoured; on a lua config the
# monitor gets set through hl.monitor() instead. Re-enabling is just a reload,
# so the real settings only live in monitors.lua.
echo -n "Disabling HDMI-A-1... "
hyprctl eval 'hl.monitor({ output = "HDMI-A-1", disabled = true })'
sleep 3
echo -n "Re-enabling HDMI-A-1... "
hyprctl reload
