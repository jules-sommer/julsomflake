{
  pkgs,
  lib,
  helpers,
  ...
}: let
  inherit (lib) mapAttrs concatMapAttrs mapAttrs' nameValuePair;
  flattenWithSeparator = separator:
    concatMapAttrs
    (theme: pkgs:
      mapAttrs'
      (pkg: drv: nameValuePair "${theme}${separator}${pkg}" drv)
      pkgs);

  flatten = flattenWithSeparator "_";

  findModules = base_dir: (lib.mapAttrs (
      basename: kind: let
        path = lib.path.append base_dir basename;
        defaultNixExists = lib.pathExists (lib.path.append path "default.nix");
      in
        if defaultNixExists
        then import path {inherit (pkgs) fetchFromGitHub;}
        else findModules path
    )
    (lib.filterAttrs (_: kind: kind == "directory") (builtins.readDir base_dir)));
in
  flatten (findModules ./.)
