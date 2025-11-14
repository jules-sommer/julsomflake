{lib, ...}: let
  inherit (lib) pathExists;
in
  pkg: binaryName: let
    binPath = "${pkg}/bin";
    fullPath = "${binPath}/${binaryName}";
  in
    if !pathExists binPath
    then throw "Package '${pkg.name or "unknown"}' has no /bin directory"
    else if !pathExists fullPath
    then throw "Binary '${binaryName}' not found in package '${pkg.name or "unknown"}'"
    else fullPath
