{ lib, config, ... }:
let
  inherit (lib) mkEnableOpt;
  keys = lib.callPackage ./keys.nix { };
  cfg = config.local.evremap;
in
{
  options.local = {
    evremap = mkEnableOpt "Enable evremap key remapping service.";
  };
  config = {
    services = {
      evremap = {
        inherit (cfg) enable;
        settings = {
          device_name = "Evision RGB Keyboard";
          phys = "usb-0000:10:00.0-2/input0";

          dual_role = [
            {
              input = keys.KEY_CAPSLOCK;
              hold = [ "KEY_CAPSLOCK" ];
              tap = [ "KEY_GRAVE" ];
            }
            {
              input = "KEY_RIGHTSHIFT";
              hold = [ "KEY_SUPER" ];
              tap = [ "KEY_RIGHTSHIFT" ];
            }
          ];
        };
      };
    };
  };
}
