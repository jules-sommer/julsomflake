{ pkgs, lib, ... }:
let
  inherit (lib) disabled enabled;
in
{
  imports = [
    ./btop
    ./waybar
    ./kitty
    ./fish
    ./river
    ./starship
    ./helix
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
      monospace = [ "JetBrainsMono Nerd Font" ];
      sansSerif = [ "NotoSans Nerd Font" ];
      serif = [ "NotoSans Nerd Font" ];
    };
  };

  home = {
    packages = with pkgs; [
      ianny
      jan
      eza
      gh
      ghostty
      just
      vesktop
      joshuto
      broot
      dust
      chromium
    ];

    sessionVariables = {
      EDITOR = "nvim";
      MANPAGER = "nvim +Man!";
    };

    stateVersion = "24.11";
  };

  stylix = {
    enable = true;
    autoEnable = true;
    targets = {
      kitty = enabled;
      fuzzel = enabled;
    };
    iconTheme = {
      dark = "breeze-dark";
      light = "breeze";
      package = pkgs.breeze-icons;
    };
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
