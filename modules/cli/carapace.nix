{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) enabled' enableShellIntegrations;
in {
  environment.systemPackages = with pkgs; [carapace];
  local.home.programs.carapace = enabled' (enableShellIntegrations ["fish" "zsh" "bash"] true);
}
