{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ## Lsp
    nixd # nix

    ## formating
    shfmt
    treefmt
    nixfmt

    ## C / C++
    gcc
    gdb
    gef
    cmake
    gnumake
    valgrind
    llvmPackages_20.clang-tools

    ## Python
    python3
    python312Packages.ipython

    ## Java / Kotlin
    jdk21
    kotlin

    ## JavaScript / Node.js
    nodejs
    pnpm
    bun
    devbox
    bruno
    ungoogled-chromium

    ## Security
    burpsuite

    ## JetBrains IDEs
    jetbrains.gateway
    jetbrains.idea
    jetbrains.pycharm
    jetbrains.webstorm
    jetbrains-toolbox

    ## Editors
    zed-editor # Zed code editor

    ## Android / Mobile
    scrcpy
    android-studio

    ## ESP32 / Embedded
    platformio # project management and build workflow
    esptool # Espressif serial flasher
    espflash # fast Rust-based flashing utility
    cargo-espmonitor # serial monitor for Espressif targets
    espup # installs Rust ESP toolchain pieces
    openocd # JTAG / on-chip debugging
    dfu-util # DFU flashing for supported boards/adapters

    freerdp
    remmina
  ];
}
