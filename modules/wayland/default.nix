{
  helpers,
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (helpers)
    includeIf
    enabled
    enabledIf
    mkEnableOpt
    enabledPred
    mkOpt
    disabledIf
    enabled'
    ;
  inherit (lib)
    mkIf
    types
    attrsets
    foldl'
    ;
  inherit (attrsets) recursiveUpdate;
  cfg = config.local.wayland;
  isAnyWaylandCompositorEnabled = cfg.niri.enable || cfg.river.enable || cfg.plasma.enable;
in
{
  imports = [
    ./river
    ./waybar
    ./fuzzel
    ./kde_plasma
    ./mako
    ./niri
  ];

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

  config = foldl' recursiveUpdate { } [
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
      security.pam.services.waylock = { };
    }
    {
      xdg.portal = mkIf cfg.enable {
        wlr = enabled;
        extraPortals =
          with pkgs;
          [
            xdg-desktop-portal-gtk
            xdg-desktop-portal-wlr
          ]
          ++ (with pkgs.kdePackages; [
            xdg-desktop-portal-kde
          ]);

        config = {
          common.default = [ "gtk" ];
          river.default = [
            "wlr"
            "gtk"
          ];
          niri.default = [
            "wlr"
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
      };
    }
    {
      services.xserver = {
        enable = !cfg.enable;
        autoRepeatDelay = 200;
        autoRepeatInterval = 30;
        autorun = true;
        xkb = {
          layout = "us";
          options = "eurosign:e,caps:escape";
        };
      };
    }
  ];
}
