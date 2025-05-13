{ inputs, ... }:
_: prev: {
  inherit (inputs.zls.packages.${prev.system}) zls;
}
