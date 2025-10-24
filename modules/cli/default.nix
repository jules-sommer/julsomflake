{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption getModulesRecursive;
in {
  imports = getModulesRecursive ./. {max-depth = 1;};

  options.local.cli =
    mkOption {
    };

  config = {
    local.home.programs = with pkgs; [
      serie
      jq
    ];
  };
}
