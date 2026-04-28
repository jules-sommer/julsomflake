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
in {
  fonts = {
    fontDir = enabled;
    enableDefaultPackages = true;
    packages = fontPkgs ++ fonts.packages;
    fontconfig = enabled' {
      subpixel.rgba = "rgb";
      includeUserConf = true;
      antialias = true;
      hinting = enabled' {
        style = "slight";
      };
      defaultFonts = {
        monospace = optional (defaults.monospace != null) defaults.monospace.name;
        sansSerif = optional (defaults.sans-serif != null) defaults.sans-serif.name;
        serif = optional (defaults.serif != null) defaults.serif.name;
        emoji = optional (defaults.emoji != null) defaults.emoji.name;
      };
    };
  };

  # local.home.fonts.fontconfig.defaultFonts = {
  #   # emoji = optional (defaults.emoji != null) [defaults.emoji.name];
  #   serif = optional (defaults.serif != null) [defaults.serif.name];
  #   sansSerif = optional (defaults.sansSerif != null) [defaults.sansSerif.name];
  #   monospace = optional (defaults.monospace != null) [defaults.monospace.name];
  # };
  stylix.fonts = {
    sizes = defaults.sizes or {};

    monospace = mkIf (defaults.monospace != null) {inherit (defaults.monospace) name package;};
    sansSerif = mkIf (defaults.sans-serif != null) {inherit (defaults.sans-serif) name package;};
    serif = mkIf (defaults.serif != null) {inherit (defaults.serif) name package;};
    emoji = mkIf (defaults.emoji != null) {inherit (defaults.emoji) name package;};
  };
}
