{
  config,
  packages,
  lib,
  helpers,
  ...
}: let
  cfg = config.local.cli.starship;
  inherit (packages) themes_catppuccin_starship;
  inherit (helpers) enabledPred;
  inherit (lib) concatStrings;
in {
  local.home.programs.starship = enabledPred cfg.enable {
    enableFishIntegration = true;
    enableTransience = true;
    settings = let
      catppuccin = builtins.fromTOML (builtins.readFile "${themes_catppuccin_starship}/themes/mocha.toml");
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
        # palette = "catppuccin_mocha";
        character = {
          success_symbol = "||>";
          error_symbol = "~~>";
        };
      };
  };
}
