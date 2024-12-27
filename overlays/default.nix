{ inputs, channels }:
let
  importOverlay = path: import path { inherit inputs channels; };
  overlayIncludes = [
    ./zig
    ./zen-browser
    ./unfree-pkgs
  ];

  zig = importOverlay ./zig;
  zen-browser = importOverlay ./zen-browser;
  unfree-pkgs = importOverlay ./unfree-pkgs;

  # Combine all overlays
  allOverlays = [
    zig
    zen-browser
    unfree-pkgs
  ];
in
{
  # Return the combined overlay
  default = final: prev: builtins.foldl' (acc: overlay: acc // (overlay final prev)) { } allOverlays;

  inherit zig zen-browser unfree-pkgs;
}
