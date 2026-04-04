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
    
    ## JavaScript / Node.js
    nodejs
    devbox
    bruno
    code-cursor
    gemini-cli-bin
    codex
    antigravity
    (runCommand "agy" {} ''
      mkdir -p $out/bin
      ln -s ${antigravity}/bin/antigravity $out/bin/agy
    '')
    google-chrome
    ungoogled-chromium

    ## Security
    burpsuite

    ## Android / Mobile
    scrcpy
    android-studio
  ];
}
