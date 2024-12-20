{ ... }:
{
  imports = [
    ./printing
    ./kernel
  ];

  local.audio = {
    pipewire.enable = true;
  };

  system.stateVersion = "24.05";
}
