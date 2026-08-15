{ inputs, ... }:
{
  imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

  services.flatpak = {
    enable = true;
    packages = [
      "com.github.tchx84.Flatseal"
      "com.logseq.Logseq"
      "dev.deedles.Trayscale"
      "dev.geopjr.Collision"
      "io.github.plrigaux.sysd-manager"
      "org.ferdium.Ferdium"
      "me.iepure.devtoolbox"
      "io.github.dzheremi2.lrcmake-gtk"
      "so.libdb.dissent"
      "org.vinegarhq.Sober"
      "io.github.mrvladus.List"
      "net.fasterland.converseen"
      "com.github.huluti.Curtail"
      "org.gnome.gitlab.YaLTeR.Identity"
      "net.lutris.Lutris"
    ];
    overrides = {
      global = {
        # Force Wayland by default
        Context.sockets = [
          "wayland"
          "!x11"
          "!fallback-x11"
        ];
      };
    };
  };
}
