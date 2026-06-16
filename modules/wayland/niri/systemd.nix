{
  config,
  lib,
  ...
}: let
  inherit (lib) getExe mkCmd;
  niri = mkCmd [(getExe config.programs.niri.package)];
  target = config.home.wayland.systemd.target;
in {
  # systemd.user.services.niri = {
  #   description = "A scrollable-tiling Wayland compositor";
  #   bindsTo = [target];
  #   before = [target "xdg-desktop-autostart.target"];
  #   wants = ["graphical-session-pre.target" "xdg-desktop-autostart.target"];
  #   after = ["graphical-session-pre.target"];
  #   serviceConfig = {
  #     Slice = "session.slice";
  #     Type = "notify";
  #     ExecStart = niri ["--session"];
  #   };
  # };
  #
  # systemd.user.targets.niri-shutdown = {
  #   description = "Shutdown running niri session";
  #   conflicts = [target "graphical-session-pre.target"];
  #   after = [target "graphical-session-pre.target"];
  #   unitConfig = {
  #     DefaultDependencies = false;
  #     StopWhenUnneeded = true;
  #   };
  # };
}
