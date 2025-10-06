{lib, ...}: let
  inherit (lib) typeOf replaceStrings stringLength concatMap concatStringsSep attrNames;

  dashify = k: replaceStrings ["_"] ["-"] k;

  flagTokens = k: v: let
    name = dashify k;
    flag =
      (
        if stringLength name == 1
        then "-"
        else "--"
      )
      + name;
    vt = typeOf v;
  in
    if vt == "null" || (vt == "bool" && v == false)
    then []
    else if vt == "bool" && v == true
    then [flag]
    else if vt == "list"
    then
      concatMap (
        vv: let
          vvt = typeOf vv;
        in
          if vvt == "null" || (vvt == "bool" && vv == false)
          then []
          else if vvt == "bool" && vv == true
          then [flag]
          else [flag] ++ [(toString vv)]
      )
      v
    else [flag] ++ [(toString v)];

  flatten = x: let
    t = typeOf x;
  in
    if t == "list"
    then concatMap flatten x
    else if t == "set"
    then concatMap (k: flagTokens k x.${k}) (attrNames x)
    else if t == "null"
    then []
    else [(toString x)];

  cmdList = parts: flatten parts;
  cmd = parts: concatStringsSep " " (cmdList parts);
in {
  inherit cmd cmdList;
}
