{lib, ...}: let
  inherit (builtins) filter split substring concatStringsSep stringLength;
  inherit (lib) toUpper toLower;
in
  s: let
    words = filter (w: w != "") (split " " s);
    capitalize = w:
      if w == ""
      then ""
      else toUpper (substring 0 1 (toLower w)) + substring 1 (stringLength w - 1) (toLower w);
    result = concatStringsSep " " (map capitalize words);
  in
    if result == s
    then s
    else result
