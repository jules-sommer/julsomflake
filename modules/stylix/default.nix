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
    optionalAttrs
    mkMerge
    foldl'
    recursiveUpdate
    genAttrs
    concatLists
    mkDefault
    mkForce
    ;

  font = name: package: {
    inherit name package;
  };

  cfg = config.local.stylix;
in {
  options.local.stylix = mkEnableOpt "Enable theming via stylix.";

  config = mkMerge [
    # Stylix system targets and config
    {
      stylix = enabled' {
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

        icons = enabled' {
          dark = "breeze-dark";
          light = "breeze";
          package = pkgs.kdePackages.breeze-icons;
        };

        targets = {
          gtk = enabled;
          qt = enabled' {
            platform = mkForce "qtct";
          };
        };

        opacity = genAttrs ["terminal" "popups" "applications" "desktop"] (_: 0.9);

        # fonts = foldl' recursiveUpdate {} [
        #   {
        #     sizes = genAttrs ["applications" "terminal" "desktop" "popups"] (_: 14);
        #     monospace = font "JetBrainsMono Nerd Font" pkgs.nerd-fonts.jetbrains-mono;
        #     emoji = font "Noto Color Emoji" pkgs.noto-fonts-color-emoji;
        #   }
        #   (genAttrs ["sansSerif" "serif"] (_: font "NotoSans Nerd font" pkgs.nerd-fonts.noto))
        # ];
      };
    }

    # Stylix home-manager targets and config
    {
      local.home.stylix = {
        autoEnable = true;
        targets = {
          fuzzel = disabled;
          swaylock = disabled;
          gtk = enabled;
          qt = enabled' {
            platform = mkForce "qtct";
          };
        };
      };
    }

    # GTK related theming overrides
    {
      environment.systemPackages = concatLists [
        (with pkgs; [
          adwaita-icon-theme
          hicolor-icon-theme
        ])
        (with pkgs.kdePackages; [
          breeze-gtk
        ])
      ];

      programs.dconf = enabled;

      local.home = {
        gtk = enabled' {
          gtk4.theme = null;
          theme = mkForce {
            name = "Breeze-Dark";
            package = pkgs.kdePackages.breeze-gtk;
          };
          iconTheme = mkForce {
            name = "breeze-dark";
            package = pkgs.kdePackages.breeze-icons;
          };
        };

        dconf.settings = {
          "org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
            cursor-theme = "BreezeX-RosePineDawn-Linux";
            icon-theme = "breeze-dark";
          };
        };
      };
    }

    # QT 5/6 related theming overrides
    {
      qt = enabled' (mkForce {
        platformTheme = "kde";
        style = "breeze";
      });

      environment.systemPackages = concatLists [
        (with pkgs.kdePackages; [
          qt6ct
          breeze
          breeze.qt5
        ])
        (with pkgs.libsForQt5; [
          qt5ct
          qtstyleplugins
          breeze-icons
        ])
      ];

      local.home = {
        qt = enabled' {
          platformTheme = mkForce {
            package = pkgs.kdePackages.plasma-integration;
            name = "kde";
          };
          style = mkForce {
            name = "breeze";
            package = pkgs.kdePackages.breeze;
          };
        };

        home.sessionVariables = {
          QT_QPA_PLATFORM = "wayland";
          QT_QPA_PLATFORMTHEME = "kde";
          QT_QPA_PLATFORMTHEME_QT6 = "kde";
        };
      };
    }
  ];
}
