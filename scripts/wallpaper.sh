#!/usr/bin/env bash
set -euo pipefail

img="${1:?usage: wallpaper.sh <image>}"

pkill -x swaybg || true
swaybg -m fill -i "$img" &
disown
