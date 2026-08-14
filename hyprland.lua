-- Hyprland configuration
-- https://wiki.hypr.land/Configuring/

-- Modular configuration. `require` resolves relative to this directory, and
-- each module is loaded once - colours.lua and vars.lua return tables that
-- appearance.lua and keybinds.lua pull in themselves.

require("colours")
require("vars")
require("monitors")
require("startup")
require("appearance")
require("input")
require("keybinds")
require("workspaces")
require("rules")
