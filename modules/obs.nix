{
  pkgs,
  lib,
  ...
}: let
  inherit (lib) enabled';
in {
  local.home.programs.obs-studio = enabled' {
    plugins = with pkgs.obs-studio-plugins; [wlrobs];
  };
}
