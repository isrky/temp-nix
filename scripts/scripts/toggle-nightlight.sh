#!/usr/bin/env bash

# hyprctl hyprsunset temperature keeps reporting the last-set value after
# identity is applied, so track on/off state ourselves
STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/nightlight-state"

get_default_state() {
    # mirror the hyprsunset schedule: 3500K between 21:00 and 6:30
    local now
    now=$(date +%H%M)
    if [ "$now" -ge 2100 ] || [ "$now" -lt 0630 ]; then
        echo on
    else
        echo off
    fi
}

state=$(cat "$STATE_FILE" 2>/dev/null || get_default_state)

if [ "$state" = "on" ]; then
    hyprctl hyprsunset identity
    echo off > "$STATE_FILE"
    notify-send -t 2000 "Night light" "Disabled"
else
    hyprctl hyprsunset temperature 3500
    echo on > "$STATE_FILE"
    notify-send -t 2000 "Night light" "Enabled (3500K)"
fi
