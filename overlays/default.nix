{ inputs, channels }:
let
  importOverlay = name: import ./${name} { inherit inputs channels; };

  zig = importOverlay "zig";
  zen-browser = importOverlay "zen-browser";
  unfree-pkgs = importOverlay "unfree-pkgs";

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
