{
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOpt enabled' mkIf;
  keys = lib.callPackage ./keys.nix {};
  cfg = config.local.evremap;
in {
  options.local.evremap = mkEnableOpt "Enable evremap key remapping service.";
  config.services.evremap = mkIf (cfg.enable) (enabled' {
    settings = {
      device_name = "Evision RGB Keyboard";
      phys = "usb-0000:10:00.0-2/input0";

      dual_role = [
        {
          input = keys.KEY_CAPSLOCK;
          hold = keys.KEY_CAPSLOCK;
          tap = keys.KEY_GRAVE;
        }
        {
          input = "KEY_RIGHTSHIFT";
          hold = ["KEY_SUPER"];
          tap = ["KEY_RIGHTSHIFT"];
        }
      ];
    };
  });
}
