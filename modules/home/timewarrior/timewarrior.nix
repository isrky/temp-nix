{ pkgs, ... }:
{
  home.packages = with pkgs; [ timewarrior ];

  # timew's first run interactively asks to create the database; pre-creating
  # the dir skips the prompt so waybar/scripts work non-interactively
  xdg.dataFile."timewarrior/.keep".text = "";

  xdg.configFile."timewarrior/timewarrior.cfg".source = ./timewarrior.cfg;
  xdg.configFile."timewarrior/extensions/worktime.py" = {
    source = ./worktime.py;
    executable = true;
  };
}
