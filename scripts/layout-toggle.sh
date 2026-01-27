#!/bin/bash

# Toggle between grouped (tabbed) and ungrouped (tiled) windows
# Similar to sway's layout toggle tabbed/split

# Get current workspace ID
workspace_id=$(hyprctl activeworkspace -j | jq -r '.id')

# Get all window addresses on current workspace
windows=$(hyprctl clients -j | jq -r --arg ws "$workspace_id" '.[] | select(.workspace.id == ($ws | tonumber)) | .address')

# Count windows
window_count=$(echo "$windows" | wc -l)

# Check if any window is already grouped
is_grouped=$(hyprctl clients -j | jq -r --arg ws "$workspace_id" '.[] | select(.workspace.id == ($ws | tonumber)) | .grouped | length > 0' | grep -q "true" && echo "true" || echo "false")

if [ "$is_grouped" = "false" ]; then
    # Group all windows (enter tabbed mode)

    # Create group with first window
    first_window=$(echo "$windows" | head -n1)
    hyprctl dispatch focuswindow "address:$first_window"
    hyprctl dispatch togglegroup

    # Add each remaining window by trying all directions
    for window in $(echo "$windows" | tail -n +2); do
        hyprctl dispatch focuswindow "address:$window"

        # Try each direction until one works
        for direction in l r u d; do
            hyprctl dispatch moveintogroup $direction 2>/dev/null

            # Check if window is now grouped
            is_now_grouped=$(hyprctl clients -j | jq -r --arg addr "$window" '.[] | select(.address == $addr) | .grouped | length > 0')
            if [ "$is_now_grouped" = "true" ]; then
                break
            fi
        done
    done

    notify-send -t 1000 "Layout" "Grouped (Tabbed)" 2>/dev/null || true
else
    # Ungroup all windows (return to tiled mode)

    for window in $windows; do
        hyprctl dispatch focuswindow "address:$window"
        hyprctl dispatch moveoutofgroup
    done

    notify-send -t 1000 "Layout" "Ungrouped (Tiled)" 2>/dev/null || true
fi
