{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    mkEnableOpt
    mkIf
    ;
  cfg = config.local.stylix;
in
{
  options.local.stylix = mkEnableOpt "Enable theming via stylix.";

  config = mkIf cfg.enable {
    stylix = {
      enable = true;
      autoEnable = true;
      image = ./assets/city-night-neon-pink.png;
      polarity = "dark";
      cursor.size = 24;
      homeManagerIntegration = {
        autoImport = true;
        followSystem = true;
      };
      override = {
        base00 = "000000";
      };
      targets = {
        nixvim = {
          enable = true;
          plugin = "mini.base16";
          transparentBackground = {
            main = true;
            signColumn = true;
          };
        };
      };
      opacity = {
        terminal = 0.75;
        popups = 0.75;
        applications = 0.9;
        desktop = 0.9;
      };
      fonts = {
        monospace = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "Jetbrains Mono Nerd Font";
        };

        sansSerif = {
          package = pkgs.nerd-fonts.noto;
          name = "NotoSans Nerd font";
        };
        serif = {
          package = pkgs.nerd-fonts.noto;
          name = "NotoSerif Nerd font";
        };
        sizes = {
          applications = 12;
          terminal = 15;
          desktop = 11;
          popups = 12;
        };
      };
    };
  };
}
