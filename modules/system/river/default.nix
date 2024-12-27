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
        dunst
        scrot
        wshowkeys
        fuzzel
        cliphist
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
        enable = true;
        autoRepeatDelay = 200;
        autoRepeatInterval = 30;
        autorun = true;
        xkb = {
          layout = "us";
          options = "eurosign:e,caps:escape";
        };
      };

    };
    qt = {
      enable = true;
      style = "breeze";
      platformTheme = "kde";
    };
  };
}
