#!/usr/bin/env bash
# Retag the last auto-break (open or closed) from off back to job —
# for when AFK automation misfiled off-computer work (meeting etc.)

state_dir="${XDG_RUNTIME_DIR:-/tmp}"
marker="$state_dir/timew-aw-autobreak"
last_break="$state_dir/timew-aw-lastbreak"

retag() { # $1 = @id
    if timew untag "$1" off :yes >/dev/null 2>&1 &&
        timew tag "$1" job :yes >/dev/null 2>&1; then
        notify-send -t 5000 "Timewarrior" "Break reclassified as work"
    else
        notify-send -u critical "Timewarrior" "Failed to retag interval $1"
    fi
}

if [ -e "$marker" ]; then # auto-break still open -> it is @1
    retag @1
    rm -f "$marker" # now plain job; the bridge handles it normally
    exit 0
fi

# closed auto-break: match stored start against export (@1 = last array element,
# so @id = length - index); fallback = most recent off interval today
start=""
[ -e "$last_break" ] && start=$(cat "$last_break")
if [ -n "$start" ]; then
    id=$(timew export :day 2>/dev/null | jq -r --arg s "$start" \
        'length as $n | to_entries[]
         | select(.value.start == $s and (.value.tags | index("off")))
         | "@\($n - .key)"' | head -1)
else
    id=$(timew export :day 2>/dev/null | jq -r \
        'length as $n | to_entries[]
         | select(.value.tags | index("off")) | "@\($n - .key)"' | tail -1)
fi
if [ -n "$id" ]; then
    retag "$id"
    rm -f "$last_break"
else
    notify-send -t 5000 "Timewarrior" "No break found to reclassify"
fi
