{lib}: pkg: let
  inherit (lib) filterAttrs filter findFirst elem head length concatStringsSep pathExists attrNames;
  inherit (builtins) readDir;
  binPath = "${pkg}/bin";

  mainProgram = pkg.meta.mainProgram or null;

  getBinaryFromDir = let
    binaries =
      readDir "${pkg}/bin"
      |> filterAttrs (name: type: type == "regular" || type == "symlink")
      |> attrNames;

    possibleNames = filter (x: x != null) [
      (pkg.pname or null)
      (pkg.name or null)
      (pkg.meta.name or null)
    ];

    matchedBinary =
      findFirst
      (bin: elem bin possibleNames)
      null
      binaries;
  in
    if binaries == []
    then throw "Package '${pkg.name or "unknown"}' has no binaries in ${binPath}"
    else if length binaries == 1
    then head binaries
    else if matchedBinary != null
    then matchedBinary
    else throw "Package '${pkg.name or "unknown"}' has multiple binaries (${concatStringsSep ", " binaries}) but none match package metadata";
in
  if mainProgram != null
  then "${pkg}/bin/${mainProgram}"
  else if pathExists binPath
  then "${pkg}/bin/${getBinaryFromDir}"
  else throw "Package '${pkg.name or "unknown"}' has no /bin directory"
