#!/bin/sh
# Split a wallpaper across monitors using hyprctl monitor info + ImageMagick, then set via swaybg
IMG="${1:?Usage: wallpaper.sh <image>}"
CACHE_DIR="$HOME/.cache/hypr-wallpaper"
mkdir -p "$CACHE_DIR"

killall swaybg 2>/dev/null

# Get monitor info from hyprctl (name, width, height, x, y, scale)
hyprctl monitors -j | python3 -c "
import json, sys, subprocess, os

img = '$IMG'
cache = '$CACHE_DIR'
monitors = json.load(sys.stdin)

# Sort by x position
monitors.sort(key=lambda m: m['x'])

# Total virtual canvas size
total_w = max(m['x'] + int(m['width'] / m['scale']) for m in monitors)
total_h = max(m['y'] + int(m['height'] / m['scale']) for m in monitors)

# Get image dimensions
result = subprocess.run(['identify', '-format', '%w %h', img], capture_output=True, text=True)
img_w, img_h = map(int, result.stdout.strip().split())

# Scale image to cover the virtual canvas
scale = max(total_w / img_w, total_h / img_h)
scaled_w = int(img_w * scale)
scaled_h = int(img_h * scale)
offset_x = (scaled_w - total_w) // 2
offset_y = (scaled_h - total_h) // 2

swaybg_args = []
for m in monitors:
    ew = int(m['width'] / m['scale'])
    eh = int(m['height'] / m['scale'])
    # Crop region in scaled image space
    cx = m['x'] + offset_x
    cy = m['y'] + offset_y
    frag = os.path.join(cache, f'{m[\"name\"]}.png')
    subprocess.run([
        'magick', img,
        '-resize', f'{scaled_w}x{scaled_h}!',
        '-crop', f'{ew}x{eh}+{cx}+{cy}',
        '+repage', frag
    ], check=True)
    swaybg_args += ['-o', m['name'], '-i', frag, '-m', 'fill']

subprocess.Popen(['swaybg'] + swaybg_args)
"
