{
  pkgs,
  lib,
  helpers,
  ...
}: let
  inherit (helpers) enabled enabled';
in {
  fonts = {
    fontDir = enabled;
    enableDefaultPackages = true;
    fontconfig = enabled' {
      subpixel.rgba = "rgb";
      includeUserConf = true;
      antialias = true;
      hinting = enabled' {
        style = "slight";
      };
    };

    packages = with pkgs.nerd-fonts; [
      jetbrains-mono
      fira-code
      zed-mono
      iosevka
      victor-mono
      sauce-code-pro
      open-dyslexic
      lilex
      hack
    ];
  };

  home-manager.users.jules.fonts.fontconfig = enabled' {
    defaultFonts = {
      emoji = ["Noto Color Emoji"];
      monospace = ["JetBrainsMono Nerd Font"];
      sansSerif = ["NotoSans Nerd Font"];
      serif = ["NotoSans Nerd Font"];
    };
  };
}
