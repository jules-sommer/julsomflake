{inputs}: let
  inherit (builtins) isFunction;
  getModulesRecursive = import ./getModulesRecursive.nix {inherit (inputs.nixpkgs) lib;};
  helpers = inputs.helpers.lib;

  inherit
    (inputs.nixpkgs.lib)
    recursiveUpdate
    concatLists
    foldl'
    ;
in
  inputs.nixpkgs.lib.extend (
    _: prev:
      foldl' recursiveUpdate {} (
        concatLists [
          [{__extended = true;}]

          (with inputs; [
            {helpers = helpers.lib;}
            {utils = utils.lib;}
            home-manager.lib
            {niri = niri-flake.lib;}
          ])

          (
            getModulesRecursive ./. {
              returnNameValuePairs = true;
              importNixFiles = true;
              importFunction = depth: name: kind: path:
                import path {
                  inherit (inputs.nixpkgs) lib;
                  inherit helpers;
                };
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
        ]
      )
  )
