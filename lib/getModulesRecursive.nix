{lib, ...}: let
  inherit (lib) attrNames hasPrefix hasSuffix filterAttrs path concatMap;
  inherit (builtins) readDir;
in
  dir: {
    # The maximum depth this function will recurse finding modules to import.
    # This is set to one as it gives good generalised behaviour when used for
    # importing modules. It will include all importable files in the top-level
    # directory, following it's exclusion predicate, as well as any importable
    # files in any top-level directories it discovered.
    max-depth ? 1,
    # the default exclusion predicate fn works in most cases and excludes the following:
    #   ->  Any default.nix files on the top-level dir (depth == 0) where the fn is called from.
    #       This has the effect of excluding the file that it is likely being called from (default.nix).
    #       Including this file causes circular imports / infinite recursion in the case where
    #       the top-level default.nix file is already imported from elsewhere.
    #   ->  Any file/dir prefixed with one or two underscores AND hidden files/dirs ("." prefixed).
    exclude ? (depth: n: v: (n == "default.nix" && v == "regular" && depth == 0) || hasPrefix "_" n || hasPrefix "__" n || hasPrefix "." n),
  }: let
    recurse = dir: depth: let
      entries = readDir dir |> filterAttrs (n: v: !(exclude depth n v));
      names = attrNames entries;

      collect =
        names
        |> concatMap (
          name: let
            tp = entries.${name};
            pathValue = path.append dir name;
          in
            if tp == "directory" && depth < max-depth
            then recurse pathValue (depth + 1)
            else if tp == "regular"
            then [pathValue]
            else []
        );
    in
      collect;
  in
    recurse dir 0
