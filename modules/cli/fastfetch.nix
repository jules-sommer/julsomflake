{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) enabled';
in {
  environment.systemPackages = with pkgs; [fastfetch];
  local.home.programs.fastfetch =
    enabled' {
    };
}
