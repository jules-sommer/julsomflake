let
  inherit (pkgs) callPackage;
  inherit (flake) inputs;

  lib = flake.lib.extendLibMany flake.inputs.nixpkgs.lib [
    helpers
    {utils = flake.inputs.utils.lib;}
    {hm = flake.inputs.home-manager.lib;}
    flake.lib
  ];

  helpers = inputs.helpers.lib;

  flake = builtins.getFlake (builtins.toString ./.);

  pkgs = import inputs.nixpkgs {
    config.allowUnfree = true;
    overlays = lib.attrValues flake.overlays;
  };
in
  flake
  // {
    inherit pkgs lib helpers;
    inherit (flake.inputs) nixpkgs;
    configs = {
      estradiol = flake.nixosConfigurations.estradiol.config;
    };
  }
