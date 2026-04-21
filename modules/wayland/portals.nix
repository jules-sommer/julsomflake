{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    types
    concatLists
    enabled
    mkIf
    mkOpt
    ;

  cfg = config.local.wayland;

  portalPackages = concatLists [
    (with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gnome
    ])
    (with pkgs.kdePackages; [
      xdg-desktop-portal-kde
    ])
  ];
in {
  options.local.wayland.portals = mkOpt types.bool (
    cfg.enable && cfg.activeCompositor != null
  ) "Whether to enable wayland xdg-desktop-portal implementations.";

  config = {
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

        niri = {
          default = ["gtk"];
          "org.freedesktop.impl.portal.FileChooser" = ["kde"];
          "org.freedesktop.impl.portal.OpenURI" = ["kde"];
        };

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
