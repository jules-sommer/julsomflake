{
  lib,
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
          sync = "rsync -avh --progress";
          mirror_sync = "rsync -avzHAX --delete --numeric-ids --info=progress2";
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
