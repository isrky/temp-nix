#!/usr/bin/env bash
# Rofi popup for the timew worktime report (voluntary/regular/off/overtime)

if pgrep -x rofi > /dev/null; then
    pkill rofi
    exit 0
fi

meeting=off
[ -e "${XDG_RUNTIME_DIR:-/tmp}/timew-meeting" ] && meeting=on
choice=$(printf 'Today\nThis Week\nThis Month\nMeeting Mode: %s\nLast break was work\nOpen ActivityWatch' \
    "$meeting" | rofi -dmenu -p "Worktime")
case "$choice" in
    "Today") range=":day" ;;
    "This Week") range=":week" ;;
    "This Month") range=":month" ;;
    "Meeting Mode: "*) timew-meeting; exit 0 ;;
    "Last break was work") timew-was-work; exit 0 ;;
    "Open ActivityWatch") xdg-open http://localhost:5600 >/dev/null 2>&1 & exit 0 ;;
    *) exit 0 ;;
esac

report=$(timew worktime "$range" 2>/dev/null)
[ -n "$report" ] || report="No tracked time in range."

rofi -dmenu -theme-str 'window {width: 50%;} listview {columns: 1;}' \
    -p "Worktime — ${choice}" <<< "$report"
