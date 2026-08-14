--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- Ignore maximize requests from apps. You'll probably like this.
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Slack always on workspace 10 (HDMI monitor)
hl.window_rule({
    name  = "slack-to-hdmi",
    match = { class = "^(slack|Slack)$" },

    workspace = 10,
})

-- Vivaldi on workspace 2
hl.window_rule({
    name  = "vivaldi-ws2",
    match = { class = "^(vivaldi-stable)$" },

    workspace = 2,
})

-- Mailspring on workspace 9
hl.window_rule({
    name  = "mailspring-ws9",
    match = { class = "^(Mailspring)$" },

    workspace = 9,
})

-- Steam on workspace 9
hl.window_rule({
    name  = "steam-ws9",
    match = { class = "^(steam)$" },

    workspace = 9,
})

-- Discord on workspace 10
hl.window_rule({
    name  = "discord-ws10",
    match = { class = "^(discord)$" },

    workspace = 10,
})

-- Wispr Flow status bar: the surface is 440x320 but almost entirely
-- transparent - only a small pill at the bottom is real. Blur/shadow/rounding
-- were painting the whole empty box, hence the "giant thing in the middle".
hl.window_rule({
    name  = "wispr-flow-bar",
    match = {
        class = "^(wispr-flow)$",
        title = "^(Status)$",
    },

    -- float must come before pin - pin is rejected on a tiled window
    float       = true,
    no_blur     = true,
    no_shadow   = true,
    no_anim     = true,
    border_size = 0,
    rounding    = 0,
    no_focus    = true,
    pin         = true,

    -- The pill is bottom-anchored: it sits ~23px above the surface's bottom
    -- edge. So to land it 8px from the top of the screen the window itself has
    -- to hang mostly offscreen above it, hence 8+23-window_h. Hyprland allows
    -- the negative Y without clamping.
    move = "(monitor_w-window_w)/2 31-window_h",
})

-- Obsidian on workspace 6
hl.window_rule({
    name  = "obsidian-ws6",
    match = { class = "^(obsidian)$" },

    workspace = 6,
})
