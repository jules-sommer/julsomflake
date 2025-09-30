{
  pkgs,
  helpers,
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (helpers) enabledPred enabled enabled';
  cfg = config.local.shells.zsh;
in {
  config = {
    programs.zsh =
      enabled;

    local.home.programs.zsh = enabledPred cfg.enable {
      package = pkgs.zsh;
      setOptions = [
        "EXTENDED_HISTORY"
        "RM_STAR_WAIT"
        "NO_BEEP"
      ];
      shellAliases =
        {
          screenshot = "grim -g \"$(slurp -d)\" - | tee ~/060_media/005_screenshots/$(date +%Y-%m-%d_%H-%M-%S).png | wl-copy -t image/png";
          targz = "tar -czvf";
          cat = "bat";
          ls = "eza --icons=always --hyperlink --color=always --color-scale=all";
        }
        // (mkIf config.security.doas.enable {
          sudo = "doas";
          sudoedit = "doas rnano";
        });
      zsh-abbr = enabled' {
        abbreviations = {
          lst = "ls -TL2";
          ff = "fastfetch";
          br = "broot -hips";
          brw = "broot -hips";
          yank = "wl-copy";
          put = "wl-paste";

          cd = "z";
          ci = "zi";
          clone = "gix clone";
          gco = "git checkout";
          gc = "git commit";
          gca = "git commit -a";
        };
      };
    };
  };
}
