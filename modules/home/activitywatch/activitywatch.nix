{ pkgs, lib, ... }:
{
  # curated categories, pushed to the server by aw-set-categories (exec-once)
  xdg.configFile."activitywatch/aw-categories.json".source = ./aw-categories.json;

  services.activitywatch = {
    enable = true;
    # rust server: provides bin/aw-server (matches the module's ExecStart) and
    # ships the web UI; avoids the Qt-heavy `activitywatch` bundle
    package = pkgs.aw-server-rust;
    watchers.awatcher = {
      # combined Wayland window+AFK watcher for Hyprland; executable defaults
      # to the attr name "awatcher" which matches the package's mainProgram
      package = pkgs.awatcher;
    };
  };

  # the HM module hangs everything off default.target, which starts at login
  # before Hyprland has exported WAYLAND_DISPLAY into the systemd user env;
  # retarget to the Hyprland session (env is imported before the target starts
  # thanks to wayland.windowManager.hyprland.systemd.enable)
  systemd.user.targets.activitywatch = {
    Unit = {
      Requires = lib.mkForce [ ];
      After = lib.mkForce [ "hyprland-session.target" ];
      PartOf = [ "hyprland-session.target" ];
    };
    Install.WantedBy = lib.mkForce [ "hyprland-session.target" ];
  };

  # the module sets no Restart for watchers; awatcher dies if the compositor
  # socket vanishes briefly (monitor hotplug etc.)
  systemd.user.services.activitywatch-watcher-awatcher.Service = {
    Restart = "on-failure";
    RestartSec = 5;
  };
}
