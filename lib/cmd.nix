{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) typeOf concatMap concatStringsSep mapAttrsToList;

  flatten = x: let
    t = typeOf x;
  in
    if t == "list"
    then concatMap flatten x
    else if t == "null"
    then []
    else [(toString x)];
in rec {
  /**
  Flattens a nested list/string/null structure into a flat list of string tokens.
  Nulls are dropped; all other values are coerced to strings.
  */
  cmdList = parts: flatten parts;

  /**
  Like `cmdList` but joins the tokens into a single space-separated command string.
  */
  cmdString = parts: concatStringsSep " " (cmdList parts);
  cmd = cmdString;

  /**
  Creates a curried command builder with pre-applied fixed tokens.
  `fixed` is a list of the binary and any arguments that are always present.
  The returned function accepts a list of additional arguments and returns a string.

  Example:
    sudoLs = mkCmd [(getExe pkgs.sudo) "ls"];
    sudoLs ["-la" "/etc"]  =>  "sudo ls -la /etc"
  */
  mkCmd = fixed: args: cmdString (fixed ++ args);

  mkShellCmd = {
    package ? pkgs.bash,
    args ? ["-c"],
  }: cmd:
    mkCmd ([(lib.getExe package)] ++ args) cmd;

  /**
  Like `mkCmd` but returns a token list instead of a string.
  Use for compositors that accept commands as lists (e.g. niri `action.spawn`).
  */
  mkListCmd = fixed: args: cmdList (fixed ++ args);

  /**
  Produces a quoted spawn command for compositors that require it (e.g. river).
  `prefix` controls the leading tokens; `env` injects `KEY=value` pairs before the command.

  Default:            spawn "bin arg..."
  prefix-riverctl:    riverctl spawn "bin arg..."
  with env:           spawn "KEY=val bin arg..."
  */
  quotedSpawn = {
    env ? {},
    prefix ? ["spawn"],
  }: parts: let
    envTokens = env |> mapAttrsToList (k: v: "${k}=${toString v}");
    inner = cmdString (envTokens ++ flatten parts);
  in
    cmdString (prefix ++ ["\"${inner}\""]);
}
