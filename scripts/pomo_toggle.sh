#!/bin/bash

active_screen=$(hyprctl -j activeworkspace | jq -r '.monitorID')
eww open --toggle pomo_window --screen "$active_screen"
