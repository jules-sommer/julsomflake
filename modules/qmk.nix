{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) enabled;
in {
  hardware.keyboard.qmk = enabled;
  environment.systemPackages = with pkgs; [
    qmk
    qmk_hid
    hid-listen
    keymap-drawer
    wev
    qmk-udev-rules
    keymapviz
  ];
}
