{ lib }:
extensions:
let
  inherit (lib) extend foldl' recursiveUpdate;
in
extend (
  _: prev:
  foldl' recursiveUpdate { } (
    [
      { __extended = true; }
    ]
    ++ extensions
  )
)
