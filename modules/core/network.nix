{ pkgs, host, ... }:
{
  networking = {
    hostName = "${host}";
    networkmanager.enable = true;
    search = [ "ts.net" ];
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
        80
        443
        5555
        5556
        8080
        59010
        59011
        3080
      ];
      allowedUDPPorts = [
        59010
        59011
      ];
      # Allow all traffic from LAN and Tailscale. If your interface names differ, check with: ip link
      trustedInterfaces = [
        "wlp0s20f3"
        "enp8s0f1"
        "tailscale0"
        "waydroid0"
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    cloudflared
    networkmanagerapplet
    v2ray
    xray
  ];
}
