#!/usr/bin/env bash
# Toggle meeting mode: while the flag exists, timew-aw-bridge takes no actions
# (protects off-computer work like meetings from AFK auto-break)

flag="${XDG_RUNTIME_DIR:-/tmp}/timew-meeting"
if [ -e "$flag" ]; then
    rm -f "$flag"
    notify-send -t 5000 "Timewarrior" "Meeting mode OFF — AFK automation resumed"
else
    touch "$flag"
    notify-send -t 5000 "Timewarrior" "Meeting mode ON — AFK automation paused"
fi
