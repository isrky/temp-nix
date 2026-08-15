{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ## Better core utils
    duf # disk information
    eza # ls replacement
    fd # find replacement
    gping # ping with a graph
    gtrash # rm replacement, put deleted files in system trash
    hexyl # hex viewer
    man-pages # extra man pages
    ncdu # disk space
    nmap
    neovim
    ripgrep # grep replacement
    tldr

    ## Tools / useful cli
    aoc-cli # Advent of Code command-line tool
    asciinema
    asciinema-agg
    binsider
    bitwise # cli tool for bit / hex manipulation
    broot # tree files view
    caligula # User-friendly, lightweight TUI for disk imaging
    google-cloud-sdk # Google Cloud CLI
    flyctl # Fly.io CLI
    hyperfine # benchmarking tool
    just # command runner (makefile like)
    pastel # cli to manipulate colors
    scooter # Interactive find and replace in the terminal
    swappy # snapshot editing tool
    android-tools # ADB and other Android tools
    tdf # cli pdf viewer
    tokei # project line counter
    translate-shell # cli translator
    tmux
    woomer
    yt-dlp-light
    zellij

    ## TUI
    epy # ebook reader
    gtt # google translate TUI
    mc # midnight commander file manager
    toipe # typing test in the terminal
    ttyper # cli typing test

    ## Monitoring / fetch
    dnsutils # dig, nslookup, nsupdate
    htop
    inxi # system information tool
    nvtopPackages.nvidia # GPU monitor
    onefetch # fetch utility for git repo
    speedtest-cli # internet speed test tool
    wavemon # monitoring for wireless network devices

    ## Fun / screensaver
    asciiquarium-transparent
    cbonsai
    cmatrix
    countryfetch
    cowsay
    figlet
    fortune
    lavat
    lolcat
    pipes
    sl
    tty-clock

    ## Multimedia
    imv
    lowfi
    mpv
    phockup # photo/video organizer by date

    ## Utilities
    entr # perform action when file change
    ffmpeg
    file # Show file information
    jq # JSON processor
    killall
    lazydocker # Docker TUI
    libnotify
    lsof
    lzip
    mimeo
    openssl
    pamixer # pulseaudio command line mixer
    playerctl # controller for media players
    poweralertd
    socat
    udiskie # Automounter for removable media
    unzip
    wget
    wl-clipboard # clipboard utils for wayland (wl-copy, wl-paste)
    xdg-utils
    xpipe

    winetricks
    wineWow64Packages.waylandFull
  ];
}
