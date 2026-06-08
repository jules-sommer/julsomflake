{
  pkgs,
  lib,
  ...
}: let
  inherit (lib) enabled';
in {
  local.kernel.xanmod = enabled' {
    zfs.enable = false;
  };
  boot = {
    kernelPackages = pkgs.linuxPackages_xanmod_latest;
    plymouth.enable = true;
  };
}
