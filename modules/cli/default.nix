{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption getModulesRecursive foldl' concat;
in {
  imports = getModulesRecursive ./. {max-depth = 2;};

  config.local.home.home.packages = foldl' concat [] [
    (with pkgs; [
      serie
      dust
      caligula
      vimv-rs
    ])
    (with pkgs.kdePackages; [
      ark
    ])
  ];
}
