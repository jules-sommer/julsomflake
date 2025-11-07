{ pkgs, lib, ... }:
{
  boot = {
    kernelPackages = pkgs.linuxPackages_xanmod_latest;
    plymouth.enable = true;
  };
}
