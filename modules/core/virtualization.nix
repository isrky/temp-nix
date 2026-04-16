{ pkgs, username, ... }:
{
  # Add user to libvirtd and kvm groups
  users.users.${username}.extraGroups = [
    "libvirtd"
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
    distrobox
    # gvisor
  ];

  # Manage the virtualisation services
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
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
