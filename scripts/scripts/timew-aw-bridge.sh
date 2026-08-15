#!/usr/bin/env bash
# Bridges ActivityWatch AFK data into timewarrior. Clock-IN stays manual.
#  - tracking job && AFK >= worktime.afk_break min  -> break backdated to AFK start
#  - in auto-break && user returns                  -> resume job (manual breaks untouched)
#  - in auto-break && AFK >= worktime.afk_leave min -> clock out as of AFK start
#  - meeting-mode flag (timew-meeting) suspends all automation
# If the user returns for under one poll interval and leaves again, the
# auto-break simply continues and the clock-out timer restarts — acceptable.

AW_API="${TIMEW_AW_API:-http://localhost:5600/api/0}" # overridable for testing
state_dir="${XDG_RUNTIME_DIR:-/tmp}"
meeting_flag="$state_dir/timew-meeting"
marker="$state_dir/timew-aw-autobreak"     # open auto-break: "<afk_epoch> <timew_utc_start>"
last_break="$state_dir/timew-aw-lastbreak" # last closed auto-break: "<timew_utc_start>"

ts_local() { date -d "@$1" +%Y-%m-%dT%H:%M:%S; } # for timew arguments
ts_timew() { date -u -d "@$1" +%Y%m%dT%H%M%SZ; } # matches timew export "start"

# marker no longer matches reality (user intervened); keep break findable for tway
demote_marker() {
    [ -e "$marker" ] || return 0
    read -r _ m_start < "$marker" && printf '%s\n' "$m_start" > "$last_break"
    rm -f "$marker"
}

while :; do
    sleep 30
    [ -e "$meeting_flag" ] && continue

    # rederive all state every loop (crash-safe / idempotent)
    if [ "$(timew get dom.active 2>/dev/null)" != "1" ]; then
        demote_marker
        continue
    fi
    tag=$(timew get dom.active.tag.1 2>/dev/null)

    # --- AFK state from ActivityWatch; any failure -> skip cycle silently ---
    bucket=$(curl -sf --max-time 3 "$AW_API/buckets" 2>/dev/null |
        jq -r 'keys[] | select(startswith("aw-watcher-afk"))' | head -1)
    [ -n "$bucket" ] || continue
    event=$(curl -sf --max-time 3 "$AW_API/buckets/$bucket/events?limit=1" 2>/dev/null |
        jq -c '.[0] // empty') || continue
    [ -n "$event" ] || continue
    status=$(jq -r '.data.status // empty' <<< "$event")
    ev_start=$(date -d "$(jq -r '.timestamp' <<< "$event")" +%s 2>/dev/null) || continue
    ev_dur=$(jq -r '.duration | floor' <<< "$event")
    now=$(date +%s)
    # heartbeats stopped >2 min ago (watcher dead, suspend) -> unknown, skip
    [ $((now - ev_start - ev_dur)) -le 120 ] || continue
    afk_secs=0
    [ "$status" = "afk" ] && afk_secs=$((now - ev_start))

    # config (timew get returns empty string + exit 0 for undefined keys)
    afk_break=$(timew get dom.rc.worktime.afk_break 2>/dev/null)
    [ -n "$afk_break" ] || afk_break=10
    afk_leave=$(timew get dom.rc.worktime.afk_leave 2>/dev/null)
    [ -n "$afk_leave" ] || afk_leave=60

    if [ "$tag" = "job" ]; then
        demote_marker # e.g. user resumed job manually mid-auto-break
        [ "$afk_secs" -ge $((afk_break * 60)) ] || continue
        # boundary = AFK start, clamped inside the active interval
        job_epoch=$(date -d "$(timew get dom.active.start 2>/dev/null)" +%s 2>/dev/null) || continue
        boundary=$ev_start
        [ "$boundary" -le "$job_epoch" ] && boundary=$((job_epoch + 60))
        [ "$boundary" -lt $((now - 60)) ] || continue # nothing meaningful to backdate
        # marker BEFORE the timew call: worst crash case = manual-looking break
        printf '%s %s\n' "$boundary" "$(ts_timew "$boundary")" > "$marker"
        if timew start "$(ts_local "$boundary")" off :yes >/dev/null 2>&1; then
            notify-send -t 8000 "Timewarrior" \
                "AFK since $(date -d "@$boundary" +%H:%M) — switched to break"
        else
            rm -f "$marker"
            notify-send -u critical "Timewarrior" "Auto-break failed"
        fi

    elif [ "$tag" = "off" ] && [ -e "$marker" ]; then
        read -r m_epoch m_start < "$marker"
        if [ "$status" = "not-afk" ]; then
            if timew start job :yes >/dev/null 2>&1; then
                printf '%s\n' "$m_start" > "$last_break" # for timew-was-work
                rm -f "$marker"
                notify-send -t 8000 "Timewarrior" \
                    "Welcome back — break was $(((now - m_epoch) / 60)) min"
            fi
        elif [ "$afk_secs" -ge $((afk_leave * 60)) ]; then
            timew stop :yes >/dev/null 2>&1
            # delete the auto-break interval only if it is provably ours
            if [ "$(timew export :day 2>/dev/null | jq -r '.[-1].start')" = "$m_start" ]; then
                timew delete @1 :yes >/dev/null 2>&1
                notify-send -u critical "Timewarrior" \
                    "Away ${afk_leave}+ min — clocked out as of $(date -d "@$m_epoch" +%H:%M)"
            else
                notify-send -u critical "Timewarrior" \
                    "Away ${afk_leave}+ min — clocked out (break interval kept: manual edits detected)"
            fi
            rm -f "$marker" "$last_break"
        fi
    fi
    # tag=off without marker: manual break — never auto-resumed, never touched
done
