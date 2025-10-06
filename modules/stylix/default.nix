{
  lib,
  pkgs,
  helpers,
  config,
  ...
}: let
  inherit
    (lib)
    mkEnableOpt
    enabled'
    disabled
    genAttrs
    ;
  inherit
    (helpers)
    enabledPred
    ;
  cfg = config.local.stylix;
in {
  options.local.stylix = mkEnableOpt "Enable theming via stylix.";

  config.stylix = enabledPred cfg.enable {
    autoEnable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine.yaml";
    polarity = "dark";
    cursor = {
      name = "BreezeX-RosePineDawn-Linux";
      package = pkgs.rose-pine-cursor;
      size = 24;
    };
    homeManagerIntegration = {
      autoImport = true;
      followSystem = true;
    };
    targets = {};
    opacity = genAttrs ["terminal" "popups" "applications" "desktop"] (_: 0.9);
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
      sizes = let
        size = 13;
      in {
        applications = size;
        terminal = size;
        desktop = size;
        popups = size;
      };
    };
  };
}
