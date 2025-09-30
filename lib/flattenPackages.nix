{ lib, ... }:
let
  inherit (lib)
    isDerivation
    concatStringsSep
    concatMapAttrs
    isAttrs
    ;
  go =
    separator: path: value:
    if isDerivation value then
      {
        ${concatStringsSep separator path} = value;
      }
    else if isAttrs value then
      concatMapAttrs (name: go separator (path ++ [ name ])) value
    else
      { }; # Ignore the functions which makeScope returns
in
go
