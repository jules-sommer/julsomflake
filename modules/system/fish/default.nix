{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    mkIf
    mkOpt
    types
    ;
  cfg = config.local.shell;
in
{
  options.local.shell = {
    fish = {
      enable = mkOpt types.bool true "Enable fish.";
    };
  };

  config = {
    programs = {
      # Launch fish if bash is run interactively.
      # This is used to avoid setting Fish as the login shell due to non-posix compliance
      # Source: https://nixos.wiki/wiki/Fish
      bash = {
        interactiveShellInit = ''
          if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
          then
            shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
            exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
          fi
        '';
      };
      direnv = {
        enable = true;
        loadInNixShell = true;
      };
      nix-index = {
        enable = true;
        enableFishIntegration = true;
      };

      command-not-found.enable = lib.mkDefault false;

      fish = mkIf cfg.fish.enable {
        enable = true;
        shellInit = lib.concatStringsSep "\n" [
          "set fish_greeting ''"
          ''''
        ];
        shellAliases =
          {
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
          yank = "wl-copy";
          put = "wl-paste";
          # sync = "rsync -avh --progress";
          # mirror_sync = "rsync -avzHAX --delete --numeric-ids --info=progress2";
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
