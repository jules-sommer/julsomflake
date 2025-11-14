let
  inherit (flake) inputs lib;
  inherit (builtins) currentSystem getFlake toString;
  inherit (lib) foldl' recursiveUpdate attrValues importJSON mapAttrs removeAttrs isAttrs attrNames hasAttr all;

  system = currentSystem;

  helpers = inputs.helpers.lib;

  flake = getFlake (toString ./.);

  npins = (importJSON ./npins/sources.json).pins;

  stable = inputs.nixpkgs-stable.legacyPackages.${system};
  unfree = inputs.unfree.legacyPackages.${system};

  packages = flake.outputs.packages.${system};

  pkgs = import inputs.nixpkgs {
    config.allowUnfree = true;
    overlays = attrValues flake.overlays;
  };

  validSystems = inputs.utils.lib.system;

  isSystemAttrs = attrs:
    isAttrs attrs
    && (let
      keys = attrNames attrs;
    in
      keys != [] && all (k: hasAttr k validSystems) keys);

  flattenSystemOutputs = attrs:
    if isSystemAttrs attrs
    then attrs.${system} or {}
    else if isAttrs attrs
    then mapAttrs (_: flattenSystemOutputs) attrs
    else attrs;

  flakeOutputs = flake.outputs |> flattenSystemOutputs;
  flakeNoOutputs = removeAttrs flake ["devShells" "lib" "nixosConfigurations" "overlays" "packages"];
in (
  foldl' recursiveUpdate {} [
    flakeOutputs
    flakeNoOutputs
    {
      inherit pkgs lib helpers npins;
      inherit (flake.inputs) nixpkgs;
      inherit stable unfree;
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
    {
      inherit packages;
    }
  ]
)
