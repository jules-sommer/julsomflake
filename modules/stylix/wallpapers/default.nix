{
  lib,
  helpers,
  ...
}: let
  hasSuffix = lib.hasSuffix or lib.strings.hasSuffix;
  files = builtins.attrNames (builtins.readDir ./.);
  images = builtins.filter (f: !(hasSuffix ".nix" f)) files;
  stripSuffix = n: let
    parts = lib.splitStringBy (prev: curr: curr == ".") false n;
  in
    if lib.length parts > 1
    then lib.concatStringsSep "." (lib.init parts)
    else n;
in
  lib.foldl' (acc: elem: acc // {${stripSuffix elem} = lib.path.append ./. elem;}) {} images
