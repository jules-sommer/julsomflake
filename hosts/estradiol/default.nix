{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) enabled enabled' getModulesRecursive;
in {
  imports = getModulesRecursive ./. {};

  specialisation = {
    niri.configuration = {
      system.nixos.tags = ["niri"];

      local.wayland = {
        niri = enabled;
        login.settings.default_session = "niri";
      };
    };

    plasma.configuration = {
      system.nixos.tags = ["plasma"];

      local.wayland = {
        plasma = enabled;
        login.settings.default_session = "startplasma-wayland";
      };
    };

    river.configuration = {
      system.nixos.tags = ["river"];

      local.wayland = {
        river = enabled;
        login.settings.default_session = "river";
      };
    };
  };

  local = {
    meta = {
      primaryUser = {
        username = "jules";
        email = "jsomme@pm.me";
        full_name = "Jules Sommer";
      };
    };
    wayland = enabled' {
      login.greetd = enabled;
    };

    stylix = enabled;

    cli = {
      joshuto = enabled;
      btop = enabled;
      helix = enabled;
      starship = enabled;
    };

    programs = {
      kmail = enabled;
      libreoffice = enabled;
      masterpdf = enabled;
      okular = enabled;
    };

    shells = {
      fish = enabled;
      zsh = enabled;
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
        claude-code =
          enabled' {
          };
        fzf = enabled;
        ripgrep = enabled;
        git = enabled' {
          delta = enabled;
          ignores = [
            "*~"
            "~*"
            "zig-out/**/*"
            ".zig-cache/**/*"
            "target/**/*"
          ];
        };
      };

      home.sessionVariables = {
        EDITOR = "nvim";
        MANPAGER = "nvim +Man!";
        SCREENSHOT_DIR = "/home/jules/060_media/005_screenshots";
        TERMINAL = "kitty";
      };

      home.stateVersion = "24.11";

      home.packages = with pkgs;
        [
          jan
          eza
          jq
          gh
          ghostty
          just
          gimp-with-plugins
          gitoxide
          vesktop
          joshuto
          broot
          dust
          helium
          heroic
          audacity
          rofi-rbw-wayland
          bitwarden-desktop
        ]
        ++ (with pkgs.kdePackages; [
          ark
          dolphin
        ]);
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
    wireshark = enabled;
    mtr = enabled;
    nix-ld = enabled;
    fuse = {
      userAllowOther = true;
      mountMax = 1000;
    };

    gnupg.agent = enabled' {
      enableSSHSupport = true;
    };
    git = {
      lfs = enabled' {
        enablePureSSHTransfer = true;
      };
      config = {
        init = {
          defaultBranch = "main";
        };
        url = {
          "https://github.com/" = {
            insteadOf = [
              "gh:"
              "github:"
            ];
          };
        };
      };
    };
  };

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  system.stateVersion = "24.05";

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

  nix.settings.extra-system-features = lib.mkForce [
    "gccarch-znver4"
  ];

  environment = {
    systemPackages = with pkgs; [
      zed-editor
      zen-browser
      wl-clipboard
      wayshot
      kdePackages.spectacle
      tmux
      gh
      uutils-coreutils-noprefix
      protonvpn-cli
      radeontop
      nixfmt-rfc-style
      neovim
      bitwarden-cli
      nixVersions.latest
      masterpdfeditor4
      btop
      mpv
      kitty
    ];

    variables = {
      LOG_ICONS = "true";
      KITTY_ENABLE_WAYLAND = "1";
      EDITOR = "nvim";
      NIX_BUILD_CORES = 2;
      GC_INITIAL_HEAP_SIZE = "8G";
      MANPAGER = "nvim +Man!";
    };
  };

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
    protonmail-bridge = {
      enable = true;
      path = with pkgs; [
        pass
        gnome-keyring
      ];
    };
  };

  networking = {
    hostName = "estradiol";
    hostId = lib.mkDefault "30a4185c";
  };
}
