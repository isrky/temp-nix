#!/usr/bin/env bash
# Locks the session when the Bluetooth link to the phone drops (proximity lock).
# Arms only after the phone connects, so hosts where the phone never pairs are
# unaffected and it locks once per departure. While locked it stands down, so
# re-arming after an unlock always requires a fresh connection (no re-lock when
# unlocking without the phone, e.g. after suspend/resume). Polling starts 5 min
# after session start to let bluetooth settle and the phone auto-reconnect.
# Subcommands off|on|toggle|status manage a pause flag (no rebuild needed).
# A disconnect also switches an active timewarrior "job" to an auto-break
# (bridge-compatible; reclassify later with tway / the report menu).

MAC="${BT_LOCK_MAC:-6C:D1:99:F4:71:C6}"
POLL=5     # seconds between checks
MISS_MAX=3 # consecutive failed checks before locking (~15 s debounce)
flag="${XDG_RUNTIME_DIR:-/tmp}/bt-lock-off"

# timewarrior integration: phone-disconnect creates an auto-break in the same
# marker format as timew-aw-bridge, so the bridge auto-resumes it on return
# and timew-was-work can reclassify it (meeting taken with the phone).
meeting_flag="${XDG_RUNTIME_DIR:-/tmp}/timew-meeting"
marker="${XDG_RUNTIME_DIR:-/tmp}/timew-aw-autobreak"

ts_local() { date -d "@$1" +%Y-%m-%dT%H:%M:%S; }
ts_timew() { date -u -d "@$1" +%Y%m%dT%H%M%SZ; }

phone_break() { # $1 = disconnect epoch (first missed check)
    [ -e "$meeting_flag" ] && return                                  # meeting mode suspends automation
    [ "$(timew get dom.active 2>/dev/null)" = "1" ] || return         # not clocked in
    [ "$(timew get dom.active.tag.1 2>/dev/null)" = "job" ] || return # already off / other
    local boundary=$1 job_epoch now
    job_epoch=$(date -d "$(timew get dom.active.start 2>/dev/null)" +%s 2>/dev/null) || return
    now=$(date +%s)
    [ "$now" -gt "$job_epoch" ] || return                            # degenerate: job started this second
    [ "$boundary" -le "$job_epoch" ] && boundary=$((job_epoch + 60)) # clamp inside active interval
    [ "$boundary" -gt "$now" ] && boundary=$now                      # timew refuses future starts
    # marker BEFORE the timew call: worst crash case = manual-looking break
    printf '%s %s\n' "$boundary" "$(ts_timew "$boundary")" > "$marker"
    if timew start "$(ts_local "$boundary")" off :yes >/dev/null 2>&1; then
        notify-send -t 8000 "Timewarrior" \
            "Phone left at $(date -d "@$boundary" +%H:%M) — switched to break"
    else
        rm -f "$marker"
    fi
}

case "${1:-}" in
off) touch "$flag"; exit ;;
on) rm -f "$flag"; exit ;;
toggle)
    if [ -e "$flag" ]; then rm -f "$flag"; else touch "$flag"; fi
    [ -e "$flag" ] && echo "paused" || echo "active"
    exit ;;
status) [ -e "$flag" ] && echo "paused" || echo "active"; exit ;;
esac

sleep 300 # grace period after hyprland session start

armed=0 misses=0
while :; do
    sleep "$POLL"
    [ -e "$flag" ] && continue
    # while locked, stand down: re-arming after unlock requires a fresh connection
    if pidof hyprlock >/dev/null; then
        armed=0 misses=0
        continue
    fi
    if bluetoothctl info "$MAC" 2>/dev/null | grep -q "Connected: yes"; then
        armed=1 misses=0
    elif [ "$armed" = 1 ]; then
        misses=$((misses + 1))
        [ "$misses" = 1 ] && miss_start=$(date +%s) # disconnect epoch
        if [ "$misses" -ge "$MISS_MAX" ]; then
            armed=0 misses=0
            pidof hyprlock >/dev/null || hyprlock &
            phone_break "$miss_start" # lock first, then break
        fi
    fi
done
