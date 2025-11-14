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
    disabled
    enabled'
    foldl'
    recursiveUpdate
    mkIf
    genAttrs
    mkDefault
    mkForce
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

      iconTheme = enabled' {
        dark = "breeze-dark";
        light = "breeze";
        package = pkgs.kdePackages.breeze-icons;
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
          emoji = font "Noto Color Emoji" pkgs.noto-fonts-color-emoji;
        }
        (genAttrs ["sansSerif" "serif"] (_: font "NotoSans Nerd font" pkgs.nerd-fonts.noto))
      ];
    });

    qt = enabled' (mkForce {
      platformTheme = "kde";
      style = "breeze";
    });

    environment.systemPackages = with pkgs; [
      adwaita-icon-theme
      hicolor-icon-theme
    ];

    programs.dconf = enabled;

    local.home = {
      gtk = enabled' {
        theme = mkForce {
          name = "Breeze-Dark";
          package = pkgs.kdePackages.breeze-gtk;
        };
        iconTheme = mkForce {
          name = "breeze-dark";
          package = pkgs.kdePackages.breeze-icons;
        };
      };

      stylix = {
        autoEnable = true;
        targets = {
          fuzzel = disabled;
          swaylock = disabled;
          gtk = enabled;
          qt = enabled' {
            platform = "kde";
          };
        };
      };

      qt = enabled' {
        platformTheme = {
          package = pkgs.kdePackages.plasma-integration;
          name = lib.mkForce "kde";
        };
        style = {
          name = lib.mkForce "breeze";
          package = pkgs.kdePackages.breeze;
        };
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
