{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) enabled' enableShellIntegrations;
in {
  environment.systemPackages = with pkgs; [nix-index];
  local.home.programs.nix-index = enabled' (enableShellIntegrations ["fish" "zsh" "bash"] true);
}
