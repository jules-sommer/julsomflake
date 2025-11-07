{lib, ...}: let
  inherit (lib) typeOf replaceStrings stringLength concatMap concatStringsSep attrNames isString isList mapAttrsToList foldl';
  strings = import ./strings.nix {inherit lib;};
  inherit (strings) splitOnWhitespace;

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
in rec {
  inherit cmd cmdList;

  spawn = spawnWithOptions {};

  spawnWithoutShell = spawnWithOptions {use-shell = false;};

  # builds a command string using `cmd` to spawn the provided
  # command/binary, optionally passes the provided command through
  # a shell, i.e `fish -c`, for cmd substitution and such. The
  # option `use-shell` configures this behaviour.
  spawnWithOptions = {
    use-shell ? true,
    shell ? ["fish" "-c"],
    env ? {},
  }: command: let
    commandIsString = isString command;
    commandIsList = isList command;
    shellCmd =
      if use-shell
      then shell
      else [];

    envVars = env |> mapAttrsToList (k: v: ["${k}=${toString v}"]);
  in
    cmd (foldl' (acc: elem: acc ++ elem) [] [
      envVars
      shellCmd
      (
        if commandIsString
        then (splitOnWhitespace command)
        else if commandIsList
        then command
        else throw "`spawn` only accepts commands of type `string` or `list`, instead got: ${typeOf command}."
      )
    ]);

  riverSpawnDefault = riverSpawnWithOptions {};
  riverSpawnWithEnv = env: riverSpawnWithOptions {inherit env;};
  riverSpawnWithOptions = {
    prefix-riverctl ? false,
    env ? {},
  }: command: let
    commandIsString = isString command;
    commandIsList = isList command;
    envVars = env |> mapAttrsToList (k: v: ["${k}=${toString v}"]);
    prefix =
      if prefix-riverctl
      then ["riverctl" "spawn"]
      else ["spawn"];
  in
    cmd (foldl' (acc: elem: acc ++ elem) [] [
      prefix
      [
        "\""
        envVars
        (
          if commandIsString
          then (splitOnWhitespace command)
          else if commandIsList
          then command
          else throw "`spawn` only accepts commands of type `string` or `list`, instead got: ${typeOf command}."
        )
        "\""
      ]
    ]);
}
