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
        };
        shellAliases = {
          "ls" = "eza";
          "targz" = "tar -czvf";
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
