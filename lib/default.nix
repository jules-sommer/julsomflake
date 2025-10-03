{ inputs }:
let
  inherit (builtins) isFunction listToAttrs readDir;
  inherit (inputs.nixpkgs.lib)
    recursiveUpdate
    foldl'
    attrValues
    mapAttrs
    removeSuffix
    hasPrefix
    isAttrs
    filterAttrs
    hasSuffix
    ;
in
inputs.nixpkgs.lib.extend (
  _: prev:
  foldl' recursiveUpdate { } (
    [
      { __extended = true; }
    ]
    ++ (with inputs; [
      helpers
      { utils = utils.lib; }
      home-manager.lib
    ])
    ++ (
      readDir ./.
      |> filterAttrs (
        file: kind:
        kind == "regular" && hasSuffix "nix" file && file != "default.nix" && !hasPrefix "__" file
      )
      |> mapAttrs (
        file: _:
        let
          value = import ./${file} { inherit (inputs.nixpkgs) lib; };
          name = removeSuffix ".nix" file;
        in
        if isAttrs value then
          value
        else if isFunction value then
          listToAttrs [
            {
              inherit name;
              inherit value;
            }
          ]
        else
          { }
      )
      |> attrValues
    )
  )
)
