{lib, ...}: let
  inherit (lib) enabled';
  keys = import ./evremap/__keys.nix;
in {
  services.evremap = enabled' {
    devices = [
      {
        device_name = "SEMICO   USB Gaming Keyboard ";
        device_path = "/dev/input/by-id/usb-SEMICO_USB_Gaming_Keyboard-event-kbd";
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
