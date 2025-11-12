let
  inherit (pkgs) callPackage;
  inherit (flake) inputs lib;
  inherit (lib) foldl' recursiveUpdate attrValues importJSON mapAttrs;

  helpers = inputs.helpers.lib;

  flake = builtins.getFlake (builtins.toString ./.);

  npins = (importJSON ./npins/sources.json).pins;

  pkgs = import inputs.nixpkgs {
    config.allowUnfree = true;
    overlays = attrValues flake.overlays;
  };
in (
  foldl' recursiveUpdate {} [
    flake
    {
      inherit pkgs lib helpers npins;
      inherit (flake.inputs) nixpkgs;
      inherit
        (lib)
        elemAt
        map
        mapAttrs
        foldl'
        attrNames
        attrValues
        filterAttrs
        importJSON
        recurisveUpdate
        foldlAttrs
        ;
      inherit (builtins) readDir readFile;
    }
    (
      flake.nixosConfigurations
      |> mapAttrs (n: v: v.config)
    )
  ]
)
