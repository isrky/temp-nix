{
  inputs,
  pkgs,
  system,
  ...
}:
{
  _2048 = pkgs.callPackage ./2048 { stdenv = pkgs.gcc14Stdenv; };
  colloid-gtk-theme = pkgs.callPackage ./colloid-gtk-theme { };
  maple-mono-custom = pkgs.callPackage ./maple-mono { inherit inputs; };
  pomo = pkgs.callPackage ./pomo { };
}
