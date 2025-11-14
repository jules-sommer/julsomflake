{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkForce enabled enabled';
in {
  local.audio = {
    pipewire.enable = true;
  };

  environment.systemPackages = with pkgs; [radeontop];

  hardware = {
    keyboard.qmk = enabled;
    cpu.amd.ryzen-smu = enabled;
    graphics = enabled' {
      enable32Bit = true;
      extraPackages = with pkgs; [
        vulkan-loader
        vulkan-validation-layers
        vulkan-extension-layer
      ];
    };
  };

  nix.settings.extra-system-features = mkForce [
    "gccarch-znver4"
  ];

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  system.stateVersion = "24.05";
}
