{
  lib,
  helpers,
  config,
  ...
}: let
  inherit (helpers) enabled enabled';
  inherit (lib) mkOption mkIf types foldl' recursiveUpdate genAttrs;
  fonts = config.local.ui.fonts;
  inherit (lib) optional;
  inherit (config.local.ui.fonts) defaults;
  fontPkgs = builtins.filter (p: p != null) (
    map (f:
      if f != null
      then f.package
      else null) (
      builtins.attrValues defaults
    )
  );

  defaultFonts = {
    monospace = optional (defaults.monospace != null) defaults.monospace.name;
    sansSerif = optional (defaults.sans-serif != null) defaults.sans-serif.name;
    serif = optional (defaults.serif != null) defaults.serif.name;
    emoji = optional (defaults.emoji != null) defaults.emoji.name;
  };
in {
  fonts = {
    fontDir = enabled;
    enableDefaultPackages = true;
    packages = fontPkgs ++ fonts.packages;
    fontconfig = enabled' {
      inherit defaultFonts;
      subpixel.rgba = fonts.subpixel;
      includeUserConf = true;
      antialias = fonts.antialias;
      hinting = {
        inherit (fonts.hinting) enable style;
        autohint = fonts.hinting.enable && fonts.hinting.style != "none";
      };
    };
  };

  local.home.fonts.fontconfig = {
    inherit defaultFonts;
    antialiasing = true;
    hinting = mkIf (fonts.hinting.enable != false) fonts.hinting.style;

    subpixelRendering = fonts.subpixel;
  };

  stylix.fonts = {
    sizes = {inherit (fonts.sizes) applications terminal desktop popups;};

    monospace = mkIf (defaults.monospace != null) {inherit (defaults.monospace) name package;};
    sansSerif = mkIf (defaults.sans-serif != null) {inherit (defaults.sans-serif) name package;};
    serif = mkIf (defaults.serif != null) {inherit (defaults.serif) name package;};
    emoji = mkIf (defaults.emoji != null) {inherit (defaults.emoji) name package;};
  };
}
