#!/usr/bin/env bash
# Push the curated ActivityWatch categories (declarative, in nixos-config) to
# aw-server's settings so every host gets the same classification. Runs from
# Hyprland exec-once; waits for the server, then POSTs the "classes" setting.

api="${TIMEW_AW_API:-http://localhost:5600/api/0}"
src="${XDG_CONFIG_HOME:-$HOME/.config}/activitywatch/aw-categories.json"

[ -r "$src" ] || { echo "aw-set-categories: $src not found" >&2; exit 1; }

# wait up to 5 min for aw-server (starts with hyprland-session.target)
for _ in $(seq 60); do
    curl -sf --max-time 2 "$api/info" >/dev/null 2>&1 && break
    sleep 5
done
curl -sf --max-time 2 "$api/info" >/dev/null 2>&1 || exit 0 # server never came up

# export format -> settings value (the web UI stores categories as "classes")
classes=$(jq -c '[.categories[] | {id, name, rule} + (if .data then {data} else {} end)]' "$src") || exit 1

curl -sf -X POST "$api/settings/classes" \
    -H 'Content-Type: application/json' -d "$classes" >/dev/null || {
    echo "aw-set-categories: POST failed" >&2
    exit 1
}

# verify round-trip
stored=$(curl -sf "$api/settings/classes" 2>/dev/null)
[ "$(jq -cS . <<< "$stored")" = "$(jq -cS . <<< "$classes")" ] || {
    echo "aw-set-categories: verification mismatch" >&2
    exit 1
}
