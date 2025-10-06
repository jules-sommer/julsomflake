{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) enabled';
in {
  environment.systemPackages = with pkgs; [nix-init];
  local.home.programs.nix-init = enabled' {
    settings = {};
  };
}
