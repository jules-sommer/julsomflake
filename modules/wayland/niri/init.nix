{
  pkgs,
  lib,
  config,
  ...
}: let
  niri-session-init = pkgs.writeShellScript "niri-session-init" ''
    ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all
    ${pkgs.systemd}/bin/systemctl --user import-environment PATH
  '';
in {
  config = {
    local.home = {
      programs.niri.settings = {
        environment = {
          XDG_CURRENT_DESKTOP = "niri";
          QT_QPA_PLATFORMTHEME = config.qt.platformTheme;
          QT_STYLE_OVERRIDE = config.qt.style;
        };

        spawn-at-startup = [
          {argv = ["${niri-session-init}"];}
        ];
      };

      # systemd.user.targets.niri-session = {
      #   Unit = {
      #     Description = "Niri compositor session";
      #     Documentation = ["man:systemd.special(7)"];
      #     BindsTo = ["graphical-session.target"];
      #     Wants = ["graphical-session-pre.target"];
      #     After = ["graphical-session-pre.target"];
      #   };
      # };
    };
  };
}
