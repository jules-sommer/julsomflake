{ pkgs, lib, ... }:
{
  imports = [
    ./btop
    ./waybar
    ./kitty
    ./fish
    ./river
    ./starship
  ];

  local = {
    kitty.enable = true;
    river.enable = true;
    starship.enable = true;
    fish.enable = true;
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      emoji = [ "Noto Color Emoji" ];
      monospace = [ "JetBrains Mono" ];
      sansSerif = [ "Noto" ];
      serif = [ "Iosevka" ];
    };
  };

  home = {
    packages = with pkgs; [
      ianny
      eza
      just
    ];

    sessionVariables = {
      EDITOR = "nvim";
      MANPAGER = "nvim +Man!";
    };

    stateVersion = "24.11";
  };

  programs = {
    ripgrep.enable = true;
    nh = {
      enable = true;
      flake = ./.;
      clean = {
        enable = true;
        dates = "weekly";
      };
    };
    git = {
      enable = true;
      delta = {
        enable = true;
      };
      ignores = [
        "*~"
        "~*"
        "zig-out/**/*"
        ".zig-cache/**/*"
        "target/**/*"
      ];
    };
    lazygit.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    eza = {
      enable = true;
      enableFishIntegration = true;
      icons = "always";
    };
    fuzzel = {
      settings = {
        main = {
          terminal = "kitty -e";
          icon-theme = "breeze";
        };
      };
    };
  };

  xdg = {
    enable = true;
    configHome = /home/jules/.config;
  };
}
