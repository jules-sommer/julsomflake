{
  pkgs,
  helpers,
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (helpers) enabledPred enabled;
  cfg = config.local.shells.fish;
in {
  config = {
    programs.fish = enabled;

    local.home.programs.fish = enabledPred cfg.enable {
      package = pkgs.fish;
      # plugins = with pkgs.fishPlugins; [
      #   fifc
      #   # pure
      #   sponge
      #   fish-you-should-use
      #   done
      #   tide
      # ];

      functions = {
        fish_greeting.body = "";
        file = {
          description = "Combines functions of touch and mkdir to create directory structure recursively and finally the file itself (with sudo if needed).";
          body = builtins.readFile ./functions/file.fish;
        };
      };

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

      shellAbbrs = {
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
}
