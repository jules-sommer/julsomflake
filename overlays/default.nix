{
  lib,
  inputs,
  callPackage,
  ...
}: let
  inherit (lib) composeManyExtensions map;
  callOverlay = path: callPackage path {inherit inputs;};
in
  composeManyExtensions (map callOverlay [
    ./unfree.nix
    ./zen-browser
  ])
