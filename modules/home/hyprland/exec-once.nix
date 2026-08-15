{ lib, host, ... }:
{
  wayland.windowManager.hyprland.settings.exec-once = [
    # "hash dbus-update-activation-environment 2>/dev/null"
    "dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
    "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"

    "hyprlock"

    "nm-applet &"
    "poweralertd &"
    "wl-clip-persist --clipboard both &"
    "wl-paste --watch cliphist store &"
    "waybar &"
    "sleep 2 && kdeconnect-indicator &"
    "swaync &"
    "udiskie --automount --notify --smart-tray &"
    "hyprctl setcursor Bibata-Modern-Ice 24 &"
    "init-wallpaper &"

    # only start monitor watching screen on laptop
    "${if (host == "p14s" || host == "laptop") then "monitor-watcher &" else ""}"

    # ActivityWatch AFK -> timewarrior auto-break/clock-out bridge
    "timew-aw-bridge &"
    # push curated AW categories to the server (waits for it internally)
    "aw-set-categories &"
    # lock when bluetooth link to phone drops (bt-lock-watch off|on|toggle to pause)
    "bt-lock-watch &"

    "ghostty --gtk-single-instance=true --quit-after-last-window-closed=false --initial-window=false"
    "[workspace 1 silent] zen-beta"
    # "[workspace 2 silent] ghostty"
  ];
}
