{
  lib,
  inputs,
  callPackage,
  ...
}: let
  inherit (lib) composeManyExtensions map foldlAttrs hasSuffix path;
  inherit (builtins) readDir;
  callOverlay = path: callPackage path {inherit inputs;};
in
  composeManyExtensions (map callOverlay (foldlAttrs (
    acc: k: v:
      if v == "regular" && (hasSuffix ".nix" k) && (k != "default.nix")
      then acc ++ [(path.append ./. k)]
      else acc ++ []
  ) [] (readDir ./.)))
#

