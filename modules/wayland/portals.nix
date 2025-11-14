{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    types
    enabled
    mkIf
    mkOpt
    ;

  cfg = config.local.wayland;
  shouldEnablePortals = cfg.activeCompositor != null;

  portalPackages = with pkgs;
    [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gnome
    ]
    ++ (with pkgs.kdePackages; [
      xdg-desktop-portal-kde
    ]);
in {
  options.local.wayland.portals = mkOpt types.bool (
    cfg.enable && cfg.activeCompositor != null
  ) "Whether to enable wayland xdg-desktop-portal implementations.";

  config = mkIf shouldEnablePortals {
    environment.systemPackages = portalPackages;
    xdg.portal = {
      wlr = enabled;
      extraPortals = portalPackages;

      config = {
        common.default = ["gtk"];
        river.default = [
          "wlr"
          "gtk"
        ];
        niri.default = [
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
    };
  };
}
