{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ## Multimedia
    amberol # music player
    audacity
    gimp
    handbrake
    media-downloader
    obs-studio
    qbittorrent
    pavucontrol
    video-trimmer
    vlc

    newsflash

    ## Office
    libreoffice
    gnome-calculator

    ## Utility
    dconf-editor
    gnome-boxes
    gnome-disk-utility
    popsicle
    mission-center # GUI resources monitor
    seahorse # gnome-keyring UI
    system-config-printer
    zenity

    ## Level editor
    godot
    ldtk
    tiled

    ## Mapping / GIS
    josm

    ## Communication
    geary # email
    localsend
    pear-desktop
    telegram-desktop

    ## Reverse engineering / hex editors
    ghex
    imhex
    wxhexeditor
  ];
}
