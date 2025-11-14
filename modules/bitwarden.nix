{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkEnableOpt enabled' mkIf;
  cfg = config.local.bitwarden;
in {
  options.local.bitwarden =
    mkEnableOpt "Enable Bitwarden with desktop, CLI, and rofi integration.";

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [bitwarden-cli];
    local.home = {
      programs.rbw = enabled' {
        settings = {
          email = "rcsrc@pm.me";
        };
      };
      home.packages = with pkgs; [
        bitwarden-desktop
        rofi-rbw-wayland
      ];
    };
  };
}
