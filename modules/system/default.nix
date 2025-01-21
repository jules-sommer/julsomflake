{
  pkgs,
  ...
}:
{
  imports = [
    ./audio
    ./documents+pdf
    ./fish
    ./kmail
    ./security
    ./nix
    ./river
    ./users
    ./xanmod_kernel
    ./fonts
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
      protonvpn-cli
      radeontop
      nixfmt-rfc-style
      neovim
      bitwarden-cli
      nixVersions.git # install latest (git master) version of nix pkg manager
      btop
      mpv
      kitty
      localsend
    ];
  };

  programs = {
    fuse = {
      userAllowOther = true;
      mountMax = 1000;
    };
    wireshark = {
      enable = true;
    };
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

  services = {
    evremap = {
      enable = true;
      settings = {
        device_name = "Evision RGB Keyboard";
        dual_role = [
          {
            input = "KEY_CAPSLOCK";
            hold = [ "KEY_CAPSLOCK" ];
            tap = [ "KEY_GRAVE" ];
          }
        ];
      };
    };

    protonmail-bridge = {
      enable = true;
      path = with pkgs; [
        pass
        gnome-keyring
      ];
    };
  };

  xdg.icons.enable = true;

  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";
}
