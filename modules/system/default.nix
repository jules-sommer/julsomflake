{
  pkgs,
  lib,
  ...
}: let
  inherit (lib) enabled enabled';
in {
  imports = [
    ./documents+pdf
    ./kmail
    ./security
    ./nix
    ./users
    ./xanmod_kernel
    ./evremap
  ];

  environment = {
    variables = {
      LOG_ICONS = "true";
      KITTY_ENABLE_WAYLAND = "1";
      EDITOR = "nvim";
      NIX_BUILD_CORES = 2;
      GC_INITIAL_HEAP_SIZE = "8G";
      MANPAGER = "nvim +Man!";
    };

    systemPackages = with pkgs; [
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
  };

  programs = {
    starship = enabled' {
      presets = ["nerd-font-symbols"];
    };
    fuse = {
      userAllowOther = true;
      mountMax = 1000;
    };
    wireshark = enabled;
    wshowkeys.enable = true;
    waybar.enable = true;
    git = {
      enable = true;
      lfs = {
        enable = true;
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
  xdg = {
    mime = {
      enable = true;
      defaultApplications = {
        "x-scheme-handler/http" = ["zen.desktop"];
        "x-scheme-handler/https" = ["zen.desktop"];
        "image/*" = ["imv.desktop"];
        "video/*" = ["mpv.desktop"];
        "application/pdf" = ["okular.desktop"];
        "text/*" = ["nvim.desktop"];
      };
    };

    icons.enable = true;
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
}
