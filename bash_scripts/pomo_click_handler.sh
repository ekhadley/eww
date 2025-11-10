#!/bin/bash



# args:
# $1 - timer id (1, 2, 3, ...)
# $2 - state (running, paused)
# $3 - duration  in seconds

# script does the same thing as this:
#:onclick "eww update pomo${id}_start=${current_time} pomo${id}_state=${state=='running' ? 'paused' : 'running'}"

if ["$1" == "running" ]; then
    current_time=$(date +%s)
    eww update "pomo${1}_start=${current_time}" "pomo${1}_state=paused"
else
    eww update "pomo${1}_state=running"
    duration_min= $3/60
    #/home/ek/.config/eww/scripts/pomo_show.sh | at now + $duration_min minutes
    /home/ek/.config/eww/scripts/pomo_show.sh | at now + $duration_min minutes
fi
