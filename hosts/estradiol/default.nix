{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) enabled enabled';
in {
  imports = [
    ./hardware
    ./kernel
    ./printing
    ./stylix
    ./system
    ./users
  ];

  local = {
    programs = {
      kmail = enabled;
      libreoffice = enabled;
      masterpdf = enabled;
      okular = enabled;
    };
    stylix = enabled;
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

    home = {
      qt = enabled' (
        lib.mkDefault {
          platformTheme.name = "kde6";
          style.name = "breeze";
        }
      );

      xdg = {
        enable = true;
        configHome = /home/jules/.config;
      };

      programs = {
        rbw = enabled' {
          settings = {
            email = "rcsrc@pm.me";
          };
        };
        fzf = enabled;
        bat = enabled;
        ripgrep = enabled;
        nh = enabled' {
          flake = builtins.toString ./.;
          clean = {
            enable = true;
            dates = "weekly";
          };
        };
        lazygit.enable = true;
        direnv = enabled' {
          nix-direnv = enabled;
        };
        eza = enabled' {
          enableFishIntegration = true;
          icons = "always";
        };
        starship = enabled;
        waybar = enabled;
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
      };

      home.stateVersion = "24.11";

      home.packages = with pkgs; [
        ianny
        jan
        eza
        gh
        ghostty
        just
        gimp-with-plugins
        gitoxide

        vesktop
        joshuto
        broot
        dust
        chromium
        heroic
        audacity
        rofi-rbw-wayland
        bitwarden-desktop
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
      localsend
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
    icons.enable = true;
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

  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";

  networking = {
    networkmanager.enable = true;
    firewall.enable = false;

    hostName = "estradiol";
    hostId = lib.mkDefault "30a4185c";
  };
}
