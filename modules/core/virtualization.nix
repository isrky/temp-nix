{ pkgs, username, ... }:
{
  # Add user to libvirtd, docker, and kvm groups
  users.users.${username}.extraGroups = [
    "libvirtd"
    "docker"
    "kvm"
  ];

  # Install necessary packages
  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    virtio-win
    win-spice
    adwaita-icon-theme
    # gvisor
  ];

  # Manage the virtualisation services
  virtualisation = {
    docker = {
      enable = true;
      daemon.settings = {
        # runtimes = {
        #   runsc = {
        #     path = "${pkgs.gvisor}/bin/runsc";
        #   };
        # };
      };
    };
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
      };
    };
    spiceUSBRedirection.enable = true;
  };
  services.spice-vdagentd.enable = true;
}
