#!/bin/bash
echo -n "Disabling HDMI-A-1... "
hyprctl keyword monitor "HDMI-A-1,disable"
sleep 3
echo -n "Re-enabling HDMI-A-1... "
hyprctl keyword monitor "HDMI-A-1,3840x2160@60,1920x0,2"
