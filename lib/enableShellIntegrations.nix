{lib, ...}: let
  toTitleCase = import ./toTitleCase.nix {inherit lib;};
in
  shells': value': let
    inherit (lib) isList isString genAttrs isBool;
    validShells = ["fish" "zsh" "nushell" "ion" "bash"];
    shells =
      if isList shells'
      then shells'
      else if isString shells'
      then [shells']
      else [];

    makeEnableString = shell: "enable${toTitleCase shell}Integration";
    shellEnableStrings = shells |> map makeEnableString;
    value =
      if isBool value'
      then value'
      else throw "Value must be a boolean.";
  in
    genAttrs shellEnableStrings (_: value)
