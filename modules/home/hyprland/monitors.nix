{ pkgs, host, ... }:
let
  isLaptop = host == "laptop" || host == "p14s";
in
{
  wayland.windowManager.hyprland = {
    settings = {
      monitor =
        if isLaptop then
          [
            "eDP-1,1920x1080@120,0x0,1"
            # any external monitor: preferred mode, placed to the left
            ",preferred,auto-left,1"
          ]
        else
          [ ",preferred,auto,auto" ];

      # workspaces 1-5 live on the laptop panel; 6-10 are bound to the
      # external monitor at runtime by monitor-watcher (name is dynamic)
      workspace =
        if isLaptop then
          [
            "1, monitor:eDP-1"
            "2, monitor:eDP-1"
            "3, monitor:eDP-1"
            "4, monitor:eDP-1"
            "5, monitor:eDP-1"
          ]
        else
          [ ];
    };

    # runtime overrides via nwg-displays; sourced after the settings above,
    # so anything in these files wins over the nix monitor rules
    extraConfig = ''
      # hyprlang noerror true
        source = ~/.config/hypr/monitors.conf
        source = ~/.config/hypr/workspaces.conf
      # hyprlang noerror false
    '';
  };

  home.packages = with pkgs; [ nwg-displays ];
}
