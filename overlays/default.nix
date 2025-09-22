{
  lib,
  inputs,
  ...
}: let
  inherit (lib) composeManyExtensions map foldlAttrs hasSuffix path all;
  inherit (builtins) readDir isFunction isList toString;

  files =
    foldlAttrs
    (acc: k: v:
      if v == "regular" && (hasSuffix ".nix" k) && (k != "default.nix")
      then acc ++ [(path.append ./. k)]
      else acc)
    []
    (readDir ./.);

  normalize = p: v:
    if isFunction v
    then [v]
    else if isList v
    then
      if all isFunction v
      then v
      else throw "overlay list in ${toString p} contains non-function elements"
    else throw "overlay ${toString p} must return an overlay function or a list of overlay functions";

  overlays =
    map
    (p: let
      v = import p {inherit inputs;};
    in
      normalize p v)
    files
    |> lib.flatten;
in
  overlays
