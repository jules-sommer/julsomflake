{
  helpers,
  lib,
  ...
}: let
  inherit
    (helpers)
    mkEnableOpt
    ;
  inherit (lib) enableShellIntegrations;
in {
  imports = [
    ./fish
    ./zsh
    ./aliases.nix
  ];

  options.local.shells = {
    fish = mkEnableOpt "Enable Fish shell.";
    zsh = mkEnableOpt "Enable Zsh shell.";
  };

  config.local.home.home.shell =
    {
      enableShellIntegration = true;
    }
    // enableShellIntegrations ["fish" "zsh" "bash"] true;
}
