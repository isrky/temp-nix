{ pkgs, ... }:
{
  services = {
    gvfs.enable = true;

    gnome = {
      tinysparql.enable = true;
      gnome-keyring.enable = true;
    };

    dbus.enable = true;
    fstrim.enable = true;
    fwupd.enable = true;
    openssh.enable = true;

    # needed for GNOME services outside of GNOME Desktop
    dbus.packages = with pkgs; [
      gcr
      gnome-settings-daemon
    ];

    logind.settings.Login = {
      # don’t shutdown when power button is short-pressed
      HandlePowerKey = "ignore";

      # ignore lid close when docked/external monitor conected
      HandleLidSwitchDocked = "ignore";
    };

    udisks2.enable = true;

    zapret = {
      enable = true;
      params = [
        "--dpi-desync=fake"
        "--dpi-desync-ttl=3"
      ];
      configureFirewall = true;
      udpSupport = true;
      udpPorts = [
        "443"
        "50000"
        "50001"
        "50002"
      ];
    };
  };

  programs.kdeconnect.enable = true;
}
