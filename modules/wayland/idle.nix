{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) enabled' getExe;
  swaylock-pkg = config.home.programs.swaylock.package;
  niri-pkg = config.home.programs.niri.package;
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
    services.swayidle = let
      lock = "${getExe swaylock-pkg} --daemonize";
      display = status: "${getExe niri-pkg} msg action power-${status}-monitors";

      minutes = min: min * lib.time.s_per_min;
    in
      enabled' {
        timeouts = [
          {
            timeout = 60;
            command = display "off";
            resumeCommand = display "on";
          }
          {
            timeout = minutes 15;
            command = "${pkgs.libnotify}/bin/notify-send 'Locking in 5 seconds' -t ${5 * lib.time.ms_per_s |> toString}";
          }
          {
            timeout = (minutes 15) + 5;
            command = lock;
          }
          {
            timeout = minutes 30;
            command = "${pkgs.systemd}/bin/systemctl suspend --check-inhibitors";
          }
        ];
        events = {
          before-sleep = lock;
          after-resume = "sleep 2; " + display "on";
          lock = (display "off") + "; " + lock;
          unlock = display "on";
        };
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
