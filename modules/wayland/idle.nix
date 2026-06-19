{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) enabled' getExe getExe' mkShellCmd mkCmd;

  notify-send = mkCmd [(getExe pkgs.libnotify)];
  systemctl = mkCmd [(getExe' pkgs.systemd "systemctl")];

  hyprlock-pkg = config.home.programs.hyprlock.package;
  niri-pkg = config.home.programs.niri.package;
in {
  local.home.services.swayidle = let
    lock = getExe (pkgs.writers.writeFishBin "lock-session" ''
      ${getExe niri-pkg} msg action do-screen-transition --delay-ms 300
      ${getExe hyprlock-pkg}
    '');

    display = status: "${getExe niri-pkg} msg action power-${status}-monitors";

    minutes = min: min * lib.time.s_per_min;
  in
    enabled' {
      timeouts = [
        {
          timeout = minutes 2;
          command = display "off";
          resumeCommand = display "on";
        }
        {
          timeout = minutes 15;
          command = notify-send ["'Locking in 5 seconds'" "-t" (5 * lib.time.ms_per_s |> toString)];
        }
        {
          timeout = (minutes 15) + 5;
          command = lock;
        }
        {
          timeout = minutes 30;
          command = systemctl ["suspend"];
        }
      ];
      events = {
        before-sleep = lock;
        after-resume = display "off" + "; sleep 0.5; " + display "on" + "; " + systemctl ["--user" "restart" "swayidle.service"];
        lock = (display "off") + "; " + lock;
        unlock = display "on";
      };
    };
}
