{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) enabled enabled';
in
{
  imports = [
    ./system
    ./hardware
  ];

  local = {
    kernel.xanmod = enabled' {
      zfs.enable = true;
    };
    audio.pipewire = enabled' {
      enableBackCompat = true;
    };
    programs = {
      kmail = enabled;
      libreoffice = enabled;
      masterpdf = enabled;
      okular = enabled;
    };
    river = enabled;
    shell.fish = enabled;
    stylix = enabled;
  };

  hardware.amdgpu = {
    opencl.enable = true;
    initrd.enable = true;
    amdvlk = {
      enable = true;
      supportExperimental.enable = true;
      support32Bit.enable = true;
      settings = { };
    };
  };

  nix.settings.extra-system-features = lib.mkForce [
    "gccarch-znver4"
  ];

  environment.systemPackages = with pkgs; [
    zen-browser
    wl-clipboard
    wayshot
    spectacle
  ];

  programs = {
    nix-ld.enable = true;
    nix-index = {
      enable = true;
      enableFishIntegration = true;
    };
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };
  networking = {

    networkmanager.enable = true;
    firewall.enable = false;

    hostName = "estradiol";
    hostId = lib.mkDefault "30a4185c";
  };
}
