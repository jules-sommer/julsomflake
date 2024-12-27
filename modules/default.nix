{
  # Default module that can be used with any host, effectively shared modules.
  default = _: {
    imports = [
      ./system/default.nix
    ];

    home-manager = {
      sharedModules = [
        ./home/default.nix
      ];

      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };

  nixRegistryInputs = _: {
    imports = [
      ./system/nix/registry.nix
    ];
  };

  system = _: {
    imports = [
      ./system/default.nix
    ];
  };

  home = _: {
    home-manager = {
      sharedModules = [
        ./home/default.nix
      ];

      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };

  stylix = _: {
    imports = [
      ./system/stylix/default.nix
    ];
  };
}
