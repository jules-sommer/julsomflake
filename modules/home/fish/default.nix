{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    ;
  cfg = config.local.fish;
in
{
  options.local.fish = {
    enable = mkEnableOption "Enable fish shell configuration";
  };

  config = {
    programs = {
      fish = {
        inherit (cfg) enable;
        functions.fish_greeting.body = "";
        plugins = [ ];
        functions = {
          shell = {
            body = ''
              if test (count $argv) -eq 0
                  command nix shell -c $SHELL
                else
                  command nix shell $argv -c $SHELL
                end
              end
            '';
          };
        };
        shellAliases = {
          "ls" = "eza";
        };
      };

      zoxide = {
        enable = true;
        enableFishIntegration = true;
      };

      carapace = {
        enable = true;
        enableFishIntegration = true;
      };
    };

  };
}
