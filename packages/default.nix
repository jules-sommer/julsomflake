{
  self,
  inputs,
  pkgs,
  lib,
  npins,
  ...
}: let
  inherit (lib.customisation) makeScope;
  inherit (lib.filesystem) packagesFromDirectoryRecursive;

  inherit
    (lib)
    isDerivation
    concatStringsSep
    concatMapAttrs
    isAttrs
    foldl'
    recursiveUpdate
    ;

  inherit (lib) foldlAttrsRecursive;

  flattenPackages = separator: path: value:
    if isDerivation value
    then {
      ${concatStringsSep separator path} = value;
    }
    else if isAttrs value
    then concatMapAttrs (name: flattenPackages separator (path ++ [name])) value
    else {}; # Ignore the functions which makeScope returns

  inputsScope = makeScope pkgs.newScope (_: {
    inherit inputs pkgs getPinVersion fetchFromNpins npins;
    inherit (pkgs) fetchFromGitHub;
  });

  getPinVersion = pin:
    if pin ? version
    then pin.version
    else if pin ? revision
    then pin.revision
    else if pin ? hash && pin ? repository
    then "${pin.repository.owner}/${pin.repository.repo}/${pin.hash}"
    else null;

  fetchFromNpins = pin:
    pkgs.fetchFromGitHub {
      inherit (pin.repository) owner repo;
      rev = pin.revision;
      sha256 = pin.hash;
    };

  scopeFromDirectory = directory:
    packagesFromDirectoryRecursive {
      inherit directory;
      inherit (inputsScope) newScope callPackage;
    };

  defaultFlattenPackages = flattenPackages "_" [];
  scopeFromDirectoryFlatten = dir: dir |> scopeFromDirectory |> defaultFlattenPackages;
in
  foldlAttrsRecursive (map defaultFlattenPackages [
    {
      themes = scopeFromDirectoryFlatten ./themes;
    }
    (scopeFromDirectoryFlatten ./by-name)
  ])
