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
        functions = {
          fish_greeting.body = "";
        };
        shellAliases = {
          "ls" = "eza";
          "screenshot" =
            "grim -g \"$(slurp -d)\" - | tee ~/060_media/005_screenshots/$(date +%Y-%m-%d_%H-%M-%S).png | wl-copy -t image/png";
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
