{
  helpers,
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkIf
    types
    attrsets
    foldl'
    enabled
    mkEnableOpt
    mkOpt
    enabled'
    getModulesRecursive
    defaultExcludePredicate
    ;
  inherit (attrsets) recursiveUpdate;
  cfg = config.local.wayland;
  isAnyWaylandCompositorEnabled = cfg.niri.enable || cfg.river.enable || cfg.plasma.enable;
  trace = x: builtins.trace x x;
in {
  imports = getModulesRecursive ./. {
    blacklist = [
      {
        # exclude evremap/keys.nix since it is itself not a nixos module
        name = "keys.nix";
        kind = "regular";
        depth = 1;
      }
      # {
      #   # exclude evremap/keys.nix since it is itself not a nixos module
      #   name = "evremap";
      #   kind = "directory";
      #   depth = 0;
      # }
    ];
  };

  options.local.wayland = {
    enable =
      mkOpt types.bool isAnyWaylandCompositorEnabled
      "Enable wayland support, setting this option to true configures and enables wayland-related portals and other settings. And disables xserver if not already.";
    login = {
      greetd = mkEnableOpt "Enable greetd login manager.";
      settings = {
        default_session = mkOpt types.str "river" "The default command to start our session with.";
      };
    };
  };

  config = foldl' recursiveUpdate {} [
    {
      services.playerctld = enabled;
    }
    {
      users.users.seat = {
        isSystemUser = true;
        group = "seat";
        description = "Seat management daemon user";
      };

      services.seatd = enabled' {
        user = "seat";
        group = "seat";
      };

      users.users.jules.extraGroups = ["seat"];
    }
    {
      security.pam.services.greetd.enableGnomeKeyring = true;
      services.greetd = {
        inherit (cfg.login.greetd) enable;
        settings.default_session.command = "${pkgs.tuigreet}/bin/tuigreet --cmd ${cfg.login.settings.default_session}";
      };
    }
    {
      local.home.home.packages = with pkgs; [
        julespkgs.screenshot
      ];
    }
    {
      security.pam.services.waylock = {};
    }
    {
      xdg.portal = mkIf (cfg.enable || isAnyWaylandCompositorEnabled) (enabled' {
        wlr = enabled;
        extraPortals = with pkgs;
          [
            xdg-desktop-portal-gtk
            xdg-desktop-portal-wlr
            xdg-desktop-portal-gnome
          ]
          ++ (with pkgs.kdePackages; [
            xdg-desktop-portal-kde
          ]);

        config = {
          common.default = ["gtk"];
          river.default = [
            "wlr"
            "gtk"
          ];
          niri.default = [
            "wlr"
            "gnome"
            "gtk"
          ];
          hyprland.default = [
            "wlr"
            "gtk"
          ];
          plasma.default = [
            "kde"
            "gtk"
          ];
        };
      });
    }
    {
      services.xserver = {
        enable = !cfg.enable;
        autoRepeatDelay = 200;
        autoRepeatInterval = 30;
        autorun = true;
        xkb = {
          layout = "us";
          options = "eurosign:e";
        };
      };
    }
  ];
}
