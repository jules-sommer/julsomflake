{lib, ...}: let
  inherit (lib) filter splitString replaceStrings;
in {
  splitOnWhitespace = str:
    replaceStrings ["\n" "\r" "\t"] [" " " " " "] str |> splitString " " |> filter (x: x != "");
}
