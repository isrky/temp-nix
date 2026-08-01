#!/usr/bin/env bash
# Toggle timewarrior work tracking (used by waybar custom/timew on-click)

if [ "$(timew get dom.active 2>/dev/null)" = "1" ]; then
    if timew stop; then
        notify-send -t 3000 "Timewarrior" "Stopped work tracking"
    else
        notify-send -u critical -t 5000 "Timewarrior" "Failed to stop tracking"
    fi
else
    # tag is "job" because timew's date parser swallows a bare "work" argument
    if timew start job; then
        notify-send -t 3000 "Timewarrior" "Started work tracking"
    else
        notify-send -u critical -t 5000 "Timewarrior" "Failed to start tracking"
    fi
fi
