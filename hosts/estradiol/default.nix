{
  lib,
  pkgs,
  src,
  ...
}: let
  inherit (lib) enabled enabled' disabled getModulesRecursive;
in {
  imports = getModulesRecursive ./. {};

  specialisation = {
    niri.configuration = {
      system.nixos.tags = ["niri"];
      local.wayland.activeCompositor = "niri";
    };

    plasma.configuration = {
      system.nixos.tags = ["plasma"];
      local.wayland.activeCompositor = "plasma";
    };

    river.configuration = {
      system.nixos.tags = ["river"];
      local.wayland.activeCompositor = "river";
    };
  };

  boot.initrd.kernelModules = ["amdgpu"];

  local = {
    meta = {
      primaryUser = {
        username = "jules";
        email = "jsomme@pm.me";
        full_name = "Jules Sommer";
      };
    };

    wayland = enabled' {
      portals = true;
      login.greetd = enabled;
    };

    cli = {
      joshuto = enabled;
      nnn = enabled;
      btop = enabled;
      helix = disabled;
      starship = enabled;
    };

    programs = {
      kmail = disabled;
      libreoffice = enabled;
      masterpdf = enabled;
      okular = enabled;
    };

    shells = {
      fish = enabled;
      zsh = enabled;
    };

    stylix = enabled;
    gaming = enabled;
    development = enabled;
    bitwarden = enabled;

    communication = {
      discord = true;
      signal = true;
    };

    kernel.xanmod = enabled' {
      zfs.enable = false;
    };

    home = {
      programs = {
        rbw = enabled' {
          settings = {
            email = "rcsrc@pm.me";
          };
        };
      };

      home.sessionVariables = {
        NIXOS_FLAKE_DIR = "/home/jules/000_dev/000_nix/julsomflake";
        QMK_HOME = "/home/jules/000_dev/090_qmk/qmk_firmware";
        EDITOR = "nvim";
        MANPAGER = "nvim +Man!";
        SCREENSHOT_DIR = "/home/jules/060_media/005_screenshots";
        # WALLPAPER = "/home/jules/060_media/010_wallpapers/zoe-love-bg/zoe-love-4k.png";
        WALLPAPER = "/home/jules/060_media/010_wallpapers/rose_pine_contourline.png";
        TERMINAL = "kitty";
      };

      home.stateVersion = "24.11";

      home.packages = with pkgs; [
        helium
        gimp-with-plugins
        julespkgs.screenshot
      ];
    };

    audio.pipewire = enabled' {
      settings = {
        compatibility = true;
        withExtras = true;
      };
    };
  };

  programs = {
    wshowkeys = enabled;
    nix-ld = enabled;
    fuse = {
      userAllowOther = true;
      mountMax = 1000;
    };
  };

  environment = {
    systemPackages = with pkgs; [
      zen-browser
      masterpdfeditor4
      inkscape-with-extensions
      btop
      mpv
      jmtpfs
      libmtp
    ];

    variables = {
      LOG_ICONS = "true";
      KITTY_ENABLE_WAYLAND = "1";
      EDITOR = "nvim";
      GC_INITIAL_HEAP_SIZE = "8G";
      MANPAGER = "nvim +Man!";
    };
  };

  # Ryzen 5 7600X
  # 12 cores on estradiol
  # 4.4 <-> 5.4 GHz clock speed

  # These settings allow nix builders to do the following:
  #   1. Build a maximum of 3 derivations at once.
  #   2. Each derivation being built gets access to 4 cores.
  #   3. This means that 3 jobs running with 4 cores use all 12 cores.
  nix.settings = {
    max-jobs = 3;
    cores = 4;
  };

  environment.variables.NIX_BUILD_CORES = 4;

  xdg = {
    icons = enabled;
    mime = enabled' {
      defaultApplications = {
        "x-scheme-handler/http" = ["zen.desktop"];
        "x-scheme-handler/https" = ["zen.desktop"];
        "image/*" = ["imv.desktop"];
        "video/*" = ["mpv.desktop"];
        "application/pdf" = ["okular.desktop"];
        "text/*" = ["nvim.desktop"];
      };
    };
  };

  services = {
    gvfs = enabled;
    protonmail-bridge = {
      enable = true;
      path = with pkgs; [
        pass
      ];
    };
  };

  networking = {
    hostName = "estradiol";
    hostId = lib.mkDefault "30a4185c";
  };
}
