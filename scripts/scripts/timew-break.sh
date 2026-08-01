#!/usr/bin/env bash
# Switch between work and off-work tracking (waybar custom/timew right-click)

if [ "$(timew get dom.active 2>/dev/null)" != "1" ]; then
    notify-send -t 3000 "Timewarrior" "Not tracking — clock in first (left-click)"
    exit 0
fi

if [ "$(timew get dom.active.tag.1 2>/dev/null)" = "off" ]; then
    # tag is "job" because timew's date parser swallows a bare "work" argument
    if timew start job; then
        notify-send -t 3000 "Timewarrior" "Back to work"
    else
        notify-send -u critical -t 5000 "Timewarrior" "Failed to resume work tracking"
    fi
else
    if timew start off; then
        notify-send -t 3000 "Timewarrior" "Break started"
    else
        notify-send -u critical -t 5000 "Timewarrior" "Failed to start break"
    fi
fi
