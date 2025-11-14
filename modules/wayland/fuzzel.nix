{
  pkgs,
  packages,
  lib,
  ...
}: let
  inherit (lib) enabled' mkForce getBinary;
in {
  local.home = {
    home.packages = with pkgs.kdePackages; [breeze-icons];
    programs.fuzzel = enabled' {
      settings = {
        main = {
          # include = "${packages.themes_rose-pine_fuzzel}/themes/rose-pine.ini";
          font = mkForce "JetBrainsMono Nerd Font:size=12";

          use-bold = true;
          hide-prompt = true;
          icon-theme = "breeze-dark";
          icons-enabled = true;
          inner-pad = 15;
          line-height = 28;
          vertical-pad = 20;
          horizontal-pad = 32;
          dpi-aware = "no";
          terminal = getBinary pkgs.kitty;
          layer = "overlay";
        };

        border = {
          width = 2;
          radius = 12;
        };

        colors = {
          background = "#422464ce";
          border = "#cd81e8f2";
          selection = "#d35bffc8";
        };
      };
    };
  };
}
