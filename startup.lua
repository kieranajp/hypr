-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
-- The `hyprland.start` event is the replacement for exec-once: it fires on
-- startup only, not on config reload.

local dms = require("dms")

hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE DISPLAY HYPRLAND_INSTANCE_SIGNATURE")
    for _, cmd in ipairs(dms.start) do
        hl.exec_cmd(cmd)
    end
    hl.exec_cmd("hypridle")
    hl.exec_cmd("music-assistant-companion") -- lands on special:music, see rules.lua
    hl.exec_cmd("systemctl --user start graphical-session.target")
    hl.exec_cmd("liquidctl --match Kraken set lcd screen orientation 270 && liquidctl --match Kraken set lcd screen liquid")
end)

---------------------
---- PERMISSIONS ----
---------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
-- Permission changes require a Hyprland restart and are not applied
-- on-the-fly, for security reasons.

-- hl.config({
--     ecosystem = {
--         enforce_permissions = true,
--     },
-- })

-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")
