{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) enabled' enabled;
in {
  programs.bat = enabled;
  local = {
    home = {
      programs.bat = enabled' {
        extraPackages = with pkgs.bat-extras; [
          batdiff
          batman
          prettybat
        ];
        config = {
          map-syntax = [
            "*.ino:C++"
            ".ignore:Git Ignore"
          ];
        };
      };
    };

    shells = {
      settings = {
        aliases.cat = "bat";
        abbreviations = {
          "--help" = {
            position = "anywhere";
            expansion = "--help | bat -plhelp";
          };
          "-h" = {
            position = "anywhere";
            expansion = "-h | bat -plhelp";
          };
        };
      };
    };
  };
}
