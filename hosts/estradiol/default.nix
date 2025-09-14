{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) enabled enabled';
in {
  imports = [
    ./system
    ./hardware
  ];

  local = {
    wayland = {
      river = enabled;

      login = {
        greetd = enabled;
        settings.default_session = "river";
      };
    };
    shells = {
      fish = enabled;
      zsh = enabled;

      extras = {
        direnv = enabled;
        nix-index = enabled;
      };
    };

    kernel.xanmod = enabled' {
      zfs.enable = false;
    };
    audio.pipewire = enabled' {
      settings = {
        compatibility = true;
        withExtras = true;
      };
    };
    programs = {
      kmail = enabled;
      libreoffice = enabled;
      masterpdf = enabled;
      okular = enabled;
    };
    stylix = enabled;
  };

  hardware = {
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

  nix.settings.extra-system-features = lib.mkForce [
    "gccarch-znver4"
  ];

  environment.systemPackages = with pkgs; [
    zed-editor
    zen-browser
    wl-clipboard
    wayshot
    kdePackages.spectacle
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
