{ pkgs, host, ... }:
{
  networking = {
    hostName = "${host}";
    networkmanager.enable = true;
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
      ];
      allowedUDPPorts = [
        59010
        59011
      ];
      # Allow all traffic from LAN and Tailscale. If your interface names differ, check with: ip link
      trustedInterfaces = [
        "enp8s0f1"
        "tailscale0"
        "waydroid0"
      ];
    };
  };

  environment.systemPackages = with pkgs; [ networkmanagerapplet ];
}
