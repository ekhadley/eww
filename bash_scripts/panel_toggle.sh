#!/bin/bash

active_screen=$(hyprctl -j activeworkspace | jq -r '.monitorID')

system_info_str=$(fastfetch -c /home/ek/.config/eww/panel/fastfetch-config.jsonc)
echo $system_info_str
eww update system_info_str="$system_info_str"
# eww update system_info_str="abc123"
eww open --toggle panel_window --screen "$active_screen"
