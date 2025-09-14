{
  config,
  lib,
  pkgs,
  self,
  system,
  ...
}:
with lib; let
  cfg = config.local.starship;
  inherit (self.packages.catppuccin) starship;
in {
  options.local.starship = {
    enable = mkEnableOption "Enable the prompt";
  };

  config = mkIf cfg.enable {
    local.home.programs.starship = {
      enable = true;
      enableFishIntegration = true;
      enableTransience = true;
      settings = let
        catppuccin = builtins.fromTOML (builtins.readFile "${starship}/themes/mocha.toml");
      in
        catppuccin
        // {
          format = concatStrings [
            "[╭─](#ff2199)"
            " "
            "$directory"
            "$container"
            "$all"
            "($cmd_duration)"
            "$line_break"
            "[╰─](#ff2199)"
            "$jobs"
            "$status"
            "$username"
            "$hostname"
            " "
            "$character"
          ];
          right_format = "$time$shell$sudo";
          palette = "catppuccin_mocha";
          character = {
            success_symbol = "||>";
            error_symbol = "~~>";
          };
        };
    };
  };
}
