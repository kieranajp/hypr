--------------------
---- WORKSPACES ----
--------------------

-- See https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Bind workspace 10 (SUPER+0) to the HDMI monitor
hl.workspace_rule({
    workspace = "10",
    monitor   = "HDMI-A-1",
    default   = true,
})
