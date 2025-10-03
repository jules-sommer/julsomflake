let
  inherit (pkgs) callPackage;
  inherit (flake) inputs lib;

  helpers = inputs.helpers.lib;

  flake = builtins.getFlake (builtins.toString ./.);

  pkgs = import inputs.nixpkgs {
    config.allowUnfree = true;
    overlays = lib.attrValues flake.overlays;
  };
in
(
  flake
  // {
    inherit pkgs lib helpers;
    inherit (flake.inputs) nixpkgs;
    inherit (lib)
      elemAt
      map
      mapAttrs
      foldl'
      attrNames
      attrValues
      filterAttrs
      importJSON
      ;
    inherit (builtins) readDir readFile;
    configs = {
      estradiol = flake.nixosConfigurations.estradiol.config;
    };
  }
)
