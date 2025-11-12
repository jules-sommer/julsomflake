{lib, ...}: let
  inherit (lib) foldl' recursiveUpdate;
in {
  foldlAttrsRecursive = foldl' recursiveUpdate {};
}
