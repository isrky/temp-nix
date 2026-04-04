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
      # Allow all traffic from LAN (ethernet). If your interface name differs, check with: ip link
      trustedInterfaces = [ "enp8s0f1" ];
    };
  };

  environment.systemPackages = with pkgs; [ networkmanagerapplet ];
}
