#!/usr/bin/env bash
set -euo pipefail

# Catppuccin Macchiato: teal -> mauve (saturated so the LEDs don't wash out)
TEAL="00ffd9"
MAUVE="7c00ff"

liquidctl initialize all

liquidctl --match "Smart Device" set sync color breathing "$TEAL" "$MAUVE"
liquidctl --match "Fusion" set sync color fixed "$MAUVE"
