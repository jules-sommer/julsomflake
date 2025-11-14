{
  pkgs,
  lib,
  ...
}: let
  inherit
    (lib)
    mkEnableOpt
    enableShellIntegrations
    ;
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
  config = {
    environment.systemPackages = with pkgs; [
      killall
    ];
    local.home.home.shell =
      {
        enableShellIntegration = true;
      }
      // enableShellIntegrations ["fish" "zsh" "bash"] true;
  };
}
