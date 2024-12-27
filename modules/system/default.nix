{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkIf;
in
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

  services.evremap = {
    enable = false;
    settings = {
      device_name = "Evision RGB Keyboard";
      dual_role = [
        {
          input = "KEY_CAPSLOCK";
          hold = [ "KEY_LEFTCTRL" ];
          tap = [ "KEY_ESC" ];
        }
      ];
    };
  };

  xdg.icons.enable = true;

  programs = {
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

  fonts = {
    fontDir.enable = true;
    enableDefaultPackages = true;
    fontconfig = {
      enable = true;
      subpixel.rgba = "rgb";
      includeUserConf = true;
      antialias = true;
      hinting = {
        enable = true;
        style = "full";
      };
    };
    packages =
      (with pkgs.nerd-fonts; [
        jetbrains-mono
        fira-code
        zed-mono
        iosevka
        victor-mono
        sauce-code-pro
        open-dyslexic
        lilex
        hack
      ])
      ++ (with pkgs; [
        #   fira-code
        #   jetbrains-mono
        #   roboto-mono
        #   roboto-slab
        #   roboto-serif
        #   fira-sans
        #   source-sans
        #   source-serif
        #   source-code-pro
        #   hack-font
        #   noto-fonts
        #   open-dyslexic
        #   font-awesome
        #   noto-fonts-emoji
      ]);
  };

  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";
}
