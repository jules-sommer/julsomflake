{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) enabled' optional mkEnableOption mkPackageOption flatten;
  cfg = config.local.cli.imv;
in {
  options.local.cli.imv = {
    enable = mkEnableOption "imv" // {default = true;};
    package = mkPackageOption "imv" {};
    setAsDefault = mkEnableOption "imv as default program for images" // {default = true;};
  };

  config.local.home = {
    xdg.mimeApps = {
      defaultApplicationPackages = flatten (optional cfg.setAsDefault [pkgs.imv]);
    };
    programs.imv = enabled' {
      settings = {
        options = {
          background = "checks";
          scaling_mode = "shrink";
        };
        aliases = {
          x = "close";
          h = "pan -50 0";
          j = "pan 0 -50";
          k = "pan 0 50";
          l = "pan 50 0";
        };
      };
    };
  };
}
