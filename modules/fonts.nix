{
  pkgs,
  lib,
  helpers,
  ...
}: let
  inherit (helpers) enabled enabled';
  inherit (lib) concatLists types mkOption genAttrs;
in {
  local.ui.fonts = {
    packages = concatLists [
      (with pkgs.nerd-fonts; [
        jetbrains-mono
        fira-code
        zed-mono
        victor-mono
        sauce-code-pro
        open-dyslexic
        lilex
        iosevka
        iosevka-term
        iosevka-term-slab
        hack
      ])
      (with pkgs; [
        google-fonts
        maple-mono.NF
        iosevka
      ])
    ];
    defaults = {
      monospace = {
        name = "JetBrainsMono Nerd Font";
        package = pkgs.nerd-fonts.jetbrains-mono;
      };
      emoji = {
        name = "Noto Color Emoji";
        package = pkgs.noto-fonts-color-emoji;
      };
      serif = {
        name = "IosevkaSlab Nerd Font";
        package = pkgs.nerd-fonts.iosevka-term-slab;
      };
      sans-serif = {
        name = "NotoSans Nerd Font";
        package = pkgs.nerd-fonts.noto;
      };
    };
    sizes = {
      applications = 16;
      popups = 16;
      terminal = 16;
      desktop = 16;
    };
  };
}
