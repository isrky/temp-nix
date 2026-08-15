#!/usr/bin/env bash
# Waybar JSON status for timewarrior work tracking.
# Pre-shift work (before worktime.shift_start) is voluntary overtime;
# post-shift presence (work + off) beyond worktime.threshold hours is overtime;
# off-tagged time is informational, flagged past worktime.off_allowance hours.

fmt() { printf "%dh %02dm" "$(($1 / 3600))" "$((($1 % 3600) / 60))"; }

# pre/post-shift seconds of an interval array, clamped at $t0
JQ_SPLIT='
  [.[] |
    (.start | strptime("%Y%m%dT%H%M%SZ") | mktime) as $s |
    (if .end then (.end | strptime("%Y%m%dT%H%M%SZ") | mktime) else now end) as $e |
    { pre:  (([$e, $t0] | min) - ([$s, $t0] | min)),
      post: (([$e, $t0] | max) - ([$s, $t0] | max)) }
  ] | "\((map(.pre) | add // 0) | floor) \((map(.post) | add // 0) | floor)"'

split_day() { # $1 = tag
    json=$(timew export :day "$1" 2>/dev/null) || json="[]"
    echo "$json" | jq -r --argjson t0 "$shift_epoch" "$JQ_SPLIT"
}

active=$(timew get dom.active 2>/dev/null || echo 0)
active_tag=$(timew get dom.active.tag.1 2>/dev/null)
# timew get returns empty (exit 0) for undefined keys, so check for content
shift_start=$(timew get dom.rc.worktime.shift_start 2>/dev/null)
[ -n "$shift_start" ] || shift_start="08:00"
threshold=$(timew get dom.rc.worktime.threshold 2>/dev/null)
[ -n "$threshold" ] || threshold=9
allowance=$(timew get dom.rc.worktime.off_allowance 2>/dev/null)
[ -n "$allowance" ] || allowance=1
min_extra=$(timew get dom.rc.worktime.min_extra 2>/dev/null)
[ -n "$min_extra" ] || min_extra=15
warn_before=$(timew get dom.rc.worktime.warn_before 2>/dev/null)
[ -n "$warn_before" ] || warn_before=15
shift_epoch=$(date -d "$(date +%F) ${shift_start}" +%s)

# work is tagged "job" because timew's date parser swallows a bare "work" argument
read -r work_pre work_post < <(split_day job)
read -r off_pre off_post < <(split_day off)

off=$((off_pre + off_post))
presence=$((work_post + off_post))
total=$((work_pre + work_post + off))
limit=$((threshold * 3600))
allowance_s=$((allowance * 3600))
min_extra_s=$((min_extra * 60))
regular=$presence
ot=0
if [ "$presence" -gt "$limit" ]; then
    regular=$limit
    ot=$((presence - limit))
fi
# sub-min_extra amounts are unintentional (shift-end chit-chat, arriving
# a few minutes early) — fold them into regular
vol=$work_pre
if [ "$ot" -gt 0 ] && [ "$ot" -lt "$min_extra_s" ]; then
    regular=$presence
    ot=0
fi
if [ "$vol" -gt 0 ] && [ "$vol" -lt "$min_extra_s" ]; then
    regular=$((regular + vol))
    vol=0
fi

if [ "$ot" -gt 0 ]; then
    class="overtime"
elif [ "$active" = "1" ] && [ "$active_tag" = "off" ]; then
    class="break"
elif [ "$active" = "1" ] && [ "$(date +%s)" -lt "$shift_epoch" ]; then
    class="voluntary"
elif [ "$active" = "1" ]; then
    class="active"
else
    class="inactive"
fi

# once-per-day notifications while tracking: heads-up before the presence
# limit, critical when it is crossed (waybar runs this script every 30s)
warn_s=$((warn_before * 60))
state_dir="${XDG_RUNTIME_DIR:-/tmp}"
today=$(date +%F)
if [ "$active" = "1" ]; then
    if [ "$presence" -ge "$((limit - warn_s))" ] && [ "$presence" -lt "$limit" ] \
        && [ ! -e "$state_dir/timew-warn-$today" ]; then
        touch "$state_dir/timew-warn-$today"
        notify-send -t 10000 "Timewarrior" \
            "Regular hours end in $(((limit - presence) / 60)) min — wrap up" >/dev/null 2>&1
    fi
    if [ "$presence" -ge "$limit" ] && [ ! -e "$state_dir/timew-limit-$today" ]; then
        touch "$state_dir/timew-limit-$today"
        notify-send -u critical "Timewarrior" \
            "${threshold}h presence reached — overtime starts now" >/dev/null 2>&1
    fi
fi

detail=""
[ "$vol" -gt 0 ] && detail="voluntary $(fmt "$vol")"
[ "$regular" -gt 0 ] && detail="${detail:+$detail, }regular $(fmt "$regular")"
if [ "$off" -gt 0 ]; then
    detail="${detail:+$detail, }off $(fmt "$off")"
    [ "$off" -gt "$allowance_s" ] && detail="$detail (+$(fmt $((off - allowance_s))))"
fi
[ "$ot" -gt 0 ] && detail="${detail:+$detail, }overtime $(fmt "$ot")"
if [ "$active" = "1" ]; then
    [ "$active_tag" = "off" ] && state="On break" || state="Tracking work"
else
    state="Not tracking"
fi
tooltip="${state} — today: $(fmt "$total")${detail:+ (${detail})}"
[ -e "${XDG_RUNTIME_DIR:-/tmp}/timew-meeting" ] &&
    tooltip="$tooltip — meeting mode (AFK automation paused)"

text=$(fmt "$total")
# icon only when idle and nothing tracked yet
[ "$active" != "1" ] && [ "$total" -eq 0 ] && text=""
printf '{"text":"󱎫 %s","tooltip":"%s","class":"%s"}\n' "$text" "$tooltip" "$class"
