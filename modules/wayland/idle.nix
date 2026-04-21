{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) enabled' getExe' getExe;
in {
  security.pam.services.swaylock = {};
  local.home = {
    programs.swaylock = enabled' {
      package = pkgs.swaylock-effects;

      settings = {
        grace = 2;
        grace-no-mouse = true;
        grace-no-touch = true;

        daemonize = true;
        ignore-empty-password = true;
        show-failed-attempts = true;

        # Appearance (swaylock-effects specific)
        screenshots = true;
        clock = true;
        timestr = "%-I:%M %p";
        datestr = "";

        # Font
        font = "JetBrainsMono NF Light";
        font-size = 48;

        # Indicator
        indicator = true;
        indicator-radius = 150;
        indicator-thickness = 4;

        # Effects (swaylock-effects specific)
        effect-blur = "25x3";
        effect-vignette = "0.25:0.25";

        # Colors
        fade-in = 0.5;
        ring-color = "c4a7e760";
        key-hl-color = "eb6f92";
        line-color = "00000000";
        text-color = "c4a7e7ff";
        inside-color = "ffffff05";
        separator-color = "eb6f92ff";
      };
    };

    services.swayidle = enabled' {
      systemdTargets = [config.home.wayland.systemd.target];
      events = {
        before-sleep = "${getExe' pkgs.systemd "loginctl"} lock-session";
        lock = "${getExe' pkgs.systemd "loginctl"} lock-session";
      };
      timeouts = [
        {
          timeout = 300;
          command = "${getExe' pkgs.systemd "loginctl"} lock-session";
        }
        {
          timeout = 600;
          command = "${getExe pkgs.niri} msg action power-off-monitors";
          resumeCommand = "${getExe pkgs.niri} msg action power-on-monitors";
        }
      ];
    };

    systemd.user.services.swaylock = {
      Unit = {
        Description = "Screen locker for Wayland";
        PartOf = [config.home.wayland.systemd.target];
        After = [config.home.wayland.systemd.target];
      };

      Service = {
        ExecStart = getExe pkgs.swaylock-effects;
        Restart = "on-failure";
        RestartSec = 1;
      };

      Install.WantedBy = ["lock.target" "xdg-desktop-autostart.target"];
    };
  };
}
