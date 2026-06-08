{
  lib,
  src,
  ...
}: let
  inherit (lib) enabled';
  inherit (builtins) toString;
in {
  local.home.programs.nh = enabled' {
    flake = toString src;
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep 5 --keep-since 3d";
    };
  };
}
