{
  inputs,
  channels,
}: let
  importOverlay = path: import path {inherit inputs channels;};

  zen-browser = importOverlay ./zen-browser;
  unfree-pkgs = importOverlay ./unfree-pkgs;

  allOverlays = [
    zen-browser
    unfree-pkgs
  ];
in {
  default = final: prev: builtins.foldl' (acc: overlay: acc // (overlay final prev)) {} allOverlays;

  inherit
    zen-browser
    unfree-pkgs
    ;
}
