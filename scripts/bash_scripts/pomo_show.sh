#!/bin/bash

active_screen=$(hyprctl -j activeworkspace | jq -r '.monitorID')
echo "$active_screen"
eww open pomo_window --screen "$active_screen"
