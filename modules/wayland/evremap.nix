{lib, ...}: let
  inherit (lib) enabled';
  keys = import ./evremap/keys.nix {};
in {
  services.evremap = enabled' {
    devices = [
      {
        device_name = "SEMICO   USB Gaming Keyboard";
        device_path = "";
        phys = "usb-0000:10:00.0-2/input0";
        remap = with keys; [
          {
            input = [KEY_CAPSLOCK];
            output = [KEY_ESC];
          }
        ];
      }
    ];
  };
}
