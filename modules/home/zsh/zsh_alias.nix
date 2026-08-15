{ ... }:
{
  programs.zsh = {
    shellAliases = {
      # Utils
      c = "clear";
      cd = "z";
      tt = "gtrash put";
      cat = "bat";
      nano = "micro";
      code = "codium";
      openclaude = "pnpm dlx @gitlawb/openclaude@latest";
      openclaude-npx = "npx -y @gitlawb/openclaude@latest";
      cline = "pnpm dlx cline";
      apkmitm = "pnpm dlx apk-mitm";
      aiderdesk = "pnpm dlx @aiderdesk/aiderdesk";
      diff = "delta --diff-so-fancy --side-by-side";
      less = "bat";
      copy = "wl-copy";
      f = "superfile";
      py = "python";
      ipy = "ipython";
      icat = "kitten icat";
      dsize = "du -hs";
      pdf = "tdf";
      open = "xdg-open";
      space = "ncdu";
      man = "batman";

      l = "eza --icons -a --group-directories-first -1 --no-user --long"; # EZA_ICON_SPACING=2
      tree = "eza --icons --tree --group-directories-first";

      # Nixos
      cdnix = "cd ~/nixos-config && zeditor ~/nixos-config";
      cdpio = "cd /home/ismails/Documents/PlatformIO/Projects";
      cdprojects = "cd /home/ismails/Documents/projects";
      ns = "nom-shell --run zsh";
      nsp = "nom-shell --run zsh -p";
      nd = "nom develop --command zsh";
      nb = "nom build";
      nc = "nh-notify nh clean all --keep 5";
      nft = "nh-notify nh os test";
      nfs = "nh-notify nh os switch";
      nfu = "nh-notify nh os boot --update";
      nsearch = "nh search";

      # python
      piv = "python -m venv .venv";
      psv = "source .venv/bin/activate";

      # Timewarrior
      tw = "timew";
      twi = "timew start job"; # clock in ("work" is swallowed by timew's date parser)
      two = "timew stop"; # clock out
      twb = "timew start off"; # break
      twc = "timew continue";
      twd = "timew summary :day";
      tww = "timew summary :week";
      twrd = "timew worktime :day"; # regular/overtime report
      twrw = "timew worktime :week";
      twrm = "timew worktime :month";
      twu = "timew undo";
      twm = "timew-meeting"; # toggle meeting mode (pauses AFK automation)
      tway = "timew-was-work"; # reclassify last auto-break as work
    };
  };
}
