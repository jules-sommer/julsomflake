{lib, ...}: let
  inherit (lib) enableShellIntegrations enabled';
in {
  local.home.programs.eza =
    enabled' {
      colors = "auto";
      git = true;
      icons = "auto";
    }
    // enableShellIntegrations ["bash" "fish" "zsh"] true
    // enableShellIntegrations ["ion" "nushell"] false;
}
