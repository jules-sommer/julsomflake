{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) getExe getExe' enabled' mkCmd;
  loginctl = mkCmd [(getExe' pkgs.systemd "loginctl")];
  systemctl = mkCmd [(getExe' pkgs.systemd "systemctl")];

  hyprlock = getExe pkgs.hyprlock;
  niri = mkCmd [(getExe config.home.programs.niri.package)];

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
          action = hyprlock;
          text = "Lock";
          keybind = "l";
          icon = icon "lock";
        }
        {
          label = "logout";
          action = loginctl ["terminate-user" "$USER"];
          text = "Logout";
          keybind = "e";
          icon = icon "logout";
        }
        {
          label = "shutdown";
          action = systemctl ["poweroff"];
          text = "Shutdown";
          keybind = "s";
          icon = icon "shutdown";
        }
        {
          label = "lock-monitors";
          action = "${hyprlock} & sleep 0.5 && ${niri ["msg" "action" "power-off-monitors"]}";
          text = "Lock + Monitors Off";
          keybind = "L";
          icon = icon "lock";
        }
        {
          label = "reboot";
          action = systemctl ["reboot"];
          text = "Reboot";
          keybind = "r";
          icon = icon "reboot";
        }
        {
          label = "sleep";
          action = "${loginctl ["lock-sessions"]}; sleep 1; ${systemctl ["suspend"]}";
          text = "Sleep";
          keybind = "z";
          icon = icon "suspend";
        }
      ];
    };
  };
}
