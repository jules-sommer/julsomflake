{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) cmd getExe getExe' enabled' getBinary;
  loginctl = getExe' pkgs.systemd "loginctl";
  systemctl = getExe' pkgs.systemd "systemctl";
  swaylock = getExe pkgs.swaylock-effects;
in {
  local.home.programs.wleave = enabled' {
    settings = {
      margin = 200;
      buttons-per-row = "1/1";
      delay-command-ms = 100;
      close-on-lost-focus = true;
      show-keybinds = true;
      buttons = [
        {
          label = "lock";
          action = swaylock;
          text = "Lock";
          keybind = "l";
          icon = "${pkgs.wleave}/share/wleave/icons/lock.svg";
        }
        {
          label = "logout";
          action = cmd [loginctl "terminate-user" "$USER"];
          text = "Logout";
          keybind = "e";
          icon = "${pkgs.wleave}/share/wleave/icons/logout.svg";
        }
        {
          label = "shutdown";
          action = cmd [systemctl "poweroff"];
          text = "Shutdown";
          keybind = "s";
          icon = "${pkgs.wleave}/share/wleave/icons/shutdown.svg";
        }
      ];
    };
  };
}
