{ pkgs, ... }:
{
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
}
