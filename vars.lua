-- Programs and environment variables.
-- Returns the program table; requiring this file also applies the env vars.

---------------------
---- MY PROGRAMS ----
---------------------

local M = {
    terminal     = "kitty",
    browser      = "vivaldi",
    file_manager = "nemo",
    menu         = "wofi --config ~/.config/wofi/config/config"
                .. " --style ~/.config/wofi/src/macchiato/style.css --show drun",
}

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("GDK_SCALE", "2")
-- hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_ENABLE_HIGHDPI_SCALING", "1")
hl.env("GTK_THEME", "catppuccin-macchiato-teal-standard+default:dark")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("SSH_AUTH_SOCK", os.getenv("XDG_RUNTIME_DIR") .. "/ssh-agent.socket")

return M
