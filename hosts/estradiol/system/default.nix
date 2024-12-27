{ ... }:
{
  imports = [
    ./printing
    ./kernel
  ];

  local.audio = {
    pipewire.enable = true;
  };

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  system.stateVersion = "24.05";
}
