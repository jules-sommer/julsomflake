let
  inherit (pkgs) callPackage;
  inherit (flake) inputs;

  lib = pkgs.lib.extend (
    _: prev:
      prev
      // helpers
      // {utils = flake.inputs.utils.lib;}
      // {hm = flake.inputs.home-manager.lib;}
  );

  helpers = inputs.helpers.lib;

  flake = builtins.getFlake (builtins.toString ./.);

  pkgs = import inputs.nixpkgs {
    config.allowUnfree = true;
    overlays = with inputs; [
      ghostty.overlays.default
    ];
  };
in
  {
    inherit pkgs lib helpers;
    inherit (flake.inputs) nixpkgs;
    configs = {
      estradiol = flake.nixosConfigurations.estradiol.config;
    };
  }
  // flake
