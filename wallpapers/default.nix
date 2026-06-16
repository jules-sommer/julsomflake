{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) hasSuffix attrNames filter splitStringBy concatStringsSep length init path listToAttrs nameValuePair;
  inherit (builtins) readDir;

  images =
    readDir ./.
    |> attrNames
    |> filter
    (f: !(hasSuffix ".nix" f));

  stripSuffix = n: let
    parts = splitStringBy (prev: curr: curr == ".") false n;
  in
    if length parts > 1
    then concatStringsSep "." (init parts)
    else n;

  toPath = f: path.append ./. f;
in {
  # an attrset of wallpaper names and paths.
  named =
    images
    |> map (str: nameValuePair (stripSuffix str) (toPath str))
    |> listToAttrs;

  # all wallpapers linked into a nix store drv path.
  dir =
    images
    |> map (f: {
      name = f;
      path = toPath f;
    })
    |> pkgs.linkFarm "julsomflake-wallpapers";
}
