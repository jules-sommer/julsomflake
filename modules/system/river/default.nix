{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption;
  cfg = config.local.river;
in
{
  options.local.river = {
    enable = mkEnableOption "Enable river wm.";
  };

  config = {
    programs.river = {
      inherit (cfg) enable;
      xwayland.enable = true;
      extraPackages = with pkgs; [
        wayland-protocols
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
        dunst
        scrot
        wlr-randr
        slurp
        grim
        mpv
        river-bnf
        river-tag-overlay
        wshowkeys
        fuzzel
        cliphist
        lswt
        wlrctl
        ydotool
        waylock
        wbg
        brightnessctl
        imv
      ];
    };

    security = {
      polkit.enable = true;
      pam = {
        services.waylock = { };
      };
    };

    xdg = {
      portal = {
        wlr.enable = true;
        extraPortals = [
          pkgs.xdg-desktop-portal-gtk
          pkgs.xdg-desktop-portal-wlr
        ];
        config.river.default = lib.mkDefault [
          "wlr"
          "gtk"
        ];
      };
    };

    services = {
      greetd.enable = true;
      greetd.settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd river";
        };
      };

      xserver = {
        enable = false;
        autoRepeatDelay = 200;
        autoRepeatInterval = 30;
        autorun = true;
        xkb = {
          layout = "us";
          options = "eurosign:e,caps:escape";
        };
      };

    };
  };
}
