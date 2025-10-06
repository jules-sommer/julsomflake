{
  lib,
  src,
  ...
}: let
  inherit (lib) enabled' cmd;
  inherit (builtins) toString;
in {
  local.home.programs.nh = enabled' {
    flake = toString src;
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = cmd {
        keep = 5;
        keep-since = "3d";
      };
    };
  };
}
