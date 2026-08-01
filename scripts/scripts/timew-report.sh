#!/usr/bin/env bash
# Rofi popup for the timew worktime report (voluntary/regular/off/overtime)

if pgrep -x rofi > /dev/null; then
    pkill rofi
    exit 0
fi

choice=$(printf 'Today\nThis Week\nThis Month' | rofi -dmenu -p "Worktime")
case "$choice" in
    "Today") range=":day" ;;
    "This Week") range=":week" ;;
    "This Month") range=":month" ;;
    *) exit 0 ;;
esac

report=$(timew worktime "$range" 2>/dev/null)
[ -n "$report" ] || report="No tracked time in range."

rofi -dmenu -theme-str 'window {width: 50%;} listview {columns: 1;}' \
    -p "Worktime — ${choice}" <<< "$report"
