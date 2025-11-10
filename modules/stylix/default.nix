{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit
    (lib)
    mkEnableOpt
    enabled
    enabled'
    foldl'
    recursiveUpdate
    mkIf
    genAttrs
    ;

  font = name: package: {
    inherit name package;
  };

  cfg = config.local.stylix;
in {
  options.local.stylix = mkEnableOpt "Enable theming via stylix.";
  config = {
    stylix = mkIf cfg.enable (enabled' {
      autoEnable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine.yaml";
      polarity = "dark";
      cursor = {
        name = "BreezeX-RosePineDawn-Linux";
        package = pkgs.rose-pine-cursor;
        size = 32;
      };

      homeManagerIntegration = {
        autoImport = true;
        followSystem = true;
      };

      iconTheme = {
        dark = "breeze-dark";
        light = "breeze";
        package = pkgs.breeze-icons;
      };

      targets = {
        gtk = enabled;
        qt = enabled;
      };

      opacity = genAttrs ["terminal" "popups" "applications" "desktop"] (_: 0.9);

      fonts = foldl' recursiveUpdate {} [
        {
          sizes = genAttrs ["applications" "terminal" "desktop" "popups"] (_: 14);
          monospace = font "JetBrainsMono Nerd Font" pkgs.nerd-fonts.jetbrains-mono;
          emoji = font "Noto Color Emoji" pkgs.noto-fonts-emoji;
        }
        (genAttrs ["sansSerif" "serif"] (_: font "NotoSans Nerd font" pkgs.nerd-fonts.noto))
      ];
    });

    local.home = {
      qt = enabled' {
        platformTheme.name = lib.mkForce "kde";
        style.name = lib.mkForce "breeze";
      };

      dconf.settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          cursor-theme = "BreezeX-RosePineDawn-Linux";
          icon-theme = "breeze-dark";
        };
      };

      home.sessionVariables = {
        QT_QPA_PLATFORMTHEME = "kde";
        QT_STYLE_OVERRIDE = "breeze";
      };
    };
  };
}
