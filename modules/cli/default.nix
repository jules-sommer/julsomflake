{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption getModulesRecursive;
in {
  imports = getModulesRecursive ./. {max-depth = 2;};

  options.local.cli =
    mkOption {
    };

  config.local.home.home.packages = with pkgs; [
    serie
  ];
}
