{ inputs, channels }:
let
  importOverlay = path: import path { inherit inputs channels; };

  zig = importOverlay ./zig;
  zen-browser = importOverlay ./zen-browser;
  unfree-pkgs = importOverlay ./unfree-pkgs;
  zls = importOverlay ./zls;

  allOverlays = [
    zig
    zen-browser
    unfree-pkgs
    zls
  ];
in
{
  # Return the combined overlay
  default = final: prev: builtins.foldl' (acc: overlay: acc // (overlay final prev)) { } allOverlays;
  inherit
    zig
    zen-browser
    unfree-pkgs
    zls
    ;
}
