{inputs}: let
  inherit (builtins) isFunction listToAttrs readDir;
  getModulesRecursive = import ./getModulesRecursive.nix {inherit (inputs.nixpkgs) lib;};

  inherit
    (inputs.nixpkgs.lib)
    recursiveUpdate
    concatLists
    foldl'
    attrValues
    mapAttrs
    removeSuffix
    hasPrefix
    isAttrs
    filterAttrs
    hasSuffix
    ;

  isNixFile = filename: kind:
    hasSuffix "nix" filename
    && kind == "regular";

  libInclusionPredicate = filename: kind:
    isNixFile filename kind
    && filename != "default.nix"
    && !(filename |> hasPrefix "__");

  importLibModule = path: import path {inherit (inputs.nixpkgs) lib;};
in
  inputs.nixpkgs.lib.extend (
    _: prev:
      foldl' recursiveUpdate {} (
        concatLists [
          [{__extended = true;}]

          (with inputs; [
            helpers
            {utils = utils.lib;}
            home-manager.lib
          ])

          (
            getModulesRecursive ./. {
              returnNameValuePairs = true;
              importNixFiles = true;
              importFunction = depth: name: kind: path: import path {inherit (inputs.nixpkgs) lib;};
            }
            |> map (
              {
                name,
                value,
                ...
              }:
                if isFunction value
                then {${name} = value;}
                else value
            )
          )

          # (
          #   readDir ./.
          #   |> filterAttrs (
          #     file: kind:
          #       kind == "regular" && hasSuffix "nix" file && file != "default.nix" && !hasPrefix "__" file
          #   )
          #   |> mapAttrs (
          #     file: _: {
          #       name = removeSuffix ".nix" file;
          #       value = import ./${file} {inherit (inputs.nixpkgs) lib;};
          #     }
          #   )
          #   |> mapAttrs (
          #     _: {
          #       name,
          #       value,
          #     }:
          #       if isFunction value
          #       then {${name} = value;}
          #       else value
          #   )
          #   |> attrValues
          # )

          # (
          #   readDir ./.
          #   |> filterAttrs (
          #     file: kind:
          #       kind == "regular" && hasSuffix "nix" file && file != "default.nix" && !hasPrefix "__" file
          #   )
          #   |> mapAttrs (
          #     file: _: let
          #       value = import ./${file} {inherit (inputs.nixpkgs) lib;};
          #       name = removeSuffix ".nix" file;
          #     in
          #       if isAttrs value
          #       then value
          #       else if isFunction value
          #       then
          #         listToAttrs [
          #           {
          #             inherit name;
          #             inherit value;
          #           }
          #         ]
          #       else {}
          #   )
          #   |> attrValues
          # )
        ]
      )
  )
