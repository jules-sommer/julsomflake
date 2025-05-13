{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.local.starship;
in
{
  options.local.starship = {
    enable = mkEnableOption "Enable the prompt";
  };

  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableFishIntegration = true;
      enableTransience = true;
      settings =
        let
          catppuccin-starship = pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "starship";
            rev = "e99ba6b210c0739af2a18094024ca0bdf4bb3225";
            hash = "sha256-1w0TJdQP5lb9jCrCmhPlSexf0PkAlcz8GBDEsRjPRns=";
          };
          catppuccin = builtins.fromTOML (builtins.readFile (catppuccin-starship + "/themes/mocha.toml"));
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
