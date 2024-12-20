{ inputs, ... }:
_: prev: {
  zig = inputs.zig-overlay.packages.${prev.system}.master;
}
