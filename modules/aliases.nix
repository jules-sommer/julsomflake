{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOptWithExample mkOption types any all isList isString hasAttr setAttrByPath foldl' getAttrFromPath;
  inherit (types) listOf attrs;
in {
  imports = [
    (
      lib.mkAliasOptionModule
      ["homeDirectory"]
      ["home-manager" "users" "jules" "home" "homeDirectory"]
    )
  ];

  options.local.config_aliases = mkOption {
    type = listOf attrs;
    default = [];
    description = ''
      List of attribute-sets that map a source config path to a destination config path.
      Each element must be an attribute-set with keys "source" and "dest", both of which
      are lists of strings representing path components.
    '';
    example = [
      {
        source = ["homeDirectory"];
        dest = ["home-manager" "users" "jules" "home" "homeDirectory"];
      }
    ];
    validate = v: let
      bad = any (e: !(hasAttr "source" e && hasAttr "dest" e && isList e.source && isList e.dest && all isString e.source && all isString e.dest)) v;
    in
      if bad
      then throw "Each element of config.local.config_aliases must be an attribute-set with 'source' and 'dest' lists of strings."
      else null;
  };

  config =
    foldl' (
      acc: alias:
        setAttrByPath alias.source (getAttrFromPath alias.dest config) acc
    )
    config (config.local.config_aliases or []);
}
