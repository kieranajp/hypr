---------------------
---- KEYBINDINGS ----
---------------------

-- See https://wiki.hypr.land/Configuring/Basics/Binds/

local p = require("vars")

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

hl.bind(mainMod .. " + Return",         hl.dsp.exec_cmd(p.terminal))
hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.exec_cmd(p.browser))
hl.bind(mainMod .. " + Q",              hl.dsp.window.close())
hl.bind(mainMod .. " + M",              hl.dsp.exit())
hl.bind(mainMod .. " + SHIFT + R",      hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mainMod .. " + E",              hl.dsp.exec_cmd(p.file_manager))
hl.bind(mainMod .. " + V",              hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + D",              hl.dsp.exec_cmd(p.menu))
hl.bind(mainMod .. " + SHIFT + D",      hl.dsp.exec_cmd("wofi-emoji"))
hl.bind(mainMod .. " + P",              hl.dsp.window.pseudo())

-- Layout management (sway muscle memory)
hl.bind(mainMod .. " + F",         hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mainMod .. " + T",         hl.dsp.exec_cmd("~/.config/hypr/scripts/layout-toggle.sh"))
hl.bind(mainMod .. " + TAB",         hl.dsp.group.next())
hl.bind(mainMod .. " + SHIFT + TAB", hl.dsp.group.prev())
hl.bind(mainMod .. " + SHIFT + G",   hl.dsp.window.move({ out_of_group = true }))

-- Move focus (hjkl)
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "d" }))

-- Move windows
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.move({ direction = "d" }))

-- Move workspace between monitors (sway muscle memory)
hl.bind(mainMod .. " + CTRL + SHIFT + h", hl.dsp.workspace.move({ monitor = "l" }))
hl.bind(mainMod .. " + CTRL + SHIFT + l", hl.dsp.workspace.move({ monitor = "r" }))
hl.bind(mainMod .. " + CTRL + SHIFT + k", hl.dsp.workspace.move({ monitor = "u" }))
hl.bind(mainMod .. " + CTRL + SHIFT + j", hl.dsp.workspace.move({ monitor = "d" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
-- hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
-- hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Screenshots
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd(
    "hyprshot --freeze --mode=region --raw --clipboard-only | satty -f - --copy-command 'wl-copy'"))

-- Launch work/play session
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("~/.config/hypr/scripts/session-launcher.sh"))

-- Multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
