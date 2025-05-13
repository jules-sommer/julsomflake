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
    disabled
    ;
  cfg = config.local.stylix;

  wallpaperImages = import ./assets/wallpaper.nix { inherit pkgs lib; };
in
{
  options.local.stylix = mkEnableOpt "Enable theming via stylix.";

  config = mkIf cfg.enable {
    stylix = {
      enable = true;
      autoEnable = true;
      base16Scheme = ./tokyo-night-dark-b24.yaml;
      image = builtins.elemAt wallpaperImages 2;
      polarity = "dark";
      cursor = {
        name = "Bibata-Modern-Ice";
        package = pkgs.bibata-cursors;
        size = 24;
      };

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
          plugin = "mini.hues";
          transparentBackground = {
            main = true;
            signColumn = true;
          };
        };
      };
      opacity = {
        terminal = 0.85;
        popups = 0.85;
        applications = 0.9;
        desktop = 0.9;
      };
      fonts = {
        monospace = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font";
        };
        sansSerif = {
          package = pkgs.nerd-fonts.noto;
          name = "NotoSans Nerd font";
        };
        serif = config.stylix.fonts.sansSerif;
        emoji = {
          package = pkgs.noto-fonts-emoji;
          name = "Noto Color Emoji";
        };
        sizes =
          let
            size = 13;
          in
          {
            applications = size;
            terminal = size;
            desktop = size;
            popups = size;
          };
      };
    };
  };
}
