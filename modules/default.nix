{ config, lib, ... }:
{
  imports = [
    ./system/default.nix
  ];

  home-manager = {
    sharedModules = [
      ./home/default.nix
    ];
  };
}
