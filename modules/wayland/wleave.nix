{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) cmd getExe getExe' enabled';
  loginctl = getExe' pkgs.systemd "loginctl";
  systemctl = getExe' pkgs.systemd "systemctl";
  swaylock = getExe pkgs.swaylock-effects;
  niri = getExe config.home.programs.niri.package;

  icon = name: "${pkgs.wleave}/share/wleave/icons/${name}.svg";
in {
  local.home.programs.wleave = enabled' {
    settings = {
      margin = 200;
      buttons-per-row = "3";
      delay-command-ms = 100;
      close-on-lost-focus = true;
      show-keybinds = true;
      buttons = [
        {
          label = "lock";
          action = swaylock;
          text = "Lock";
          keybind = "l";
          icon = icon "lock";
        }
        {
          label = "logout";
          action = cmd [loginctl "terminate-user" "$USER"];
          text = "Logout";
          keybind = "e";
          icon = icon "logout";
        }
        {
          label = "shutdown";
          action = cmd [systemctl "poweroff"];
          text = "Shutdown";
          keybind = "s";
          icon = icon "shutdown";
        }
        {
          label = "lock-monitors";
          action = "sh -c '${swaylock} & sleep 0.5 && ${niri} msg action power-off-monitors'";
          text = "Lock + Monitors Off";
          keybind = "L";
          icon = icon "lock";
        }
        {
          label = "reboot";
          action = cmd [systemctl "reboot"];
          text = "Reboot";
          keybind = "r";
          icon = icon "reboot";
        }
      ];
    };
  };
}
