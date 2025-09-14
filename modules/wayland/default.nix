{
  helpers,
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (helpers) includeIf enabled enabledIf mkEnableOpt enabledPred mkOpt disabledIf enabled';
  inherit (lib) types attrsets foldl';
  inherit (attrsets) recursiveUpdate;
  cfg = config.local.wayland;
in {
  imports = [
    ./river
    ./waybar
    ./fuzzel
    ./kde_plasma
    ./mako
    ./niri
  ];

  options.local.wayland =
    (mkEnableOpt "Enable wayland support + portals.")
    // {
      login = {
        greetd = mkEnableOpt "Enable greetd login manager.";
        settings = {
          default_session = mkOpt types.str "river" "The default command to start our session with.";
        };
      };
    };

  config = foldl' recursiveUpdate {} [
    (includeIf cfg.login.greetd.enable {
      security.pam.services.greetd.enableGnomeKeyring = true;
      services.greetd = enabled' {
        settings.default_session.command = "${pkgs.tuigreet}/bin/tuigreet --cmd ${cfg.login.settings.default_session}";
      };
    })
    (includeIf cfg.enable {
      xdg.portal = {
        wlr = enabled;
        extraPortals = with pkgs;
          [
            xdg-desktop-portal-gtk
            xdg-desktop-portal-wlr
          ]
          ++ (with pkgs.kdePackages; [
            xdg-desktop-portal-kde
          ]);

        config = {
          common.default = ["gtk"];
          river.default = ["wlr" "gtk"];
          niri.default = ["wlr" "gtk"];
          hyprland.default = ["wlr" "gtk"];
          plasma.default = ["kde" "gtk"];
        };
      };
    })
    (includeIf (!cfg.enable) {
      services.xserver =
        (disabledIf cfg.enable)
        // {
          autoRepeatDelay = 200;
          autoRepeatInterval = 30;
          autorun = true;
          xkb = {
            layout = "us";
            options = "eurosign:e,caps:escape";
          };
        };
    })
  ];
}
