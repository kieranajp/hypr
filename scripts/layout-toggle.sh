#!/bin/bash

# Toggle between grouped (tabbed) and ungrouped (tiled) windows
# Similar to sway's layout toggle tabbed/split
#
# Hyprland 0.55+ runs a lua config, so `hyprctl dispatch <name> <args>` no
# longer parses. The whole thing now goes through one `hyprctl eval` chunk,
# which also gets rid of the jq round-trips.

hyprctl eval '
local ws = hl.get_active_workspace()
if not ws then return "no active workspace" end

local windows = hl.get_workspace_windows(ws)
if #windows == 0 then return "no windows" end

local grouped = false
for _, w in ipairs(windows) do
    if w.group then grouped = true break end
end

if grouped then
    -- Ungroup all windows (return to tiled mode)
    for _, w in ipairs(windows) do
        hl.dispatch(hl.dsp.window.move({ out_of_group = true, window = w }))
    end
    hl.exec_cmd("notify-send -t 1000 Layout \"Ungrouped (Tiled)\"")
else
    -- Group all windows (enter tabbed mode)
    hl.dispatch(hl.dsp.group.toggle({ window = windows[1] }))

    -- Try each direction until one takes, same as the old shell version
    for i = 2, #windows do
        local w = windows[i]
        for _, dir in ipairs({ "l", "r", "u", "d" }) do
            hl.dispatch(hl.dsp.window.move({ into_group = dir, window = w }))
            if w.group then break end
        end
    end
    hl.exec_cmd("notify-send -t 1000 Layout \"Grouped (Tabbed)\"")
end
'
