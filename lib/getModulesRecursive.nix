{lib, ...}: let
  inherit (lib) attrNames hasPrefix hasSuffix filterAttrs path concatMap any;
  inherit (builtins) readDir;

  listContainsEntry = list: depth: n: kind:
    list
    |> any (
      entry:
        entry.name
        == n
        && (!entry ? "kind" || entry.kind == kind)
        && (!entry ? "depth" || entry.depth == depth)
    );
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
    blacklist ? [
      {
        name = "stylix";
        kind = "directory";
      }
    ],
    whitelist ? [],
    exclude ? (
      depth: n: kind:
        if listContainsEntry whitelist depth n kind
        then false
        else
          # don't include the default.nix that is calling this function @ depth == 0
          (n == "default.nix" && kind == "regular" && depth == 0)
          # underscore prefix excludes files
          || hasPrefix "_" n
          || hasPrefix "__" n
          # dont include hidden files
          || hasPrefix "." n
          # ignore non .nix files
          || (kind == "regular" && !(hasSuffix ".nix" n))
          || listContainsEntry blacklist depth n kind
    ),
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
