{
  pkgs,
  helpers,
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf foldl' recursiveUpdate;
  inherit (helpers) enabledPred;
  cfg = config.local.shells.fish;
in {
  config = {
    programs.fish.enable = true;
    local.home.programs.fish = enabledPred cfg.enable {
      package = pkgs.fish;
      plugins = [
        {
          name = "fifc";
          src = pkgs.fishPlugins.fifc;
        }
        {
          name = "sponge";
          src = pkgs.fishPlugins.sponge;
        }
        {
          name = "fish-you-should-use";
          src = pkgs.fishPlugins.fish-you-should-use;
        }
        {
          name = "done";
          src = pkgs.fishPlugins.done;
        }
        {
          name = "tide";
          src = pkgs.fishPlugins.tide;
        }
      ];

      functions = {
        fish_greeting.body = "";
        file = {
          description = "Combines functions of touch and mkdir to create directory structure recursively and finally the file itself (with sudo if needed).";
          body = builtins.readFile ./functions/file.fish;
        };

        show-env = {
          description = "Pretty-print environment with bat";
          body = ''
            printenv -0 \
              | string split0 \
              | string replace -r '^(.*?)=(.*)$' '$1 = $2' \
              | sort \
              | ${pkgs.bat}/bin/bat -l ini
          '';
        };
      };

      # shellAliases = foldl' recursiveUpdate {} [
      #   {
      #     # screenshot = "grim -g \"$(slurp -d)\" - | tee ~/060_media/005_screenshots/$(date +%Y-%m-%d_%H-%M-%S).png | wl-copy -t image/png";
      #     targz = "tar -czvf";
      #     cat = "bat";
      #     ls = "eza --icons=always --hyperlink --color=always --color-scale=all";
      #   }
      #   (mkIf config.security.doas.enable {
      #     sudo = "doas";
      #     sudoedit = "doas rnano";
      #   })
      #   (mkIf config.home.programs.fastfetch.enable {
      #     ff = "fastfetch";
      #   })
      # ];
      #
      # shellAbbrs = {
      #   lst = "ls -TL2";
      #   br = "broot -hips";
      #   brw = "broot -hips";
      #
      #   cd = "z";
      #   ci = "zi";
      #   clone = "gix clone";
      #   gco = "git checkout";
      #   gc = "git commit";
      #   gca = "git commit -a";
      # };
    };
  };
}
